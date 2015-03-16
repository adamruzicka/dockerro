class AddBuildConfigsToDockerImages < ActiveRecord::Migration
  def up
    add_column :katello_docker_images, :docker_build_config_id, :int
    add_column :katello_docker_images, :base_image_id, :int
  end

  def down
    remove_column :katello_docker_images, :docker_build_config_id
    remove_column :katello_docker_images, :base_image_id
  end
end
