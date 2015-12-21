module BackupAgent
  class << self
    def s3_config
      @s3_config ||= S3Config.new
    end

    def configure_s3(&block)
      @s3 = nil
      s3_config.configure(&block)
    end

    def s3
      @s3 ||= begin
        Aws.config.update(
          region: s3_config.region,
          credentials: Aws::Credentials.new(s3_config.access_key_id, s3_config.secret_access_key)
        )
        Aws::S3::Resource.new
      end
    end
  end
end