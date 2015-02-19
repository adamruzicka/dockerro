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
      class RetrievePackageList < Actions::EntryAction
        input_format do
          param :container_uuid
        end

        def run
          uuid = ::Container.find(input[:container_id]).uuid
          container = Docker::Container.get(uuid)
          chunks = []
          container.copy("/var/rpms") { |chunk| chunks << chunk }
          output[:rpms] = JSON.parse(chunks.join()[/\{.*\}/])['postbuild_plugins']['all_rpm_packages']
        end

        def humanized_name
          _("Retrieve package list")
        end
      end
    end
  end
end
