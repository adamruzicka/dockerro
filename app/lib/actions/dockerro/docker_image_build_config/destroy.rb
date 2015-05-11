module Actions
  module Dockerro
    module DockerImageBuildConfig
      class Destroy < Actions::EntryAction

        input_format do
          param :id, Integer
        end

        def plan(build_config)
          plan_self :id => build_config.id
        end

        def run
          @build_config = ::Dockerro::DockerImageBuildConfig.find(input[:id])
          @build_config.destroy!
        end

        def humanized_name
          _("Destroy Build Config")
        end

      end
    end
  end
end
