module Dockerro
  class Api::V2::DockerImageBuildConfigsController < ::Katello::Api::V2::ApiController
    respond_to :json

    before_filter :find_build_config, :only => [:show, :destroy]
    before_filter :find_organization, :only => [:index, :create]
    before_filter :find_base_image, :only => [:create]
    before_filter :create_build_config, :only => [:create]
    before_filter :find_compute_resource, :only => [:bulk_create]
    # before_filter :find_repository, :only => [:index]

    resource_description do
      api_version 'v2'
      api_base_url "/dockerro/api"
    end

    def index
      ids = DockerImageBuildConfig.where(:organization_id => @organization.id).pluck(:id)
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
    #   abstract
    #   activation_key_prefix
    # r content_view_id
    # r repository_id
    #   content_view_environment_id
    def create
      sync_task(::Actions::Dockerro::DockerImageBuildConfig::Create, @build_config)
      @build_config.reload
      # respond_for_show(:resource => @build_config)
      render :json => @build_config
    end

    # r id
    def destroy
      task = async_task(::Actions::Dockerro::DockerImageBuildConfig::Destroy, @build_config)
      respond_for_async(:resource => task)
    end

    private

    def create_build_config
      @build_config = ::Dockerro::DockerImageBuildConfig.new(::Dockerro::DockerImageBuildConfig.docker_image_build_config_params(params))
      content_view_environment = ::Katello::ContentViewEnvironment.where(:content_view_id => params[:content_view_id],
                                                                         :environment_id => @organization.library.id).first
      @build_config.base_image_tag = @base_image.name
      @build_config.content_view_environment = content_view_environment
      @build_config.abstract = true
      @build_config.organization = @organization
      @build_config.base_image = @base_image.docker_image
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

    def respond_with_template(action, resource_name, options = {}, &block)
      yield if block_given?
      status = options[:status] || 200
      render :template => "dockerro/api/v2/#{resource_name}/#{action}",
             :status => status,
             :locals => { :object_name => options[:object_name],
                          :root_name => options[:root_name] },
             :layout => "katello/api/v2/layouts/#{options[:layout]}"
    end

  end
end
