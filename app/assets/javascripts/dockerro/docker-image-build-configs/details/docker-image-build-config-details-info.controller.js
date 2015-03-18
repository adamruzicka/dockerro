/**
 * Copyright 2014 Red Hat, Inc.
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
 * @name  Dockerro.docker-image-build-configs.controller:DockerImageBuildConfigDetailsInfoController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires DockerImageBuildConfig
 * @requires MenuExpander
 *
 * @description
 *   Provides the functionality for the product details action pane.
 */
angular.module('Dockerro.docker-image-build-configs').controller('DockerImageBuildConfigDetailsInfoController',
    ['$scope', '$state', '$q', 'translate', 'DockerImageBuildConfig', 'MenuExpander', 'CurrentOrganization',
    function ($scope, $state, $q, translate, DockerImageBuildConfig, MenuExpander, CurrentOrganization) {

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.menuExpander = MenuExpander;
        $scope.panel = $scope.panel || {loading: false};

        $scope.dockerImageBuildConfig = $scope.dockerImageBuildConfig || DockerImageBuildConfig.get({id: $scope.$stateParams.dockerImageBuildConfigId, organization_id: CurrentOrganization}, function () {
            $scope.panel.loading = false;
        });

    }]
);
