// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import PaymentMethodsController from "./payment_methods_controller"
import UtilsController from "./utils_controller"

application.register("payment-methods", PaymentMethodsController)
application.register("utils", UtilsController)
