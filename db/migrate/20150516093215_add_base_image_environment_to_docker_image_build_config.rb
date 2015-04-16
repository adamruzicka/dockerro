class AddBaseImageEnvironmentToDockerImageBuildConfig < ActiveRecord::Migration
  def up
    add_column :dockerro_docker_image_build_configs, :base_image_environment_id, :int
    add_column :dockerro_docker_image_build_configs, :base_image_content_view_id, :int
  end

  def down
    remove_column :dockerro_docker_image_build_configs, :base_image_environment_id
    remove_column :dockerro_docker_image_build_configs, :base_image_content_view_id
    remove_column :dockerro_docker_image_build_configs, :base_image_full_name
  end
end
