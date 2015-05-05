/**
 * @ngdoc service
 * @name  Dockerro.docker-images.factory:DDockerImage
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for Dockerro docker images.
 */
angular.module('Dockerro.docker-images').factory('DDockerImage',
['BastionResource',
function (BastionResource) {
  return BastionResource('/dockerro/api/v2/docker_images/:id/:action',
  {id: '@id'}, {
  })
}]
);

/**
 * @ngdoc service
 * @name  Dockerro.docker-images.factory:DockerImageBulkAction
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for bulk actions on docker images.
 */
angular.module('Dockerro.docker-images').factory('DockerImageBulkAction',
    ['BastionResource',
        function (BastionResource) {
            return BastionResource('/dockerro/api/v2/docker_images/:action',
                {}, {
                    bulkBuild: {method: 'POST', params: {action: 'bulk_build'}},
                    bulkUpdate: {method: 'POST', params: {action: 'bulk_update'}}
                })
        }]
);
