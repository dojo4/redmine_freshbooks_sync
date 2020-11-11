class CreateFreshbooksProjectMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :freshbooks_project_mappings do |t|
      t.references            :project, null: true, index: true, foreign_key: true
      t.references :freshbooks_project, null: true, index: true, foreign_key: true
      t.string                :state,   null: false, default: 'unmapped'
      t.timestamps
    end
  end
end
