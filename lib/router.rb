module MuDispatch
  class Route
    attr_reader :pattern, :http_method, :controller_class, :action_name

    def initialize(pattern, http_method, controller_class, action_name)
      @pattern = pattern
      @http_method = http_method
      @controller_class = controller_class
      @action_name = action_name
    end

    def matches?(req)
      matched_path = req.path =~ pattern

      req.request_method == http_method.to_s.upcase && matched_path
    end

    def run(req, res)
      match_data = pattern.match(req.path)
      keys = match_data.names

      route_params = {}
      keys.each do |key|
        route_params[key] = match_data[key]
      end

      controller = controller_class.new(req, res, route_params)

      controller.invoke_action(action_name)
    end
  end

  class Router
    attr_reader :routes

    def initialize
      @routes = []
    end

    def add_route(pattern, method, controller_class, action_name)
      @routes << Route.new(pattern, method, controller_class, action_name)
    end

    def draw(&proc)
      self.instance_eval(&proc)
    end

    [:get, :post, :put, :delete].each do |http_method|
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
