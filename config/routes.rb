Rails.application.routes.draw do

  get 'schedule/index'

  get 'schedule/p1'

  get 'schedule/p2'

  get "/courses/sort " => "courses#sort", :as => 'sort'

  get 'prof/index'

  get 'prof/list'

  get 'prof/show'

  get 'prof/new'
  resources :faculties


  resources :courses
  resources  :welcome

  get 'url_construct/index'
  match ':controller(/:action(/:id))', :via => :get
  match ':controller(/:action(/:id))', :via => :post


  get 'admin/new'

  get 'admin/become_admin_attempt'
  post 'admin/become_admin_attempt'

  get 'sessions/login'
  post 'sessions/login_attempt'
  get 'sessions/logout'

  get 'users/login'
  get 'users/new'
  get 'welcome/index'

  resources :users
  # match '/curl_courses' => 'request_courses#curl_get_courses', via::get
  # match '/curl_courses' => 'request_courses#curl_post_courses', via::post

  root 'welcome#index'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
