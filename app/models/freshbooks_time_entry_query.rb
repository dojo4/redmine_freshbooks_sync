# frozen_string_literal: true

# Based off of TimeEntryQuery from Redmine itself
#
class FreshbooksTimeEntryQuery < ::Query
  self.queried_class = ::TimeEntry
  self.view_permission = :view_time_entries

  self.available_columns = [
  ]

  def initialize(attributes=nil, *args)
    super attributes
    self.filters ||= { 'spent_on' => {:operator => "*", :values => []} }
  end

  def initialize_available_filters
    add_available_filter "spent_on", :type => :date_past
    add_available_filter(
      "sync_state",
      :type => :list,
      :values => lambda { ::FreshbooksTimeEntry::STATES }
    )
    add_available_filter(
      "project_id",
      :type => :list, :values => lambda { project_values }
    ) if project.nil?

    if project && !project.leaf?
      add_available_filter(
        "subproject_id",
        :type => :list_subprojects,
        :values => lambda { subproject_values })
    end

    add_available_filter("issue_id", :type => :tree, :label => :label_issue)
    add_available_filter(
      "user_id",
      :type => :list_optional, :values => lambda { author_values }
    )
    add_available_filter "comments", :type => :text
    add_available_filter "hours", :type => :float
  end

  def available_columns
    return @available_columns if @available_columns
    @available_columns = []
  end

  def default_columns_names
    @default_columns_names ||= begin
      default_columns = Setting.time_entry_list_defaults.symbolize_keys[:column_names].map(&:to_sym)
      project.present? ? default_columns : [:project] | default_columns
    end
  end

  def default_totalable_names
    Setting.time_entry_list_defaults.symbolize_keys[:totalable_names].map(&:to_sym)
  end

  def default_sort_criteria
    [['spent_on', 'desc']]
  end

  # If a filter against a single issue is set, returns its id, otherwise nil.
  def filtered_issue_id
    if value_for('issue_id').to_s =~ /\A(\d+)\z/
      $1
    end
  end

  def base_scope
    TimeEntry.visible.
      for_freshbooks.
      references(:project, :user, :freshbooks_time_entry).
      left_join_issue.
      where(statement)
  end

  def results_scope(options={})
    order_option = [group_by_sort_order, (options[:order] || sort_clause)].flatten.reject(&:blank?)

    order_option << "#{TimeEntry.table_name}.id ASC"
    base_scope.
      order(order_option).
      joins(joins_for_order_statement(order_option.join(',')))
  end

  # Returns sum of all the spent hours
  def total_for_hours(scope)
    map_total(scope.sum(:hours)) {|t| t.to_f.round(2)}
  end

  def sql_for_issue_id_field(field, operator, value)
    case operator
    when "="
      "#{TimeEntry.table_name}.issue_id = #{value.first.to_i}"
    when "~"
      issue = Issue.where(:id => value.first.to_i).first
      if issue && (issue_ids = issue.self_and_descendants.pluck(:id)).any?
        "#{TimeEntry.table_name}.issue_id IN (#{issue_ids.join(',')})"
      else
        "1=0"
      end
    when "!*"
      "#{TimeEntry.table_name}.issue_id IS NULL"
    when "*"
      "#{TimeEntry.table_name}.issue_id IS NOT NULL"
    end
  end

  def sql_for_sync_state_field(field, operator, value)
    sql_op = nil
    if operator == "=" then
      sql_op = "IN"
    elsif operator == "!" then
      sql_op = "NOT IN"
    else
      return ""
    end

    sql = "#{::FreshbooksTimeEntry.table_name}.sync_state #{sql_op} (?)"
    ::FreshbooksTimeEntry.sanitize_sql([sql, value])
  end

  # Accepts :from/:to params as shortcut filters
  def build_from_params(params, defaults={})
    super
    if params[:from].present? && params[:to].present?
      add_filter('spent_on', '><', [params[:from], params[:to]])
    elsif params[:from].present?
      add_filter('spent_on', '>=', [params[:from]])
    elsif params[:to].present?
      add_filter('spent_on', '<=', [params[:to]])
    end
    self
  end

  def joins_for_order_statement(order_options)
    joins = [super]
    joins.compact!
    joins.any? ? joins.join(' ') : nil
  end
end
