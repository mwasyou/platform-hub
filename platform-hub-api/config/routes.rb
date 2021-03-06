Rails.application.routes.draw do

  scope :format => false do

    root to: 'root#index'

    get '/healthz', to: 'healthcheck#show'

    get '/me', to: 'me#show'
    post '/me/agree_terms_of_service', to: 'me#agree_terms_of_service'
    post '/me/complete_hub_onboarding', to: 'me#complete_hub_onboarding'
    post '/me/complete_services_onboarding', to: 'me#complete_services_onboarding'
    post '/me/global_announcements/mark_all_read', to: 'me#global_announcements_mark_all_read', constraints: lambda { |_| FeatureFlagService.is_enabled?(:announcements) }
    get '/me/kubernetes_tokens', to: 'me#kubernetes_tokens', constraints: lambda { |_| FeatureFlagService.is_enabled?(:kubernetes_tokens) }

    resources :feature_flags, only: [ :index ] do
      put '/:flag', to: 'feature_flags#update_flag', on: :collection
    end

    constraints service: /kubernetes/ do
      delete '/me/identities/:service', to: 'me#delete_identity'
    end

    constraints service: /github/ do
      delete '/me/identities/:service', to: 'me#delete_identity'

      get '/identity_flows/start/:service',
        to: 'identity_flows#start_auth_flow',
        as: 'identity_flows_start'

      get '/identity_flows/callback/:service',
        to: 'identity_flows#callback',
        as: 'identity_flows_callback'
    end

    resources :users, only: [ :index, :show ] do
      get '/search/:q', to: 'users#search', on: :collection, :constraints => { :q => /[^\/]+/ }

      get :identities, on: :member

      post :make_admin, on: :member
      post :revoke_admin, on: :member
      post :make_limited_admin, on: :member
      post :revoke_limited_admin, on: :member

      post :activate, on: :member
      post :deactivate, on: :member

      post :onboard_github, on: :member
      post :offboard_github, on: :member
    end

    resources :projects, constraints: lambda { |request| FeatureFlagService.is_enabled?(:projects) } do
      get :memberships, on: :member
      put '/memberships/:user_id', to: 'projects#add_membership', on: :member
      delete '/memberships/:user_id', to: 'projects#remove_membership', on: :member

      constraints lambda { |request| ProjectMembership.roles.keys.include?(request.params[:role]) } do
        get '/memberships/role_check/:role', to: 'projects#role_check', on: :member
        put '/memberships/:user_id/role/:role', to: 'projects#set_role', on: :member
        delete '/memberships/:user_id/role/:role', to: 'projects#unset_role', on: :member
      end

      get :kubernetes_clusters, on: :member
      get :kubernetes_groups, on: :member
      get :kubernetes_user_tokens, on: :member
      get '/kubernetes_user_tokens/:token_id', to: 'projects#show_kubernetes_user_token', on: :member
      post :kubernetes_user_tokens, to: 'projects#create_kubernetes_user_token', on: :member
      patch '/kubernetes_user_tokens/:token_id', to: 'projects#update_kubernetes_user_token', on: :member
      delete '/kubernetes_user_tokens/:token_id', to: 'projects#destroy_kubernetes_user_token', on: :member

      get :bills, on: :member

      resources :services do
        get :kubernetes_groups, on: :member
        get :kubernetes_robot_tokens, on: :member
        get '/kubernetes_robot_tokens/:token_id', to: 'services#show_kubernetes_robot_token', on: :member
        post :kubernetes_robot_tokens, to: 'services#create_kubernetes_robot_token', on: :member
        patch '/kubernetes_robot_tokens/:token_id', to: 'services#update_kubernetes_robot_token', on: :member
        delete '/kubernetes_robot_tokens/:token_id', to: 'services#destroy_kubernetes_robot_token', on: :member
      end

      resources :docker_repos,
        only: [ :index, :create, :destroy ],
        constraints: lambda { |request| FeatureFlagService.is_enabled?(:docker_repos) } do
          put :access, to: 'docker_repos#update_access', on: :member
        end
    end

    resources :support_request_templates, constraints: lambda { |request| FeatureFlagService.is_enabled?(:support_requests) } do
      get :form_field_types, on: :collection
      get :git_hub_repos, on: :collection
    end

    resources :support_requests, only: [ :create ], constraints: lambda { |request| FeatureFlagService.is_enabled?(:support_requests) }

    resources :platform_themes

    resource :app_settings, only: [ :show, :update ]

    resources :contact_lists,
      except: [ :create ],
      constraints: { id: ContactList::ID_REGEX_FOR_ROUTES }

    resources :announcement_templates, constraints: lambda { |_| FeatureFlagService.is_enabled?(:announcements) } do
      get :form_field_types, on: :collection
      post :preview, on: :collection
    end

    resources :announcements, constraints: lambda { |_| FeatureFlagService.is_enabled?(:announcements) } do
      get :global, on: :collection
      post :mark_sticky, on: :member
      post :unmark_sticky, on: :member
      post :resend, on: :member
    end

    constraints lambda { |_| FeatureFlagService.is_enabled?(:kubernetes_tokens) } do
      namespace :kubernetes do

        resources :tokens do
          constraints lambda { |_| FeatureFlagService.all_enabled?([:kubernetes_tokens_escalate_privilege, :kubernetes_tokens])} do
            patch '/escalate', to: 'tokens#escalate', on: :member
            patch '/deescalate', to: 'tokens#deescalate', on: :member
          end
        end

        resources :clusters, except: :destroy do
          post :allocate, on: :member
          get :allocations, on: :member
          get :robot_tokens, on: :member
          get :user_tokens, on: :member
        end

        get '/changeset/:cluster', to: 'changeset#index'

        post '/sync', to: 'sync#sync', constraints: lambda { |_| FeatureFlagService.all_enabled?([:kubernetes_tokens_sync, :kubernetes_tokens]) }
        post '/revoke', to: 'revoke#revoke'

        resources :groups do
          post :allocate, on: :member
          get :allocations, on: :member
          get :tokens, on: :member
          get :filters, on: :collection
        end

        resources :namespaces
      end
    end

    resources :allocations, only: [ :destroy ]

    resources :costs_reports,
      only: [ :index, :show, :create, :destroy ],
      constraints: { id: CostsReport::ID_REGEX_FOR_ROUTES } do
      get :available_data_files, on: :collection
      post :prepare, on: :collection
      post :publish, on: :member
      get :last_published_config, on: :collection
    end

    constraints lambda { |_| FeatureFlagService.is_enabled? :help_search } do
      get '/help/search', to: 'help#search'
      get '/help/search_status', to: 'help#search_status'
      get '/help/search_query_stats', to: 'help#search_query_stats'
      post '/help/hide_search_query_stat', to: 'help#hide_search_query_stat'
    end

    resources :docs_sources do
      post '/sync', to: 'docs_sources#sync_all', on: :collection
      post :sync, on: :member
      get :entries, on: :member
    end

    get '/pinned_help_entries', to: 'pinned_help_entries#show'
    put '/pinned_help_entries', to: 'pinned_help_entries#update'

    resources :qa_entries
  end

end
