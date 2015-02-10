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
        input_format do
          param :environment_variables
          param :container_settings
        end
        
        # @param [Hash] container_options can set any of the following
        # @option container_options [String] :repository_name       Name of the image to use as build container
        # @option container_options [String] :tag ('latest')        Tag of the image to use as build container
        # @option container_options [Int]    :registry_id           TODO: find out what it does
        # @option container_options [String] :name                  Name of the build container
        # @option container_options [Int]    :compute_resource_id   Id of the compute resource on which the build should be performed
        # @option container_options [Bool]   :tty (false)           If the container should have pseudo-tty allocated
        # @option container_options [String] :memory ('')           Quota on build container's memory usage
        # @option container_options [String] :entrypoint ('')       Build container's entrypoint
        # @option container_options [String] :command ('')          Command to run in the build container
        # @option container_options [Bool]   :attach_stdout (true)  If the build container should have stdout allocated
        # @option container_options [Bool]   :attach_stdin (true)   If the build container should have stdin allocated
        # @option container_options [Bool]   :attach_stderr (true)  If the build container should have stderr allocated
        # @option container_options [String] :cpu_shares (nil)      TODO: find out what it does
        # @option container_options [String] :spu_set (nil)         TODO: find out what it does
        # @param [Hash] environment_variables Hash of environment variables passed to the build
        def plan(container_options, environment_variables = {})
          container_settings = add_defaults container_options
          container = ::ForemanDocker::Service::Containers::Container.new(container_settings) do |c|
            environment_variables.each_pair do |k, v|
              c.environment_variables.build :name => k,
                                            :value => v
            end
          end
          container.save!
          plan_self(:container_id => container.id)
          plan_action(::ForemanDocker::Service::Actions::Container::Provision, container)
         end

        def run
          output[:uuid] = input[:container_id]
        end

        def humanized_name
          _("Create")
        end

        private

        def add_defaults(options)
          {
            :tag=>"latest",
            :registry_id=>nil,
            :tty=>false,
            :memory=>"",
#            :entrypoint=>"",
#            :command=>"",
            :attach_stdout=>true,
            :attach_stdin=>true,
            :attach_stderr=>true,
            :cpu_shares=>nil,
            :cpu_set=>nil
          }.merge(options)
        end

      end
    end
  end
end
