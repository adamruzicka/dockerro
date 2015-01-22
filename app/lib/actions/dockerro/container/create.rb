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
      class Create < Actions::EntryAction
        def plan(options, compute_resource)
          container = Container.new(options.reject(:environment)) do |c|
            options[:environment].each do |evar|
              c.environment_variables.build(evar)
            end
          end
          fail "Bogus" unless ::Service::Containers.start_container(container)
          container.save!
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
