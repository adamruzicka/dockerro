require 'dockerro_test_helper'

module Dockerro
  class DockerImageBuildConfigTest < ActiveSupport::TestCase
    def setup
      @organization          = FactoryGirl.create(:katello_organization)
      @library               = FactoryGirl.create(:katello_library, :organization => @organization)
      @environment           = FactoryGirl.create(:katello_environment, :organization => @organization, :priors => [@library])
      @content_view          = FactoryGirl.create(:katello_content_view, :organization => @organization, :environments => [@library, @environment])
      @content_view_version  = FactoryGirl.create(:katello_content_view_version, :content_view => @content_view)
      @product               = FactoryGirl.create(:katello_product,
                                                  :organization => @organization,
                                                  :provider     => FactoryGirl.create(:katello_provider))
      @repository            = FactoryGirl.create(:docker_repository,
                                                 :content_view_version => @content_view_version,
                                                 :product              => @product,
                                                 :docker_upstream_name => "centos")
      @base_image            = FactoryGirl.create(:docker_image)
      @build_config_template = FactoryGirl.create(:docker_image_build_config_template,
                                                 :repository   => @repository,
                                                 :content_view => @content_view,
                                                 :base_image   => @base_image)
      @build_config          = FactoryGirl.create(:docker_image_build_config,
                                                 :repository    => @repository,
                                                 :content_view  => @content_view,
                                                 :base_image    => @base_image,
                                                 :parent_config => @build_config_template)
    end

    test 'it generates its name from repository name or label' do
      assert_equal @repository.docker_upstream_name, @build_config.name
      @repository.docker_upstream_name = nil
      assert_equal @repository.label, @build_config.name
    end

    test 'it has to have a repository' do
      assert @build_config.valid?
      @build_config.repository = nil
      refute @build_config.valid?
    end

    test 'it has to have a content view' do
      assert @build_config.valid?
      @build_config.content_view = nil
      refute @build_config.valid?
    end

    test 'it may have a base image' do
      assert @build_config.valid?
      @build_config.base_image = nil
      assert @build_config.valid?
    end

    test 'it has to have unique combination of content_view_version and repository' do
      assert @build_config.valid?
      clone = @build_config.dup
      refute clone.valid?
    end

    test 'it is template if it doesn have associated content view version' do
      assert @build_config_template.template?
      refute @build_config.template?
    end

    test 'it doesnt have environment if its a template' do
      assert_nil @build_config_template.send(:environment)
      @build_config_template.environment = @environment
      assert_nil @build_config_template.send(:environment)
    end

    test 'it select library as environment if environment is not set' do
      # TODO: This doesn't work yet
      skip "not working yet"
      assert_equal @library, @build_config.send(:environment)
    end

    test 'it doesnt have activation key if its a template' do
      assert_raises(RuntimeError) { @build_config_template.activation_key }
      @build_config.environment = @environment
      refute_nil @build_config.activation_key
    end

    test 'it creates new activation key' do
      @build_config.environment = @environment
      key = @build_config.activation_key
      assert_equal "#{@build_config.activation_key_prefix}-#{@content_view.label}-#{@environment.label}", key.name
      assert_equal @content_view, key.content_view
      assert_equal @environment, key.environment
      assert_equal @organization, key.organization
      refute key.auto_attach
    end

    test 'it uses already existing activation key' do
      key = ::Katello::ActivationKey.new
      key.name = "#{@build_config.activation_key_prefix}-#{@content_view.label}-#{@environment.label}"
      key.content_view = @content_view
      key.environment = @environment
      key.organization = @organization
      key.auto_attach = false
      key.save!
      @build_config.environment = @environment
      assert_equal key, @build_config.activation_key
    end

    test 'it generates prebuild plugins' do
      # TODO: Write this test
      skip "Not Implemented"
    end

    test 'it clones itself for the latest version' do
      @build_config_template.expects(:latest_base_tag).returns(nil)
      cloned = @build_config_template.clone_for_latest_version
      assert_equal @content_view_version, cloned.content_view_version
      assert_equal @build_config_template, cloned.parent_config
    end

    test 'it returns saved cloned if it already exists for the version' do
      @build_config_template.expects(:latest_base_tag).twice.returns(nil)
      cloned = @build_config_template.clone_for_latest_version
      cloned.save!
      cloned2 = @build_config_template.clone_for_latest_version
      assert_equal cloned2, cloned
    end

    test 'it generates postbuild plugins' do
      @build_config.environment = @environment
      image_name = @build_config.image_name
      result     = [
        { 'name' => 'post_run_cmd',
          'args' => {
            'cmd' => "subscription-manager repos\n",
            'image_id' => image_name
          }
        }
      ]
      assert_equal result, @build_config.send(:postbuild_plugins)
    end

    test 'it generates plugins' do
      name   = 'plugin_name'
      result = {
          'name' => name,
          'args' => {}
      }
      assert_equal result, @build_config_template.send(:plugin, name)
      args_hash      = { :a => 1, :b => 2 }
      result['args'] = args_hash
      assert_equal result, @build_config_template.send(:plugin, name, args_hash)
    end

  end
end
