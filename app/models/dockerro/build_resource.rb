#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Dockerro
  class BuildResource < ActiveRecord::Base
    include Taxonomix
    # include Encryptable
    include Authorizable
    include Parameterizable::ByIdName

    belongs_to :compute_resource,
               :class_name => "::ComputeResource"

    default_scope lambda {
      with_taxonomy_scope do
        order("dockerro_build_resources.name")
      end
    }

    def taxonomy_foreign_conditions
      { :compute_resource_id => compute_resource.id }
    end
  end
end
