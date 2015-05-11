module Dockerro
  module Concerns
    module DockerImageExtensions
      extend ActiveSupport::Concern

      included do

        belongs_to :docker_image_build_config,
                :class_name => "::Dockerro::DockerImageBuildConfig",
                :inverse_of => :base_image

        belongs_to :base_image,
                   :class_name => "::Katello::DockerImage",
                   :inverse_of => :successor_images

        has_many :successor_images,
                 :class_name => "::Katello::DockerImage",
                 :inverse_of => :base_image

        belongs_to :content_host,
                   :class_name => "::Katello::System",
                   :inverse_of => :docker_image


        def all_available_updates
          available_updates + inherited_available_updates
        end

        def available_updates
          @available_updates ||= calculate_available_updates
        end

        def inherited_available_updates
          @inherited_available_updates ||= calculate_parent_image_available_updates
        end

        def packages
          content_host.nil? ? [] : content_host.simple_packages
        end

        private

        def calculate_available_updates
          return [] if content_host.nil?
          # Get packages from content host and from content view version
          # In format { 'package_name' => package }
          fmt = lambda { |acc, cur| acc.update cur.name => cur }
          present_packages = packages.reduce({}, &fmt)
          available = content_host.activation_keys.map do |key|
            key.content_view.version(key.environment).packages
          end.flatten.reduce({}, &fmt)
          # Select present_packages which have different version &| release than the ones from the content view version
          with_updates = available.select do |name, pkg|
            present_packages[name] &&
                (present_packages[name].version != pkg.version ||
                    present_packages[name].release != pkg.release)
          end.values
          with_updates - inherited_available_updates
        end

        def calculate_parent_image_available_updates
          return [] if base_image.nil? || base_image.content_host.nil?
          base_image.available_updates
        end

      end
    end
  end
end

