object @docker_image

attributes :id, :image_id, :content_host_id

child :docker_image_build_config => :docker_image_build_config do
    attributes :id, :name
end

child :content_host => :content_host do
  extends "katello/api/v2/systems/show"
end

node :errata_counts do |docker_image|
  erratas = docker_image.content_host.nil? ? ::Katello::Erratum.limit(0) : docker_image.content_host.installable_errata
  partial('katello/api/v2/errata/counts', :object => Katello::RelationPresenter.new(erratas))
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