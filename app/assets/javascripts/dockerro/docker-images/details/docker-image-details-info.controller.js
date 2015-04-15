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
 * @name  Dockerro.docker-images.controller:DockerImageDetailsInfoController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires DockerImage
 * @requires MenuExpander
 *
 * @description
 *   Provides the functionality for the product details action pane.
 */
angular.module('Dockerro.docker-images').controller('DockerImageDetailsInfoController',
    ['$scope', '$state', '$q', 'translate', 'DDockerImage', 'MenuExpander', 'CurrentOrganization',
        function ($scope, $state, $q, translate, DockerImage, MenuExpander, CurrentOrganization) {

            $scope.successMessages = [];
            $scope.errorMessages = [];

            $scope.menuExpander = MenuExpander;
            $scope.panel = $scope.panel || {loading: false};

            $scope.dockerImage = $scope.dockerImage || DockerImage.get({id: $scope.$stateParams.dockerImageTagId, organization_id: CurrentOrganization}, function () {
                $scope.panel.loading = false;
            });

        }]
);
