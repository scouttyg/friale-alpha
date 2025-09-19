module Utils
  module Settings
    class Frontend
      APPLICATION_NAME = I18n.t(:application_name)
      COLORS = {
        primary: "#FFFFFF"
      }.freeze

      DEFAULT_DESCRIPTION = "#{APPLICATION_NAME} is a great way to save your data in a secure way.".freeze
      SEO = {
        keywords: "data, save, secure, data-later, data later, data-later.com"
      }.freeze

      SOCIALS = {
        twitter: "https://twitter.com/data_later",
        facebook: "https://www.facebook.com/data_later",
        linkedin: "https://www.linkedin.com/company/data-later",
        github: "https://www.github.com/data-later"
      }.freeze
    end
  end
end
