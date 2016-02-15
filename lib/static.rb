require 'byebug'
require 'rack'

module MuDispatch
  class Static
    def initialize(app)
      @app = app
    end

    def call(env)
      if env["REQUEST_METHOD"] == "GET"
        file_name = env["PATH_INFO"][1..-1]
        file_path = "public/#{file_name}"

        if File.file?(file_path)
          file = File.read(file_path)
          mime_type = Rack::Mime.mime_type(File.extname(file_name))
          return serve(file, mime_type)
        end
      end

      @app.call(env)
    end

    def serve(file, mime_type)
      [200, { 'Content-Type' => "#{mime_type}" }, [file]]
    end
  end
end
