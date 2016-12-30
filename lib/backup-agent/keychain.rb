def keychain(&block)
  block ? Backup.keychain.instance_exec(&block) : Backup.keychain
end

module Backup
  class << self
    def keychain
      @keychain ||= Keychain.new
    end
  end

  class Keychain
    def initialize
      @map = {}
    end

    def [](name)
      @map.fetch(name)
    end

    # define MySQLCredentials => [:mysql, :localhost, { host: 'localhost', user: 'root', password: 'root' }]
    def define(arg)
      (@map[arg.values[0][0]] ||= {})[arg.values[0][1]] = arg.keys[0].new(*[arg.values[0][2]])
    end

    def mysql(defs)
      defs.map do |name, params|
        define Backup::Tasks::MySQL::Credentials => [:mysql, name, params]
      end
    end
  end
end
