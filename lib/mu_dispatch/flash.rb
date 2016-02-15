require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/hash/keys'

module MuDispatch
  class FlashNow
    attr_accessor :flash

    def initialize(flash)
      @flash = flash
    end

    def []=(k, v)
      k = k.to_s
      @flash[k] = v
      @flash.discard(k)
      v
    end

    def [](k)
      @flash[k.to_s]
    end
  end

  class Flash
    include Enumerable

    # flash is called
    def self.from_session_value(value)
      if value['_mu_flashes']
        flashes = JSON.parse(value['_mu_flashes'])
        new(flashes, flashes.keys)
      else
        new
      end
    end

    def initialize(flashes = {}, discard = [])
      @flashes = flashes.stringify_keys
      @discard = Set.new(discard.map(&:to_s))
      @now = nil
    end

    # after redirect / render_content
    def commit_flash(res)
      flashes_to_keep = @flashes.except(*@discard)

      res.set_cookie(
        '_mu_flashes',
        path: '/',
        value: flashes_to_keep.to_json
      )
    end

    def each(&blk)
      @flashes.each(&blk)
    end

    def []=(k, v)
      k = k.to_s
      @discard.delete k
      @flashes[k] = v
    end

    def [](k)
      @flashes[k.to_s]
    end

    def now
      @now ||= FlashNow.new(self)
    end

    def keys
      @flashes.keys
    end

    def discard(k = nil)
      k = k.to_s if k
      @discard.merge Array(k || keys)
      k ? self[k] : self
    end
  end
end
