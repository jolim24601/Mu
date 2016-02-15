require 'rack'
require 'erb'

module MuDispatch
  class ShowExceptions
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue Exception => e
      case
      when e.message.starts_with?("No such file or directory")
        render(404, e)
      when e.message.starts_with?("Unprocessable Entity")
        render(422, e)
      else
        render(500, e)
      end
    end

    def render(status, error)
      # template_file = "templates/public/#{status}.html"
      # template = File.read(template_file)
      dev_error_template = File.read("templates/error.development.html.erb")
      erb_template = ERB.new(dev_error_template).result(binding)
      # [status, { 'Content-Type' => 'text/html' }, [template]]
      [status, { 'Content-Type' => 'text/html' }, [erb_template]]
    end
  end
end
