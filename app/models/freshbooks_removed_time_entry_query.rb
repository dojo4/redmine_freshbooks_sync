# frozen_string_literal: true

# Based off of TimeEntryQuery from Redmine itself
#
class FreshbooksRemovedTimeEntryQuery < ::Query
  self.queried_class = ::FreshbooksTimeEntry
  self.view_permission = :view_time_entries

  self.available_columns = [
  ]

  def initialize(attributes=nil, *args)
    super attributes
    self.filters ||= { 'synced_at' => {:operator => "*", :values => []} }
  end

  def initialize_available_filters
    add_available_filter "synced_at", :type => :date_past
    add_available_filter(
      "sync_state",
      :type => :list,
      :values => lambda { ::FreshbooksTimeEntry::STATES }
    )
    # add_available_filter(
    #   "project_id",
    #   :type => :list, :values => lambda { project_values }
    # ) if project.nil?

    # if project && !project.leaf?
    #   add_available_filter(
    #     "subproject_id",
    #     :type => :list_subprojects,
    #     :values => lambda { subproject_values })
    # end
  end

  def available_columns
    return @available_columns if @available_columns
    @available_columns = []
  end

  def default_columns_names
    @default_columns_names ||= %w[ id sync_state synced_at ]
  end

  def default_sort_criteria
    [['synced_at', 'desc']]
  end

  def base_scope
    FreshbooksTimeEntry.where(statement)
  end

  def results_scope(options={})
    order_option = [group_by_sort_order, (options[:order] || sort_clause)].flatten.reject(&:blank?)
    base_scope.
      order(synced_at: :desc).
      joins(joins_for_order_statement(order_option.join(',')))
  end

  # Accepts :from/:to params as shortcut filters
  def build_from_params(params, defaults={})
    super
    if params[:from].present? && params[:to].present?
      add_filter('synced_at', '><', [params[:from], params[:to]])
    elsif params[:from].present?
      add_filter('synced_at', '>=', [params[:from]])
    elsif params[:to].present?
      add_filter('synced_at', '<=', [params[:to]])
    end
    self
  end

  def joins_for_order_statement(order_options)
    joins = [super]
    joins.compact!
    joins.any? ? joins.join(' ') : nil
  end
end
