require 'rack'
require_relative '../lib/controller_base'
require_relative '../lib/router'
require_relative '../lib/show_exceptions'
require_relative '../lib/static'
require 'byebug'

class SimpleController < ControllerBase
  def index
    # @cats = "Cat cat cat"
  end

  def create
    verify_authenticity_token
    render :index
  end

  def show
  end

  def new
  end
end

router = MuDispatch::Router.new
router.draw do
  get Regexp.new("^/$"), SimpleController, :index
  get Regexp.new("^/new$"), SimpleController, :new
  post Regexp.new("^/$"), SimpleController, :create
end

app = Rack::Builder.app do
  use MuDispatch::Static
  use MuDispatch::ShowExceptions
  run lambda { |env|
    req = Rack::Request.new(env)
    res = Rack::Response.new
    router.run(req, res)
    res.finish
  }
end

Rack::Server.start(
  app: app,
  Port: 3000
)
