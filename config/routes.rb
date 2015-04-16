require 'katello/api/mapper_extensions'
class ActionDispatch::Routing::Mapper
  include Katello::Routing::MapperExtensions
end

Dockerro::Engine.routes.draw do

  resources :build_resources, :only => [:index, :create, :destroy, :show, :new, :edit, :update]

  scope :dockerro, :path => '/dockerro' do

    namespace :api do
      scope "(:api_version)", :module => :v2, :defaults => {:api_version => 'v2'}, :api_version => /v2/, :constraints => ApiConstraints.new(:version => 2, :default => true) do
        api_resources :docker_images, :only => [:create, :index, :show] do
          collection do
            post :bulk_build
            post :bulk_update
          end
        end
        api_resources :docker_image_build_configs, :only => [:create, :index, :show, :update, :destroy] do
          member do
            post :build
          end
        end
      end
    end
  end
end
