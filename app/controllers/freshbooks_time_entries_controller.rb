require 'set'
class FreshbooksTimeEntriesController < FreshbooksBaseController

  helper :queries
  include ::QueriesHelper

  def index
    retrieve_time_entry_query # this will set @query
    scope = time_entry_scope

    if @query.queried_class == ::TimeEntryQuery then
      scope.preload(:issue => [:project, :tracker, :status, :assigned_to, :priority])
        .preload(:project, :user)
    end

    @time_entry_count = scope.count
    @time_entry_pages = Paginator.new @time_entry_count, per_page_option, params['page']
    @time_entries = scope.offset(@time_entry_pages.offset).limit(@time_entry_pages.per_page).to_a
    if @query.queried_class == ::TimeEntryQuery then
      @time_entries.each { |t| t.ensure_freshbooks_time_entry }
    end
    @last_synced_at = ::FreshbooksTimeEntry.maximum(:synced_at)
  end

  def push_all
    ::FreshbooksTimeEntriesPushJob.perform_later
    flash[:notice] = t('.time_entry_push_is_in_progress')
    redirect_to freshbooks_time_entries_path
  end

  def push_one
    entry = ::TimeEntry.find_by(id: params[:id])
    ::FreshbooksTimeEntryPushJob.perform_later(entry.id)
    flash[:notice] = t('.time_entry_push_is_in_progress', id: entry.id)
    redirect_to freshbooks_time_entries_path
  end

  def delete_one
    entry = ::FreshbooksTimeEntry.find_by(id: params[:id])
    ::FreshbooksTimeEntryDeleteJob.perform_later(entry.id)
    flash[:notice] = t('.time_entry_delete_is_in_progress', id: entry.id)
    redirect_to freshbooks_time_entries_path
  end

  def time_entry_scope(options={})
    @query.results_scope(options)
  end

  def retrieve_time_entry_query
    sync_state = Set.new(params.dig('v', 'sync_state'))
    Rails.logger.info "Sync State: #{sync_state.to_a}"
    if sync_state.intersect?(Set.new(::FreshbooksTimeEntry::REMOVED_STATES)) then
      Rails.logger.info("Picking Freshbooks Remvoed Time Entry")
      retrieve_query(::FreshbooksRemovedTimeEntryQuery, false, :defaults => @default_columns_names)
    else
      retrieve_query(::FreshbooksTimeEntryQuery, false, :defaults => @default_columns_names)
    end
  end
end
