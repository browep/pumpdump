# Load the rails application
require File.expand_path('../application', __FILE__)

raw_config = File.read("/usr/local/pumpdump/conf/app_config.yml")
APP_CONFIG = YAML.load(raw_config)[Rails.env]

class Hash
  def symbolize_keys
    t = self.dup
    self.clear
    t.each_pair { |k, v| self[k.to_sym] = v }
    self
  end
end
APP_CONFIG.symbolize_keys


module ActiveSupport
  class BufferedLogger
    def add(severity, message = nil, progname = nil, &block)
      return if @level > severity
      message = (message || (block && block.call) || progname).to_s

      level = {
        0 => "DEBUG",
        1 => "INFO",
        2 => "WARN",
        3 => "ERROR",
        4 => "FATAL"
      }[severity] || "U"

      message = "[%s: %s #%d] %s" % [level,
                                     Time.now.strftime("%m%d %H:%M:%S"),
                                     $$,
                                     message]

      message = "#{message}\n" unless message[-1] == ?\n
      buffer << message
      auto_flush
      message
    end
  end
end

ActionController::Base.cache_store = :file_store, "/var/lib/pumpdump/cache"

# Initialize the rails application
Pumpdump::Application.initialize!


