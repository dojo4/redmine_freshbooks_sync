class FreshbooksProjectsController < FreshbooksBaseController
  def index
    @projects = Project.active.includes(:freshbooks_project).order(::Arel.sql("lower(name)"))
    @projects.each { |p| p.ensure_freshbooks_project_mapping }
    @freshbooks_projects = FreshbooksProject.all.to_a.sort_by { |p| p.title.downcase }
    @last_synced_at = FreshbooksProject.maximum(:synced_at)
  end

  def associate
    project = Project.find_by(id: params[:id])
    freshbooks_project = FreshbooksProject.find_by(id: params[:freshbooks_project_id])
    if freshbooks_project.present?  then
      project.freshbooks_project_mapping.map(freshbooks_project.id)
      flash[:notice] = t(".associate_notice", redmine_project: project.name, freshbooks_project: freshbooks_project.title)
    else
      flash[:error] = t(".please_select_a_freshbooks_project", redmine_project: project.name)
    end
    redirect_to freshbooks_projects_path
  end

  def disassociate
    project = Project.find(params[:id])
    project.freshbooks_project_mapping.unmap
    flash[:notice] = t(".disassociate_notice", project: project.name)
    redirect_to freshbooks_projects_path
  end

  def sync
    FreshbooksProjectsSyncJob.perform_later
    flash[:notice] = t('.project_synchronization_in_process')
    redirect_to freshbooks_projects_path
  end

  def mark_internal
    project = Project.find(params[:id])
    project.freshbooks_project_mapping.mark_internal
    flash[:notice] = t('.mark_internal_notice', project: project.name)
    redirect_to freshbooks_projects_path
  end

  def mark_associable
    project = Project.find(params[:id])
    project.freshbooks_project_mapping.unmap
    flash[:notice] = t(".mark_associable", project: project.name)
    redirect_to freshbooks_projects_path
  end
end
