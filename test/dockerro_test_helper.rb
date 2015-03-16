require 'test_helper'
require 'dynflow/testing'
require "#{Katello::Engine.root}/test/support/foreman_tasks/task"


FactoryGirl.definition_file_paths = ["#{Dockerro::Engine.root}/test/factories"]
FactoryGirl.find_definitions