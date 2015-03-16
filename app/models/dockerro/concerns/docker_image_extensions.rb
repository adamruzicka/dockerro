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

module Dockerro
  module Concerns
    module DockerImageExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :docker_build_image_config,
                   :class_name => "::Dockerro::DockerImageBuildConfig",
                   :inverse_of => :built_images

        belongs_to :base_image,
                   :class_name => "::Katello::DockerImage",
                   :inverse_of => :successor_images

        has_many   :successor_images,
                   :class_name => "::Katello::DockerImage",
                   :inverse_of => :base_image

      end
    end
  end
end

