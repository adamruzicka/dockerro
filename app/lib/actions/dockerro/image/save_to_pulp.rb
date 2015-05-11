module Actions
  module Dockerro
    module Image
      class SaveToPulp < Actions::EntryAction
        output_format do
          param :path, String
        end

        input_format do
          param :path, String
        end

        def plan(image, repository, compute_resource)
          sequence do
            tar = plan_action(::Actions::Dockerro::Image::Save, :image_name => image, :url => compute_resource.url)
            upload_request = plan_action(Pulp::Repository::CreateUploadRequest)
            plan_action(Pulp::Repository::UploadFile,
                        upload_id: upload_request.output[:upload_id],
                        file: tar.output[:path])
            plan_action(Pulp::Repository::ImportUpload,
                        pulp_id: repository.pulp_id,
                        unit_type_id: repository.unit_type_id,
                        upload_id: upload_request.output[:upload_id])
            plan_action(Pulp::Repository::DeleteUploadRequest,
                        upload_id: upload_request.output[:upload_id])
            plan_action(::Actions::Katello::Repository::FinishUpload,
                        repository)
            plan_self :path => tar.output[:path]
          end
        end

        def run
          File.unlink input[:path]
        end

        def humanized_name
          _("Save")
        end
      end
    end
  end
end
