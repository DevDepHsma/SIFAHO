(function(){this.RailsAdmin||(this.RailsAdmin={}),this.RailsAdmin.I18n=function(){function t(){}return t.init=function(t,i){if(this.locale=t,this.translations=i,moment.locale(this.locale),"string"==typeof this.translations)return this.translations=JSON.parse(this.translations)},t.t=function(t){var i;return i=t.charAt(0).toUpperCase()+t.replace(/_/g," ").slice(1),this.translations[t]||i},t}()}).call(this);