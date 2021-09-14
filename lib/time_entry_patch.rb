require_dependency 'time_entry'

# Patches Redmine's TimeEntry dynamically adds a relationship `has_one` to
# FreshbooksTimeEntry
module TimeEntryPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      has_one :freshbooks_time_entry, dependent: :nullify
      after_save :ensure_freshbooks_time_entry
      after_save :submit_freshbooks_push_job
      before_destroy :submit_freshbooks_delete_job

      scope :for_freshbooks, lambda {
        spent_on_start = ::Setting.plugin_redmine_freshbooks_sync['earliest_time_entry_date'].to_date
        where("spent_on >= ?", spent_on_start)
         .includes(:project, :freshbooks_time_entry, :user, issue: [:tracker, :status, :priority] )
         .joins(project: :freshbooks_project_mapping)
         .where("freshbooks_project_mappings.state = ?", ::FreshbooksProjectMapping::MAPPED)
      }
    end
  end

  module InstanceMethods
    def ensure_freshbooks_time_entry
      return if freshbooks_time_entry.present?
      freshbooks_project_id = project.freshbooks_project_id
      self.create_freshbooks_time_entry(freshbooks_project_id: freshbooks_project_id)
    end

    def submit_freshbooks_push_job
      ::FreshbooksTimeEntryPushJob.perform_later(self.id)
    end

    def submit_freshbooks_delete_job
      return unless freshbooks_time_entry.present?
      freshbooks_time_entry.update(sync_state: ::FreshbooksTimeEntry::PENDING_DELETE)
      ::FreshbooksTimeEntryDeleteJob.perform_later(freshbooks_time_entry.id)
    end

    def needs_freshbooks_push?
      freshbooks_time_entry.pending? || (updated_on >= freshbooks_time_entry.synced_at)
    end
  end
end

# add module to TimeEntry
TimeEntry.send(:include, TimeEntryPatch)
