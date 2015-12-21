```ruby
require 'backup-agent'

storage_config = Backup::S3Config.new do
  set :access_key_id, 'xxx'
  set :secret_access_key, 'yyy'
  set :region, 'eu-central-1'
end

storage = Backup::S3Storage.new(storage_config, bucket: 'my-backups')

Backup.perform storage do
  set :mysql_host, 'xxx.yyy.xxx.yyy'
end
```

## Gemfile
```ruby
gem 'backup-agent'
```
