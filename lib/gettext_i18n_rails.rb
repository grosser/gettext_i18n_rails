# include translations into all the places it needs to go...
[ActiveRecord::Base,ActionController::Base,ActionView::Base,ActionMailer::Base].each do |clas|
  clas.send(:include,FastGettext::Translation)
end
module ApplicationHelper
  include FastGettext::Translation
end

#link i18n and FastGettext.locale
I18n.backend = I18n::Backend::Simple.new
require 'gettext_i18n_rails/gettext_hacks'

#method that will set the locale from cookies/session/header/params
#recommended in FIRST before_filter
class ActionController::Base
  def set_gettext_locale
    requested_locale = params[:locale] || session[:locale] || cookies[:locale] ||  requested_locales_from_header
    #try each locale, and keep the best that was accepted
    [*requested_locale].reverse.each {|l|FastGettext.set_locale(l)}
    session[:locale] = FastGettext.locale
  end

  private

  def requested_locales_from_header
    #yeah wtf, weird shit stolen from gettext...
    request.env['HTTP_ACCEPT_LANGUAGE'].to_s.gsub(/\s/, "").split(/,/).map{|v| v.split(";q=")}.map{|j| [j[0], j[1] ? j[1].to_f : 1.0]}.sort{|a,b| -(a[1] <=> b[1])}.map{|x|x[0].to_s.sub('-','_')}
  end
end