# encoding: UTF-8
# frozen_string_literal: true

require "fileutils"
require "tempfile"
require "shellwords"
require "open3"
require "singleton"
require "aws-sdk"
require "method-not-implemented"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/filters"
require "active_support/core_ext/string/multibyte"
require "active_support/core_ext/numeric/time"

["ruby", "tar", "gzip", "xz", "mysql", "mysqldump"].each do |x|
  stdout, stderr, exit_status = Open3.capture3(x, "--version")
  puts (stderr.presence || stdout).squish
end

$LOAD_PATH << __dir__ unless $LOAD_PATH.include?(__dir__)

require "backup-agent/dsl"
require "backup-agent/credentials"
require "backup-agent/performer"

require "backup-agent/storages"
require "backup-agent/storages/base"
require "backup-agent/storages/local"
require "backup-agent/storages/amazon-s3"

require "backup-agent/tasks/directory"
require "backup-agent/tasks/mysql"

include Backup::DSL
