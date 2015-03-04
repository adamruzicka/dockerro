module Dockerro
  class Api::V2::DockerImagesController < ::Katello::Api::V2::ApiController
    before_filter :find_content_view, :only => [:create]
    before_filter :find_compute_resource, :only => [:create]
    before_filter :find_repository, :only => [:create]

    respond_to :json

    resource_description do
      api_version 'v2'
      api_base_url "/dockerro/api"
    end

    def create
      require 'pry'; binding.pry
      fail "TODO: this doesn't work yet" if @compute_resource.url[/^unix:\/\//]
      environment_variables = {
        'BUILD_JSON' => JSON.dump(get_build_options),
        'DOCKER_CONNECTION' => @compute_resource.url
      }
      build_config = {}
      build_config[:compute_resource_id] = @compute_resource.id
      build_config[:repository_name] = Setting[:dockerro_builder_image]
      build_config[:command] = "dock -v inside-build --input env"
      task = async_task(::Actions::Dockerro::Image::Create, image_name, @content_view_environment, @repository, build_config, environment_variables)
      respond_for_async(:resource => task)
      # render json: {'response' => "Docker Image build started with plan id #{plan.execution_plan_id}"}
    end

    private

    def current_organization
      ::Organization.current
    end

    def get_build_options
      build_config = {}

      if params.key? :target_registry_ids
        build_config[:target_registries] = docker_registries.
                                       select { |dr| params[:target_registry_ids].include? dr.id }.
                                       map { |reg| reg.url.gsub(/https?:\/\//, '') }
      end
      if params.key? [:parent_registry_id]
        build_config[:parent_registry] = docker_registries.
                                       select { |dr| params[:parent_registry_id] == dr.id }.
                                       first.url.gsub(/https?:\/\//, '')
      end
      [:git_url, :git_commit, :tag].each do |key|
        build_config[key] = params[key] if params.key?(key)
      end
      build_config[:image] = image_name
      build_config[:prebuild_plugins] = prebuild_plugins
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
      [
        @content_view_environment.content_view_version.repos(@content_view_environment.environment).select(&:yum?).map do |repo|
          hostname = /https?:\/\/([^\/]+)/.match(repo.uri)[1]
          addr = Resolv.getaddress hostname
          {
            'name' => 'add_yum_repo',
            'args' => {
              'repo_name' => repo.name,
              'baseurl' => repo.uri.gsub(hostname, addr).gsub('https', 'http')
            }
          }
        end,
        {
          'name' => 'inject_yum_repo',
          'args' => {}
        }
      ].flatten
    end

    def postbuild_plugins
      [
        {
          'name' => 'all_rpm_packages',
          'args' => {
            'image_id' => image_name
          }
        },
        {
          'name' => 'store_logs_to_file',
          'args' => {
            'file_path' => '/var/rpms'
          }
        }
      ]
    end

    def find_content_view
      @content_view = ::Katello::ContentView.find(params[:content_view_id])
      @content_view_environment = ::Katello::ContentViewEnvironment.find(params[:environment][:id])
    end

    def find_repository
      @repository = ::Katello::Repository.find(params[:pulp_repository_id]) if params.key? :pulp_repository_id
    end

    def find_compute_resource
      @compute_resource = ::ComputeResource.find(params[:compute_resource_id])
    end
  end
end
