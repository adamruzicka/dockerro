module Actions
  module Dockerro
    module DockerImageBuildConfig
      class AssociateImage < Actions::EntryAction

        input_format do
          param :build_config_id
          param :base_image_id
        end

        def finalize
          build_config = ::Dockerro::DockerImageBuildConfig.find(input[:build_config_id])
          # image = build_config.repository.docker_tags.select { |docker_tag| docker_tag.name == build_config.tag }.first.docker_image
          image = ::Katello::DockerImage.find(input[:base_image_id])
          image.docker_image_build_config = build_config
          image.save!
        end

        def humanized_name
          _("Associate Build Config with Image")
        end

      end
    end
  end
end
