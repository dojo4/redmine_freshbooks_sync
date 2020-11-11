module Freshbooks
  # This is an example token store to be used to load and store a persisted
  # fresbooks AuthToken
  class TokenStore
    def fetch
      Setting['plugin_redmine_freshbooks_sync']['token']
    end

    def store(token_hash)
      setting = Setting['plugin_redmine_freshbooks_sync']
      setting['token'] = token_hash
      Setting['plugin_redmine_freshbooks_sync'] = setting
    end
  end
end
