module Backup
  class S3Config < AbstractStorageConfig
    def initialize(*)
      set :access_key_id, nil
      set :secret_access_key, nil
      set :region, nil
      set :bucket, nil
      super
    end
  end
end