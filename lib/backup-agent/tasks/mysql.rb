module Backup::Tasks
  class MySQL
    include Backup::Utils

    attr_reader :credentials

    def initialize(credentials, databases = :all, options = {})
      @databases   = databases
      @options     = options
      @credentials = credentials
    end

    def perform(storage)
      databases.map do |db|
        dump_name = name_fmt(db, '.sql')
        dump_path = "#{tmp_dir}/#{dump_name}"
        dump_cmd  = "mysqldump #{credentials.stringify} #{dump_options.join(' ')} --databases #{db}"

        exec with_env("#{dump_cmd} > #{dump_path}")
        exec with_env("xz --compress -9 --keep --threads=0 --verbose #{dump_path}")

        storage.write("#{dump_path}.xz" => "#{dump_name}.xz")
      end
    end

    def databases
      if @databases == :all
        exec with_env(%{ mysql #{credentials.stringify} -e "SHOW DATABASES;" })
               .split("\n")
               .reject { |el| el =~ /Database|information_schema|mysql|performance_schema|test|phpmyadmin/ }
      else
        Array(@databases).flatten
      end
    end

    def dump_options
      @options.fetch(:dump_options) do
        %w( --add-drop-database
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
      end
    end

    class Credentials
      def initialize(params = {})
        @user     = params.fetch(:user,     'root')
        @password = params.fetch(:password, 'root')
        @host     = params.fetch(:host,     'localhost')
      end

      def stringify
        password = @password.nil? || @password.empty? ? '' : "--password=#{@password}"
        "--user #{@user} #{password} --host=#{@host}"
      end
    end
  end
end
