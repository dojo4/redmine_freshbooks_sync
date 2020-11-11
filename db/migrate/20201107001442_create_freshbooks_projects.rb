class CreateFreshbooksProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :freshbooks_projects do |t|
      t.integer    :upstream_id, null:  true, index: true
      t.jsonb      :upstream_raw
      t.string     :sync_state,  null:  false, default: 'pending'
      t.timestamp  :synced_at
      t.timestamps
    end
  end
end
