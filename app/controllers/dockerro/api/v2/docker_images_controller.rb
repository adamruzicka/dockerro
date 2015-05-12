module Dockerro
  class Api::V2::DockerImagesController < ::Katello::Api::V2::ApiController
    before_filter :find_content_view, :only => [:create]
    before_filter :find_compute_resource, :only => [:create, :bulk_build]
    before_filter :find_repository, :only => [:create]
    before_filter :find_base_image, :only => [:create]
    before_filter :find_image, :only => [:show]
    before_filter :create_build_config, :only => [:create]
    before_filter :find_build_resource, :only => [:bulk_update]

    include Api::V2::Rendering

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
      fail "Building Docker images on Compute Resource with unix socket is not supported" if @compute_resource.url[/^unix:\/\//]
      task = async_task(::Actions::Dockerro::Image::Create, @build_config, @base_image, @compute_resource, request.host)
      respond_for_async(:resource => task)
    end

    api :POST, '/docker_images/bulk_build'
    param :compute_resource_id, :identifier
    param :ids, Array
    def bulk_build
      build_configs = params.fetch(:ids).map { |id| DockerImageBuildConfig.find(id) }
      task = async_task ::Actions::BulkAction,
                        ::Actions::Dockerro::DockerImageBuildConfig::Build,
                        build_configs,
                        @compute_resource.id,
                        request.host
      respond_for_async(:resource => task)
    end

    api :POST, '/docker_images/bulk_update'
    param :compute_resource_id, :identifier
    param :ids, Array
    def bulk_update
      image_ids = ::Katello::DockerTag.where(:id => params[:ids]).pluck(:docker_image_id)
      task = async_task ::Actions::Dockerro::Image::Update, image_ids, @build_resource.compute_resource, request.host
      respond_for_async(:resource => task)
    end

    api :GET, '/docker_images'
    param :organization_id, :identifier
    param :with_updates_only, :bool
    def index
      # We don't care about images without tag since we cannot use them anyway
      tags = []
      joined = ::Katello::DockerTag.joins(:docker_image, :repository => :environment)
                                   .where("organization_id = %s" % params[:organization_id])
      if params.fetch(:restrict_updateable, false)
        # Filter out images withou build config because we dont know how to rebuild them
        tags.concat(joined.where("docker_image_build_config_id IS NOT NULL"))
      else
        tags = joined.all
      end
      results = {
          :results => tags,
          :subtotal => tags.count,
          :total => tags.count,
          :page => 1,
          :per_page => tags.count
      }
      respond_for_index(:collection => results)
    end

    api :GET, '/docker_images/:id'
    param :id, :identifier, :required => true
    def show
      respond_for_show(:resource => @docker_image)
    end

    private

    def subscribe_activation_key(activation_key)
      activation_key.reload
      activation_key.available_subscriptions.each { |subscription| @build_config.activation_key.subscribe subscription.cp_id }
    end

    def find_content_view
      @content_view = ::Katello::ContentView.find(params[:content_view_id]) if params.key? :content_view_id
      @environment  = ::Katello::KTEnvironment.find(params[:environment][:id]) if params.key? :environment
    end

    def find_base_image
      @base_image = ::Katello::DockerTag.find(params[:base_image_id]) if params.key? :base_image_id
    end

    def find_build_resource
      @build_resource = ::Dockerro::BuildResource.with_taxonomy_scope.first
      fail "There is no Build Resource in current Organization and Location" if @build_resource.nil?
    end

    def find_image
      @docker_image = ::Katello::DockerTag.find(params[:id])
    end

    def find_repository
      @repository = ::Katello::Repository.find(params[:repository_id]) if params.key? :repository_id
    end

    def find_compute_resource
      @compute_resource = ::ComputeResource.find(params[:compute_resource_id])
    end

    def find_organization
      @organization = ::Organization.find(params[:organization_id])
    end

    def create_build_config
      @build_config = ::Dockerro::DockerImageBuildConfig.new
      @build_config.git_url = params.fetch(:git_url)
      @build_config.git_commit = params[:git_commit]
      @build_config.content_view_version = @content_view.version(@environment)
      @build_config.content_view = @content_view
      @build_config.repository = @repository
      @build_config.base_image_full_name = @base_image.full_name unless @base_image.nil?
      @build_config.base_image = @base_image.docker_image unless @base_image.nil?
      @build_config.activation_key_prefix = params[:activation_key_prefix] || 'dockerro'
      @build_config.environment = @environment
    end
  end
end
