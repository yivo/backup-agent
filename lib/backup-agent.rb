%w( ruby tar xz mysql ).each { |x| puts `#{x} --version` }

$LOAD_PATH << __dir__

require 'fileutils'
require 'shellwords'
require 'open3'
require 'aws-sdk'

require 'backup-agent/patch'
require 'backup-agent/utils'
require 'backup-agent/errors'
require 'backup-agent/performer'
require 'backup-agent/keychain'

require 'backup-agent/storages/base'
require 'backup-agent/storages/base-config'
require 'backup-agent/storages/base-object'

require 'backup-agent/storages/s3'
require 'backup-agent/storages/s3-config'
require 'backup-agent/storages/s3-object'

require 'backup-agent/tasks/mysql'
