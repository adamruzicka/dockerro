class CreateDockerroTables < ActiveRecord::Migration
  def up
    create_table 'dockerro_docker_image_build_configs', :force => true do |t|
      t.string  'git_url', :null => false
      t.string  'git_commit'
      t.string  'base_image_tag'
      t.boolean 'abstract', :null => false
      t.string  'activation_key_prefix', :default => 'dockerro'
      t.integer 'content_view_id', :null => false
      t.integer 'repository_id', :null => false
      t.integer 'organization_id', :null => false
      t.integer 'base_image_id'
      t.integer 'content_view_environment_id'
    end

    add_index :dockerro_docker_image_build_configs, :repository_id
  end

  def down
    drop_table 'dockerro_docker_image_build_configs'
  end
end
