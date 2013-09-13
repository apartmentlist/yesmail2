require 'hashie'
require 'logger'

module Yesmail2
  def self.config
    if @config.nil?
      @config = Hashie::Mash.new(defaults)
    end

    @config
  end

  def self.defaults
    {
      :api_user => '',
      :api_key => '',
      :base_path => 'https://api.yesmail.com/v2/',
      :retries => 5,
      :logger => Logger.new(STDOUT).tap {|x| x.level = Logger::DEBUG }
    }
  end
end
