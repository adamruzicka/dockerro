module Dockerro
  module Concerns
    module SystemExtensions
      extend ActiveSupport::Concern

      included do
        has_many :docker_image,
                 :class_name => "::Katello::DockerImage",
                 :dependent  => :destroy,
                 :inverse_of => :content_host,
                 :foreign_key => :content_host_id

        def represents_docker_image?
          facts.fetch('dockerro.represents', false)
        end

      end

    end
  end
end
