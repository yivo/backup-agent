module Backup::Storages
  class S3::Object < Base::Object
    def initialize(storage, bucket, id)
      super(storage, id)
      @bucket = bucket
    end

    def last_modified
      @bucket.object(@id).last_modified
    end
  end
end
