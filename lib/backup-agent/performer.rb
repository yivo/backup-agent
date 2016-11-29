module Backup
  class Performer
    attr_reader :storage, :config

    def perform_backup(storage, config)
      @storage = storage
      @config = config
      @started_at = Time.now.utc
      @timestamp = @started_at.strftime('%s - %A %d %B %Y %H:%M')
      storage.open
      make_tmp_dir
      backup_mysql if Backup.features.mysql_installed?
      backup_mongodb if Backup.features.mongodb_installed?
      backup_directories
      backup_files
      cleanup_old_backups
    ensure
      remove_tmp_dir
      storage.close
    end

  protected

    def backup_directories
      config.get(:directories).each do |name, dir|
        dir_filename  = "#{name}.tar.xz"
        dir_fileparam = Shellwords.escape(dir_filename)
        cmd = "cd #{dir} && /usr/bin/env XZ_OPT=-9 tar -cJvf #{tmp_path}/#{dir_fileparam} ."
        puts "Exec #{cmd}"
        system(cmd)
        storage.upload("#{@timestamp}/#{dir_filename}", "#{tmp_path}/#{dir_filename}")
      end
    end

    def backup_files
      config.get(:files).each do |name, files|
        begin
          files_tmp_path   = File.join(tmp_path, "#{name}-tmp")
          file_bunch_name  = "#{name}.tar.xz"
          file_bunch_param = Shellwords.escape(file_bunch_name)

          FileUtils.mkdir_p(files_tmp_path)
          FileUtils.cp(files.select { |el| File.exists?(el) }, files_tmp_path)

          cmd = "cd #{files_tmp_path} && /usr/bin/env XZ_OPT=-9 tar -cJvf #{tmp_path}/#{file_bunch_param} ."
          system(cmd)

          storage.upload("#{@timestamp}/#{file_bunch_name}", "#{tmp_path}/#{file_bunch_name}")
        ensure
          FileUtils.remove_dir(files_tmp_path)
        end
      end
    end

    def backup_mysql
      config.get(:mysql_databases).each do |db|
        dump_path = "#{tmp_path}/#{ shell_escape(db) }.sql"
        dump_cmd  = "mysqldump #{config.get(:mysql_connect)} #{config.get(:mysqldump_options).join(' ')} --databases #{db}"

        exec with_env("#{dump_cmd} > #{dump_path}")
        exec with_env("xz --compress --extreme -9 --keep --threads=0 --verbose #{dump_path}")

        storage.upload("#{@timestamp}/#{ shell_escape(db) }.sql.xz", "#{dump_path}.xz")
      end
    end

    def backup_mongodb
      mongo_dump_dir = File.join(tmp_path, 'mongo')
      FileUtils.mkdir_p(mongo_dump_dir)

      config.get(:mongo_databases).each do |db|
        db_filename  = "Mongo Database #{db}.tar.xz"
        db_fileparam = Shellwords.escape(db_filename)
        dump = with_env "mongodump #{config.get(:mongo_connect)} -d #{db} -o #{mongo_dump_dir}"
        cd   = "cd #{mongo_dump_dir}/#{db}"
        tar  = with_env "XZ_OPT=-9 tar -cJvf #{tmp_path}/#{db_fileparam} ."

        puts "Exec #{dump} && #{cd} && #{tar}"
        system "#{dump} && #{cd} && #{tar}"

        storage.upload("#{@timestamp}/#{db_filename}", "#{tmp_path}/#{db_filename}")
      end
    ensure
      FileUtils.remove_dir(mongo_dump_dir)
    end

    def cleanup_old_backups
      cutoff_date = Time.now.utc.to_i - (config.get(:days_to_keep_backups) * 86400)
      storage.each do |obj|
        obj.delete if obj.last_modified.to_i < cutoff_date
      end
    end

    def make_tmp_dir
      FileUtils.mkdir_p(tmp_path)
    end

    def remove_tmp_dir
      FileUtils.remove_dir(tmp_path)
    end

    def tmp_path
      "/tmp/backup-agent-#{@started_at.strftime('%d-%m-%Y-%H:%M')}"
    end

    def with_env(cmd)
      "/usr/bin/env #{cmd}"
    end

    def shell_escape(x)
      Shellwords.escape(x)
    end

    def exec(cmd)
      puts "Exec #{cmd}"
      system cmd
    end
  end
end
