import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Set initial checkbox state when controller connects
    const darkMode = localStorage.getItem('dark') === 'true';
    const dashboardDarkModeCheckbox = document.getElementById('toggle_dark_mode_checkbox');
    if (dashboardDarkModeCheckbox) {
      dashboardDarkModeCheckbox.checked = darkMode;
    }
  }

  toggleDarkMode(event) {
    event.preventDefault();
    event.stopPropagation();

    const html = document.querySelector("html");
    html.classList.toggle("dark");
    const isDark = html.classList.contains("dark");
    localStorage.setItem("dark", isDark);

    // Update icon states
    const themeToggleDarkIcon = document.getElementById('themeToggleDarkIcon');
    const themeToggleLightIcon = document.getElementById('themeToggleLightIcon');

    if (themeToggleDarkIcon && themeToggleLightIcon) {
      if (isDark) {
        themeToggleLightIcon.classList.remove('hidden');
        themeToggleDarkIcon.classList.add('hidden');
      } else {
        themeToggleDarkIcon.classList.remove('hidden');
        themeToggleLightIcon.classList.add('hidden');
      }
    }

    // Update dashboard checkbox if it exists
    const dashboardDarkModeCheckbox = document.getElementById('toggle_dark_mode_checkbox');
    if (dashboardDarkModeCheckbox) {
      dashboardDarkModeCheckbox.checked = isDark;
    }
  }
}
