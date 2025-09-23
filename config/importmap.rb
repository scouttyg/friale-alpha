# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Digital Credentials modules
pin "digital_credentials", to: "digital_credentials.js"
pin_all_from "app/javascript/digital_credentials", under: "digital_credentials"
