module Dockerro
  module Concerns
    module RepositoryExtensions
      extend ActiveSupport::Concern

      included do
        has_many :docker_image_build_configs,
                 :class_name => "::Dockerro::DockerImageBuildConfig",
                 :dependent  => :destroy,
                 :inverse_of => :repository
      end
    end
  end
end
