require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require_relative './mu_dispatch/session'
require_relative './mu_dispatch/flash'
require 'erb'

require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = req.params.merge(route_params)
  end

  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Cannot redirect twice" if already_built_response?
    @already_built_response = true

    self.res.status = 302
    res['location'] = url

    flash.commit_flash(res)
    session.store_session(res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Cannot redirect twice" if already_built_response?

    @already_built_response = true
    res['Content-Type'] = content_type
    res.write(content)

    flash.commit_flash(res)
    session.store_session(res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.to_s.underscore
    template_file = ROOT_FOLDER + "views/#{controller_name}/#{template_name}.html.erb"
    template = File.read(template_file)

    erb_template = ERB.new(template).result(binding)
    render_content(erb_template, 'text/html')
  end

  def flash
    @flash ||= MuDispatch::Flash.from_session_value(req.cookies)
  end

  # method exposing a `Session` object
  def session
    @session ||= MuDispatch::Session.new(req)
  end

  def verify_authenticity_token
    unless session["authenticity_token"] == @req.params["authenticity_token"]
      raise "Missing authenticity token"
    end
  end

  def form_authenticity_token
    session["authenticity_token"] = SecureRandom.urlsafe_base64
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
    render(name) unless already_built_response?
  end
end
