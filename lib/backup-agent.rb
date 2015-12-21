puts "Ruby version #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"

%w( rubygems aws-sdk fileutils confo-config shellwords ).each { |el| require(el) }

%w( abstract_storage abstract_storage_config abstract_storage_object
   s3_storage s3_config s3_object
   features task performer ).each { |el| require_relative("backup-agent/#{el}") }

module Backup
  class << self
    def perform(storage, &block)
      Performer.new.perform_backup(storage, Task.new(&block))
    end

    def features
      @features ||= Features.new
    end
  end
end