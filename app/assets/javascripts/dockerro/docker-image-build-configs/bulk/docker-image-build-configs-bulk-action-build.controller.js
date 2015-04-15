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
 * @name  Bastion.products.controller:ProductsBulkActionSyncController
 *
 * @requires $scope
 * @requires translate
 * @requires ProductBulkAction
 *
 * @description
 *   A controller for providing bulk sync functionality for products..
 */
angular.module('Dockerro.docker-image-build-configs').controller('DockerImageBuildConfigsBulkActionBuildController',
    ['$scope', '$q', '$state', 'translate', 'DockerImageBulkAction', 'BastionResource', 'CurrentOrganization',
     function ($scope, $q, $state, translate, DockerImageBulkAction, BastionResource, CurrentOrganization) {
         $scope.computeResources = [];

         $q.all([fetchComputeResources().$promise]).finally(function () {
             $scope.panel.loading = false;
         });

         function fetchComputeResources() {
             var ComputeResource = BastionResource('/api/v2/compute_resources/:id/:action',
                 {id: '@id', organizationId: CurrentOrganization}, {
                 });
             return ComputeResource.queryUnpaged({'search': 'docker', 'organization_id': CurrentOrganization }, function (resources) {
                 $scope.computeResources = resources.results.filter(function(x) { if(x.provider == 'Docker') return x;});
             });
         }

         $scope.buildDockerImageBuildConfigs = function () {
             $scope.actionParams.ids = $scope.getSelectedDockerImageBuildConfigIds();
             $scope.actionParams.compute_resource_id = $scope.compute_resource.id;

             DockerImageBulkAction.bulkBuild($scope.actionParams, function (task) {
                 $state.go('task', {taskId: task.id});
             });
         }
    }]
);
