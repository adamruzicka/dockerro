/**
 * @ngdoc object
 * @name  Dockerro.docker-image-build-configs.controller:DockerImageBuildConfigsBulkActionController
 *
 * @requires $scope
 * @requires translate
 * @requires DockerImageBulkAction
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing bulk action functionality to the docker image build configs page.
 */
angular.module('Dockerro.docker-image-build-configs').controller('DockerImageBuildConfigsBulkActionController',
    ['$scope', 'translate', 'DockerImageBulkAction', 'CurrentOrganization',
    function ($scope, translate, DockerImageBulkAction, CurrentOrganization) {

        $scope.actionParams = {
            ids: [],
            'organization_id': CurrentOrganization
        };

        $scope.getSelectedDockerImageBuildConfigIds = function () {
            var rows = $scope.table.getSelected();
            return _.pluck(rows, 'id');
        };

    }]
);
