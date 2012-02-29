::Refinery::Application.routes.draw do
  scope(:path => 'supplier', :module => 'supplier') do
    root :to => 'posts#index', :as => 'supplier_root'
    match 'feed.rss', :to => 'posts#index', :as => 'supplier_rss_feed', :defaults => {:format => "rss"}
    match ':id', :to => 'posts#show', :as => 'supplier_post'
    match 'categories/:id', :to => 'categories#show', :as => 'supplier_category'
    match ':id/comments', :to => 'posts#comment', :as => 'supplier_post_supplier_comments'
    get 'archive/:year(/:month)', :to => 'posts#archive', :as => 'archive_supplier_posts'
    get 'tagged/:tag_id(/:tag_name)' => 'posts#tagged', :as => 'tagged_posts'
  end

  scope(:path => 'refinery', :as => 'admin', :module => 'admin') do
    scope(:path => 'supplier', :as => 'supplier', :module => 'supplier') do
      root :to => 'posts#index'
      resources :posts do
        collection do
          get :uncategorized
          get :tags
        end
      end

      resources :categories

      resources :comments do
        collection do
          get :approved
          get :rejected
        end
        member do
          get :approved
          get :rejected
        end
      end

      resources :settings do
        collection do
          get :notification_recipients
          post :notification_recipients

          get :moderation
          get :comments
          get :teasers
        end
      end
    end
  end
end
