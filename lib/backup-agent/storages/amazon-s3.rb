# encoding: UTF-8
# frozen_string_literal: true

#
# Storage based on Amazon S3
#
class Backup::Storages
  class AmazonS3 < Backup::Storages::Base
    def initialize(region:, bucket:, credentials:)
      @aws_s3_ruby_credentials = Aws::Credentials.new(credentials.access_key_id, credentials.secret_access_key)
      @aws_s3_ruby_resource    = Aws::S3::Resource.new(region: region, credentials: @aws_s3_ruby_credentials)
      @aws_s3_ruby_bucket      = @aws_s3_ruby_resource.bucket(bucket)
    end

    def store(id, file_to_upload)
      aws_s3_ruby_object = @aws_s3_ruby_bucket.object(id)
      aws_s3_ruby_object.upload_file(file_to_upload)
      Backup::Storages::AmazonS3::Object.new(self, @aws_s3_ruby_bucket, aws_s3_ruby_object.key)
    end

    def delete(id)
      @aws_s3_ruby_bucket.object(id).delete
    end

    def each
      @aws_s3_ruby_bucket.objects.each do |aws_s3_ruby_object|
        yield Backup::Storages::AmazonS3::Object.new(self, @aws_s3_ruby_bucket, aws_s3_ruby_object.key)
      end
    end

    class Credentials
      attr_reader :access_key_id, :secret_access_key

      def initialize(access_key_id:, secret_access_key:)
        @access_key_id     = access_key_id
        @secret_access_key = secret_access_key
      end
    end

    class Object < Backup::Storages::Base::Object
      def initialize(storage, aws_s3_ruby_bucket, id)
        super(storage, id)
        @aws_s3_ruby_bucket = aws_s3_ruby_bucket
      end

      def last_modified
        @aws_s3_ruby_bucket.object(id).last_modified.utc
      end
    end
  end
end
