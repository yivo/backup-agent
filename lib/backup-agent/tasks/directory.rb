# encoding: UTF-8
# frozen_string_literal: true

module Backup::Tasks
  class Directory
    def initialize(path, options = {})
      @path    = path
      # @name    = options.fetch(:name)
      @options = options

      if options[:compressor]
        @compressor = Symbol === options[:compressor] ? { type: options[:compressor] } : options[:compressor]
      end
    end

    def perform(storage)
      return if !File.readable?(@path) || !File.directory?(@path)

      @options.fetch(:name, @path).tap do |x|
        @filename = add_extension(construct_filename(File.basename(x, ".*")) + File.extname(x))
      end

      Tempfile.open do |tempfile|
        with compression_environment do
          command "tar", tar_flags, tempfile.path, "-C", @path, "."
        end
        storage.store(@filename, tempfile.path)
      end
    end

    def compression_environment
      case @compressor&.fetch(:type)
        when :xz   then { XZ_OPT: "-#{@compressor.fetch(:level, 3)}" }
        when :gzip then { GZIP:   "-#{@compressor.fetch(:level, 3)}" }
      end
    end

    def tar_flags
      flags = ["c"]

      flags << "h" if @options.fetch(:symlinks, :follow) == :follow

      case @compressor&.fetch(:type)
        when :xz   then flags << "J"
        when :gzip then flags << "z"
      end

      flags << "v"
      flags << "f"
      flags.join("")
    end

    def add_extension(name)
      case @compressor&.fetch(:type)
        when :xz   then name + ".tar.xz"
        when :gzip then name + ".tar.gz"
        else            name + ".tar"
      end
    end
  end
end
