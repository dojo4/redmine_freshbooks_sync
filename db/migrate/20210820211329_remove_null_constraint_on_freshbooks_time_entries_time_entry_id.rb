class RemoveNullConstraintOnFreshbooksTimeEntriesTimeEntryId < ActiveRecord::Migration[5.2]
  def change
    change_column_null :freshbooks_time_entries, :time_entry_id, true
  end
end
