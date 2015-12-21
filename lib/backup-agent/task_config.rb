module BackupAgent
  class TaskConfig < Confo::Config
    def initialize(*)
      super
      set :mysql_user, 'root'
      set :mysql_password, 'root'
      set :mysql_host, 'localhost'
      set :mysql_databases, -> do
        `/usr/bin/env mysql #{get(:mysql_connect)} -e "SHOW DATABASES;"`
          .split("\n")
          .reject { |el| el =~ /Database|information_schema|mysql|performance_schema|test|phpmyadmin/ }
      end

      set :mysqldump_options, %w(
        --single-transaction
        --add-drop-table
        --add-locks
        --create-options
        --disable-keys
        --extended-insert
        --quick)

      set :mysql_connect, -> do
        pass       = get(:mysql_password)
        pass_param = pass && !pass.empty? ? "-p#{pass}" : ''
        "-u #{get(:mysql_user)} #{pass_param} -h #{get(:mysql_host)}"
      end

      set :mongo_databases, -> do
        if `/usr/bin/env mongo --eval "db.getMongo().getDBNames()"` =~ /connecting to: (.*)/m
          $1.split(/[\n,]/).reject(&:empty?)
        else
          []
        end
      end

      set :mongo_host, 'localhost'
      set :mongo_connect, -> { "-h #{get(:mongo_host)}" }

      set :directories, -> do
        Dir['/var/www/*'].each_with_object({}) do |el, memo|
          if Dir.exists?(File.join(el, 'current/public/uploads'))
            memo["#{File.basename(el)}-uploads"] = File.join(el, 'current/public/uploads')
          end
        end
      end

      set :files, {}

      set :s3_bucket, nil

      set :days_to_keep_backups, 30
    end
  end
end