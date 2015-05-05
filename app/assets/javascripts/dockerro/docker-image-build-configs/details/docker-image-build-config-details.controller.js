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
 * @name  Dockerro.docker-image-build-configs.controller:DockerImageBuildConfigDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires DockerImageBuildConfig
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
