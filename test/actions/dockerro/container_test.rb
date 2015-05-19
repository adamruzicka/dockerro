require File.expand_path('../../../dockerro_test_helper', __FILE__)

module ::Actions::Dockerro::Container
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    # include ::Support::Actions::RemoteAction
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }
    let(:container_id) { 1 }
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Dockerro::Container::Create }

    it 'plans' do
      container = mock()
      container.stubs(:id).returns(container_id)
      container.expects(:save!)
      container_options = {}
      action.expects(:add_defaults).with(container_options)
      ::ForemanDocker::Service::Containers::Container.expects(:new).returns(container)
      planned_action = plan_action action, container_options
      assert_action_planed_with action, ::ForemanDocker::Service::Actions::Container::Provision do |cont|
        assert_equal cont.first.id, container.id
      end
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Dockerro::Container::Destroy }
    let(:action_planned) { create_and_plan_action action_class, :container_id => container_id }

    it 'plans' do
      assert_run_phase action_planned
    end

    it 'runs' do
      container = mock()
      container.expects(:in_fog).returns(container)
      container.expects(:destroy)
      ::Container.expects(:find).with(container_id).returns(container)

      run_action action_planned
    end
  end
end
