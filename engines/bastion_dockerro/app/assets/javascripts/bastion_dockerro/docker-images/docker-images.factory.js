(function () {
    'use strict';

    /**
     * @ngdoc config
     * @name  Bastion.docker-images.factory:DockerImage
     *
     * @description
     *   Defines the API endpoint for Content Host
     */
    function DockerImage(BastionResource) {
        return BastionResource('/dockerro/api/v2/docker-images/:id/:action',
            {id: '@uuid'})
//            {
////                update: {method: 'PUT'},
////                query: {method: 'GET', isArray: false},
////                releaseVersions: {method: 'GET', params: {action: 'releases'}
//                : {
//                }
//            });
    }

    angular
        .module('Bastion.docker-images')
        .factory('DockerImage', DockerImage);

    DockerImage.$inject = ['BastionResource'];

})();