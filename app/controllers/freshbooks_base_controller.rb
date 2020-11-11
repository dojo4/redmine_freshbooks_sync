class FreshbooksBaseController < ApplicationController
  before_action :load_settings
  before_action :init_freshbooks_client

  def load_settings
    @settings = Setting['plugin_redmine_freshbooks_sync']
  end

  def init_freshbooks_client
    @freshbooks_client = ::Freshbooks::Client.new(client_id: @settings['client_id'],
                                                client_secret: @settings['client_secret'],
                                                redirect_uri: redirect_freshbooks_url,
                                                api_endpoint: @settings['api_endpoint'],
                                                auth_endpoint: @settings['auth_endpoint'])
  end
end
