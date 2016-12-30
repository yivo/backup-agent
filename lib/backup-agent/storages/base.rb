module Backup::Storages
  class Base
    include Enumerable

    attr_reader :config

    def initialize(config)
      raise ArgumentError unless Backup::Storages::Base::Config === config
      @config = config
    end

    def read(id)

    end

    def write(key, path)
      raise Backup::MethodNotImplemented, "#{self.class.name}#each"
    end

    def delete(id)
      raise Backup::MethodNotImplemented, "#{self.class.name}#delete(key)"
    end

    def each
      raise Backup::MethodNotImplemented, "#{self.class.name}#each"
    end
  end
end

require 'backup-agent/storages/base-config'
require 'backup-agent/storages/base-object'
