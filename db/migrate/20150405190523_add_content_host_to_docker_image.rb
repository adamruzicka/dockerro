class AddContentHostToDockerImage < ActiveRecord::Migration
  def up
    add_column :katello_docker_images, :content_host_id, :int
  end

  def down
    remove_column :katello_docker_images, :content_host_id
  end
end
