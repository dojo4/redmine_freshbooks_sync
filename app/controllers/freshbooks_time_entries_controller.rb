class FreshbooksTimeEntriesController < FreshbooksBaseController
  def index
    scope = ::TimeEntry.for_freshbooks
    @time_entries = scope.order(spent_on: :desc).to_a
    @time_entries.each { |t| t.ensure_freshbooks_time_entry }
    @last_synced_at = ::FreshbooksTimeEntry.maximum(:synced_at)
  end

  def push_all
    ::FreshbooksTimeEntriesPushJob.perform_later
    flash[:notice] = t('.time_entry_push_is_in_progress')
    redirect_to freshbooks_time_entries_path
  end

  def push_one
    entry = TimeEntry.find_by(id: params[:id])
    ::FreshbooksTimeEntryPushJob.perform_later(entry)
    flash[:notice] = t('.time_entry_push_is_in_progress', id: entry.id)
    redirect_to freshbooks_time_entries_path
  end
end
