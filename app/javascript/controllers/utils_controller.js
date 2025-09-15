import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleDarkMode = () => {
    const html = document.querySelector("html");
    html.classList.toggle("dark");
    localStorage.setItem("dark", html.classList.contains("dark"));
  }
}
