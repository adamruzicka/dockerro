module Actions
  module Dockerro
    module DockerImageBuildConfig
      class CreateAndAttachActivationKey < ::Actions::EntryAction
        include Dynflow::Action::WithSubPlans

        input_format do
          param :activation_key_id, Integer
        end

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
