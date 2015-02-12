module Dockerro
  class ImagesController < ::ApplicationController
    before_filter :prepare_form_data, :only => [:new]
    before_filter :find_content_view, :only => [:create]
    before_filter :find_compute_resource, :only => [:create]

    def new
    end

    def create
      fail "TODO: this doesn't work yet" if @compute_resource.url[/^unix:\/\//]
      environment_variables = {
        'BUILD_JSON' => JSON.dump(get_build_options(params)),
        'DOCKER_CONNECTION' => @compute_resource.url
      }
      build_config = {}
      build_config[:compute_resource_id] = @compute_resource.id
      build_config[:repository_name] = Setting[:dockerro_builder_image]
      build_config[:command] = "dock -v inside-build --input env"
      ForemanTasks.trigger(::Actions::Dockerro::Image::Create, build_config, environment_variables)
      render json: {'action' => 'create'}
    end

    private

    def current_organization
      ::Organization.current
    end

    def prepare_form_data
      fmt = lambda { |x| [x.name, x.id] }
      @compute_resources = current_organization.
                           compute_resources.
                           select { |cr| cr.type == 'ForemanDocker::Docker' }.
                           map &fmt
      @registries = DockerRegistry.select { |dr| dr.organization_ids.include? current_organization.id }
      @content_views = current_organization.content_views.map &fmt
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
      [:image, :git_url, :git_commit].each do |key|
        params[:docker_image][key] && build_config[key] = params[:docker_image][key]
      end
      build_config[:prebuild_plugins] = prebuild_plugins
      build_config[:postbuild_plugins] = postbuild_plugins
      build_config
    end

    def prebuild_plugins
      # TODO: find out the parent image (if exists)
      # res = [
      #     {
      #         'name' => 'change_from_in_dockerfile',
      #         'args' => {
      #             'base_image' => ''
      #         }
      #     }
      # ]
      # res << @content_view.repos.map do |repo|
      #   {
      #     'name' => 'add_yum_repo',
      #     'args' => {
      #       'repo_name' => repo.name,
      #       'baseurl' => repo.url
      #     }
      #   }
      # end
      # TODO: enable if changing repos
      # res << {
      #   'name' => 'inject_yum_repo',
      #   'args' => {}
      # }
      []
    end

    def postbuild_plugins
      [
        {
          'name' => 'all_rpm_packages',
          'args' => {
            'image_id' => params[:docker_image][:image]
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
      @content_view = ::Katello::ContentView.find(params[:docker_image][:content_view_id].to_i)
    end

    def find_compute_resource
      @compute_resource = ::ComputeResource.find(params[:docker_image][:compute_resource_id].to_i)
    end
  end
end
