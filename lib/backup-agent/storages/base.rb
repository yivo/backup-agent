# encoding: UTF-8
# frozen_string_literal: true

#
# Base stuff for storages
#
class Backup::Storages
  class Base
    def store(id, path)
      method_not_implemented
    end

    def delete(id)
      method_not_implemented
    end

    def each
      method_not_implemented
    end

    class Object
      attr_reader :storage, :id

      def initialize(storage, id)
        @storage = storage
        @id      = id
      end

      def last_modified
        method_not_implemented
      end

      def to_s
        id
      end
    end
  end
end
