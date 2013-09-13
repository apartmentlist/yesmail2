module Yesmail2

end


require 'yesmail/config'
require 'yesmail/api_base'
require 'yesmail/email'
require 'yesmail/logging'
require 'yesmail/reference_data'
require 'yesmail/subscriber'
require 'yesmail/ticket'

## include all the nested files
#project_root = File.dirname(File.absolute_path(__FILE__))
#
#files = ['/api_base.rb', '/config.rb', '/email.rb', '/logging.rb', '/reference_data.rb',
# '/subscriber.rb', '/ticket.rb', '/yesmail2.rb']
#files.each {|filename| require project_root + "/#{filename}" }
