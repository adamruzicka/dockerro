module Dockerro
  class ImagesController < ::ApplicationController
    before_action :prepare_form_data, :only [:new]
    def index
      render json: {'key'=> 'value'}
    end

    def new
    end

    def create
      environment_variables = {
        'BUILD_JSON' => JSON.dump(get_build_options(params))
      }
      build_config = {}
      build_config[:compute_resource_id] = params[:docker_image][:compute_resource_id].to_i
      # TODO: load :repository_name from settings
      build_config[:repository_name] = 'dockerhost-builder'
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
