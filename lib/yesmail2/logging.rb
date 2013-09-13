module Yesmail2
  module Logging
    def info(*args); Yesmail2.config.logger.info(*args); end
    def warn(*args); Yesmail2.config.logger.warn(*args); end
    def error(*args); Yesmail2.config.logger.error(*args); end
  end
end
