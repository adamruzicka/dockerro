#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Actions
  module Dockerro
    module Image
      class AssociateWithContentHost < Actions::EntryAction

        middleware.use Actions::Middleware::KeepCurrentUser

        input_format do
          param :build_config_id
          param :activation_key_id
        end

        def finalize
          build_config = ::Dockerro::DockerImageBuildConfig.find(input[:build_config_id])
          activation_key = build_config.activation_key
          image = build_config.built_image
          system = activation_key.systems.select do |system|
            system.represents_docker_image? && system.facts['dockerro.build_config_id'] == build_config.id
          end.first
          image.content_host = system
          image.save!
        end

        def humanized_name
          _("Associate Build Config with Image")
        end

      end
    end
  end
end
