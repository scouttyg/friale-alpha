import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["radio", "priceDisplay", "link"]
  static values = { planId: String }

  connect() {
    // Set initial state
    this.updateDisplay(this.radioTargets[0])
    this.updateButtonStyles()
  }

  toggle(event) {
    const button = event.currentTarget

    // Update all buttons' data-selected attribute
    this.radioTargets.forEach(radio => {
      radio.dataset.selected = (radio === button).toString()
    })

    this.updateDisplay(button)
    this.updateButtonStyles()
  }

  updateDisplay(button) {
    if (!button) return

    const price = button.dataset.price
    const interval = button.dataset.interval
    const periodId = button.dataset.periodId

    // Update price display
    this.priceDisplayTarget.innerHTML = `
      <span class="mr-2 text-5xl font-extrabold">${price}</span>
      <span class="text-gray-500">/${interval}</span>
    `

    // Update the "Get started" link to include the selected period
    const currentUrl = new URL(this.linkTarget.href)
    currentUrl.searchParams.set('plan_id', this.planIdValue)
    currentUrl.searchParams.set('plan_period_id', periodId)
    this.linkTarget.href = currentUrl.toString()
  }

  updateButtonStyles() {
    this.radioTargets.forEach(button => {
      if (button.dataset.selected === 'true') {
        button.classList.add('bg-primary-600', 'text-white')
        button.classList.remove('text-gray-700', 'dark:text-gray-300')
      } else {
        button.classList.remove('bg-primary-600', 'text-white')
        button.classList.add('text-gray-700', 'dark:text-gray-300')
      }
    })
  }
}
