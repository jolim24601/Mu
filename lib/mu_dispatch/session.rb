require 'json'

module MuDispatch
  class Session
    def initialize(req)
      if req.cookies["_mu_app"]
        @cookie = JSON.parse(req.cookies["_mu_app"])
      else
        @cookie = {}
      end
    end

    def [](key)
      @cookie[key]
    end

    def []=(key, val)
      @cookie[key] = val
    end

    def store_session(res)
      res.set_cookie("_mu_app", path: "/", value: @cookie.to_json)
    end
  end
end
