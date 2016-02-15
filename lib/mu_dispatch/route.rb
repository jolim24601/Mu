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
end
