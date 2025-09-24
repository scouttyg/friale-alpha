import { Controller } from "@hotwired/stimulus"

// Stimulus controller for payment methods
export default class extends Controller {
  static targets = ["form", "cardElement", "errors"]
  static values = {
    key: String,
    clientSecret: String
  }

  connect() {
    // Wait for Stripe script to load
    if (document.getElementById('stripe-js')) {
      document.getElementById('stripe-js').addEventListener('load', () => {
        this.initializeStripe()
      })
    } else {
      console.log("Stripe script not found")
    }

    // If script already loaded, initialize immediately
    if (window.Stripe) {
      this.initializeStripe()
    }
  }

  initializeStripe() {
    if (!this.hasKeyValue || !this.hasClientSecretValue) {
      console.log("Missing required values", {
        hasKey: this.hasKeyValue,
        hasSecret: this.hasClientSecretValue
      });
      return;
    }

    const stripe = window.Stripe(this.keyValue);
    const elements = stripe.elements();
    const card = elements.create('card');

    card.mount(this.cardElementTarget);

    // Handle validation errors
    card.addEventListener('change', (event) => {
      if (event.error) {
        this.errorsTarget.textContent = event.error.message;
      } else {
        this.errorsTarget.textContent = '';
      }

      // Enable/disable submit button
      this.element.querySelector('button[type="submit"]').disabled = !!event.error;
    });

    // Handle form submission
    this.element.addEventListener('submit', async (event) => {
      event.preventDefault();

      const { setupIntent, error } = await stripe.confirmCardSetup(
        this.clientSecretValue,
        {
          payment_method: {
            card: card
          }
        }
      );

      if (error) {
        this.errorsTarget.textContent = error.message;
      } else {
        // Send payment method ID to your server
        const hiddenInput = document.createElement('input');
        hiddenInput.setAttribute('type', 'hidden');
        hiddenInput.setAttribute('name', 'payment_method_id');
        hiddenInput.setAttribute('value', setupIntent.payment_method);
        this.element.appendChild(hiddenInput);

        this.element.submit();
      }
    });
  }

  disconnect() {
    // Clean up Stripe elements if needed
  }
}
