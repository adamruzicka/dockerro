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
      class Create < Actions::EntryAction
        include Actions::Base::Polling
        include ::Dynflow::Action::Cancellable

        FINISHED_STATES = %w(finished error canceled skipped)

        input_format do
          param :container_id
          param :compute_resource_id
        end
        
        def done?
          @container.state
        end

        def cancel!
        end

        def invoke_external_task
          find_container(input[:container_id], input[:compute_resource_id]).send(:start)
        end

        def poll_external_task
          find_container(input[:container_id], input[:compute_resource_id]).refresh
        end
        
        def plan(options)
          require 'pry'; binding.pry
          # add defaults to input
          config = add_defaults(options)
          # create container
          container = plan_action(::Actions::Dockerro::Container::Create, config)
          # run it and wait for it to finish
          plan_self(:container_id => container.id,
                    :compute_resource_id => container.compute_resource_id)
          # [delete container]
          if config[:destroy_after_run]
            plan_action(::Actions::Dockerro::Container::Destroy, container)
          end
        end

        def humanized_name
          _("Create")
        end

        private
        
        def add_defaults(options)
          options
        end

        def find_container(container_id, resource_id)
          find_compute_resource(resource_id).find_vm_by_uuid(container_id)
        end

        def find_compute_resource(id, permission = :view_compute_resources)
          ComputeResource.authorized(permission).find(id)
        end
      end
    end
  end
end
