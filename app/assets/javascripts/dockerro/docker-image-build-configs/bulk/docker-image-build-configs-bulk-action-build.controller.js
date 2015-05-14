/**
 * @ngdoc object
 * @name  Dockerro.docker-image-build-configs.controller:DockerImageBuildConfigsBulkActionBuildController
 *
 * @requires $scope
 * @requires $q
 * @requires $state
 * @requires translate
 * @requires DockerImageBulkAction
 * @requires BastionResource
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing bulk build functionality for docker image build configs.
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

             var success = function (task) {
                 $state.go('task', {taskId: task.id});
             };

             var error = function(err) {
                 $scope.errorMessages.push(err.data.displayMessage);
             };

             DockerImageBulkAction.bulkBuild($scope.actionParams, success, error);
         }
    }]
);
