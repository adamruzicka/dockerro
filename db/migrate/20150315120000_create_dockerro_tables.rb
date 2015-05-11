class CreateDockerroTables < ActiveRecord::Migration
  def up
    create_table 'dockerro_docker_image_build_configs', :force => true do |t|
      t.string  'git_url', :null => false
      t.string  'git_commit'
      t.string  'base_image_full_name'
      t.string  'activation_key_prefix', :default => 'dockerro'
      t.boolean 'automatic', :default => false

      t.integer 'base_image_id'
      t.integer 'content_view_id', :null => false
      t.integer 'content_view_version_id'
      t.integer 'repository_id', :null => false
      t.integer 'parent_config_id'
    end

    add_index :dockerro_docker_image_build_configs, [:repository_id, :content_view_id, :content_view_version_id],
              :unique => true,
              :name => :index_dockerro_docker_image_build_config_unique
  end

  def down
    drop_table 'dockerro_docker_image_build_configs'
  end
end
