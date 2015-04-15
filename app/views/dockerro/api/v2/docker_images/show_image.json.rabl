object @docker_image

attributes :id, :image_id

child :docker_image_build_config => :docker_image_build_config do
    attributes :id
end

child :available_updates => :available_updates do
    extends "dockerro/api/v2/packages/show"
end

child :inherited_available_updates => :inherited_available_updates do
    extends "dockerro/api/v2/packages/show"
end

child :packages => :packages do
  extends "dockerro/api/v2/packages/show"
end