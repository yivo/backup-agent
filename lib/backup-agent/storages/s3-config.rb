module Backup::Storages
  class S3::Config < Base::Config
    attr_reader :access_key_id, :secret_access_key, :region, :bucket

    def initialize(arg)
      @access_key_id = arg[:access_key_id]
      @secret_access_key = arg[:secret_access_key]
      @region = arg[:region]
      @bucket = arg[:bucket]
    end
  end
end
