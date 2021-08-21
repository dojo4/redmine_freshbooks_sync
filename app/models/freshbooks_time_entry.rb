class FreshbooksTimeEntry < ::ActiveRecord::Base
  belongs_to :time_entry, optional: true
  belongs_to :freshbooks_project, optional: true

  PENDING = 'pending'
  PUSHING = 'pushing'
  PUSHED  = 'pushed'
  PENDING_DELETE = 'pending_delete'
  DELETED = 'deleted'

  STATES = [ PENDING, PUSHING, PUSHED, PENDING_DELETE, DELETED ]
  REMOVED_STATES = [ PENDING_DELETE, DELETED ]

  scope :pending_delete, -> { where(sync_state: PENDING_DELETE) }

  def pending?
    PENDING == self.sync_state
  end

  def pushed?
    PUSHED == self.sync_state
  end

  def pending_delete?
    PENDING_DELETE == self.sync_state
  end

  def deleted?
    DELETED == self.sync_state
  end

  def pushing?
    PUSHING == self.sync_state
  end

  def url
    if time_entry.present? then
      local_date = time_entry.spent_on.to_time.utc.strftime("%Y-%m-%d")
    else
      local_date = synced_at.strftime("%Y-%m-%d")
    end
    "https://my.freshbooks.com/#/time-tracking?forceSwitch=true&timelineDay=#{local_date}"
  end
end
