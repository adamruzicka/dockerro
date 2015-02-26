class AddGitUrlToContentView < ActiveRecord::Migration
  def up
    add_column :katello_content_views, :git_repository_url, :string
  end

  def down
    remove_column :katello_content_views, :git_repository_url
  end
end
