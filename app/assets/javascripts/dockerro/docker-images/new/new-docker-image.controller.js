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
    ['$scope', '$q', '$location', 'FormUtils', 'DDockerImage', 'DockerTag', 'Organization', 'CurrentOrganization', 'ActivationKey', 'ContentView', 'Repository', 'BastionResource',
        function ($scope, $q, $location, FormUtils, DockerImage, DockerTag, Organization, CurrentOrganization, ActivationKey, ContentView, Repository, BastionResource) {

            $scope.successMessages = [];
            $scope.errorMessages = [];

            $scope.baseImageSelector = {
                environments: [],
                baseImagesLoaded: true,
                environments: Organization.readableEnvironments({id: CurrentOrganization})
            };
            $scope.dockerImage = $scope.dockerImage || new DockerImage();
            $scope.panel = { 'loading': true };
            $scope.form = { 'environment': undefined };
            $scope.contentViews = [];
            $scope.dockerRegistries = [];
            $scope.pulpRepositories = [];
            $scope.computeResources = [];
            $scope.baseImages = [];
            $scope.cvloaded = true;
            $scope.dockerImage.default_key = true;
            $q.all([fetchPulpRepositories().$promise, fetchComputeResources().$promise]).finally(function () {
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
                return ComputeResource.queryUnpaged({'search': 'docker', 'organization_id': CurrentOrganization }, function (resources) {
                    $scope.computeResources = resources.results.filter(function(x) { if(x.provider == 'Docker') return x;});
                });
            }

            $scope.environments = Organization.readableEnvironments({id: CurrentOrganization});

            //$scope.$watch('dockerImage.default_key', function(default_key) {
            //    if(!default_key) {
            //        $scope.keyloaded = false;
            //        ActivationKey.queryUnpaged({ 'organization_id': CurrentOrganization }, function(response) {
            //            $scope.activationKeys = response.results;
            //            $scope.keyloaded = true;
            //        })
            //    } else {
            //        $scope.activationKeys = [];
            //    }
            //})

            $scope.$watch('dockerImage.environment', function (environment) {
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

            $scope.$watch('baseImageSelector.environment', function(environment) {
                $scope.baseImages = [];
                if(environment) {
                    $scope.baseImagesLoaded = false;
                    DockerTag.queryUnpaged({
                        // 'organization_id': CurrentOrganization,
                        'environment_id': environment.id
                    }, function (tags) {
                        $scope.baseImages = tags.results;
                        $scope.baseImagesLoaded = true;
                    })
                }
            });

            $scope.save = function (dockerImage) {
                dockerImage.katello_hostname = $location.host();
                if(dockerImage.tag === undefined) { dockerImage.tag = "latest"; }
                dockerImage.organization_id = CurrentOrganization;
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
