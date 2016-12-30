module Backup::Storages
  class S3 < Base
    def initialize(*)
      super
      Aws.config.update(region:      config.region,
                        credentials: Aws::Credentials.new(config.access_key_id, config.secret_access_key))
      @aws_s3_resource = Aws::S3::Resource.new
      @aws_s3_bucket   = @aws_s3_resource.bucket(config.bucket)
    end

    def write(arg)
      id, path = arg.values[0], arg.keys[0]
      @aws_s3_bucket.object(id).upload_file(path)
    end

    def delete(id)
      @aws_s3_bucket.object(id).delete
    end

    def each
      @aws_s3_bucket.objects.each do |aws_s3_object|
        yield S3::Object.new(self, bucket, aws_s3_object.key)
      end
    end
  end
end
