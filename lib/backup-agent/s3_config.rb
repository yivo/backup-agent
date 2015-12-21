module BackupAgent
  class S3Config < Confo::Config
    def initialize(*)
      super
      set :access_key_id, nil
      set :secret_access_key, nil
      set :region, nil
    end
  end
end