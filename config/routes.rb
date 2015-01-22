Rails.application.routes.draw do
  resources :images, :only => [:index, :new, :show, :destroy]
end
