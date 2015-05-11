module Actions
  module Dockerro
    module DockerImageBuildConfig
      class Create < Actions::EntryAction

        input_format do
          param :build_config_id, Integer
        end

        output_format do
          param :build_config_id, Integer
        end

        def plan(build_config)
          build_config.save!
          plan_self :build_config_id => build_config.id
        end

        def run
          output[:build_config_id] = input[:build_config_id]
        end

        def humanized_name
          _("Create Build Config")
        end

      end
    end
  end
end
