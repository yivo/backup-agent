# encoding: UTF-8
# frozen_string_literal: true

module Backup
  class Credentials
    include Singleton

    def initialize
      @groups = {}
    end

    # Usage: credentials(type: :name)
    def [](pair)
      @groups.fetch(pair.keys[0]).fetch(pair.values[0])
    end

    # define Class => [:type, :name, arguments...]
    def define(definitions)
      definitions.map do |klass, definition|
        (@groups[definition[0]] ||= {})[definition[1]] = klass.new(*definition.drop(2))
      end
    end

    def mysql(definitions)
      definitions.map do |name, args|
        define Backup::Tasks::MySQL::Credentials => [:mysql, name, *[args].flatten(1)]
      end.flatten(1)
    end

    def amazon_s3(definitions)
      definitions.map do |name, args|
        define Backup::Storages::AmazonS3::Credentials => [:amazon_s3, name, *[args].flatten(1)]
      end.flatten(1)
    end
  end
end
