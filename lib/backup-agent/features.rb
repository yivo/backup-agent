module Backup
  class Features
    def initialize
      check_mysql
      check_mongodb
    end

    def check_mysql
      if @mysql_check.nil?
        @mysql_check = system('/usr/bin/env mysql --version') ? true : (puts('MySQL is not installed'); false)
      end
      @mysql_check
    end

    def check_mongodb
      if @mongodb_check.nil?
        @mongodb_check = system('/usr/bin/env mongod --version') ? true : (puts('MongoDB is not installed'))
      end
      @mongodb_check
    end

    def mysql_installed?
      !!@mysql_check
    end

    def mongodb_installed?
      !!@mongodb_check
    end
  end
end