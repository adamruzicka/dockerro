/**
 * Copyright 2014 Red Hat, Inc.
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
 * @name  Dockerro.docker-image-build-configs.controller:DockerImageBuildConfigsBulkActionController
 *
 * @requires $scope
 * @requires translate
 * @requires DockerImageBulkAction
 * @requires CurrentOrganization
 *
 * @description
 *   A controller for providing bulk action functionality to the docker image build configs page.
 */
angular.module('Dockerro.docker-image-build-configs').controller('DockerImageBuildConfigsBulkActionController',
    ['$scope', 'translate', 'DockerImageBulkAction', 'CurrentOrganization',
    function ($scope, translate, DockerImageBulkAction, CurrentOrganization) {

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.actionParams = {
            ids: [],
            'organization_id': CurrentOrganization
        };

        $scope.getSelectedDockerImageBuildConfigIds = function () {
            var rows = $scope.table.getSelected();
            return _.pluck(rows, 'id');
        };

    }]
);
