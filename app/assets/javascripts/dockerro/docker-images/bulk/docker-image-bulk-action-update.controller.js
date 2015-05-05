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
// TODO: ngdoc
/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductsBulkActionSyncController
 *
 * @requires $scope
 * @requires translate
 * @requires ProductBulkAction
 *
 * @description
 *   A controller for providing bulk sync functionality for products..
 */
angular.module('Dockerro.docker-images').controller('DockerImageBulkActionUpdateController',
    ['$scope', '$q', '$state', 'translate', 'DockerImageBulkAction', 'BastionResource', 'CurrentOrganization',
        function ($scope, $q, $state, translate, DockerImageBulkAction, BastionResource, CurrentOrganization) {
            $scope.computeResources = [];

            //$q.all([fetchComputeResources().$promise]).finally(function () {
            //    $scope.panel.loading = false;
            //});

            $scope.buildDockerImages = function () {
                $scope.actionParams.ids = $scope.getSelectedDockerImageIds();
                // $scope.actionParams.compute_resource_id = $scope.compute_resource.id;

                DockerImageBulkAction.bulkUpdate($scope.actionParams, function (task) {
                    $state.go('task', {taskId: task.id});
                });
            }
        }]
);
