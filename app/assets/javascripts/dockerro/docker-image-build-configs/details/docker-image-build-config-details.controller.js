/**
 * @ngdoc object
 * @name  Dockerro.docker-image-build-configs.controller:DockerImageBuildConfigDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires DockerImageBuildConfig
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the docker image build config details action pane.
 */
angular.module('Dockerro.docker-image-build-configs').controller('DockerImageBuildConfigDetailsController',
    ['$scope', '$state', 'DockerImageBuildConfig', 'CurrentOrganization', function ($scope, $state, DockerImageBuildConfig, CurrentOrganization) {
        $scope.successMessages = [];
        $scope.errorMessages = [];

        if ($scope.dockerImageBuildConfig) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.dockerImageBuildConfig = DockerImageBuildConfig.get({id: $scope.$stateParams.dockerImageBuildConfigId, organization_id: CurrentOrganization}, function () {
            $scope.panel.loading = false;
        });

        $scope.build = function(buildConfig) {
            $scope.actionParams = {
                id: buildConfig.id,
                organization_id: CurrentOrganization
            };
            DockerImageBuildConfig.build($scope.actionParams, function (task) {
                $state.go('task', {taskId: task.id});
            });
        };

        $scope.removeDockerImageBuildConfig = function (buildConfig) {
            var id = buildConfig.id;

            buildConfig.$delete(function (data) {
                $scope.removeRow(id);
                $scope.$emit('dockerImageBuildConfigDelete', data.id);
                $scope.transitionTo('docker-image-build-configs.index');
            });
        };
    }]
);
