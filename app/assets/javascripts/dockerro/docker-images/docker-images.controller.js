/**
 * @ngdoc object
 * @name  Dockerro.docker-images.controller:DockerImagesController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires DDockerImage
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to docker images for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Dockerro.docker-images').controller('DockerImagesController',
    ['$scope', '$location', 'translate', 'Nutupane', 'DDockerImage', 'CurrentOrganization',
    function ($scope, $location, translate, Nutupane, DDockerImage, CurrentOrganization) {

        var params = {
            'organization_id':  CurrentOrganization,
            'search':           $location.search().search || "",
            'sort_by':          'name',
            'sort_order':       'ASC',
            'paged':            true
        };

        $scope.dockerImageNutupane = new Nutupane(DDockerImage, params);
        $scope.dockerImageTable = $scope.dockerImageNutupane.table;
        $scope.removeRow = $scope.dockerImageNutupane.removeRow;
        $scope.dockerImageTable.refresh = $scope.dockerImageNutupane.refresh;

        $scope.table = $scope.dockerImageTable;

        $scope.table.closeItem = function () {
             $scope.transitionTo('docker-images.index');
        };

        $scope.showUpdateable = false;

        $scope.toggleUpdateable = function () {
            nutupane.table.params['restrict_updateable'] = $scope.showUpdateable;
            nutupane.refresh();
        };

    }]
);
