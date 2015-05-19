# require 'dockerro_test_helper'
require File.expand_path('../../../dockerro_test_helper', __FILE__)

module ::Actions::Dockerro::DockerImageBuildConfig
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }
    let(:build_config_id) { 1 }
    let(:build_config) { mock() }
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Dockerro::DockerImageBuildConfig::Create }

    it 'plans' do
      build_config.expects(:id).returns(build_config_id)
      build_config.expects(:save!)
      plan_action action, build_config
    end
  end

  class DestroyTest < TestBase
    let (:action_class) { Destroy }
    let (:planned_action) { plan_action action, :id => build_config_id }

    it 'plans' do
      assert_run_phase planned_action
    end

    it 'runs' do
      ::Dockerro::DockerImageBuildConfig
        .expects(:find).with(build_config_id)
        .returns(build_config)
      build_config.expects(:destroy!)
      run_action planned_action
    end
  end

  class AssociateImageTest < TestBase
    let(:action_class) { AssociateImage }
    let(:base_image_id) { 5 }
    let(:planned_action) { plan_action action, :build_config_id => build_config_id, :base_image_id => base_image_id }
    let(:base_image) { mock() }

    it 'plans' do
      assert_finalize_phase planned_action
    end

    it 'finalizes' do
      ::Dockerro::DockerImageBuildConfig.expects(:find).with(build_config_id).returns(build_config)
      ::Katello::DockerImage.expects(:find).with(base_image_id).returns(base_image)
      base_image.expects(:docker_image_build_config=).with(build_config)
      base_image.expects(:save!)
      finalize_action planned_action
    end
  end

  # TODO: Doesnt work yet
  class BuildTest < TestBase
    let(:action_class) { Build }
    let(:compute_resource) { mock() }

    it 'plans' do
      User.current = nil
      ::ComputeResource.expects(:find).returns(compute_resource)
      action.expects(:sequence)
      build_config.expects(:template?).returns(false)
      build_config.expects(:reload)
      build_config.expects(:latest_base_tag)
      action.expects(:action_subject).with(build_config)
      build_config.expects(:id).returns(build_config_id)
      plan_action action, build_config, compute_resource, 'myhostname'
    end
  end
end
