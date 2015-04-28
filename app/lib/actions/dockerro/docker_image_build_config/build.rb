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

module Actions
  module Dockerro
    module DockerImageBuildConfig
      class Build < Actions::EntryAction

        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(build_config, compute_resource_id, hostname)
          compute_resource = ::ComputeResource.find(compute_resource_id)
          config           = build_config
          sequence do
            if config.template?
              config         = build_config.clone_for_latest_version
              created_config = plan_action(::Actions::Dockerro::DockerImageBuildConfig::Create, config) if config.new_record?
            end
            config.reload
            action_subject(config)
            plan_action ::Actions::Dockerro::Image::Create,
                        config,
                        # TODO: vvvvvv this finds bad tag vvvvvv
                        # config.base_image.docker_tags.where(:name => config.base_image_tag).first,
                        # TODO: ^^^^^^                    ^^^^^^
                        config.latest_base_tag,
                        compute_resource,
                        hostname

            config_id = created_config.nil? ? config.id : created_config.output[:build_config_id]
            plan_action ::Actions::Dockerro::DockerImageBuildConfig::AssociateImage,
                        :build_config_id => config_id

          end
        end

        def run
          output = input
        end

        def humanized_name
          _("Build Build Config")
        end

      end
    end
  end
end
