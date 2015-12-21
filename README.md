```ruby
BackupAgent.configure_s3 do
  set :access_key_id, 'xxx'
  set :secret_access_key, 'yyy'
  set :region, 'eu-central-1'
end

BackupAgent.perform_backup do
  set :s3_bucket, 'my-backups'
end
```

## Gemfile
```ruby
gem 'backup-agent', github: 'yivo/backup-agent'
```