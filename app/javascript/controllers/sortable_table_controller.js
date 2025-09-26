import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["header"]
  static values = {
    currentSort: String,
    currentDirection: String,
    baseUrl: String
  }

  connect() {
    this.updateSortIndicators()
  }

  sort(event) {
    event.preventDefault()

    const header = event.currentTarget
    const column = header.dataset.sortColumn

    if (!column) return

    // Determine new direction
    let newDirection = "asc"
    if (this.currentSortValue === column && this.currentDirectionValue === "asc") {
      newDirection = "desc"
    }

    // Build URL with sort parameters
    const url = new URL(this.baseUrlValue, window.location.origin)
    url.searchParams.set('sort', column)
    url.searchParams.set('direction', newDirection)

    // Preserve existing page parameter if present
    const currentUrl = new URL(window.location)
    if (currentUrl.searchParams.has('page')) {
      url.searchParams.set('page', '1') // Reset to first page when sorting
    }

    // Navigate with Turbo
    Turbo.visit(url.toString())
  }

  updateSortIndicators() {
    this.headerTargets.forEach(header => {
      const column = header.dataset.sortColumn
      const indicator = header.querySelector('.sort-indicator')

      if (!indicator) return

      // Clear all indicators
      indicator.innerHTML = ''
      indicator.className = 'sort-indicator ml-1 inline-block w-4 h-4'

      // Add indicator for current sort column
      if (column === this.currentSortValue) {
        if (this.currentDirectionValue === 'asc') {
          indicator.innerHTML = `
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M14.707 12.707a1 1 0 01-1.414 0L10 9.414l-3.293 3.293a1 1 0 01-1.414-1.414l4-4a1 1 0 011.414 0l4 4a1 1 0 010 1.414z" clip-rule="evenodd"/>
            </svg>
          `
          indicator.classList.add('text-primary-600')
        } else {
          indicator.innerHTML = `
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd"/>
            </svg>
          `
          indicator.classList.add('text-primary-600')
        }
      } else {
        // Show neutral sort indicator for sortable columns
        indicator.innerHTML = `
          <svg class="w-4 h-4 opacity-30" fill="currentColor" viewBox="0 0 20 20">
            <path d="M5 12l5-5 5 5H5z"/>
          </svg>
        `
        indicator.classList.add('text-gray-400')
      }
    })
  }

  currentSortValueChanged() {
    this.updateSortIndicators()
  }

  currentDirectionValueChanged() {
    this.updateSortIndicators()
  }
}
