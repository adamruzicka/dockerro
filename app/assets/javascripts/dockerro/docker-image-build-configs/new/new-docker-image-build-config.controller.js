/**
 * @ngdoc object
 * @name  Dockerro.docker-image-build-configs.controller:NewDockerImageBuildConfigController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires FormUtils
 * @requires DockerImageBuildConfig
 * @requires DockerTag
 * @requires Organization
 * @requires CurrentOrganization
 * @requires ContentView
 * @requires Repository
 * @requires BastionResource
 *
 * @description
 *   Controls the creation of a docker image build config object.
 */
angular.module('Dockerro.docker-image-build-configs').controller('NewDockerImageBuildConfigController',
    ['$scope', '$q', '$location', 'FormUtils', 'DockerImageBuildConfig', 'DockerTag', 'Organization', 'CurrentOrganization', 'ContentView', 'Repository', 'BastionResource',
        function ($scope, $q, $location, FormUtils, DockerImageBuildConfig, DockerTag, Organization, CurrentOrganization, ContentView, Repository, BastionResource) {

            $scope.dockerImageBuildConfig = $scope.dockerImageBuildConfig || new DockerImageBuildConfig();
            $scope.panel = { 'loading': true };
            $scope.organization = CurrentOrganization;
            $scope.contentViews = [];
            $scope.pulpRepositories = [];
            $scope.baseImages = [];
            $scope.cvloaded = true;
            $scope.errorMessages = [];

            $scope.baseImageSelector = {
                environments: [],
                baseImagesLoaded: true,
                environments: Organization.readableEnvironments({id: CurrentOrganization})
            };

            $q.all([fetchPulpRepositories().$promise, fetchContentViews().$promise]).finally(function () {
                $scope.panel.loading = false;
            });

            function fetchPulpRepositories() {
                return Repository.queryUnpaged({'content_type': 'docker'}, function (repos) {
                    $scope.pulpRepositories = repos.results;
                });
            }

            function fetchContentViews() {
                $scope.cvloaded = false;
                return ContentView.queryUnpaged({ 'library': true }, function (response) {
                    $scope.contentViews = response.results;
                    $scope.cvloaded = true;
                });
            }

            $scope.$watch('baseImageSelector.environment', function(environment) {
                $scope.baseImagesLoaded = false;
                if(environment) {
                    DockerTag.queryUnpaged({
                        'environment_id': environment.id
                    }, function (tags) {
                        $scope.baseImages = tags.results;
                        $scope.baseImagesLoaded = true;
                    })
                } else {
                    $scope.baseImages = [];
                    $scope.baseImagesLoaded = true;
                }
            });

            $scope.save = function (dockerImageBuildConfig) {
                dockerImageBuildConfig.organization_id = CurrentOrganization;
                dockerImageBuildConfig.$save(success, error);
            };

            function success(response) {
                $scope.working = false;
                $scope.table.addRow(response);
                $scope.transitionTo('docker-image-build-configs.index');
            }

            function error(response) {
                $scope.working = false;
                $scope.errorMessages.push(response.data.displayMessage);
            }

        }]
);
