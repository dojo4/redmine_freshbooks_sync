require 'stringio'
class FreshbooksTimeEntryPushJob < FreshbooksSyncJob
  queue_as :freshbooks

  def perform(time_entry)
    push_time_entry(time_entry)
  end

  def push_time_entry(time_entry)
    client = ::Freshbooks::Client.default
    project_id = time_entry.project.freshbooks_upstream_id
    started_at = time_entry.spent_on.to_time.utc
    duration   = ::ActiveSupport::Duration.hours(time_entry.hours).to_i
    note_io    = StringIO.new

    note_io.puts "Time Entry for #{time_entry.user.name}"
    note_io.puts " * #{Rails.application.routes.url_helpers.edit_time_entry_url(time_entry, host: Setting[:host_name])}"

    if time_entry.issue then
      note_io.puts
      note_io.puts "Issue ##{time_entry.issue.id} - #{time_entry.issue.subject}"
      note_io.puts " * #{Rails.application.routes.url_helpers.issue_url(time_entry.issue, host: Setting[:host_name])}"
    end

    if time_entry.comments.present? then
      note_io.puts
      note_io.puts "Comments: #{time_entry.comments}"
    end

    time_entry.ensure_freshbooks_time_entry
    result = nil
    note = note_io.string

    if time_entry_id = time_entry.freshbooks_time_entry.upstream_id then
      result = client.update_time_entry(time_entry_id: time_entry_id, project_id: project_id,
                                        started_at: started_at, duration: duration, note: note)
    else
      result = client.create_time_entry(project_id: project_id, started_at: started_at, duration: duration, note: note)
    end

    freshbooks_time_entry = time_entry.freshbooks_time_entry
    upstream_data = result['time_entry']
    freshbooks_time_entry.update(upstream_id: upstream_data['id'],
                                 upstream_raw: upstream_data,
                                 sync_state: ::FreshbooksTimeEntry::PUSHED,
                                 synced_at: Time.now.utc)
  end
end
