// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import PaymentMethodsController from "./payment_methods_controller"
import PlanPeriodController from "./plan_period_controller"
import UtilsController from "./utils_controller"

application.register("payment-methods", PaymentMethodsController)
application.register("plan-period", PlanPeriodController)
application.register("utils", UtilsController)
