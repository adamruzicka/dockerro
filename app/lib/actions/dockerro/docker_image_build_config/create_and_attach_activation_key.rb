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
    module DockerImageBuildConfig
      class CreateAndAttachActivationKey < ::Actions::EntryAction
        include Dynflow::Action::WithSubPlans

        middleware.use Actions::Middleware::KeepCurrentUser

        def create_sub_plans
          activation_key = ::Katello::ActivationKey.find(input[:activation_key_id])
          trigger(::Actions::Katello::ActivationKey::Create, activation_key)
        end

        def plan(activation_key)
          activation_key.save!
          activation_key.reload
          plan_self :activation_key_id => activation_key.id
        end

        def on_finish
          activation_key = ::Katello::ActivationKey.find(input[:activation_key_id])
          activation_key.available_subscriptions.each { |subscription| activation_key.subscribe subscription.cp_id }
        end

        def humanized_name
          _("Create and attach activation key")
        end

      end
    end
  end
end
