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
    module Image
      class Update < Actions::EntryAction

        def plan(ids, compute_resource, hostname)
          # Find dependencies among the images
          chain = ids.map { |id| ancestor_chain(id).invert.to_a }.flatten(1).uniq
          tree = subtree(chain)
          # Collect levels of equal depth from the tree
          # Select only the input ids
          levels = tree_levels(tree).map { |level| level.select { |id| ids.include? id } }
          sequence do
            # Plan bulk build for each level
            levels.each do |level|
              build_config_ids = ::Katello::DockerImage.where(:id => level).pluck(:docker_image_build_config_id)
              build_configs = build_config_ids.map { |id| ::Dockerro::DockerImageBuildConfig.find(id) }
              plan_action(::Actions::BulkAction,
                          ::Actions::Dockerro::DockerImageBuildConfig::Build,
                          build_configs,
                          compute_resource.id,
                          hostname)
            end
          end

        end

        def humanized_name
          _("Update")
        end

        private

        def ancestor_chain(id)
          @ids ||= ::Katello::DockerImage.pluck(:id)
          @parent_ids ||= ::Katello::DockerImage.pluck(:base_image_id)
          # Create a hash { id => parent_id }
          @parent_hash ||= Hash[*@ids.zip(@parent_ids).flatten]
          chain = { id => @parent_hash[id] }
          chain.update ancestor_chain(@parent_hash[id]) if @parent_hash[id] 
          chain
        end

        def tree_levels(tree)
          level(tree, 0, {}).values.reverse
        end

        def level(tree, level, result)
          sub = tree.keys.select{|k| tree[k] != {}}.map { |k| level(tree[k], level + 1, result) }
          if result[level].is_a?(Array)
            result.update level => result[level] + tree.keys
          else
            result.update level => tree.keys
          end
        end

        # zipped = [prior, current]
        # key = prior
        def subtree(chain, key = nil)
          stree = {}
          chain.select { |k, _| k == key }.each { |_, value| stree.update subtree(chain, value) }
          { key => stree }
        end

      end
    end
  end
end
