module RedmineFreshbooks
  module Hooks
    class ViewProjectsShowLeft < Redmine::Hook::ViewListener
      def view_projects_show_left(context={})
        project = context[:project]
        content = nil

        case project.freshbooks_project_mapping&.state
        when ::FreshbooksProjectMapping::UNMAPPED
          content = <<~CONTENT
            Not currently associated with a Freshbooks project.
            <a href="#{freshbooks_projects_path}">Fix that</a>.
          CONTENT
        when ::FreshbooksProjectMapping::MAPPED
          fb_project = project.freshbooks_project
          content = "<a href=\"#{fb_project.url}\" target=\"_blank\">#{fb_project.title}</a>"
        when ::FreshbooksProjectMapping::INTERNAL
          content = "Internal project - not mapped to Freshbooks"
        end

        <<~HTML
        <div class="box">
          <h3>Freshbooks Association</h3>
          <p>
            #{content}
          </p>
        </div>
        HTML
      end
    end
  end
end
