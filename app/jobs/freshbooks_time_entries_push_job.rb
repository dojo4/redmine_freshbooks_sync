class FreshbooksTimeEntriesPushJob < FreshbooksSyncJob
  queue_as :freshbooks

  def perform(*args)
    ::TimeEntry.for_freshbooks.each do |time_entry|
      if time_entry.needs_freshbooks_push? then
        Rails.logger.info "Pushing time entry #{time_entry.id} #{time_entry.freshbooks_time_entry.sync_state}"
        FreshbooksTimeEntryPushJob.new.push_time_entry(time_entry)
      end
    end

    ::FreshbooksTimeEntry.pending_delete.each do |freshbooks_time_entry|
      Rails.logger.info "Deleging freshbooks time entry #{freshbooks_time_entry.id} #{freshbooks_time_entry.sync_state}"
      FreshbooksTimeEntryDeleteJob.new.delete_freshbooks_time_entry(freshbooks_time_entry)
    end
  end
end
