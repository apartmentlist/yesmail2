yesmail2
========

Ruby an a very unopinionated wrapper for v2 of the yesmail api.  It contains support for the the following modules:

* Subscribers API
* Emails API
* Tickets API
* Reference-Data API
* Target Lists API


For more information for what these do and how to use this gem, view the original yesmail documentation.  From
there, everything will explain itself.
http://developer.yesmail.com/yesmail-api-overview



### Setup

To use Yesmail2, you need to configure the gem with your your api user and 
api key.  Yesmail's documentation isn't obvious on what these are, 
but what I've seen your api user should look like a username, and your 
api key should look like a long string of letters numbers.  

In rails, you'd put the following code in an initializer.

    Yesmail2.config.api_user = '{{ your api user }}'
    Yesmail2.config.api_key = '{{ your api key }}'
    
    # Configure custom log levels
    if Rails.env.development? || Rails.env.test?
      Yesmail2.config.logger = Logger.new(STDOUT).tap {|x| x.level = Logger::INFO }
    else
      Yesmail2.config.logger = Rails.logger
    end


### License

Released under the MIT license
