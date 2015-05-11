module Dockerro
  class BuildResource < ActiveRecord::Base
    include Taxonomix
    # include Encryptable
    include Authorizable
    include Parameterizable::ByIdName

    belongs_to :compute_resource,
               :class_name => "::ComputeResource"

    default_scope lambda {
      with_taxonomy_scope do
        order("dockerro_build_resources.name")
      end
    }

    def taxonomy_foreign_conditions
      { :compute_resource_id => compute_resource.id }
    end
  end
end
