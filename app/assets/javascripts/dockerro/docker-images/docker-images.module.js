angular.module('Dockerro.docker-images', [
    'ngResource',
    'Bastion.components',
    'ui.router',
    'Bastion'
]);
angular.module('Dockerro.docker-images').config(['$stateProvider', function ($stateProvider) {
    $stateProvider
        .state('docker-images', {
            url: '/docker_images',
            permission: 'view_images',
            templateUrl: 'dockerro/docker-images/views/dummy.html'
        })
        .state('new-docker-image', {
            url: '/docker_images/new',
            permission: 'view_images',
            controller: 'NewDockerImageController',
            templateUrl: 'dockerro/docker-images/new/views/docker-image-new.html'
        })
}]);
