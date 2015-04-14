module Dockerro
  module Glue::ElasticSearch::DockerImage
    def self.included(base)
      base.class_eval do
        include Glue::ElasticSearch::BaseModel
      end
    end
  end
end