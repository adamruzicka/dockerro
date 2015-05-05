/**
 * Copyright 2013-2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

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
