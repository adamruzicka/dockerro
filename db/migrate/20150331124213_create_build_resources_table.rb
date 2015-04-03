class CreateBuildResourcesTable  < ActiveRecord::Migration
  def up
    create_table 'dockerro_build_resources', :force => true do |t|
      t.string  'name'
      t.integer 'compute_resource_id', :null => false
    end
  end

  def down
    drop_table 'dockerro_build_resources'
  end
end
