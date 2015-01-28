Rails.application.routes.draw do
  namespace :dockerro do
    resources :images
  end
end
