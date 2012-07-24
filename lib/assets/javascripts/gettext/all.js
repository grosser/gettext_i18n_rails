//= require ./jed 

(function(){ 
  locale = document.getElementsByTagName('html')[0].lang;
  if(!locale){
    console.warn('No locale found as an html attribute, using default.');
    return;
  }
  var i18n = new Jed(locales[locale] || {});
  window.__ = function(){ return i18n.gettext.apply(i18n, arguments) };
  window.gettext = window.__;
  window.n__ = function(){ return i18n.ngettext.apply(i18n, arguments) };
  window.ngettext = window.n__;
  window.i18n = i18n;
})();
