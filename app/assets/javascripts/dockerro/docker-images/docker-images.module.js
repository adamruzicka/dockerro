angular.module('Dockerro.docker-images', [
    'ngResource',
    'Bastion.components',
    'ui.router',
    'Bastion'
]);

angular.module('Dockerro.docker-images').config(['$stateProvider', function ($stateProvider) {
    $stateProvider
        .state('docker-images', {
            abstract: true,
            controller: 'DockerImagesController',
            templateUrl: 'dockerro/docker-images/views/docker-images.html'
        })
        .state('docker-images.index', {
            url: '/docker_images',
            permission: 'view_docker_images',
            views: {
                'table': {
                    templateUrl: 'dockerro/docker-images/views/docker-images-table-full.html'
                }
            }
        })
        .state('docker-images.new', {
            url: '/docker_images/new',
            permission: 'create_docker_images',
            collapsed: true,
            views: {
                'table': {
                    templateUrl: 'dockerro/docker-images/views/docker-images-table-collapsed.html'
                },
                'action-panel': {
                    controller: 'NewDockerImageController',
                    templateUrl: 'dockerro/docker-images/new/views/docker-image-new.html'
                }
            }
        })
        .state('docker-images.details', {
            abstract: true,
            url: '/docker_images/:dockerImageTagId',
            collapsed: true,
            views: {
                'table': {
                    templateUrl: 'dockerro/docker-images/views/docker-images-table-collapsed.html'
                },
                'action-panel': {
                    controller: 'DockerImageDetailsController',
                    templateUrl: 'dockerro/docker-images/details/views/docker-image-details.html'
                }
            }
        })
        .state('docker-images.details.info', {
            url: '/info',
            permission: 'view_docker_images',
            collapsed: true,
            controller: 'DockerImageDetailsInfoController',
            templateUrl: 'dockerro/docker-images/details/views/docker-image-info.html'
        })
        .state('docker-images.bulk-actions', {
            abstract: true,
            collapsed: true,
            views: {
                'table': {
                    templateUrl: 'dockerro/docker-images/views/docker-images-table-collapsed.html'
                },
                'action-panel': {
                    controller: 'DockerImageBulkActionController',
                    templateUrl: 'dockerro/docker-images/bulk/views/bulk-actions.html'
                }
            }

        })
        .state('docker-images.bulk-actions.update', {
            url: '/docker_images/bulk-actions/update',
            permission: 'create_docker_images',
            collapsed: true,
            controller: 'DockerImageBulkActionUpdateController',
            templateUrl: 'dockerro/docker-images/bulk/views/bulk-actions-update.html'
        });
}]);
