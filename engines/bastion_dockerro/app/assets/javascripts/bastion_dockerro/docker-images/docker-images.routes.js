(function () {
    'use strict';

    /**
     * @ngdoc config
     * @name  Bastion.docker-images.config
     *
     * @description
     *   Defines the routes for docker-images
     */
    function DockerImageRoutes($stateProvider) {
        $stateProvider.state('docker-images.index', {
            url: '/dockerro/docker-images',
            views: {
                'table': {
//                    controller: 'DockerImageTableController',
                    templateUrl: 'docker-images/views/docker-images.html'
                }
            }
        });
    }

    angular
        .module('Bastion.docker-images')
        .config(DockerImageRoutes);

    DockerImageRoutes.$inject = ['$stateProvider'];

})();