object @resource
attributes :id, :git_url, :git_commit, :base_image_tag, :abstract, :activation_key_prefix, :content_view_id, :content_view_version_id, :repository_id, :base_image_id, :name, :automatic

child :content_view => :content_view do
    extends "katello/api/v2/content_views/show"
end

child :content_view_version => :content_view_version do
    extends "katello/api/v2/content_view_versions/show"
end

child :repository => :repository do
    extends "katello/api/v2/repositories/show"
end

child :base_image => :base_image do
    extends "katello/api/v2/docker_images/show"
end