module Backup
  module Utils
    def echo(*args)
      puts(*args)
    end

    def exec(cmd)
      echo "--- execute #{cmd}"
      returned, msec = measure do
        stdout, stderr, exit_status = Open3.capture3(cmd)
        fail stderr unless exit_status.success?
        stdout
      end
      echo "--- completed in #{msec.round(1)}ms"
      returned
    end

    def with_env(cmd)
      "/usr/bin/env #{cmd}"
    end

    def make_tmp_dir
      FileUtils.mkdir_p(tmp_dir)
    end

    def remove_tmp_dir
      FileUtils.rm_rf(tmp_dir)
    end

    def tmp_dir
      '/tmp/backup-agent'
    end

    def measure
      started  = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
      returned = yield
      finished = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
      [returned, finished - started]
    end

    def name_fmt(basename, extension = nil)
      basename.gsub(/[^A-Z0-9]/i, '-') \
              .gsub(/[–—]/, '-') \
              .gsub(/-{2,}/, '-') \
              +"-#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}" \
              +extension.to_s
    end
  end
end

