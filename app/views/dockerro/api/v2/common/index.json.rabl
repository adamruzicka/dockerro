collection @collection
extends "katello/api/v2/common/metadata"
child @collection[:results] => :results do
    extends("dockerro/api/v2/%s/show" % controller_name)
end