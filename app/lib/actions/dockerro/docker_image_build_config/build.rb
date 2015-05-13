module Actions
  module Dockerro
    module DockerImageBuildConfig
      class Build < Actions::EntryAction

        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(build_config, compute_resource_id, hostname)
          compute_resource = ::ComputeResource.find(compute_resource_id)
          config           = build_config
          sequence do
            if config.template?
              config         = build_config.clone_for_latest_version
              created_config = plan_action(::Actions::Dockerro::DockerImageBuildConfig::Create, config) if config.new_record?
            end
            config.reload
            action_subject(config)
            plan_action ::Actions::Dockerro::Image::Create,
                        config,
                        config.latest_base_tag,
                        compute_resource,
                        hostname

            config_id = created_config.nil? ? config.id : created_config.output[:build_config_id]
            plan_action ::Actions::Dockerro::DockerImageBuildConfig::AssociateImage,
                        :build_config_id => config_id,
                        :base_image_id => config.base_image.id if config.base_image
          end
        end

        def run
          output = input
        end

        def humanized_name
          _("Build Build Config")
        end

      end
    end
  end
end
