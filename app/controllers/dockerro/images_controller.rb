module Dockerro
  class ImagesController < ::ApplicationController
    def index
      require 'pry'; binding.pry
      render json: {'key'=> 'value'}
    end

    def new
      @compute_resources = ComputeResource.
                           select { |cr| cr.type == 'ForemanDocker::Docker' }.
                           map { |cr| [cr.name, cr.id] }
      @registries = DockerRegistry.all
    end


    def create
      require 'pry'; binding.pry
      build_config = get_build_config(params)
      builder_image = ''
      compute_resource_id = params[:docker_image][:compute_resource_id].to_i
      ForemanTasks.trigger(::Actions::Dockerro::Image::Create, builder_image, build_config, compute_resource_id)
      render json: {'action' => 'create'}
    end

    private
#     {
#     "git_url": "http://...",
#     "image": "my-test-image",
#     "git_dockerfile_path": "django/",
#     "git_commit": "devel",
#     "parent_registry": "registry.example.com:5000",
#     "target_registries": ["registry.example2.com:5000"],
#     "prebuild_plugins": [{
#         "name": "koji",
#         "args": {
#             "target": "f22",
#             "hub": "http://koji.fedoraproject.org/kojihub",
#             "root": "https://kojipkgs.fedoraproject.org/"
#         }}, {
#             "name": "inject_yum_repo",
#             "args": {}
#         }
# }
    def get_build_config(params)
      build_json = {}
      require 'pry'; binding.pry
      params[:target_registry_ids] &&
        build_json[:target_registries] = DockerRegistry.
                                       select { |dr| params[:target_registry_ids].include? dr.id.to_s }.
                                       map(&:url)
      params[:parent_registry_ids] &&
        build_json[:parent_registry] = DockerRegistry.
                                       find(params[:parent_registry_ids].to_i)
      [:image, :git_url, :git_commit].each { |key| params[:docker_image][key] && build_json[key] = params[:docker_image][key] }
      build_json
    end
  end
end
