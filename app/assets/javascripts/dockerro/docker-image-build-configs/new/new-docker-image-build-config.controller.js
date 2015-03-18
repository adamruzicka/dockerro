/**
 * Copyright 2013-2014 Red Hat, Inc.
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
 * @name  Dockerro.docker-image-build-configs.controller:NewDockerImageBuildConfigController
 *
 * @requires $scope
 * @requires $q
 * @requires FormUtils
 * @requires DockerImageBuildConfig
 * @requires DockerTag
 * @requires Organization
 * @requires CurrentOrganization
 * @requires ContentView
 * @requires Repository
 *
 * @description
 *   Controls the creation of an empty DockerImage object for use by sub-controllers.
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
            $q.all([fetchPulpRepositories().$promise, fetchContentViews().$promise, fetchBaseImages().$promise]).finally(function () {
                $scope.panel.loading = false;
            });

            function fetchPulpRepositories() {
                return Repository.queryUnpaged({'content_type': 'docker'}, function (repos) {
                    $scope.pulpRepositories = repos.results;
                });
            }

            function fetchBaseImages() {
                return DockerTag.queryUnpaged({ 'organization_id': CurrentOrganization }, function (tags) {
                    $scope.baseImages = tags.results;
                })
            }

            function fetchContentViews() {
                $scope.cvloaded = false;
                return ContentView.queryUnpaged({ 'library': true }, function (response) {
                    $scope.contentViews = response.results;
                    $scope.cvloaded = true;
                });
            }

            $scope.save = function (dockerImageBuildConfig) {
                dockerImageBuildConfig.organization_id = CurrentOrganization;
                dockerImageBuildConfig.$save(success, error);
            };

            function success(response) {
                $scope.working = false;
                $scope.transitionTo('docker-image-build-configs.index');
            }

            function error(response) {
                $scope.working = false
                $scope.errorMessages.push(response.data.displayMessage);
            }

        }]
);
