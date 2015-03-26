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

require 'dockerro_test_helper'

module Dockerro
  class DockerImageBuildConfigTest < ActiveSupport::TestCase
    def setup
      @organization          = FactoryGirl.create(:katello_organization)
      @library               = FactoryGirl.create(:katello_library, :organization => @organization)
      @environment           = FactoryGirl.create(:katello_environment, :organization => @organization, :priors => [@library])
      @content_view          = FactoryGirl.create(:katello_content_view, :organization => @organization)
      @content_view_version  = FactoryGirl.create(:katello_content_view_version, :content_view => @content_view)
      @product               = FactoryGirl.create(:katello_product,
                                                  :organization => @organization,
                                                  :provider     => FactoryGirl.create(:katello_provider))
      @repository            = FactoryGirl.build(:docker_repository,
                                                 :content_view_version => @content_view_version,
                                                 :product              => @product,
                                                 :docker_upstream_name => "centos")
      @base_image            = FactoryGirl.build(:docker_image)
      @build_config_template = FactoryGirl.build(:docker_image_build_config_template,
                                                 :repository   => @repository,
                                                 :content_view => @content_view,
                                                 :base_image   => @base_image)
      @build_config          = FactoryGirl.build(:docker_image_build_config,
                                                 :repository    => @repository,
                                                 :content_view  => @content_view,
                                                 :base_image    => @base_image,
                                                 :parent_config => @build_config_template)
      require 'pry'; binding.pry
    end

    test 'it generates its name from repository name or label' do
      new_name = "centos"
      assert_equal @repository.label, @build_config.name
      @build_config.repository.docker_upstream_name = new_name
      assert_equal new_name, @build_config.name
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

    test 'it has to have a base image' do
      assert @build_config.valid?
      @build_config.base_image = nil
      refute @build_config.valid?
    end

    test 'it has to have unique combination of content_view_version and repository' do
      assert @build_config.valid?
      clone = @build_config.dup
      refute clone.valid?
    end

    test 'it generates build options' do
      # TODO
      skip "NotImplementedError"
    end

    test 'it generates environment variables' do
      # TODO
      skip "NotImplementedError"
    end

    test 'it is template if it doesn have associated content view version' do
      assert @build_config_template.template?
      refute @build_config.template?
    end

    test 'it doesnt have environment if its a template' do
      # TODO: This doesn't work
      skip "not working yet"
      assert_nil @build_config_template.send(:environment)
      @build_config_template.environment = @environment
      assert_nil @build_config_template.send(:environment)
    end

    test 'it select library as environment if environment is not set' do
      # TODO: This doesn't work
      skip "not working yet"
      assert_equal @library, @build_config.send(:environment)
    end

    test 'it doesnt have activation key if its a template' do
      assert_raises(RuntimeError) { @build_config_template.activation_key }
      @build_config.environemtn = @environment
      refute_nil @build_config.activation_key
    end

    test 'it generates prebuild plugins' do
      # TODO
      skip "NotImplementedError"
    end

    test 'it generates postbuild plugins' do
      image_name = @build_config_template.image_name
      result     = [
          { 'name' => 'all_rpm_packages', 'image_id' => image_name },
          { 'name' => 'store_logs_to_file', 'file_path' => '/var/rpms' }
      ]
      assert_equal result, @build_config_template.send(:postbuild_plugins)
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
