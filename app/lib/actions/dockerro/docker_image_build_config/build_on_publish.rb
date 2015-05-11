module Actions
  module Dockerro
    module DockerImageBuildConfig
      class BuildOnPublish < Actions::EntryAction

        middleware.use Actions::Middleware::KeepCurrentUser

        input_format do
          param :build_config_ids, Array
          param :compute_resource_id, Integer
          param :hostname, String
        end

        def self.subscribe
          ::Actions::Katello::ContentView::Publish
        end

        def plan(content_view, _)
          # Select applicable build configs, eg templates with automatic flag set
          build_configs = content_view.docker_image_build_configs.select(&:template?).select(&:automatic?)
          unless build_configs.empty?
            # Get compute resource from build resource
            compute_resource = ::Dockerro::BuildResource.scoped.first.compute_resource

            # Plan bulk build for found build configs
            plan_self :build_config_ids => build_configs.map(&:id),
                        :compute_resource_id => compute_resource.id,
                        :hostname => hostname
          end
        end

        def finalize
          # build_config = ::Dockerro::DockerImageBuildConfig.where(:id => input[:build_config_ids])
          build_configs = input[:build_config_ids].map { |id| ::Dockerro::DockerImageBuildConfig.find(id) }
          world.trigger(::Actions::BulkAction,
                        ::Actions::Dockerro::DockerImageBuildConfig::Build,
                        build_configs,
                        input[:compute_resource_id],
                        input[:hostname])
        end

        def hostname
          @capsule ||= ::Katello::CapsuleContent.default_capsule.capsule
          @capsule.hostname
        end

      end
    end
  end
end
