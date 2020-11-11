class FreshbooksTimeEntriesPushJob < FreshbooksSyncJob
  queue_as :freshbooks

  def perform(*args)
    ::TimeEntry.for_freshbooks.each do |time_entry|
      FreshbooksTimeEntryPushJob.new.push_time_entry(time_entry)
    end
  end
end
