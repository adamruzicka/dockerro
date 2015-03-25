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

module Actions
  module Dockerro
    module Image
      class Save < Actions::EntryAction
        output_format do
          :path
        end

        input_format do
          :image_name
          :url
        end

        def run
          tmp = Tempfile.new 'dockerro.'
          tmp_path = tmp.path
          tmp.close true
          connection = ::Docker::Connection.new(input[:url], {})
          ::Docker::Image.save([input[:image_name]], tmp_path, connection)
          output[:path] = tmp_path
        end

        def humanized_name
          _("Save")
        end
      end
    end
  end
end
