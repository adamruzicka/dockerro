module Dockerro
  module Glue::ElasticSearch::DockerImageBuildConfig
    def self.included(base)
      base.class_eval do
        include Glue::ElasticSearch::BaseModel
      end
    end
  end
end