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
