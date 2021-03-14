require_dependency 'project'

# Patches Redmine's Project dynamically adds a relationship `has_one` to
# FreshbooksProject
module ProjectPatch
  def self.included(base)
    base.class_eval do
      has_one :freshbooks_project_mapping
      has_one :freshbooks_project, through: :freshbooks_project_mapping

      after_save :ensure_freshbooks_project_mapping

      def freshbooks_project_id
        return nil unless freshbooks_project
        freshbooks_project.id
      end

      def freshbooks_upstream_id
        return nil unless freshbooks_project
        freshbooks_project.upstream_id
      end

      def freshbooks_client_id
        return nil unless freshbooks_project
        freshbooks_project.client_id
      end

      def ensure_freshbooks_project_mapping
        return if freshbooks_project_mapping.present?
        self.create_freshbooks_project_mapping
      end

    end
  end
end

# add module to Project
Project.send(:include, ProjectPatch)
