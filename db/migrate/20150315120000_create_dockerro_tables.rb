class CreateDockerroTables < ActiveRecord::Migration
  def up
    create_table 'dockerro_docker_image_build_configs', :force => true do |t|
      t.string  'name'
      t.string  'tag'
      t.string  'git_url', :null => false
      t.string  'git_commit'
      t.integer 'base_image_id'
      t.integer 'activation_key_id', :null => false
      t.integer 'content_view_id', :null => false
      t.integer 'repository_id', :null => false
      t.integer 'organization_id', :null => false
    end
  end

  def down
    drop_table 'dockerro_docker_image_build_configs'
  end
end
