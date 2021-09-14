
resource :freshbooks, only: %i[ show ] do
  member do
    get 'redirect'
    post 'authorize'

    resources :freshbooks_time_entries, path: "time_entries", only: %i[ index ] do 
      collection do
        post 'push_all'
      end

      member do
        post 'push_one'
        post 'delete_one'
      end
    end

    resources :freshbooks_projects, path: "projects", only: %i[ index ] do
      member do
        post 'associate'
        post 'disassociate'
        post 'mark_internal'
        post 'mark_associable'
      end

      collection do
        post 'sync'
      end
    end
  end
end
