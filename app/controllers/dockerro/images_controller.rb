module Dockerro
  class ImagesController < ::ApplicationController
    # before_action :prepare_form_data, :only => [:new]
    def index
      render json: {'key'=> 'value'}
    end

    def new
      prepare_form_data
    end

    def create
      compute_resource = ComputeResource.find(params[:docker_image][:compute_resource_id].to_i)
      fail "TODO: this doesn't work yet" if compute_resource.url[/^unix:\/\//]
      environment_variables = {
        'BUILD_JSON' => JSON.dump(get_build_options(params)),
        'DOCKER_CONNECTION' => compute_resource.url
      }
      build_config = {}
      build_config[:compute_resource_id] = compute_resource.id
      build_config[:repository_name] = Setting[:dockerro_builder_image]
      build_config[:command] = "dock -v inside-build --input env"
      ForemanTasks.trigger(::Actions::Dockerro::Image::Create, build_config, environment_variables)
      render json: {'action' => 'create'}
    end

    private

    def prepare_form_data
      @compute_resources = ComputeResource.
                           select { |cr| cr.type == 'ForemanDocker::Docker' }.
                           map { |cr| [cr.name, cr.id] }
      @registries = DockerRegistry.all
    end

    def get_build_options(params)
      build_config = {}
      params[:target_registry_ids] &&
        build_config[:target_registries] = DockerRegistry.
                                       select { |dr| params[:target_registry_ids].include? dr.id.to_s }.
                                       map(&:url)
      params[:parent_registry_ids] &&
        build_config[:parent_registry] = DockerRegistry.
                                       find(params[:parent_registry_ids].to_i).url
      [:image, :git_url, :git_commit].each { |key| params[:docker_image][key] && build_config[key] = params[:docker_image][key] }
      build_config
    end
  end
end
