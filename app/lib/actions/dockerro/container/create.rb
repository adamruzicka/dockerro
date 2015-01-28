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
        
        def plan(options)
          require 'pry'; binding.pry
          plan_self(:environment_variables => options, :container_settings => add_defaults)
          # TODO: return container id
        end

        def run
          container = ::Service::Containers::Container.new(input[:container_settings]) do |c|
            input[:environment_variables].each_pair do |k, v|
              c.environment_variables.build :name => k,
                                            :value => v
            end
          end
          fail "Bogus" unless ::Service::Containers.start_container(container)
          container.save!
          require 'pry'; binding.pry
          output[:uuid] = container.uuid
        end

        def humanized_name
          _("Create")
        end

        private

        def add_defaults
          {
            :repository_name=>"dockerhost-builder",
            :tag=>"latest",
            :registry_id=>nil,
#            :name=>"s2",
            :compute_resource_id=>1,
            :tty=>false,
            :memory=>"",
            :entrypoint=>"",
            :command=>"",
            :attach_stdout=>true,
            :attach_stdin=>true,
            :attach_stderr=>true,
            :cpu_shares=>nil,
            :cpu_set=>nil
          }
        end

      end
    end
  end
end
