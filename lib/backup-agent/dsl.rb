# encoding: UTF-8
# frozen_string_literal: true

module Backup
  module DSL
    def echo(*args)
      puts(*args)
    end

    def with(environment)
      @current_command_environment = environment&.each_with_object({}) { |(k, v), m| m[k.to_s] = v.to_s }
      yield
    ensure
      remove_instance_variable(:@current_command_environment)
    end

    def stdin(data, binmode: false)
      @current_command_stdin_data         = data
      @current_command_stdin_data_binmode = binmode
      yield
    ensure
      remove_instance_variable(:@current_command_stdin_data)
      remove_instance_variable(:@current_command_stdin_data_binmode)
    end

    def command(*args)
      returned, msec = measure args.map(&:to_s).join(" ") do

        if instance_variable_defined?(:@current_command_environment) && @current_command_environment
          args.unshift(@current_command_environment)
        end

        stdout, stderr, exit_status = \
          if instance_variable_defined?(:@current_command_stdin_data)
            Open3.capture3 *args, \
              stdin_data: @current_command_stdin_data,
              binmode:    @current_command_stdin_data_binmode
          else
            Open3.capture3(*args)
          end

        fail stderr unless exit_status.success?
        # echo stdout
        stdout
      end
      returned
    end

    def measure(action)
      echo "\n", action
      started  = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
      returned = yield
      finished = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
      echo "(#{ (finished - started).round(1) }ms)", "\n"
      returned
    end

    def construct_filename(basename, extension_with_dot = nil)
      [basename.gsub(/[^[[:alnum:]]]/i, "-")
               .gsub(/[-–—]+/, "-")
               .mb_chars.downcase.to_s,
       "--#{Time.now.getutc.strftime("%Y-%m-%d--%H-%M-%S--UTC")}",
       extension_with_dot.to_s.mb_chars.downcase.to_s].join("")
    end

    def storages(pair = nil, &block)
      if pair
        Backup::Storages.instance[pair]
      elsif block
        Backup::Storages.instance.instance_exec(&block)
      else
        Backup::Storages.instance
      end
    end

    def credentials(pair = nil, &block)
      if pair
        Backup::Credentials.instance[pair]
      elsif block
        Backup::Credentials.instance.instance_exec(&block)
      else
        Backup::Credentials.instance
      end
    end

    def backup(to:, &block)
      storages = [to].flatten.map { |h| h.map { |k, v| self.storages(k => v) } }.flatten
      Backup::Performer.new(storages).tap { |performer| performer.instance_eval(&block) }
    end

    def delete_backups_older_than(x)
      cutoff_timestamp = Time.now.utc.to_i - x
      storages.each do |storage|
        storage.each do |object|
          if object.last_modified.to_i < cutoff_timestamp
            puts "Delete #{object.to_s} from #{storage.to_s}"
            storage.delete(object.id)
          end
        end
      end
    end
  end
end

