module Dockerro
  class Api::V2::DockerImagesController < ::Katello::Api::V2::ApiController
    before_filter :find_content_view, :only => [:create]
    before_filter :find_compute_resource, :only => [:create, :bulk_build]
    before_filter :find_repository, :only => [:create]
    before_filter :find_base_image, :only => [:create]
    before_filter :create_build_config, :only => [:create]

    respond_to :json

    resource_description do
      api_version 'v2'
      api_base_url "/dockerro/api"
    end

    api :POST, '/docker_images'
    param :git_url, String, :desc => N_("git url"), :required => true
    param :git_commit, String, :desc => N_("git commit hash")
    param :environment_id, :identifier, :desc => N_("environment")
    param :content_view_id, :identifier, :desc => N_("content view id"), :required => true
    param :repository_id, :identifier, :desc => N_("target pulp repository id")
    param :compute_resource_id, :identifier, :desc => N_("compute resource id"), :required => true
    param :base_image_id, :identifier, :desc => N_("ID of base image to build on")

    def create
      fail "TODO: this doesn't work yet" if @compute_resource.url[/^unix:\/\//]
      if @build_config.activation_key.new_record?
        sync_task(::Actions::Katello::ActivationKey::Create, @build_config.activation_key)
        @build_config.activation_key.reload
        @build_config.activation_key.available_subscriptions.each { |subscription| @build_config.activation_key.subscribe subscription.cp_id }
      end
      task = async_task(::Actions::Dockerro::Image::Create, @build_config, @base_image, @compute_resource, request.host)
      respond_for_async(:resource => task)
    end

    api :POST, '/docker_images/bulk_build'
    param :compute_resource_id, :identifier
    param :ids, Array
    def bulk_build
      build_configs = params.fetch(:ids).map { |id| DockerImageBuildConfig.find(id) }
      task = async_task ::Actions::BulkAction,
                        ::Actions::Dockerro::Image::Create,
                        build_configs,
                        @compute_resource,
                        request.host
      respond_for_async(:resource => task)
    end

    private

    def find_content_view
      @content_view = ::Katello::ContentView.find(params[:content_view_id]) if params.key? :content_view_id
      @environment  = ::Katello::KTEnvironment.find(params[:environment][:id]) if params.key? :environment
      @content_view_environment = ::Katello::ContentViewEnvironment.where(:environment_id => @environment.id, :content_view_id => @content_view.id).first
    end

    def find_base_image
      @base_image = ::Katello::DockerTag.find(params[:base_image_id]) if params.key? :base_image_id
    end

    def find_repository
      @repository = ::Katello::Repository.find(params[:repository_id]) if params.key? :repository_id
    end

    def find_compute_resource
      @compute_resource = ::ComputeResource.find(params[:compute_resource_id])
    end

    def create_build_config
      @build_config = ::Dockerro::DockerImageBuildConfig.new(::Dockerro::DockerImageBuildConfig.docker_image_build_config_params(params))
      @build_config.content_view = @content_view
      @build_config.repository = @repository
      @build_config.base_image_tag = @base_image.name
      @build_config.content_view_environment = @content_view_environment
    end
  end
end
