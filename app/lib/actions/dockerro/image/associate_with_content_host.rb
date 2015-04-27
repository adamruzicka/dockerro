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
          param :activation_key_id
          param :build_uuid
          param :image_id
          param :content_view_version_id
        end

        def run
          activation_key = ::Katello::ActivationKey.find(input[:activation_key_id])
          image = ::Katello::DockerImage.find(input[:image_id])
          content_view_version = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          system = activation_key.systems.select do |system|
            system.represents_docker_image? && system.facts['dockerro.build_uuid'] == input[:build_uuid]
          end.first

          bind_system_repositories(system, content_view_version)

          image.content_host = system
          image.save!
          output[:system_id] = system.id
        end

        def bind_system_repositories(system, content_view_version)
          system.bound_repositories = content_view_version.repos(system.environment)
          system.save!
          system.propagate_yum_repos
          system.generate_applicability
        end

        def humanized_name
          _("Associate Build Config with Image")
        end

      end
    end
  end
end
