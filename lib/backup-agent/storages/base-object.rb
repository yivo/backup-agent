module Backup::Storages
  class Base::Object
    attr_reader :storage, :id

    def initialize(storage, id)
      @storage = storage
      @id      = id
    end

    def last_modified
      raise Backup::MethodNotImplemented, "#{self.class.name}#last_modified"
    end
  end
end
