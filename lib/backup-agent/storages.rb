# encoding: UTF-8
# frozen_string_literal: true

module Backup
  class Storages
    include Singleton
    include Enumerable

    def initialize
      @groups = {}
    end

    def [](pair)
      @groups.fetch(pair.keys[0]).fetch(pair.values[0])
    end

    def each
      @groups.each do |type, storages|
        storages.each { |name, storage| yield storage, type, name }
      end
    end

    # register AmazonS3 => [:amazon_s3, :default, storage constructor arguments...]
    def register(arg)
      arg.map do |klass, rest|
        (@groups[rest[0]] ||= {})[rest[1]] = klass.new(*rest.drop(2))
      end
    end

    def local(definitions)
      definitions.map do |name, args|
        register Backup::Storages::Local => [:local, name, *[args].flatten(1)]
      end.flatten(1)
    end

    def amazon_s3(definitions)
      definitions.map do |name, options|
        register Backup::Storages::AmazonS3 => [:amazon_s3, name, options.merge(credentials: credentials[amazon_s3: name])]
      end.flatten(1)
    end
  end
end
