require 'katello/api/mapper_extensions'
class ActionDispatch::Routing::Mapper
  include Katello::Routing::MapperExtensions
end

Dockerro::Engine.routes.draw do
  scope :dockerro, :path => '/dockerro' do

    namespace :api do
      scope "(:api_version)", :module => :v2, :defaults => {:api_version => 'v2'}, :api_version => /v2/, :constraints => ApiConstraints.new(:version => 2, :default => true) do
        api_resources :docker_images, :only => [:create]
        end
    end
  end
end
