module Actions
  module Dockerro
    module Image
      class AssociateWithContentHost < Actions::EntryAction

        middleware.use Actions::Middleware::KeepCurrentUser

        input_format do
          param :activation_key_id
          param :build_uuid
          param :image_id
          param :content_view_version_id
        end

        def run
          activation_key = ::Katello::ActivationKey.find(input[:activation_key_id])
          image = ::Katello::DockerImage.find(input[:image_id])
          system = activation_key.systems.select do |system|
            system.represents_docker_image? && system.facts['dockerro.build_uuid'] == input[:build_uuid]
          end.first

          image.content_host = system
          image.save!
          output[:system_id] = system.id
          output[:system_uuid] = system.uuid
        end

        def humanized_name
          _("Associate Build Config with Image")
        end

      end
    end
  end
end
