Rails.application.routes.draw do
  namespace :dockerro do
    resources :docker_images

    namespace :api do
      scope "(:apiv)", :module => :v2, :defaults => { :apiv => 'v2' }, :apiv => /v2/,
            :constraints => ApiConstraints.new(:version => 2) do
        resources :docker_images, :only => [:index, :create, :show]
      end
    end
  end
end
