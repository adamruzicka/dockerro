module Dockerro
  module Concerns
    module ContentViewVersionExtensions
      extend ActiveSupport::Concern

      included do
        has_many :docker_image_build_configs,
                 :class_name => "::Dockerro::DockerImageBuildConfig",
                 :dependent  => :destroy,
                 :inverse_of => :content_view_version
      end
    end
  end
end
