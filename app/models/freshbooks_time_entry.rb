class FreshbooksTimeEntry < ::ActiveRecord::Base
  belongs_to :time_entry, optional: true
  belongs_to :freshbooks_project, optional: true

  PENDING = 'pending'
  PUSHED  = 'pushed'

  STATES = [ PENDING, PUSHED ]

  def pending?
    PENDING == self.sync_state
  end

  def pushed?
    PUSHED == self.sync_state
  end

  def url
    local_date = time_entry.spent_on.to_time.utc.strftime("%Y-%m-%d")
    "https://my.freshbooks.com/#/time-tracking?forceSwitch=true&timelineDay=#{local_date}"
  end
end
