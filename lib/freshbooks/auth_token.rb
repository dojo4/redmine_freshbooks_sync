module Freshbooks

  class AuthToken

    attr_reader :access_token
    attr_reader :refresh_token
    attr_reader :token_type
    attr_reader :scope
    attr_reader :created_at
    attr_reader :expires_in

    def self.from_hash(h)
      AuthToken.new(
        access_token:  h['access_token'],
        refresh_token: h['refresh_token'],
        token_type:    h['token_type'],
        scope:         h['scope'],
        created_at:    h['created_at'],
        expires_in:    h['expires_in'],
      )
    end

    def self.to_hash
      {
        access_token:  @access_token,
        refresh_token: @refresh_token,
        token_type:    @token_type,
        scope:         @scope,
        created_at:    @created_at,
        expires_in:    @expires_in,
      }
    end

    def initialize(access_token:, refresh_token:, token_type:,
                   scope:, expires_in:, created_at:)

      @access_token  = access_token
      @refresh_token = refresh_token
      @token_type    = token_type
      @scope         = scope
      @created_at    = Time.at(created_at).utc
      @expires_in    = expires_in
      @expires_at    = @created_at + @expires_in
    end

    def expires_at
      Time.at(created_at + expires_in).utc
    end

    def expired?(since: Time.now)
      expires_at <= since
    end

    def valid?
      !expired?
    end

    def expiring_soon?(limit: 1.minute.from_now)
      expired?(since: limit)
    end

    def headers
      { 'Authorization' => "Bearer #{access_token}" }
    end

  end
end
