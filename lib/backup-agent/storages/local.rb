# encoding: UTF-8
# frozen_string_literal: true

#
# Storage based on some directory in local filesystem
#
class Backup::Storages
  class Local < Backup::Storages::Base
    attr_reader :directory

    def initialize(directory:)
      @directory = directory.gsub(/\/*\z/, "") # Ensure trailing slash
    end

    def store(relative_path, file_to_write)
      FileUtils.mkdir_p(directory)
      FileUtils.cp_r(file_to_write, File.join(directory, relative_path))
      Backup::Storages::Local::Object.new(self, relative_path)
    end

    def delete(relative_path)
      FileUtils.rm_f(File.join(directory, relative_path))
    end

    def each
      Dir.glob File.join(directory, "**", "*") do |path|
        yield Backup::Storages::Local::Object.new(self, path[directory.size+1..-1])
      end
    end

    class Object < Backup::Storages::Base::Object
      def last_modified
        File.mtime(File.join(storage.directory, id)).utc
      end
    end
  end
end
