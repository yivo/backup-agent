def backup(to:, &block)
  Backup::Performer.new(to, Backup.keychain).perform(&block)
end

module Backup
  class Performer
    include Backup::Utils

    def initialize(storage, keychain)
      @storage  = storage
      @keychain = keychain
    end

    def perform(&block)
      make_tmp_dir
      instance_exec(&block)
    ensure
      remove_tmp_dir
    end

    # task Task => [:foo, :bar, :baz]
    # task Task => :foo
    # task Task.new(:foo)
    def task(arg)
      task = if Hash === arg
        klass  = arg.keys[0]
        params = arg.values[0]
        raise ArgumentError, 'class expected' unless Class === klass
        klass.new(*[params].flatten(1))
      else
        arg
      end

      unless task.respond_to?(:perform) || task.method(:perform).arity != 1
        raise ArgumentError, 'must respond to "perform" and accept strictly one argument'
      end

      task.perform(@storage)
    end

    def mysql(databases, options = {})
      credentials = options.delete(:credentials) { keychain[:mysql][:default] }
      task Backup::Tasks::MySQL => [credentials, databases, options]
    end
  end
end
