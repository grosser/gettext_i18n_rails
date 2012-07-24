//= require ./jed 

(function(){ 
  locale = document.getElementsByTagName('html')[0].lang;
  if(!locale){
    console.warn('No locale found as an html attribute, using default.');
    return;
  }
  var i18n = new Jed(locales[locale] || {});
  window.__ = function(){ return i18n.gettext.apply(i18n, arguments) };
})();
