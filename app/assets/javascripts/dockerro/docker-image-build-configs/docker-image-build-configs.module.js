angular.module('Dockerro.docker-image-build-configs', [
    'ngResource',
    'Bastion.components',
    'ui.router',
    'Bastion'
]);

angular.module('Dockerro.docker-image-build-configs').config(['$stateProvider', function ($stateProvider) {
    $stateProvider
        .state('docker-image-build-configs', {
            abstract: true,
            controller: 'DockerImageBuildConfigsController',
            templateUrl: 'dockerro/docker-image-build-configs/views/docker-image-build-configs.html'
        })
        .state('docker-image-build-configs.index', {
            url: '/docker_image_build_configs',
            permission: 'view_docker_image_build_configs',
            views: {
                'table': {
                    templateUrl: 'dockerro/docker-image-build-configs/views/docker-image-build-configs-table-full.html'
                }
            }
        })
        .state('docker-image-build-configs.new', {
            url: '/docker_image_build_configs/new',
            permission: 'view_docker_image_build_configs',
            collapsed: true,
            views: {
                'table': {
                    templateUrl: 'dockerro/docker-image-build-configs/views/docker-image-build-configs-table-collapsed.html'
                },
                'action-panel': {
                    controller: 'NewDockerImageBuildConfigController',
                    templateUrl: 'dockerro/docker-image-build-configs/new/views/docker-image-build-config-new.html'
                }
            }
        })
        .state("docker-image-build-configs.details", {
            abstract: true,
            url: '/docker_image_build_configs/:dockerImageBuildConfigId',
            permission: 'view_docker_image_build_configs',
            collapsed: true,
            views: {
                'table': {
                    templateUrl: 'dockerro/docker-image-build-configs/views/docker-image-build-configs-table-collapsed.html'
                },
                'action-panel': {
                    controller: 'DockerImageBuildConfigDetailsController',
                    templateUrl: 'dockerro/docker-image-build-configs/details/views/docker-image-build-config-details.html'
                }
            }
        })
        .state('docker-image-build-configs.details.info', {
            url: '/info',
            permission: 'view_docker_image_build_configs',
            collapsed: true,
            controller: 'DockerImageBuildConfigDetailsInfoController',
            templateUrl: 'dockerro/docker-image-build-configs/details/views/docker-image-build-config-info.html'
        })
        .state("docker-image-build-configs.bulk-actions", {
            abstract: true,
            collapsed: true,
            views: {
                'table': {
                    templateUrl: 'dockerro/docker-image-build-configs/views/docker-image-build-configs-table-collapsed.html'
                },
                'action-panel': {
                    controller: 'DockerImageBuildConfigsBulkActionController',
                    templateUrl: 'dockerro/docker-image-build-configs/bulk/views/bulk-actions.html'
                }
            }
        })
        .state('docker-image-build-configs.bulk-actions.build', {
            url: '/docker_image_build_configs/bulk-actions/build',
            permission: 'sync_products',
            collapsed: true,
            controller: 'DockerImageBuildConfigsBulkActionBuildController',
            templateUrl: 'dockerro/docker-image-build-configs/bulk/views/bulk-actions-build.html'
        })
}]);
