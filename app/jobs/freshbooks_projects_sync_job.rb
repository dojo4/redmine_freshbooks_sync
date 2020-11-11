class FreshbooksProjectsSyncJob < FreshbooksSyncJob
  queue_as :freshbooks

  def perform(*args)
    client = ::Freshbooks::Client.default
    fb_projects = client.active_projects
    fb_projects.each do |fb_project|
      begin
        existing = ::FreshbooksProject.find_or_initialize_by(upstream_id: fb_project['id'])
        existing.update!(
          upstream_raw: fb_project,
          sync_state: 'synced',
          synced_at: Time.now.utc
        )
      rescue => e
        Rails.logger.error "Error sycning fresbhooks project : #{e} :  #{fb_project.to_json}"
      end
    end
  end
end
