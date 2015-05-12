module Dockerro
  class DockerImageBuildConfig < Katello::Model
    self.include_root_in_json = false

    include Katello::Glue
    include Glue::ElasticSearch::DockerImageBuildConfig
    include ActiveModel::Validations
    include ForemanTasks::Concerns::ActionSubject

    attr_writer :environment
    attr_accessor :build_uuid

    attr_accessible :git_url, :git_commit, :base_image_full_name,
                    :activation_key_prefix, :content_view_id,
                    :parent_config_id, :base_image_id,
                    :content_view_version_id,
                    :repository_id, :automatic

    belongs_to :content_view_version,
               :class_name => "::Katello::ContentViewVersion",
               :inverse_of => :docker_image_build_configs

    belongs_to :repository,
               :class_name => "::Katello::Repository",
               :inverse_of => :docker_image_build_configs

    belongs_to :content_view,
               :class_name => "::Katello::ContentView",
               :inverse_of => :docker_image_build_configs

    belongs_to :compute_reource,
               :class_name => "::ComputeResource"

    belongs_to :base_image_environment,
               :class_name => "::Katello::KTEnvironment"

    belongs_to :base_image_content_view,
               :class_name => "::Katello::ContentView"

    has_one :organization,
            :class_name => "::Organization",
            :through    => :content_view

    belongs_to :base_image,
               :class_name => "::Katello::DockerImage",
               :inverse_of => :docker_image_build_config

    belongs_to :parent_config,
               :class_name  => "::Dockerro::DockerImageBuildConfig",
               :inverse_of  => :child_configs,
               :foreign_key => :parent_config_id

    has_many :child_configs,
             :class_name  => "::Dockerro::DockerImageBuildConfig",
             :inverse_of  => :parent_config,
             :foreign_key => :parent_config_id

    has_one :built_image,
            :class_name => "::Katello::DockerImage",
            :inverse_of => :docker_image_build_config

    validates :repository, :presence => true
    validates :content_view, :presence => true
    validates_uniqueness_of :content_view_version_id, :scope => :repository_id

    def image_name
      "#{name}:#{tag}"
    end

    def name
      repository.docker_upstream_name.blank? ? repository.label : repository.docker_upstream_name
    end

    def automatic?
      automatic
    end

    def tag
      "#{content_view.label}-#{environment.label}"
    end

    def generate_build_options(hostname, base_image)
      {
          :git_url           => git_url,
          :git_commit        => git_commit,
          :tag               => tag,
          :image             => image_name,
          :prebuild_plugins  => prebuild_plugins(hostname, base_image),
          :postbuild_plugins => postbuild_plugins
      }
    end

    def generate_environment_variables(compute_resource, hostname, base_image)
      {
          'BUILD_JSON'        => JSON.dump(generate_build_options(hostname, base_image)),
          'DOCKER_CONNECTION' => compute_resource.url
      }
    end

    def self.docker_image_build_config_params(params)
      params.require(:docker_image_build_config).permit(:git_url,
                                                        :git_commit,
                                                        :base_image_full_name,
                                                        :base_image_id,
                                                        :repository_id,
                                                        :content_view_version_id,
                                                        :content_view_id,
                                                        :activation_key_prefix,
                                                        :parent_config_id,
                                                        :compute_resource_id,
                                                        :automatic)
    end

    def build_container_options(compute_resource)
      {
          :compute_resource_id => compute_resource.id,
          :repository_name     => Setting[:dockerro_builder_image],
          :tag                 => Setting[:dockerro_builder_image_tag],
          :command             => "dock --verbose inside-build --input env"
      }
    end

    def clone_for_latest_version
      new_config                      = self.dup
      new_config.content_view_version = content_view.versions.last
      new_config.parent_config        = self
      new_config.base_image_id        = latest_base_tag.docker_image.id unless latest_base_tag.nil?
      unless new_config.valid?
        new_config = child_configs.
            select { |config| config.content_view_version_id == new_config.content_view_version_id }.first
      end
      new_config
    end

    def base_image_tag
      @base_image_tag ||= base_image_full_name.nil? ? "" : base_image_full_name.split(":").last
    end

    def based_on_old_image?
      latest_base_tag.docker_image != base_image
    end

    def activation_key
      @activation_key ||= find_activation_key
    end

    def template?
      content_view_version.nil?
    end

    def base_image_path(hostname, base_image)
      "#{hostname}:5000/#{base_image.repository.relative_path}"
    end

    def environment
      if template?
        nil
      else
        @environment ||= content_view.environments.select(&:library?).first
      end
    end

    def latest_base_tag
      return nil if base_image_full_name.nil?
      @found_bases ||= ::Katello::DockerTag.where(:name => base_image_tag)
                           .joins(:repository)
                           .where('environment_id = %s' % base_image_environment.id)
                           .select { |tag| tag.repository.content_view.id == base_image_content_view.id }
                           .select { |tag| tag.full_name == base_image_full_name }.first
    end

    private

    def find_activation_key
      fail "Cannot build from template Build Config" if template?
      key_name       = "#{activation_key_prefix}-#{content_view.label}-#{environment.label}"
      matching_keys  = ::Katello::ActivationKey.where(:name            => key_name,
                                                      :content_view_id => content_view.id)
      if matching_keys.empty?
        activation_key              = ::Katello::ActivationKey.new
        activation_key.name         = key_name
        activation_key.content_view = content_view
        activation_key.environment  = environment
        activation_key.organization = content_view.organization
        activation_key.auto_attach  = false
      else
        activation_key = matching_keys.first
      end
      activation_key
    end

    def prebuild_plugins(hostname, base_image)
      plugins           = []
      register_commands = <<-END.gsub(/^\s*\| /, '')
        | yum localinstall -y http://#{hostname}/#{katello_ca_cert_path} && \\
        | mkdir -p /etc/rhsm/facts && \\
        | echo '#{MultiJson.dump(image_identification)}' > /etc/rhsm/facts/docker_identification.facts && \\
        | rm -rf /etc/pki/consumer /etc/pki/entitlement /etc/pki/product && \\
        | subscription-manager register --org='#{organization.label}' --activationkey='#{activation_key.name}' || \\
        | true && \\
        | subscription-manager repos
        END
      plugins << plugin('change_from_in_dockerfile', 'base_image' => "#{base_image_path(hostname, base_image)}:#{base_image.name}") unless base_image.nil?
      plugins << plugin('run_cmd_in_container',
                        'cmd' => register_commands)
      plugins
    end

    def katello_ca_cert_path
      "pub/katello-ca-consumer-latest.noarch.rpm"
    end

    def image_identification
      {
        "dockerro.represents" => true,
        "dockerro.build_config_id" => id,
        "dockerro.build_uuid" => build_uuid
      }
    end

    def postbuild_plugins
      plugins = []
      command = <<-END.gsub(/\s*\| /, '')
        | subscription-manager repos
      END
      plugins << plugin('post_run_cmd', 'cmd' => command, 'image_id' => image_name)
      plugins
    end

    def plugin(name, args = {})
      {
          'name' => name,
          'args' => args
      }
    end

  end
end
