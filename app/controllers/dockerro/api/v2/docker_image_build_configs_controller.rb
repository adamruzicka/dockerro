module Dockerro
  class Api::V2::DockerImageBuildConfigsController < ::Katello::Api::V2::ApiController
    respond_to :json

    include Api::V2::Rendering

    before_filter :find_build_config, :only => [:show, :destroy, :build]
    before_filter :find_organization, :only => [:index, :create, :build]
    before_filter :find_base_image, :only => [:create]
    before_filter :create_build_config, :only => [:create]
    before_filter :find_compute_resource, :only => [:bulk_create]
    before_filter :find_build_resource, :only => [:build]

    resource_description do
      api_version 'v2'
      api_base_url "/dockerro/api"
    end

    def index
      images = DockerImageBuildConfig.select { |build_config| build_config.organization.id == @organization.id }
      images = images.select(&:template?) unless params.fetch(:with_version, false)
      ids = images.map(&:id)
      filters = [:terms => {:id => ids}]
      options = {
          :filters => filters,
          :load_records? => true
      }
      respond_for_index(:collection => item_search(DockerImageBuildConfig, params, options))
    end

    def show
      respond_for_show(:resource => @build_config)
    end

    def update
      fail NotImplementedError
    end

    # r git_url
    #   git_commit
    #   base_image_tag
    #   activation_key_prefix
    # r content_view_id
    #   content_view_version_id
    # r repository_id
    def create
      sync_task(::Actions::Dockerro::DockerImageBuildConfig::Create, @build_config)
      @build_config.reload
      respond_for_show(:resource => @build_config)
      # render :json => @build_config
    end

    def build
      task = async_task ::Actions::Dockerro::DockerImageBuildConfig::Build,
                        @build_config,
                        @build_resource.compute_resource.id,
                        request.host
      respond_for_async(:resource => task)
    end

    # r id
    def destroy
      task = async_task(::Actions::Dockerro::DockerImageBuildConfig::Destroy, @build_config)
      respond_for_async(:resource => task)
    end

    private

    def create_build_config
      @build_config = ::Dockerro::DockerImageBuildConfig.new(::Dockerro::DockerImageBuildConfig.docker_image_build_config_params(params))
      unless @base_image.nil?
        @build_config.base_image_full_name = @base_image.full_name
        @build_config.base_image = @base_image.docker_image
        @build_config.base_image_content_view = @base_image.repository.content_view
        @build_config.base_image_environment = @base_image.repository.environment
      end
    end

    def find_base_image
      @base_image = ::Katello::DockerTag.find(params[:base_image_id])
    end

    def find_build_config
      @build_config = ::Dockerro::DockerImageBuildConfig.find_by_id(params[:id])
    end

    def find_organization
      @organization = ::Organization.find(params.fetch(:organization_id))
    end

    def find_build_resource
      @build_resource = ::Dockerro::BuildResource.scoped.first
    end

  end
end
