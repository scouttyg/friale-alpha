// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import UtilsController from "./utils_controller"

application.register("utils", UtilsController)