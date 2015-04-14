object @docker_image

attributes :id, :image_id

child :available_updates => :available_updates do
    extends "dockerro/api/v2/packages/show"
end

child :inherited_available_updates => :inherited_available_updates do
    extends "dockerro/api/v2/packages/show"
end
