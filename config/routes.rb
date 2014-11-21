Rails.application.routes.draw do

  resources :friendships

  # get 'runnings/index'
  # post 'runnings/destroy'

  get 'sport_sessions/index'
  get 'sport_sessions/show'
  get 'sport_sessions/edit'
  post 'sport_sessions/destroy'

  get 'friends/index'
  post 'friends/confirm'
  post 'friends/create'

  get 'welcome/index'


  get   'session/login'
  post  'session/login'

  get 'session/logout'

  resources :achievements

  resources :credits

  resources :users

  resources :runnings


  get 'runnings/:id/edit/result' => 'runnings#edit_result'
  post 'runnings/:id/result/save' => 'runnings#save_result'
  get 'boxings/:id/edit/result' => 'boxings#edit_result'
  post 'boxings/:id/result/save' => 'boxings#save_result'

  resources :cyclings

  resources :boxings

  resources :soccers

  resources :sport_sessions do
    get '/confirm/:user_id', :to => 'sport_sessions#confirm', :as => 'confirm'
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

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
