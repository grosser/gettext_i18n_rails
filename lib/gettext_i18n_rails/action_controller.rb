# Autoloading in initializers is deprecated on rails 6.0.  This delays initialization using the on_load
# hooks, but does not change behaviour for existing rails versions.
path_controller = ->() {
  class ::ActionController::Base
    def set_gettext_locale
      requested_locale = params[:locale] || session[:locale] || cookies[:locale] ||  request.env['HTTP_ACCEPT_LANGUAGE'] || I18n.default_locale
      locale = FastGettext.set_locale(requested_locale)
      session[:locale] = locale
      I18n.locale = locale # some weird overwriting in action-controller makes this necessary ... see I18nProxy
    end
  end
}
if defined?(Rails) && Rails::VERSION::MAJOR >= 6
  ActiveSupport.on_load(:action_controller_base) do
    path_controller.call
  end
else
  path_controller.call
end