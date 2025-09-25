module PushSubscriptions
  class Pusher
    VAPID_CONFIGURATION = {
      subject: "mailto:#{ENV.fetch('WEB_PUSH_EMAIL', nil)}",
      public_key: ENV.fetch("WEB_PUSH_PUBLIC_KEY", nil),
      private_key: ENV.fetch("WEB_PUSH_PRIVATE_KEY", nil)
    }.freeze

    STANDARD_NOTIFICATION_OPTIONS = [
      :body,
      :data,
      :dir,
      :icon,
      :lang,
      :tag
    ].freeze

    EXPERIMENTAL_NOTIFICATION_OPTIONS = [
      :actions,
      :badge,
      :image,
      :renotify,
      :requireInteraction,
      :silent,
      :timestamp,
      :vibrate
    ].freeze

    ALL_NOTIFICATION_OPTIONS = STANDARD_NOTIFICATION_OPTIONS | EXPERIMENTAL_NOTIFICATION_OPTIONS

    class Error < StandardError; end
    class InvalidVapidConfigurationError < Error; end

    # @param user [::User]
    #  A User from our application
    # @param title [String]
    #  "My Example Notification Title"
    # @param body [String]
    #  "My Example Notification Body"
    # @param options [Hash]
    # @option options [String] :body
    #  "My example notification body"
    # @option options [Hash] :data
    #  Structured clone of Notification, most likely a hash?
    # @option options [String] :dir
    #  "auto" | "ltr" | "rtl"
    # @option options [String] :icon
    #  "/icons/icon-192x192-maskable.png"
    # @option options [String] :lang
    #  "en-US", or any other language code
    # @option options [String] :tag
    #  "@creator.username", E.g a grouping system to combine similar notifications together
    # @option options [Array<String>] :actions
    #  !!EXPERIMENTAL!! - ['arbitrary', 'strings', 'here']
    # @option options [String] :badge
    #  !!EXPERIMENTAL!! - "/icons/fake-badge-here.png"
    # @option options [String] :image !!EXPERIMENTAL!! - "/fake/image.jpg"
    # @option options [Boolean] :renotify
    #  !!EXPERIMENTAL!! - Specifies whether the user should be notified after a new notification replaces an old one
    # @option options [Boolean] :requireInteraction
    #  !!EXPERIMENTAL!! - Specifies that a notification should remain active until the user clicks or dismisses it
    # @option options [Boolean] :silent
    #  !!EXPERIMENTAL!! - Specifies whether the notification should be silent, i.e., no sounds or vibrations should be issued
    # @option options [Integer] :timestamp
    #  !!EXPERIMENTAL!! - Integer time in milliseconds since epoch
    # @option options [Array<Integer>] :vibrate !!EXPERIMENTAL!! - A vibration pattern
    #
    # @return [PushSubscriptions::Pusher]
    def initialize(
      user:,
      title:,
      body:,
      options: {}
    )
      @user = user
      @title = title
      @body = body
      @options = default_options.merge(options.with_indifferent_access.slice(*ALL_NOTIFICATION_OPTIONS))
    end

    # Sends a push notification to the user for each browser they have registered a {::PushSubscription} with on our application
    #
    # @return [Boolean]
    def push!
      unless user.present? && user.is_a?(User)
        Rails.logger.info "[PushSubscriptions::Pusher] Invalid user"
        return false
      end

      was_successful = true

      user.push_subscriptions.active.newest_first.each do |push_subscription|
        was_successful = false unless send_push(push_subscription)
      end

      was_successful
    end

    private

      attr_reader :body, :options, :title, :user

      def default_options
        {
          body: body,
          icon: "/icons/icon-192x192-maskable.png",
          lang: "en-US"
        }
      end

      def send_push(push_subscription = nil)
        unless valid_vapid_configuration?
          raise InvalidVapidConfigurationError
        end

        unless valid_payload?
          Rails.logger.info "[PushSubscriptions::Pusher] Invalid payload"
          return false
        end

        unless valid_subscription?(push_subscription)
          Rails.logger.info "[PushSubscriptions::Pusher] push_subscription missing, expired, or invalid"
          return false
        end

        begin
          WebPush.payload_send(
            message: payload.to_json,
            endpoint: push_subscription.endpoint,
            p256dh: push_subscription.public_key,
            auth: push_subscription.auth_secret,
            vapid: VAPID_CONFIGURATION
          )

          true
        rescue WebPush::ExpiredSubscription
          Rails.logger.info "[PushSubscriptions::Pusher] Webpush could not be sent, push_subscription has expired."
          push_subscription.update(expires_at: Time.current)

          false
        rescue WebPush::InvalidSubscription, WebPush::Unauthorized => e
          case e
          when WebPush::InvalidSubscription
            Rails.logger.info "[PushSubscriptions::Pusher] Webpush could not be sent, push_subscription is invalid."
          when WebPush::Unauthorized
            Rails.logger.info "[PushSubscriptions::Pusher] Webpush was unauthorized (were VAPID keys recently changed?)"
          end
          push_subscription.destroy

          false
        rescue WebPush::ResponseError => e
          Rails.logger.info "[PushSubscriptions::Pusher] Response error from server, possibly due to too many notifications. " \
                            "Push Subscription: #{push_subscription.id}, " \
                            "Response Code: #{e.response.code}, " \
                            "Response Body: #{e.response.body}"

          false
        end
      end

      def valid_vapid_configuration
        @valid_vapid_configuration ||= VAPID_CONFIGURATION[:subject].present? &&
                                       VAPID_CONFIGURATION[:public_key].present? &&
                                       VAPID_CONFIGURATION[:private_key].present?
      end
      alias valid_vapid_configuration? valid_vapid_configuration

      def valid_payload
        @valid_payload ||= payload[:title].present? &&
                           payload[:options][:body].present?
      end
      alias valid_payload? valid_payload

      def payload
        @payload ||= { title: title, options: options }
      end

      def valid_subscription?(push_subscription)
        push_subscription.present? && push_subscription.active? && push_subscription.valid?
      end
  end
end
