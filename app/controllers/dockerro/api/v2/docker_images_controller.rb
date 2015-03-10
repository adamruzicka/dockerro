module Dockerro
  class Api::V2::DockerImagesController < ::Katello::Api::V2::ApiController
    before_filter :find_content_view, :only => [:create]
    before_filter :find_compute_resource, :only => [:create]
    before_filter :find_repository, :only => [:create]
    before_filter :find_or_create_activation_key, :only => [:create]
    before_filter :find_base_image, :only => [:create]

    respond_to :json

    resource_description do
      api_version 'v2'
      api_base_url "/dockerro/api"
    end

    api :POST, '/docker_images'
    param :name, String, :desc => N_("name"), :required => true
    param :tag, String, :desc => N_("tag"), :required => true
    param :git_url, String, :desc => N_("git url"), :required => true
    param :git_commit, String, :desc => N_("git commit hash")
    param :environment_id, :identifier, :desc => N_("environment")
    param :content_view_id, :identifier, :desc => N_("content view id"), :required => true
    # param :parent_registry_id, :identifier, :desc => N_("id of the parent registry")
    param :target_registry_ids, Array, :desc => N_("list of target docker registry ids")
    param :pulp_repository_id, :identifier, :desc => N_("target pulp repository id")
    param :compute_resource_id, :identifier, :desc => N_("compute resource id"), :required => true
    param :base_image, String, :desc => N_("base image to build on")

    def create
      fail "TODO: this doesn't work yet" if @compute_resource.url[/^unix:\/\//]
      environment_variables              = {
          'BUILD_JSON'        => JSON.dump(get_build_options),
          'DOCKER_CONNECTION' => @compute_resource.url
      }
      build_config                       = {}
      build_config[:compute_resource_id] = @compute_resource.id
      build_config[:repository_name]     = Setting[:dockerro_builder_image]
      build_config[:command]             = "dock --verbose inside-build --input env"
      if @activation_key.new_record?
        task = sync_task(::Actions::Katello::ActivationKey::Create, @activation_key)
        @activation_key.reload
        @activation_key.available_subscriptions.each { |subscription| @activation_key.subscribe subscription.cp_id }
      end
      task = async_task(::Actions::Dockerro::Image::Create, image_name, @activation_key, @repository, build_config, environment_variables)
      respond_for_async(:resource => task)
    end

    private

    def get_build_options
      build_config = {}

      if params.key? :target_registry_ids
        build_config[:target_registries] = docker_registries.
            select { |dr| params[:target_registry_ids].include? dr.id }.
            map { |reg| reg.url.gsub(/https?:\/\//, '') }
      end
      [:git_url, :git_commit, :tag].each do |key|
        build_config[key] = params[key] if params.key?(key)
      end
      build_config[:image]             = image_name
      build_config[:prebuild_plugins]  = prebuild_plugins
      build_config[:postbuild_plugins] = postbuild_plugins
      build_config
    end

    def image_name
      @image_name ||= "#{params[:name]}:#{params[:tag]}"
    end

    def docker_registries
      @docker_registries || DockerRegistry.all
    end

    def prebuild_plugins
      plugins           = []
      register_commands = "yum localinstall -y http://#{params[:katello_hostname]}/pub/katello-ca-consumer-latest.noarch.rpm && " +
          "subscription-manager register --org='#{current_organization.name}' --activationkey='#{@activation_key.name}' || true"
      plugins << plugin('change_from_in_dockerfile', 'base_image' => "#{params[:katello_hostname]}:5000/#{@base_image.repository.relative_path}:#{@base_image.name}") if params.key?(:base_image)
      plugins << plugin('run_cmd_in_container',
                        'cmd' => register_commands)
      plugins.flatten
    end

    def postbuild_plugins
      [
          plugin('all_rpm_packages', 'image_id' => image_name),
          plugin('store_logs_to_file', 'file_path' => '/var/rpms')
      ]
    end

    def plugin(name, args = {})
      {
          'name' => name,
          'args' => args
      }
    end

    def current_organization
      @current_organization || Organization.find(params[:organization_id].to_i)
    end

    def find_content_view
      @content_view = ::Katello::ContentView.find(params[:content_view_id]) if params.key? :content_view_id
      @environment  = ::Katello::KTEnvironment.find(params[:environment][:id]) if params.key? :environment
    end

    def find_base_image
      @base_image = ::Katello::DockerTag.find(params[:base_image]) if params.key? :base_image
    end

    def find_repository
      @repository = ::Katello::Repository.find(params[:pulp_repository_id]) if params.key? :pulp_repository_id
    end

    def find_compute_resource
      @compute_resource = ::ComputeResource.find(params[:compute_resource_id])
    end

    def find_or_create_activation_key
      if params[:default_key]
        key_name      = "dockerro-#{@environment.name}-#{@content_view.name}"
        matching_keys = ::Katello::ActivationKey.where(:name => key_name)
        if matching_keys.empty?
          @activation_key              = ::Katello::ActivationKey.new
          @activation_key.name         = key_name
          @activation_key.content_view = @content_view
          @activation_key.environment  = @environment
          @activation_key.organization = current_organization
          @activation_key.auto_attach  = false
          @activation_key.user         = current_user
        else
          @activation_key = matching_keys.first
        end
      else
        @activation_key = ::Katello::ActivationKey.find(params[:activation_key_id])
      end
    end
  end
end
