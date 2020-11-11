module Freshbooks
  def self.default_api_endpoint
    'https://api.freshbooks.com/'
  end

  def self.default_auth_endpoint
    'https://auth.freshbooks.com/service/auth/'
  end

  def self.default_earliest_time_entry_date
    today = Date.today
    Date.new(today.year, today.month, 1)
  end
end
require 'freshbooks/token_store'
require 'freshbooks/auth_token'
require 'freshbooks/client'
