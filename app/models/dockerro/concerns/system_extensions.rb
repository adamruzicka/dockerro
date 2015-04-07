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
    module SystemExtensions
      extend ActiveSupport::Concern

      included do
        has_one :docker_image,
                :class_name => "::Katello::DockerImage",
                :dependent  => :destroy,
                :inverse_of => :content_host,
                :foreign_key => :conetnt_host_id

        def represents_docker_image?
          facts.fetch('dockerro.represents', false)
        end

      end

    end
  end
end
