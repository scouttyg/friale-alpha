module PaymentMethodsHelper
  def payment_method_icon(brand)
    case brand.downcase
    when "visa"
      render template: "shared/icons/payments/visa", locals: { html_class: "h-8 w-auto" }
    when "mastercard"
      render template: "shared/icons/payments/mastercard", locals: { html_class: "h-8 w-auto" }
    else
      render template: "shared/icons/payments/generic_card", locals: { html_class: "h-8 w-auto" }
    end
  end
end
