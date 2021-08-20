require 'stringio'
class FreshbooksTimeEntryDeleteJob < FreshbooksSyncJob
  queue_as :freshbooks

  def perform(freshbooks_time_entry)
    delete_freshbooks_time_entry(freshbooks_time_entry)
  end

  def delete_freshbooks_time_entry(freshbooks_time_entry)
    return unless freshbooks_time_entry.present?
    if !freshbooks_time_entry.pending_delete? then
      Rails.logger.error "Unable to delete Facebook time entry #{freshbooks_time_entry.id} is in state #{freshbooks_time_entry.sync_state} - not 'pending_delete'"
      return
    end

    client = ::Freshbooks::Client.default

    if time_entry_id = freshbooks_time_entry.upstream_id then
      result = client.delete_time_entry(time_entry_id: time_entry_id)
      freshbooks_time_entry.update(sync_state: ::FreshbooksTimeEntry::DELETED,
                                   synced_at: Time.now.utc)
    else
      Rails.logger.error "Facebook time entry #{freshbooks_time_entry.id} does not have an usptream id"
    end
  end
end

