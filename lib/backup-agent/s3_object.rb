module Backup
  class S3Object < AbstractStorageObject
    def initialize(*)
      super
      @object = env.fetch(:object)
      @bucket = env.fetch(:bucket)
    end

    def last_modified
      @object.last_modified
    end

    def delete
      storage.delete(key)
    end
  end
end