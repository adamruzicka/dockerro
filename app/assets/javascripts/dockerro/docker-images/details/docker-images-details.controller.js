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
 * @name  Dockerro.docker-images.controller:DockerImageDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires DockerImage
 *
 * @description
 *   Provides the functionality for the docker image build config details action pane.
 */
angular.module('Dockerro.docker-images').controller('DockerImageDetailsController',
    ['$scope', '$state', 'DDockerImage', 'CurrentOrganization', function ($scope, $state, DockerImage, CurrentOrganization) {
        $scope.successMessages = [];
        $scope.errorMessages = [];

        if ($scope.dockerImage) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.dockerImage = DockerImage.get({id: $scope.$stateParams.dockerImageTagId}, function () {
            $scope.panel.loading = false;
        });

        $scope.removeDockerImage = function (dockerImage) {
            var id = dockerImage.id;

            dockerImage.$delete(function (data) {
                $scope.removeRow(id);
                $scope.$emit('dockerImageDelete', data.id);
                $scope.transitionTo('docker-images.index');
            });
        };
    }]
);
