angular.module('Dockerro.docker-image-build-configs').factory('DockerImageBuildConfig',
['BastionResource',
function (BastionResource) {
  return BastionResource('/dockerro/api/v2/docker_image_build_configs/:id/:action',
  {id: '@id' }, {
  })
}]
);
