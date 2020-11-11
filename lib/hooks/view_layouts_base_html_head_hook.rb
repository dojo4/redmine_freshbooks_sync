module RedmineFreshbooks
  module Hooks
    class ViewLayoutsBaseHtmlHeadHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        stylesheet_link_tag 'freshbooks.css', :plugin => :redmine_freshbooks_sync
      end
    end
  end
end
