module Backup
  class AbstractStorage
    include Enumerable

    attr_reader :config, :env

    def initialize(config, env = {})
      @config = config
      @env    = env
    end

    def open

    end

    def close

    end

    def upload(key, path)

    end

    def delete(key)

    end

    def each

    end
  end
end