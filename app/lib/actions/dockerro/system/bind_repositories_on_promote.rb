module Actions
  module Dockerro
    module System
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
          plan_action ::Actions::Dockerro::System::BindRepositories,
                      systems,
                      repositories
        end

      end
    end
  end
end
