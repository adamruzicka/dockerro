#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Dockerro
  class DockerImageBuildConfig < Katello::Model
    self.include_root_in_json = false

    include Katello::Glue
    include Glue::ElasticSearch::DockerImageBuildConfig
    include ActiveModel::Validations
    include ForemanTasks::Concerns::ActionSubject

    attr_writer :environment

    attr_accessible :git_url, :git_commit, :base_image_tag,
                    :activation_key_prefix, :content_view_id,
                    :parent_config_id, :base_image_id,
                    :content_view_version_id,
                    :repository_id

    belongs_to :content_view_version,
               :class_name => "::Katello::ContentViewVersion",
               :inverse_of => :docker_image_build_configs

    belongs_to :repository,
               :class_name => "::Katello::Repository",
               :inverse_of => :docker_image_build_configs

    belongs_to :content_view,
               :class_name => "::Katello::ContentView",
               :inverse_of => :docker_image_build_configs

    has_one :organization,
            :class_name => "::Organization",
            :through => :content_view

    belongs_to :base_image,
               :class_name => "::Katello::DockerImage",
               :inverse_of => :docker_image_build_config

    belongs_to :parent_config,
               :class_name => "::Dockerro::DockerImageBuildConfig",
               :inverse_of => :child_configs,
               :foreign_key => :parent_config_id

    has_many :child_configs,
             :class_name => "::Dockerro::DockerImageBuildConfig",
             :inverse_of => :parent_config,
             :foreign_key => :parent_config_id

    has_one :built_image,
            :class_name => "::Katello::DockerImage",
            :inverse_of => :docker_image_build_config

    validates :repository, :presence => true
    validates :content_view, :presence => true
    validates :base_image, :presence => true
    validates_uniqueness_of :content_view_version_id, :scope => :repository_id

    def image_name
      "#{name}:#{tag}"
    end

    def name
      repository.docker_upstream_name || repository.label
    end

    def tag
      fail "Cannot generate tag for template config" if template?
      "#{content_view.name}-#{environment.name}"
    end

    def generate_build_options(hostname, base_tag)
      {
          :git_url           => git_url,
          :git_commit        => git_commit,
          :tag               => tag,
          :image             => image_name,
          :prebuild_plugins  => prebuild_plugins(hostname, base_tag),
          :postbuild_plugins => postbuild_plugins
      }
    end

    def generate_environment_variables(compute_resource, hostname, base_tag)
      {
          'BUILD_JSON'        => JSON.dump(generate_build_options(hostname, base_tag)),
          'DOCKER_CONNECTION' => compute_resource.url
      }
    end

    def self.docker_image_build_config_params(params)
      params.require(:docker_image_build_config).permit(:git_url,
                                                        :git_commit,
                                                        :base_image_tag,
                                                        :base_image_id,
                                                        :repository_id,
                                                        :content_view_version_id,
                                                        :content_view_id,
                                                        :activation_key_prefix,
                                                        :parent_config_id)
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
      new_config = self.dup
      new_config.content_view_version = content_view.versions.last
      new_config.parent_config = self
      unless new_config.valid?
        new_config = child_configs.
            select { |config| config.content_view_version_id == new_config.content_view_version_id }.first
      end
      new_config
    end

    def activation_key
      @activation_key ||= find_activation_key
    end

    def template?
      content_view_version.nil?
    end

    private

    def environment
      if template?
        nil
      else
        @environment ||= content_view_version.environments.select(&:library?).first
      end
    end

    def find_activation_key
      raise "Cannot build from template Build Config" if template?
      key_name       = "#{activation_key_prefix}-#{content_view.name}-#{environment.name}"
      matching_keys  = ::Katello::ActivationKey.where(:name => key_name)
      activation_key = nil
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

    def prebuild_plugins(hostname, base_tag)
      plugins           = []
      register_commands = "yum localinstall -y http://#{hostname}/pub/katello-ca-consumer-latest.noarch.rpm && " +
          "subscription-manager register --org='#{organization.name}' --activationkey='#{activation_key.name}' || true && subscription-manager repos"
      plugins << plugin('change_from_in_dockerfile', 'base_tag' => "#{hostname}:5000/#{base_image.repository.relative_path}:#{base_image.name}") unless base_image.nil?
      plugins << plugin('run_cmd_in_container',
                        'cmd' => register_commands)
      plugins
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

  end
end
