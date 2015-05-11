module Actions
  module Dockerro
    module Container
      class Destroy < Actions::EntryAction
        input_format do
          :container_id
        end

        def run
          ::Container.find(input[:container_id]).in_fog.destroy
        end

      end
    end
  end
end
