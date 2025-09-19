# frozen_string_literal: true

class PushSubscriptionsController < SecureController
  def create
    push_subscription = current_user.push_subscriptions.create_or_find_by(
      endpoint: subscription_params[:endpoint],
      public_key: subscription_params[:keys][:p256dh],
      auth_secret: subscription_params[:keys][:auth]
    )

    if subscription_params[:expiration_time].present?
      new_expires_at = DateTime.parse(subscription_params[:expiration_time])
      push_subscription.update(expires_at: new_expires_at) if push_subscription.expires_at != new_expires_at
    end

    if push_subscription.errors.any?
      return render(json: { error: "Push subscription could not be created" }, status: :bad_request)
    end

    render json: {}, status: :created
  end

  def unsubscribe
    push_subscription = current_user.push_subscriptions.find_by(endpoint: subscription_params[:endpoint])
    return render(json: { error: "Not found" }, status: :not_found) if push_subscription.blank?

    push_subscription.destroy

    render json: {}, status: :ok
  end

  def unsubscribe_all
    current_user.push_subscriptions.destroy_all

    render json: {}, status: :ok
  end

  private

    def subscription_params
      params.require(:subscription).permit(:endpoint, :expiration_time, keys: [ :auth, :p256dh ])
    end
end
