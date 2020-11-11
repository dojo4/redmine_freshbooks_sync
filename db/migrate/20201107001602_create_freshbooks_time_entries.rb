class CreateFreshbooksTimeEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :freshbooks_time_entries do |t|

      t.references :time_entry,         null: false, index:   true, foreign_key: true
      t.references :freshbooks_project, null: true,  index:   true, foreign_key: true
      t.integer    :upstream_id,        null: true,  index:   true
      t.jsonb      :upstream_raw,       null: true
      t.string     :sync_state,         null: false, default: 'pending'
      t.timestamp  :synced_at
      t.timestamps
    end
  end
end
