Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :user, only: %i[index] do
    post 'mass-update', action: :mass_update, on: :collection
  end
end
