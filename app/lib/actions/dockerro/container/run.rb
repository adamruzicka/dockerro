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
      class Run < Actions::EntryAction
        include Actions::Base::Polling
        include ::Dynflow::Action::Cancellable

        input_format do
          param :container_id
          param :compute_resource_id
        end
        
        def done?
          find_container(input[:container_id], input[:compute_resource_id]).state == 'Stopped'
        end

        def invoke_external_task
          find_container(input[:container_id], input[:compute_resource_id]).send(:start)
          true
        end

        def poll_external_task
        end
        
        def humanized_name
          _("Create")
        end

        private

        def find_container(container_id, resource_id)
          ComputeResource.find(resource_id).find_vm_by_uuid(container_id)
        end
      end
    end
  end
end
