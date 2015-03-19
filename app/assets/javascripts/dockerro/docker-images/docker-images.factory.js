/**
 * @ngdoc service
 * @name  Bastion.products.factory:ProductBulkAction
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for bulk actions on products.
 */
angular.module('Dockerro.docker-images').factory('DDockerImage',
['BastionResource',
function (BastionResource) {
  return BastionResource('/dockerro/api/v2/docker_images/:id/:action',
  {id: '@id'}, {
  })
}]
);

