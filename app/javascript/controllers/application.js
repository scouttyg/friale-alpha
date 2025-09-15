import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

export { application }

document.addEventListener('turbo:load', () => {
  const dashboardDarkMode = localStorage.getItem('dark') === 'true';
  const dashboardDarkModeCheckbox = document.getElementById('toggle_dark_mode_checkbox');
  if (dashboardDarkMode && dashboardDarkModeCheckbox && !dashboardDarkModeCheckbox.checked) {
    dashboardDarkModeCheckbox.checked = true;
  }

  const themeToggleDarkIcon = document.getElementById('themeToggleDarkIcon');
  const themeToggleLightIcon = document.getElementById('themeToggleLightIcon');

  if (themeToggleDarkIcon && themeToggleLightIcon) {
    // Change the icons inside the button based on previous settings
    if (localStorage.getItem('color-theme') === 'dark' || (!('color-theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
      themeToggleLightIcon.classList.remove('hidden');
    } else {
      themeToggleDarkIcon.classList.remove('hidden');
    }
  }
})
