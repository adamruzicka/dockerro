/**
 * @ngdoc object
 * @name  Dockerro.docker-images.controller:DockerImageBulkActionController
 *
 * @requires $scope
 * @requires translate
 * @requires DockerImageBulkAction
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing bulk action functionality to the docker images page.
 */
angular.module('Dockerro.docker-images').controller('DockerImageBulkActionController',
    ['$scope', 'translate', 'DockerImageBulkAction', 'CurrentOrganization',
        function ($scope, translate, DockerImageBulkAction, CurrentOrganization) {

            $scope.successMessages = [];
            $scope.errorMessages = [];

            $scope.removeProducts = {
                confirm: false,
                workingMode: false
            };

            $scope.actionParams = {
                ids: [],
                'organization_id': CurrentOrganization
            };

            $scope.getSelectedDockerImageIds = function () {
                var rows = $scope.table.getSelected();
                return _.pluck(rows, 'id');
            };

        }]
);
