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
    module Container
      class Destroy < Actions::EntryAction
        input_format do
          :container_id
        end

        def run
          find_container(input[:container_id]).remove
        end

        private

        def find_container(container_id)
          ::Docker::Container.get(::Container.find(container_id).uuid)
        end
      end
    end
  end
end
