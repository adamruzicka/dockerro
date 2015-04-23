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
    module DockerImageBuildConfig
      class BindRepositoriesOnPromote < Actions::EntryAction

        middleware.use Actions::Middleware::KeepCurrentUser

        def self.subscribe
          ::Actions::Katello::ContentView::Promote
        end

        def plan(version, environment, _)
          content_view = version.content_view
          repositories = content_view.repos(environment)
          systems = ::Katello::System
                    .where(:environment_id => environment.id)
                    .where(:content_view_id => content_view.id)
                    .select { |sys| !sys.docker_image.empty? }
          unless systems.empty?
            plan_self :repository_ids => repositories.map(&:id),
                      :system_ids => systems.map(&:id)
            plan_action ::Actions::Katello::System::GenerateApplicability, systems
          end

        end

        def run
          systems = input[:system_ids].map { |id| ::Katello::System.find id }
          systems.each do |system|
            system.bound_repository_ids = input[:repository_ids]
            system.save!
            system.propagate_yum_repos
          end
        end

      end
    end
  end
end
