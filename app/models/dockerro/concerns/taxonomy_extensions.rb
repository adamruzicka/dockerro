module Dockerro
  module Concerns
    module TaxonomyExtensions
      extend ActiveSupport::Concern

      included do
        has_many :build_resources, :through => :taxable_taxonomies, :source => :taxable, :source_type => "Dockerro::BuildResource"
      end
    end
  end
end
