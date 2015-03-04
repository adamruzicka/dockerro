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
    ['$scope', '$q', 'FormUtils', 'DDockerImage', 'Organization', 'CurrentOrganization', 'ContentView', 'Repository', 'BastionResource',
        function ($scope, $q, FormUtils, DockerImage, Organization, CurrentOrganization, ContentView, Repository, BastionResource) {

            $scope.successMessages = [];
            $scope.errorMessages = [];

            resetForm();

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

            $scope.environments = Organization.readableEnvironments({id: CurrentOrganization});

            $scope.$watch('dockerImage.environment', function (environment) {
                if (environment) {
                    $scope.editContentView = true;
                    ContentView.queryUnpaged({ 'environment_id': environment.id }, function (response) {
                        $scope.contentViews = response.results;
                    });
                }
            });

            $scope.save = function (dockerImage) {
                dockerImage.$save(success, error);
            };

            function resetForm() {
                $scope.dockerImage = $scope.dockerImage || new DockerImage();
                $scope.panel = { 'loading': true }
                $scope.contentViews = [];
                $scope.editContentView = false;
                $scope.dockerRegistries = [];
                $scope.pulpRepositories = [];
                $scope.computeResources = [];
                $q.all([fetchPulpRepositories().$promise, fetchComputeResources().$promise]).finally(function () {
                    $scope.panel.loading = false;
                });
            }

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
