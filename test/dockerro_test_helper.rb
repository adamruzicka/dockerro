require 'test_helper'
require 'dynflow/testing'
require "#{Katello::Engine.root}/test/support/foreman_tasks/task"

FactoryGirl.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryGirl.definition_file_paths << "#{Katello::Engine.root}/test/factories"
FactoryGirl.reload
