require "stripe"
Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY", nil)

StripeEvent.signing_secret = ENV.fetch("STRIPE_SIGNING_SECRET", nil)
StripeEvent.configure do |events|
  events.subscribe "charge.failed" do |event|
    # Define subscriber behavior based on the event object
    event.class       #=> Stripe::Event
    event.type        #=> "charge.failed"
    event.data.object #=> #<Stripe::Charge:0x3fcb34c115f8>
  end

  events.all do |event|
    # Handle all event types - logging, etc.
  end
end
