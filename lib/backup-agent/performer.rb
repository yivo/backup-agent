# encoding: UTF-8
# frozen_string_literal: true

module Backup
  class Performer
    def initialize(storages)
      @storages = storages
    end

    # task Task => [:foo, :bar, :baz]
    def task(arg)
      arg.each do |klass, args|
        @storages.each { |storage| klass.new(*args).perform(storage) }
      end
      nil
    end

    def mysql(options)
      if Symbol === options[:credentials]
        options[:credentials] = credentials(mysql: options[:credentials])
      end
      task Backup::Tasks::MySQL => [options]
    end

    def directory(path, options)
      task Backup::Tasks::Directory => [path, options]
    end
  end
end
