module Actions
  module Dockerro
    module Image
      class Save < Actions::EntryAction
        output_format do
          :path
        end

        input_format do
          :image_name
          :url
        end

        def run
          tmp = Tempfile.new 'dockerro.'
          tmp_path = tmp.path
          tmp.close true
          connection = ::Docker::Connection.new(input[:url], {})
          ::Docker::Image.save([input[:image_name]], tmp_path, connection)
          output[:path] = tmp_path
        end

        def humanized_name
          _("Save")
        end
      end
    end
  end
end
