/**
 * @ngdoc object
 * @name  Dockerro.docker-images.controller:DockerImageDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires DDockerImage
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
