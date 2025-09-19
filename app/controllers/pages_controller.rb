class PagesController < ApplicationController
  def home; end

  def about; end

  def contact
    @contact_form_message = ContactFormMessage.new
  end

  def contact_post
    @contact_form_message = ContactFormMessage.new(contact_form_message_params)
    if @contact_form_message.save
      redirect_to contact_path, notice: "You have submitted your contact form request! We will be in touch soon."
    else
      error_messages = @contact_form_message.errors.full_messages.join(", ")
      redirect_to(contact_path, flash: { alert: "Your contact form message could not be sent: #{error_messages}" })
    end
  end

  def pricing
    @plans = Plan.active
  end

  private

  def contact_form_message_params
    params.require(:contact_form_message).permit(:email, :subject, :message)
  end
end
