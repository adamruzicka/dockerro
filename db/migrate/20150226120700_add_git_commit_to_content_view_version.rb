class AddGitCommitToContentViewVersion < ActiveRecord::Migration
  def up
    add_column :katello_content_view_versions, :git_commit, :string
  end

  def down
    remove_column :katello_content_view_versions, :git_commit
  end
end
