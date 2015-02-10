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

        # @param [Hash] build_options can set any of the following
        # @option build_options [String] :repository_name       Name of the image to use as build container
        # @option build_options [String] :tag ('latest')        Tag of the image to use as build container
        # @option build_options [Int]    :registry_id           TODO: find out what it does
        # @option build_options [String] :name                  Name of the build container
        # @option build_options [Int]    :compute_resource_id   Id of the compute resource on which the build should be performed
        # @option build_options [Bool]   :tty (false)           If the container should have pseudo-tty allocated
        # @option build_options [String] :memory ('')           Quota on build container's memory usage
        # @option build_options [String] :entrypoint ('')       Build container's entrypoint
        # @option build_options [String] :command ('')          Command to run in the build container
        # @option build_options [Bool]   :attach_stdout (true)  If the build container should have stdout allocated
        # @option build_options [Bool]   :attach_stdin (true)   If the build container should have stdin allocated
        # @option build_options [Bool]   :attach_stderr (true)  If the build container should have stderr allocated
        # @option build_options [String] :cpu_shares (nil)      TODO: find out what it does
        # @option build_options [String] :spu_set (nil)         TODO: find out what it does
        # @param [Hash] environment_variables Hash of environment variables passed to the build
        def plan(build_options, environment_variables = {})
          # create container
          sequence do
            container = plan_action(::Actions::Dockerro::Container::Create, build_options, environment_variables)
            # run it and wait for it to finish
            plan_action(::Actions::Dockerro::Container::MonitorRun,
                        :container_id => container.output[:uuid],
                        :compute_resource_id => build_options[:compute_resource_id])
            # [delete container]
          end
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
