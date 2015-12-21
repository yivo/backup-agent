module Backup
  class AbstractStorageObject
    attr_reader :storage, :key, :env

    def initialize(storage, key, env = {})
      @storage = storage
      @key     = key
      @env     = env
    end

    def last_modified

    end

    def delete

    end
  end
end