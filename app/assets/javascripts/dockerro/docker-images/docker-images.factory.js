angular.module('Dockerro.docker-images').factory('DDockerImage',
['BastionResource',
function (BastionResource) {
  return BastionResource('/dockerro/api/v2/docker_images/:id/:action',
  {id: '@id'}, {
  })
}]
);
