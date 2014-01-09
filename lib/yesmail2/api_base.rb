require 'hashie'
require 'json'
require 'rest_client'

module Yesmail2
  class ApiBase
    require_relative 'logging'
    extend Yesmail2::Logging

    # combine all the paths to make our full path
    # each argument is another string that gets joined into the path
    def self.full_path(*extra_parts)
      base_path =  Yesmail2.config.base_path

      api_path = self.api_path #copy

      parts = [base_path, api_path]

      parts += extra_parts

      parts = parts.map {|s| strip_leading_trailing(s, '/') }
      parts.join('/')
    end

    def self.strip_leading_trailing(string, char)
      _string = string.to_s.dup
      _string.slice!(0) if _string[0] == char
      _string = _string[(0..._string.length - 1)] if _string[-1] == char
      _string
    end

    def self.get(*args)
      http_method(:get, *args)
    end

    def self.post(*args)
      http_method(:post, *args)
    end

    def self.put(*args)
      http_method(:put, *args)
    end

    def self.delete(*args)
      http_method(:delete, *args)
    end

    def self.http_method(method, *args)
      result = nil

      options = if args[-1].is_a?(Hash)
        args[-1] ||= {}
      else
        {}.tap {|h| args << h }
      end

      options['Api-User'] = Yesmail2.config.api_user
      options['Api-Key'] = Yesmail2.config.api_key

      try_http_method(method, 0, *args)
    end

    def self.log_response(response)
      warn '--RESPONSE--'
      warn "CODE: #{response.code}"
      warn "HEADERS: #{response.headers}"
      warn "BODY: #{response.body}"
    end

    def self.try_http_method(method, tries, *extra_args)
      #protect against modifications
      _args = extra_args.dup
      _args[1] = _args[1].dup

      r = RestClient.send(method, *_args) do |response, request, result, &block|
        # Look for any successful response code: 2XX
        if response.code.to_s =~ /2../
          # In some cases, Yesmail's response is an empty string, which is not
          # valid JSON, just pretend we got an empty hash so we can pass that
          # to Hashie with no issues.
          hash = response == '' ? {} : JSON.parse(response)
          r = Hashie::Mash.new(hash)
          log_request(request)
          log_response(response)
          r
        else
          if response.code == 401 && tries < Yesmail2.config.retries
            puts "Unauthorized.  Retrying attempt #{tries}"
            try_http_method(method, tries + 1, *extra_args)
          else
            log_request(request)
            log_response(response)
            response.return!(request, result, &block)
          end
        end
      end

      r
    end

    def self.log_request(request)
      warn '--REQUEST--'
      warn "URL: #{request.url}"
      warn "METHOD: #{request.method}"
      warn "HEADERS: #{request.headers}"

      if !request.args[:payload].nil?
        warn "BODY: #{request.args[:payload]}"
      end
    end

    def self.api_path
      raise NotImplementedError
    end

  end
end
