module Yesmail2
  class Email < ApiBase
    def self.api_path
      'emails'
    end

    # Send an
    # @see https://developer.yesmail.com/post-emailssend
    #
    # @param [Hash] content A hash consisting of a single element, :templateId,
    #   the templateID of the message template to be sent. e.g
    #
    #     { templateId: 997146 }
    #
    # @param [Array<Hash>] recipients An array consisting of the recipients of
    #   the email. This request currently supports a single recipient only.
    #   Each recipient is specified as a collection containing the following
    #   elements:
    #     * :id (optional). Customer-defined unique ID. Required if
    #       updateProfile=true.
    #     * :email (mandaory). The subscriber's email address. One of either id
    #       or email must be specified, and if the recipient is not in the
    #       subscribers database, both id and email are required.
    #     * :profile (optional). A collection consisting of subscriber
    #       attributes. In current implementation, must consist of a single
    #       :userAttrs array. If updateProfile = false, these attributes will
    #       be used only for personalization of the email being sent. If
    #       updateProfile = true, the database will be updated with any
    #       attributes provided (as well as being used for personalization as
    #       appropriate).
    #         - :subscriptions (optional). A collection consisting of up to two
    #           arrays:
    #             + :add (optional) An array of subscriptions to which the
    #               subscriber is to be subscribed, in conjunction with sending
    #               the email.
    #             + :remove (optional) An array of subscriptions to which the
    #               subscriber is to be unsubscribed, in conjunction with
    #               sending the email. remove:[“*”] is permitted; this
    #               unsubscribes from all subscriptions. If both add and remove
    #               are specified, the remove operation takes place before the
    #               add operation.
    #             + :isMemberOf (optional) An array of subscriptions which will
    #               be checked for subscription status if transactional =
    #               false. The subscriber must be subscribed to at least one of
    #               the subscriptions in this array. This check is performed
    #               after any add or remove processing.
    #   e.g.
    #
    #    [
    #      {
    #        id: 'test@example.com',
    #        email: 'test@example.com',
    #        profile: {
    #          userAttrs: [
    #            {
    #              subscriptions: {
    #                add: ['sub1', 'sub2']
    #              }
    #            }
    #          ]
    #        }
    #      }
    #    ]
    #
    # @option options [String] :responseUri A customer-specified URI where
    #   Yesmail’s service can post the final status of the request. See
    #   Tickets API documentation for more details.
    # @option options [String] :responseRef A customer-specified value that the
    #   customer may wish to use to track the ticket internally. See Tickets
    #   API documentation for more details.
    # @option options [String] :transactional (false) A flag that specifies
    #   whether the email is transactional (to be sent regardless of
    #   subscription status) or not.
    #     * false - Do not send email if recipient is globally unsubscribed,
    #       “dead”, or not subscribed to at least one of the subscriptions
    #       specified in the “subscriptions” isMemberOf payload element.
    #     * true - Send email regardless of subscription status.
    # @option options [String] :updateProfile (false) A flag that specifies
    #   whether any profile information should be updated in the database.
    #     * true - Perform database update only for all elements in request
    #       payload profile, equivalent to POST subscribers/{id}/update.
    #     * false - Do not do so.
    def self.send(content, recipients, options = {})
      payload = options.merge(content: content, recipients: recipients).to_json
      post(full_path('send'), payload, content_type: :json, accept: :json)
    end
  end
end


