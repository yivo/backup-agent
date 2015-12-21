module Backup
  class S3Storage < AbstractStorage

    def initialize(*)
      super
      @bucket_name = env.fetch(:bucket)
    end

    def s3
      @s3 ||= begin
        Aws.config.update(
          region: config.region,
          credentials: Aws::Credentials.new(config.access_key_id, config.secret_access_key)
        )
        Aws::S3::Resource.new
      end
    end

    def bucket
      s3.bucket(@bucket_name)
    end

    def open
      s3
    end

    def upload(key, path)
      bucket.object(key).upload_file(path)
    end

    def delete(key)
      bucket.object(key).delete
    end

    def object(key)
      S3Object.new(self, key, object: bucket.object(key), bucket: bucket)
    end

    def each
      bucket.objects.each do |s3_obj|
        yield S3Object.new(self, s3_obj.key, object: s3_obj, bucket: bucket)
      end
    end
  end
end