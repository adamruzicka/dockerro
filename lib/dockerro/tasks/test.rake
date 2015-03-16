require File.expand_path("../engine", File.dirname(__FILE__))

namespace :test do

  namespace :dockerro do

    # Set the test loader explicitly to ensure that the ci_reporter gem
    # doesn't override our test runner
    # def set_test_runner
    #   ENV['TESTOPTS'] = "#{ENV['TESTOPTS']} #{Dockerro::Engine.root}/test/dockerro_test_runner.rb"
    # end

    desc "Run the Dockerro plugin spec test suite."
    task :spec => ['db:test:prepare'] do
      # set_test_runner
      #
      # spec_task = Rake::TestTask.new('dockerro_spec_task') do |t|
      #   t.libs << ["test", "#{Dockerro::Engine.root}/test", "spec", "#{Dockerro::Engine.root}/spec"]
      #   t.test_files = [
      #     "#{Dockerro::Engine.root}/spec/**/*_spec.rb",
      #   ]
      #   t.verbose = true
      # end

      # Rake::Task[spec_task.name].invoke
    end

    desc "Run the Dockerro plugin unit test suite."
    task :test => ['db:test:prepare'] do
      # set_test_runner
      #
      test_task = Rake::TestTask.new('dockerro_test_task') do |t|
        t.libs << ["test", "#{Dockerro::Engine.root}/test"]
        t.test_files = [
          "#{Dockerro::Engine.root}/test/**/*_test.rb",
        ]
        t.verbose = true
      end

      Rake::Task[test_task.name].invoke
    end
  end

  desc "Run the entire Dockerro plugin test suite"
  task :dockerro do
    Rake::Task['test:dockerro:spec'].invoke
    Rake::Task['test:dockerro:test'].invoke
  end

end

Rake::Task[:test].enhance do
  Rake::Task['test:dockerro'].invoke
end
