import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

export { application }

// Apply dark mode immediately on page load to prevent flash
const darkMode = localStorage.getItem('dark') === 'true';
const html = document.documentElement;

if (darkMode) {
  html.classList.add('dark');
} else {
  html.classList.remove('dark');
}

document.addEventListener('turbo:load', () => {
  const darkMode = localStorage.getItem('dark') === 'true';

  // Update theme toggle icons to match current state
  const themeToggleDarkIcon = document.getElementById('themeToggleDarkIcon');
  const themeToggleLightIcon = document.getElementById('themeToggleLightIcon');

  if (themeToggleDarkIcon && themeToggleLightIcon) {
    // Change the icons inside the button based on previous settings
    if (darkMode) {
      themeToggleLightIcon.classList.remove('hidden');
      themeToggleDarkIcon.classList.add('hidden');
    } else {
      themeToggleDarkIcon.classList.remove('hidden');
      themeToggleLightIcon.classList.add('hidden');
    }
  }
})
