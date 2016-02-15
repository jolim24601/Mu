require 'rack'
require_relative 'lib/mu_dispatch/router'
require_relative 'lib/mu_dispatch/show_exceptions'
require_relative 'lib/mu_dispatch/static'

require_relative 'lib/controller_base'
require_relative 'lib/mu_record/base'

require_relative 'humans_controller'
require_relative 'cats_controller'

require 'byebug'

router = MuDispatch::Router.new
router.draw do
  get Regexp.new("^/humans$"), HumansController, :index
  get Regexp.new("^/humans/new$"), HumansController, :new
  post Regexp.new("^/humans$"), HumansController, :create
  get Regexp.new("^/humans/(?<id>\\d+)$"), HumansController, :show
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/new$"), CatsController, :new
  post Regexp.new("^/cats$"), CatsController, :create
  get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
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
