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

backup to: $s3 do
  mysql :all
end

# Dir['/var/www/*/shared/public/uploads'].each do |dir|
#   directory dir, name: "#{dir.split('/')[3]} uploads"
# end

mysql 'scorpion_fitness_development'

# directories Dir['/var/www/*/shared/public/uploads']

# mysql 'zdorovaclinic_development'


# directory '/Users/yaroslav/Downloads/excluded' => 'lol', symlinks: :follow

# task special_db_backup


# task Backup::Database::MySQL => [:zdorovaclinic, {}]

# files '/Users/yaroslav/Downloads/1Vuvp.png',
#       '/Users/yaroslav/Downloads/Карта сайта.docx',
#       name: 'myfiles'


# directories '/var/www/zdorovaclinic/shared/public/uploads' => 'zdorovaclinic uploads',
#             '/var/www/zdorovaclinic/shared/public/uploads' => 'zdorovaclinic uploads',
#             symlinks: :follow

# file
# files
# directory
# directories
# mysql
# mongodb

