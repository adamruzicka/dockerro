/**
 * @ngdoc object
 * @name  Dockerro.docker-images.controller:DockerImageDetailsInfoController
 *
 * @requires $scope
 * @requires @state
 * @requires $q
 * @requires translate
 * @requires DDockerImage
 * @requires MenuExpander
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the docker images details action pane.
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
