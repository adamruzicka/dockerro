/**
 * @ngdoc object
 * @name  Dockerro.docker-images.controller:DockerImageBulkActionUpdateController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires DockerImageBulkAction
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing bulk update functionality for docker images.
 */
angular.module('Dockerro.docker-images').controller('DockerImageBulkActionUpdateController',
    ['$scope', '$q', '$state', 'translate', 'DockerImageBulkAction', 'BastionResource', 'CurrentOrganization',
        function ($scope, $q, $state, translate, DockerImageBulkAction, BastionResource, CurrentOrganization) {
            $scope.computeResources = [];

            $scope.buildDockerImages = function () {
                $scope.actionParams.ids = $scope.getSelectedDockerImageIds();
                DockerImageBulkAction.bulkUpdate($scope.actionParams, function (task) {
                    $state.go('task', {taskId: task.id});
                });
            }
        }]
);
