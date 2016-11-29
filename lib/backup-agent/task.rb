module Backup
  class Task < Confo::Config
    def initialize(*)
      set :mysql_user, 'root'
      set :mysql_password, 'root'
      set :mysql_host, 'localhost'
      set :mysql_databases, -> do
        `/usr/bin/env mysql #{get(:mysql_connect)} -e "SHOW DATABASES;"`
          .split("\n")
          .reject { |el| el =~ /Database|information_schema|mysql|performance_schema|test|phpmyadmin/ }
      end

      set :mysqldump_options, %w(
        --add-drop-database
        --add-drop-table
        --add-locks
        --allow-keywords
        --comments
        --complete-insert
        --create-options
        --debug-check
        --debug-info
        --extended-insert
        --flush-privileges
        --insert-ignore
        --lock-tables
        --quick
        --quote-names
        --set-charset
        --dump-date
        --secure-auth
        --tz-utc
        --disable-keys )

      set :mysql_connect, -> do
        pass       = get(:mysql_password)
        pass_param = pass && !pass.empty? ? "--password=#{pass}" : ''
        "--user #{get(:mysql_user)} #{pass_param} --host=#{get(:mysql_host)}"
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

      set :directories, -> {
        Dir['/var/www/*'].each_with_object({}) do |el, memo|
          if Dir.exists?(File.join(el, 'current/public/uploads'))
            memo["Uploads #{File.basename(el)}"] = File.join(el, 'current/public/uploads')
          end
        end
      }

      set :files, {}

      set :days_to_keep_backups, 30
      super
    end
  end
end
