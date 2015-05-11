/**
 * @ngdoc object
 * @name  Dockerro.docker-image-build-configs.controller:DockerImageBuildConfigsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires DockerImageBuildConfig
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to docker image build configs for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Dockerro.docker-image-build-configs').controller('DockerImageBuildConfigsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'DockerImageBuildConfig', 'CurrentOrganization',
    function ($scope, $location, translate, Nutupane, DockerImageBuildConfig, CurrentOrganization) {

        var params = {
            'organization_id':  CurrentOrganization,
            'search':           $location.search().search || "",
            'sort_by':          'name',
            'sort_order':       'ASC',
            'paged':            true,
            'with_versions':    false
        };

        $scope.dockerImageBuildConfigNutupane = new Nutupane(DockerImageBuildConfig, params);
        $scope.dockerImageBuildConfigTable = $scope.dockerImageBuildConfigNutupane.table;
        $scope.removeRow = $scope.dockerImageBuildConfigNutupane.removeRow;
        $scope.dockerImageBuildConfigTable.refresh = $scope.dockerImageBuildConfigNutupane.refresh;

        $scope.table = $scope.dockerImageBuildConfigTable;

        $scope.table.closeItem = function () {
            $scope.transitionTo('docker-image-build-configs.index');
        };

    }]
);
