class FreshbooksProjectMapping < ::ActiveRecord::Base
  belongs_to :freshbooks_project, optional: true
  has_many :freshbooks_project_mappings
  has_many :projects, through: :freshbooks_project_mappings

  UNMAPPED = 'unmapped'
  MAPPED   = 'mapped'
  INTERNAL = 'internal'
  STATES = [ UNMAPPED, MAPPED, INTERNAL ]

  def mapped?
    state == MAPPED
  end

  def unmapped?
    state == UNMAPPED
  end

  def internal?
    state == INTERNAL
  end

  def map(freshbooks_project_id)
    update(freshbooks_project_id: freshbooks_project_id,
           state: MAPPED)
  end

  def unmap
    update(freshbooks_project_id: nil, state: UNMAPPED)
  end

  def mark_internal
    update(freshbooks_project_id: nil, state: INTERNAL)
  end
end
