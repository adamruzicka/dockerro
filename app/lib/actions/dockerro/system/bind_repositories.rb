module Actions
  module Dockerro
    module System
      class BindRepositories < Actions::EntryAction

        middleware.use Actions::Middleware::KeepCurrentUser

        def input_format
          param :system_ids
          param :repository_ids
        end

        def plan(systems, repositories)
          unless systems.empty?
            sequence do
              plan_self :repository_ids => repositories.map(&:id),
                        :system_ids => systems.map(&:id)
              plan_action ::Actions::Katello::System::GenerateApplicability, systems
            end
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
