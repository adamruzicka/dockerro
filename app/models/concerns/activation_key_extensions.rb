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
    module ActivationKeyExtensions
      extend ActiveSupport::Concern

      included do
        has_many :docker_image_build_configs,
                 :class_name => "::Dockerro::DockerImageBuildConfig",
                 :dependent  => :nullify,
                 :inverse_of => :activation_key
      end
    end
  end
end
