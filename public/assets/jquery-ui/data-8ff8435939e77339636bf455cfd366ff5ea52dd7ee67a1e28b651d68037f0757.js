!function(e){"function"==typeof define&&define.amd?define(["jquery"],e):e(jQuery)}(function(e){return e.ui=e.ui||{},e.ui.version="1.12.1"}),function(e){"function"==typeof define&&define.amd?define(["jquery","./version"],e):e(jQuery)}(function(t){return t.extend(t.expr[":"],{data:t.expr.createPseudo?t.expr.createPseudo(function(n){return function(e){return!!t.data(e,n)}}):function(e,n,u){return!!t.data(e,u[3])}})});