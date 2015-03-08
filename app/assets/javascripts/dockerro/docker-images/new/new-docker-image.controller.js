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
 * @name  Bastion.docker-images.controller:NewDockerImageController
 *
 * @requires $scope
 * @requires $q
 * @requires FormUtils
 * @requires DockerImage
 * @requires Organization
 * @requires CurrentOrganization
 * @requires ContentView
 *
 * @description
 *   Controls the creation of an empty DockerImage object for use by sub-controllers.
 */
angular.module('Dockerro.docker-images').controller('NewDockerImageController',
    ['$scope', '$q', 'FormUtils', 'DDockerImage', 'DockerTag', 'Organization', 'CurrentOrganization', 'ContentView', 'Repository', 'BastionResource',
        function ($scope, $q, FormUtils, DockerImage, DockerTag, Organization, CurrentOrganization, ContentView, Repository, BastionResource) {

            $scope.successMessages = [];
            $scope.errorMessages = [];

            $scope.dockerImage = $scope.dockerImage || new DockerImage();
            $scope.panel = { 'loading': true };
            $scope.form = { 'environment': undefined };
            $scope.contentViews = [];
            $scope.dockerRegistries = [];
            $scope.pulpRepositories = [];
            $scope.computeResources = [];
            $scope.baseImages = [];
            $scope.cvloaded = true;
            $q.all([fetchPulpRepositories().$promise, fetchComputeResources().$promise, fetchBaseImages().$promise]).finally(function () {
                $scope.panel.loading = false;
            });

            function fetchPulpRepositories() {
                return Repository.queryUnpaged({'content_type': 'docker'}, function (repos) {
                    $scope.pulpRepositories = repos.results;
                });
            }

            function fetchComputeResources() {
                var ComputeResource = BastionResource('/api/v2/compute_resources/:id/:action',
                    {id: '@id', organizationId: CurrentOrganization}, {
                    });
                return ComputeResource.queryUnpaged({'search': 'docker'}, function (resources) {
                    $scope.computeResources = resources.results.filter(function(x) { if(x.provider == 'Docker') return x;});
                });
            }

            function fetchBaseImages() {
                return DockerTag.queryUnpaged(function (tags) {
                    $scope.baseImages = tags.results;
                })
            }

            $scope.environments = Organization.readableEnvironments({id: CurrentOrganization});

            $scope.$watch('form.environment', function (environment) {
                console.log("env changed");
                if (environment) {
                    $scope.cvloaded = false;
                    ContentView.queryUnpaged({ 'environment_id': environment.id }, function (response) {
                        $scope.contentViews = response.results;
                        $scope.cvloaded = true;
                    });
                } else {
                    $scope.contentViews = [];
                }
            });

            $scope.save = function (dockerImage) {
                dockerImage.environment_id = form.environment.id;
                console.log(dockerImage);
                console.log(dockerImage.docker_image);
                dockerImage.$save(success, error);
            };

            function success(response) {
                $scope.working = false
                $scope.transitionTo('task', {taskId: response.id});
            }

            function error(response) {
                $scope.working = false
                $scope.errorMessages.push(response.data.displayMessage);
            }

        }]
);
