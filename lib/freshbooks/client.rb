require 'http'
require 'addressable'

module Freshbooks
  class Client

    def self.default
      settings = Setting['plugin_redmine_freshbooks_sync']
      new(client_id: settings['client_id'],
          client_secret: settings['client_secret'],
          redirect_uri: 'https://dojo4.ngrok.io/freshbooks/redirect'
         )
    end

    attr_reader :client_id
    attr_reader :client_secret
    attr_reader :redirect_uri
    attr_reader :api_endpoint
    attr_reader :auth_endpoint
    attr_reader :token_store

    def initialize(client_id:, client_secret:, redirect_uri:,
                   api_endpoint: Freshbooks.default_api_endpoint,
                   auth_endpoint: Freshbooks.default_auth_endpoint,
                   token_store: TokenStore.new
                  )
      @client_id     = client_id
      @client_secret = client_secret
      @redirect_uri  = redirect_uri
      @api_endpoint  = api_endpoint
      @auth_endpoint = auth_endpoint
      @token_store   = token_store
      @auth_token    = nil
    end

    def api_uri
      @api_uri ||= Addressable::URI.parse(api_endpoint)
    end

    def auth_uri
      @auth_uri ||= Addressable::URI.parse(auth_endpoint)
    end

    def authorize_url
      uri = auth_uri.join('oauth/authorize')
      uri.query_values = {
        client_id: client_id,
        response_type: 'code',
        redirect_uri: redirect_uri
      }
      uri.to_s
    end

    def store_token_for(code)
      params = {
        grant_type: "authorization_code",
        code: code,
      }
      obtain_and_store_token(params)
    end

    def authorized?
      return true if auth_token && auth_token.valid?
    end

    def expired?
      return auth_token.expired? if auth_token
      return true
    end

    def auth_token
      return @auth_token if @auth_token
      if token_hash = token_store.fetch then
        @auth_token = AuthToken.from_hash(token_hash)
      end
    end

    def expires_at
      auth_token.expires_at
    end

    def me
      @me ||= api_get_request("/auth/api/v1/users/me")
    end

    def owner_businesses
      return [] if me.blank?
      me.dig('response', 'business_memberships').select { |m| m['role'] == 'owner' }.map { |m| m['business'] }
    end

    def account_id
      return nil if owner_businesses.blank?
      owner_businesses.first['account_id']
    end

    def business_id
      return nil if owner_businesses.blank?
      owner_businesses.first['id']
    end

    def active_projects
      params = {
        active: true,
        complete: false,
        skip_group: true,
        per_page: 100,
      }
      all_pages("/projects/business/#{business_id}/projects", %w[projects], params: params, content_type: nil)
    end

    def create_time_entry(project_id:, client_id:, started_at:, duration:, note:)
      json = {
        time_entry: {
          billable: true,
          project_id: project_id,
          client_id: client_id,
          started_at: started_at.utc.iso8601,
          duration: duration.to_i,
          is_logged: true,
          note: note,
        }
      }
      response = api_post_request("/timetracking/business/#{business_id}/time_entries", json: json)
    end

    def update_time_entry(time_entry_id:, project_id:, client_id:, started_at:, duration:, note:)
      json = {
        time_entry: {
          billable: true,
          project_id: project_id,
          client_id: client_id,
          started_at: started_at.utc.iso8601,
          duration: duration.to_i,
          is_logged: true,
          note: note,
        }
      }
      response = api_put_request("/timetracking/business/#{business_id}/time_entries/#{time_entry_id}", json: json)
    end

    def delete_time_entry(time_entry_id:)
      response = api_delete_request("/timetracking/business/#{business_id}/time_entries/#{time_entry_id}")
    end

    def all_pages(path, dig_path, params: {}, content_type: 'application/json')
      return [] unless connection?
      initial_result = api_get_request(path, params: params, content_type: content_type)
      meta = initial_result['meta']
      collection = initial_result.dig(*dig_path)
      this_page = meta['page']
      last_page = meta['pages']
      loop do
        this_page += 1
        break if this_page > last_page

        iter_params = params.merge({page: this_page})
        iter_result = api_get_request(path, params: iter_params, content_type: content_type)
        iter_items = iter_result.dig(*dig_path)
        collection.concat(iter_items)
      end
      collection
    end

    def refresh_token
      return unless auth_token && auth_token.expiring_soon?
      refresh_token!
    end

    def refresh_token!
      params = {
        grant_type: "refresh_token",
        refresh_token: auth_token.refresh_token
      }
      obtain_and_store_token(params)
    end

    def obtain_and_store_token(params)
      full_params = params.merge({
        client_id: client_id,
        client_secret: client_secret,
        redirect_uri: redirect_uri
      })
      response = http.post(api_uri.join('/auth/oauth/token'), json: full_params)
      token_hash = response.parse
      @auth_token = AuthToken.from_hash(token_hash)
      token_store.store(token_hash)
    end

    def api_get_request(path, params: {}, content_type: 'application/json')
      api_request(path: path, method: :get, params: params, content_type: content_type)
    end

    def api_post_request(path, json: {}, content_type: 'application/json')
      api_request(path: path, method: :post, json: json, content_type: content_type)
    end

    def api_put_request(path, json: {}, content_type: 'application/json')
      api_request(path: path, method: :put, json: json, content_type: content_type)
    end

    def api_delete_request(path, json: nil, content_type: 'application/json')
      api_request(path: path, method: :delete, content_type: content_type)
    end

    def api_request(path:, method:, params: nil, json: nil, content_type: 'application/json')
      return nil unless connection?
      headers = {}
      if content_type then
        headers['Content-Type'] = content_type
      end
      opts = {}
      opts.merge!({ json: json }) if json
      opts.merge!({ params: params }) if params
      response = connection(headers: headers).send(method, api_uri.join(path), opts)
      return nil if response.body.empty?
      response.parse('application/json')
    end

    def connection?
      refresh_token
      return !!auth_token
    end

    def connection(headers: {})
      refresh_token
      headers = auth_token.headers.merge(headers)
      http.headers(headers)
    end

    def http
      #::HTTP.use(logging: {logger: Rails.logger})
      ::HTTP
    end
  end
end
