require 'uri'

module Yesmail2

  # Note that when the yesmail documentation refers to a subscriber ID, in
  # our case it actually just means email.
  class Subscriber < ApiBase
    def self.api_path
      'subscribers'
    end

    # The GET /v2/subscribers call returns the profile information, subscriptions,
    # and/or message history for your subscribers.
    # params: email, limit, offset, view
    #
    # @option email [String] (optional) Filters the list of subscribers by that email address
    #
    # @option limit [Integer] (optional) The maximum number of subscribers to be provided
    #   within the request.  Valid values are integers 0-100.  The default is 25.
    # @option offset [String] (optional) The sequence number of the first subscriber to
    #   be provided within the request.
    # @option view [String] (optional) Valid values are “basic”, “profile”, “subscriptions”,
    #   “emails”, “messages”, “full.”
    def self.subscribers(params = {})
      #GET subscribers
      response = get(full_path, :params => params)
    end

    def self.view_schema
      #GET subscribers?view=schema
      response = get(full_path, :params => {:view => 'schema'})
    end

    # A convenience method for viewing what columns are available
    def self.columns
      view_schema['profile']['userAttrs'].map {|x| x['attributeName'] }
    end

    # Returns the profile information, subscriptions, and email summary
    # for a specified single subscriber
    # @param email [String]
    def self.subscriber(email)
      email = URI.encode(email)

      #GET subscribers/{id}
      response = get(full_path(email))
    end

    def self.profile(email)
      attrs = {}

      sub = Yesmail2::Subscriber.subscriber(email)
      sub['profile']['userAttrs'].each do |field|
        name = field.keys.first
        attrs[name] = field[name]
      end

      attrs
    end

    # @param email [String]
    # @return [Hash] the specified division’s subscription state
    #   information and event history, for the specified subscriber.
    def self.subscriber_divisions(email)
      #https://api.yesmail.com/v2/subscribers/{id}/subscriptions/{name}
      response = get(full_path(email, 'subscriptions'))
    end

    # Sets all of the subscriptions for this user to 'unsubscribed'.  Should
    # return an empty body if the call is successful.  Note that this doesn't
    # appear to actually delete a row.  It just unsubscribes.
    def self.delete_subscriber(email)
      #DELETE api.yesmail.com/v2/subscribers/{id}/subscriptions
      response = delete(full_path(email, 'subscriptions'))
    end

    #
    # @param email [String]
    # @param division_name [String]
    def self.subscriber_division_events(email, division_name)
      #GET api.yesmail.com/v2/subscribers/{id}/subscriptions/{name}
      response = get(full_path(email, 'subscriptions', division_name))
    end

    # see: https://developer.yesmail.com/post-subscriberssearch-0
    # @param search [Hash] a hash of key values that are used to filter the subscribers
    # @option limit [Integer] (optional) The maximum number of subscribers to be provided
    #   within the request.  Valid values are integers 0-100.  The default is 25.
    # @option offset [String] (optional) The sequence number of the first subscriber to
    #   be provided within the request.
    # @option view [String] (optional) Valid values are “basic”, “profile”, “subscriptions”,
    #   “emails”, “messages”, “full.”
    #
    # A sample query value:
    #  [
    #      {
    #          "profile.userAttrs.lastName": "Smith"
    #      },
    #      {
    #          "subscriptions.current": [
    #               {"division1": "subscribed"},
    #               {"division2": "unsubscribed"}
    #          ]
    #      },
    #      {
    #           "messages.templateId": ["1108018", "1108019", "1108020"]
    #      }
    #  ]
    def self.subscribers_search(search, params = {})
      params[:limit] ||= 100
      params[:offset] ||= 0
      params[:view] ||= 'profile'

      search = Array.wrap(search)
      payload = {:query => search}

      response = post(full_path('search'), payload.to_json, :content_type => :json, :accept => :json, :params => params)
    end

    # The subscriber array should look like....
    #
    #    [
    #        {
    #            "id": "jsmith@zzz.com",
    #            "email": "jsmith@zzz.com",
    #            "profile": {
    #                "userAttrs": [
    #                    {"firstName": "John"},
    #                    {"lastName": "Smith"},
    #                    …more Users Table attributes…
    #                ]
    #            }
    #        },
    #        {
    #            "id": "jsmith2@.com",
    #             "email": "jsmith2@.com",
    #            "profile": {
    #                "userAttrs": [
    #                    {"firstName": "Johanna"},
    #                    {"lastName": "Smith"},
    #                     …more Users Table attributes…
    #                ],
    #            }
    #        }
    #    ]
    #
    # @param subscribers [Array<Hash>] an array of hashes that each represent
    #   a user.
    # @param divisions [Array<String>] an array of divisions that each user
    #   will be subscribed to
    # @param existing_subscribers [String] what to do if one of the included
    #   subscribers already exists in the database? Choices are “replace”,
    #   “update”, “ignore”.
    # @param resubscribe [TrueClass, FalseClass] specifies whether if one of
    #   the users already exists and has been marked as unsubscribed, should
    #   this attempt to resubscribe them still work?
    def self.update_subscribers(subscribers, divisions,
        existing_subscribers = 'update', resubscribe = false)

      divisions = [divisions] if divisions.is_a?(String)

      data = {
        :existingSubscribers => existing_subscribers,
        :resubscribe => resubscribe,
        :memberOf => divisions,
        :subscribers => subscribers
      }

      #POST subscribers/import
      post(full_path('import'), data.to_json, :content_type => :json, :accept => :json)
    end

    # Iterates through each of the subscribers.  Pulls them in batches to
    # save time.
    # warning: don't add or delete items while iterating through or else
    # the counts will get messed up.
    # @param search [Hash] a hash of key-value pairs used to filter records.
    #   iterating through the entire subscribers table takes prohibitively long
    #   so narrowing at least by something is recommended.
    def self.each(search, options={})
      return to_enum(:each, search, options) unless block_given?

      offset = options[:offset] || 0
      view = options[:view] || 'profile'
      absolute_max = options[:absolute_max]

      # will get updated during the first execution of the loop
      max = 1
      returned_count = nil

      while offset < max && (absolute_max.nil? || offset < absolute_max)
        begin
          p = {:offset => offset, :view => view}
          result = self.subscribers_search(search, p)

          max = result['total']
          returned_count = result['count']
          puts "Fetched #{result['count']} starting with #{result['offset']}"

          result['subscribers'].each {|x| yield x }
        rescue StandardError => e
          # todo: make the exception type more specific
          # do nothing here.  this batch has failed and thats the end of it.
          error(e)
          error(e.message)
          error(e.backtrace)
        end

        offset += returned_count
      end
    end

    # Same as ::each except that it yields groups of subscribers rather than
    # individual subscribers.
    def self.each_batch(search, options={})
      return to_enum(:each_batch, search, options) unless block_given?

      batch_size = options[:batch_size] || 25
      e = each(search,options)

      i = -1
      chunks = e.chunk { i += 1; i / batch_size }
      chunks.each {|c| yield c[1] }
    end
  end
end


