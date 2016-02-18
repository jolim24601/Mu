require_relative 'route'

module MuDispatch
  class Router
    attr_reader :routes

    def initialize
      @routes = []
    end

    def add_route(pattern, method, controller_class, action_name)
      @routes << MuDispatch::Route.new(pattern, method, controller_class, action_name)
    end

    def draw(&proc)
      self.instance_eval(&proc)
    end

    [:get, :post, :patch, :put, :delete].each do |http_method|
      define_method(http_method) do |pattern, controller_class, action_name|
        add_route(pattern, http_method, controller_class, action_name)
      end
    end

    # should return the route that matches this request
    def match(req)
      routes.find { |route| route.matches?(req) }
    end

    # either throw 404 or call run on a matched route
    def run(req, res)
      route = match(req)

      if route
        route.run(req, res)
      else
        res.status = 404
        res.body = ["404 ERROR: PATH NOT FOUND"]
      end
    end
  end
end
