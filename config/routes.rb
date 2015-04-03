require 'katello/api/mapper_extensions'
class ActionDispatch::Routing::Mapper
  include Katello::Routing::MapperExtensions
end

Dockerro::Engine.routes.draw do

  resources :build_resources, :only => [:index, :create, :destroy, :show, :new, :edit]

  scope :dockerro, :path => '/dockerro' do

    namespace :api do
      scope "(:api_version)", :module => :v2, :defaults => {:api_version => 'v2'}, :api_version => /v2/, :constraints => ApiConstraints.new(:version => 2, :default => true) do
        api_resources :docker_images, :only => [:create] do
          collection do
            post :bulk_build
          end
        end
        api_resources :docker_image_build_configs, :only => [:create, :index, :show, :update, :destroy] do
          member do
            post :clone
          end
        end
      end
    end
  end
end
