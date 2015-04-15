object @docker_image

attributes :id

node(:name) { |tag| "#{tag.repository.docker_upstream_name || tag.repository.label}:#{tag.name}" }
node(:based_on) do |tag|
  if tag.docker_image.base_image
    tags = tag.docker_image.base_image.docker_tags
    tags.select! { |t| t.name == tag.docker_image.docker_image_build_config.base_image_tag } if tag.docker_image.docker_image_build_config
    "#{tags.first.repository}:#{tags.first.name}"
  else
    "-"
  end
end

child :docker_image => :docker_image do
  extends "dockerro/api/v2/docker_images/show_image"
end
