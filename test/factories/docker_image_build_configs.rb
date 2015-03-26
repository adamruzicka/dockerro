FactoryGirl.define do
  factory :docker_image_build_config_template, :class => ::Dockerro::DockerImageBuildConfig do
    association :content_view, :factory => :katello_content_view
    association :repository, :factory => :docker_repository
    association :base_image, :factory => :docker_image

    git_url "http://something.somewhere/someone/project.git"
    

    trait :with_version do
      association :content_view_version, :factory => :katello_content_view_version
    end

    factory :docker_image_build_config, traits: [:with_version]
  end

end
