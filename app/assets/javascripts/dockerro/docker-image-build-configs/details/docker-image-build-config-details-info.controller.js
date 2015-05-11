/**
 * @ngdoc object
 * @name  Dockerro.docker-image-build-configs.controller:DockerImageBuildConfigDetailsInfoController
 *
 * @requires $scope
 * @requires $state
 * @requires $q
 * @requires translate
 * @requires DockerImageBuildConfig
 * @requires MenuExpander
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the docker image build config details action pane.
 */
angular.module('Dockerro.docker-image-build-configs').controller('DockerImageBuildConfigDetailsInfoController',
    ['$scope', '$state', '$q', 'translate', 'DockerImageBuildConfig', 'MenuExpander', 'CurrentOrganization',
    function ($scope, $state, $q, translate, DockerImageBuildConfig, MenuExpander, CurrentOrganization) {

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.menuExpander = MenuExpander;
        $scope.panel = $scope.panel || {loading: false};

        $scope.dockerImageBuildConfig = $scope.dockerImageBuildConfig || DockerImageBuildConfig.get({id: $scope.$stateParams.dockerImageBuildConfigId, organization_id: CurrentOrganization}, function () {
            $scope.panel.loading = false;
        });

    }]
);
