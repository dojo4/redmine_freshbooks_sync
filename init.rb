
Rails.logger.info 'Starting FreshBooks Sync for Redmine'

require_dependency 'hooks/view_layouts_base_html_head_hook'
require_dependency 'hooks/view_projects_show_left_hook'
require_dependency 'freshbooks'
require_dependency 'project_patch'
require_dependency 'time_entry_patch'

require 'byebug'

VERSION = "0.5.0"

Redmine::Plugin.register :redmine_freshbooks_sync do
  name 'FreshBooks Sync'
  author 'Jeremy Hinegardner'
  description 'This is a Redmine // FreshBooks Synchronization tool'
  version VERSION
  url 'https://github.com/dojo4/redmine_freshbooks_sync'
  author_url 'https://github.com/copiousfreetime'

  settings :default => {
    'client_id'=> nil,
    'client_secret' => nil,
    'api_endpoint' => ::Freshbooks.default_api_endpoint,
    'auth_endpoint' => ::Freshbooks.default_auth_endpoint,
    'earliest_time_entry_date' => ::Freshbooks.default_earliest_time_entry_date,
  }, :partial => 'settings/freshbooks'

  menu :admin_menu, :freshbooks, { controller: 'freshbooks', action: 'show' }, caption: 'FreshBooks'
end
