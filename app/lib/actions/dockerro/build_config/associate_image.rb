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
    module DockerImageBuildConfig
      class AssociateImage < Actions::EntryAction

        input_format do
          param :build_config_id
          param :base_image_id
        end

        def finalize
          build_config = ::Dockerro::DockerImageBuildConfig.find(input[:build_config_id])
          image = build_config.repository.docker_tags.select { |docker_tag| docker_tag.name == build_config.tag }.first.docker_image
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
