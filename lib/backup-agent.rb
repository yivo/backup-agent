puts "Ruby version #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"

%w(rubygems aws-sdk fileutils confo-config shellwords).each { |lib| require lib }

require 'backup-agent/s3_config'
require 'backup-agent/task_config'
require 'backup-agent/service'
require 'backup-agent/features'
require 'backup-agent/s3'

module BackupAgent
  class << self
    def perform_backup(&block)
      task_config = TaskConfig.new
      task_config.configure(&block) if block
      Service.new(task_config).perform_backup
    end
  end
end