# encoding: UTF-8
# frozen_string_literal: true

module Backup::Tasks
  class MySQL
    attr_reader :host, :credentials, :options

    def initialize(host:, credentials:, databases: :all, **options)
      @host        = host
      @credentials = credentials
      @databases   = databases
      @options     = options
    end

    def perform(storage)
      databases.map do |db|
        Tempfile.open do |tempfile|
          command("mysqldump", *credentials.to_options, *host_options, *dump_options, "--databases", db).tap do |dump_sql|
            stdin dump_sql do
              command("xz", "--compress", "-9", "--format=xz", "--keep", "--threads=0", "--verbose", "--check=sha256").tap do |dump_xz|
                tempfile.write(dump_xz)
                storage.store(construct_filename(db, ".sql.xz"), tempfile.path)
              end
            end
          end
        end
      end
    end

    def databases
      if @databases == :all
        command("mysql", *credentials.to_options, *host_options, "-e", "SHOW DATABASES;")
            .split("\n")
            .reject { |el| el =~ /Database|information_schema|mysql|performance_schema|test|phpmyadmin/ }
      else
        [@databases].flatten.compact
      end
    end

    def dump_options
      @options.fetch(:dump_options) do
        %W( --add-drop-table
            --add-locks
            --allow-keywords
            --comments
            --complete-insert
            --create-options
            --disable-keys
            --extended-insert
            --lock-tables
            --quick
            --quote-names
            --routines
            --set-charset
            --dump-date
            --tz-utc
            --verbose )
      end
    end

    def host_options
      ["--host=#{@host}"]
    end

    class Credentials
      def initialize(user:, password:)
        @user     = user
        @password = password
      end

      def stringify
        "--user #{@user} #{stringify_password}"
      end

      def stringify_password
        @password.nil? || @password.empty? ? "" : "--password=#{@password}"
      end

      def to_options
        ["--user", @user, stringify_password]
      end
    end
  end
end
