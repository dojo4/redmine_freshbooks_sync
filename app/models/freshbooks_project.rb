class FreshbooksProject < ::ActiveRecord::Base
  belongs_to :project, optional: true
  has_many :freshbooks_time_entries

  def title
    upstream_raw['title']
  end

  def description
    upstream_raw['description']
  end

  def client_id
    upstream_raw['client_id']
  end

  def url
    "https://my.freshbooks.com/#/project/#{upstream_id}"
  end
end
