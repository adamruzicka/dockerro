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
      class MonitorRun < Actions::EntryAction
        include Actions::Base::Polling
        include ::Dynflow::Action::Cancellable

        input_format do
          param :container_id
          param :compute_resource_id
        end
        
        def done?
          task_container.state == 'Stopped'
        end

        def invoke_external_task
          input[:container_uuid] = ::Container.find(input[:container_id]).uuid
          task_container.start
          true
        end

        def poll_external_task
          container = Docker::Container.get(input[:container_uuid])
          tmp = { :stdout => [], :stderr => [] }
          container.streaming_logs(stdout: true, stderr: true) do |stream, chunk|
            tmp[stream.to_sym] << chunk
          end
          {
            :stdout => tmp[:stdout].join("\n"),
            :stderr => tmp[:stderr].join("\n")
          }
        end
        
        def humanized_name
          _("Create")
        end

        private

        def task_container
          ComputeResource.find(input[:compute_resource_id]).
            find_vm_by_uuid(input[:container_uuid])
        end
      end
    end
  end
end
