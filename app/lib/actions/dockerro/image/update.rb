module Actions
  module Dockerro
    module Image
      class Update < Actions::EntryAction

        def plan(ids, compute_resource, hostname)
          skipped = []
          # Find dependencies among the images
          chain = ids.map { |id| ancestor_chain(id).invert.to_a }.flatten(1).uniq
          tree = subtree(chain)
          # Collect levels of equal depth from the tree
          # Select only the input ids
          levels = tree_levels(tree).map { |level| level.select { |id| ids.include? id } }.reject(&:empty?)
          sequence do
            # Plan bulk build for each level
            levels.each do |level|
              build_config_ids = ::Katello::DockerImage.where(:id => level).pluck(:docker_image_build_config_id)
              require 'pry'; binding.pry
              fail "Cannot update images without Docker Image Build Config" if level.zip(build_config_ids).any? { |_, v| v.nil? }
              build_configs = ::Dockerro::DockerImageBuildConfig.where(:id => build_config_ids.compact)
              fail "Cannot update images with base image in non-library environment" if any_in_non_library?(build_configs, ids)
              plan_action(::Actions::BulkAction,
                          ::Actions::Dockerro::DockerImageBuildConfig::Build,
                          build_configs,
                          compute_resource.id,
                          hostname) unless build_configs.empty?
            end
          end
          skipped
        end

        def humanized_name
          _("Update")
        end

        private

        def any_in_non_library?(build_configs, ids)
          non_library = build_configs.select { |config| !config.base_image_environment.library? }
          non_library.any? { |config| ids.include? config.base_image.id }
        end

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
