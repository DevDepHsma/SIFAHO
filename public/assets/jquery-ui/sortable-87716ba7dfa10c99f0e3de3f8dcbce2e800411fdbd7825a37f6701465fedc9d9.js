!function(t){"function"==typeof define&&define.amd?define(["jquery"],t):t(jQuery)}(function(h){function s(t,e){var i,s,n,o=t.nodeName.toLowerCase();return"area"===o?(s=(i=t.parentNode).name,!(!t.href||!s||"map"!==i.nodeName.toLowerCase())&&(!!(n=h("img[usemap='#"+s+"']")[0])&&r(n))):(/^(input|select|textarea|button|object)$/.test(o)?!t.disabled:"a"===o&&t.href||e)&&r(t)}function r(t){return h.expr.filters.visible(t)&&!h(t).parents().addBack().filter(function(){return"hidden"===h.css(this,"visibility")}).length}var t,e,i,n;h.ui=h.ui||{},h.extend(h.ui,{version:"1.11.4",keyCode:{BACKSPACE:8,COMMA:188,DELETE:46,DOWN:40,END:35,ENTER:13,ESCAPE:27,HOME:36,LEFT:37,PAGE_DOWN:34,PAGE_UP:33,PERIOD:190,RIGHT:39,SPACE:32,TAB:9,UP:38}}),h.fn.extend({scrollParent:function(t){var e=this.css("position"),i="absolute"===e,s=t?/(auto|scroll|hidden)/:/(auto|scroll)/,n=this.parents().filter(function(){var t=h(this);return(!i||"static"!==t.css("position"))&&s.test(t.css("overflow")+t.css("overflow-y")+t.css("overflow-x"))}).eq(0);return"fixed"!==e&&n.length?n:h(this[0].ownerDocument||document)},uniqueId:(t=0,function(){return this.each(function(){this.id||(this.id="ui-id-"+ ++t)})}),removeUniqueId:function(){return this.each(function(){/^ui-id-\d+$/.test(this.id)&&h(this).removeAttr("id")})}}),h.extend(h.expr[":"],{data:h.expr.createPseudo?h.expr.createPseudo(function(e){return function(t){return!!h.data(t,e)}}):function(t,e,i){return!!h.data(t,i[3])},focusable:function(t){return s(t,!isNaN(h.attr(t,"tabindex")))},tabbable:function(t){var e=h.attr(t,"tabindex"),i=isNaN(e);return(i||0<=e)&&s(t,!i)}}),h("<a>").outerWidth(1).jquery||h.each(["Width","Height"],function(t,i){function s(t,e,i,s){return h.each(n,function(){e-=parseFloat(h.css(t,"padding"+this))||0,i&&(e-=parseFloat(h.css(t,"border"+this+"Width"))||0),s&&(e-=parseFloat(h.css(t,"margin"+this))||0)}),e}var n="Width"===i?["Left","Right"]:["Top","Bottom"],o=i.toLowerCase(),r={innerWidth:h.fn.innerWidth,innerHeight:h.fn.innerHeight,outerWidth:h.fn.outerWidth,outerHeight:h.fn.outerHeight};h.fn["inner"+i]=function(t){return t===undefined?r["inner"+i].call(this):this.each(function(){h(this).css(o,s(this,t)+"px")})},h.fn["outer"+i]=function(t,e){return"number"!=typeof t?r["outer"+i].call(this,t):this.each(function(){h(this).css(o,s(this,t,!0,e)+"px")})}}),h.fn.addBack||(h.fn.addBack=function(t){return this.add(null==t?this.prevObject:this.prevObject.filter(t))}),h("<a>").data("a-b","a").removeData("a-b").data("a-b")&&(h.fn.removeData=(e=h.fn.removeData,function(t){return arguments.length?e.call(this,h.camelCase(t)):e.call(this)})),h.ui.ie=!!/msie [\w.]+/.exec(navigator.userAgent.toLowerCase()),h.fn.extend({focus:(n=h.fn.focus,function(e,i){return"number"==typeof e?this.each(function(){var t=this;setTimeout(function(){h(t).focus(),i&&i.call(t)},e)}):n.apply(this,arguments)}),disableSelection:(i="onselectstart"in document.createElement("div")?"selectstart":"mousedown",function(){return this.bind(i+".ui-disableSelection",function(t){t.preventDefault()})}),enableSelection:function(){return this.unbind(".ui-disableSelection")},zIndex:function(t){if(t!==undefined)return this.css("zIndex",t);if(this.length)for(var e,i,s=h(this[0]);s.length&&s[0]!==document;){if(("absolute"===(e=s.css("position"))||"relative"===e||"fixed"===e)&&(i=parseInt(s.css("zIndex"),10),!isNaN(i)&&0!==i))return i;s=s.parent()}return 0}}),h.ui.plugin={add:function(t,e,i){var s,n=h.ui[t].prototype;for(s in i)n.plugins[s]=n.plugins[s]||[],n.plugins[s].push([e,i[s]])},call:function(t,e,i,s){var n,o=t.plugins[e];if(o&&(s||t.element[0].parentNode&&11!==t.element[0].parentNode.nodeType))for(n=0;n<o.length;n++)t.options[o[n][0]]&&o[n][1].apply(t.element,i)}}}),function(t){"function"==typeof define&&define.amd?define(["jquery"],t):t(jQuery)}(function(c){var o,i=0,h=Array.prototype.slice;return c.cleanData=(o=c.cleanData,function(t){var e,i,s;for(s=0;null!=(i=t[s]);s++)try{(e=c._data(i,"events"))&&e.remove&&c(i).triggerHandler("remove")}catch(n){}o(t)}),c.widget=function(t,i,e){var s,n,o,r,h={},a=t.split(".")[0];return t=t.split(".")[1],s=a+"-"+t,e||(e=i,i=c.Widget),c.expr[":"][s.toLowerCase()]=function(t){return!!c.data(t,s)},c[a]=c[a]||{},n=c[a][t],o=c[a][t]=function(t,e){if(!this._createWidget)return new o(t,e);arguments.length&&this._createWidget(t,e)},c.extend(o,n,{version:e.version,_proto:c.extend({},e),_childConstructors:[]}),(r=new i).options=c.widget.extend({},r.options),c.each(e,function(e,s){var n,o;c.isFunction(s)?h[e]=(n=function(){return i.prototype[e].apply(this,arguments)},o=function(t){return i.prototype[e].apply(this,t)},function(){var t,e=this._super,i=this._superApply;return this._super=n,this._superApply=o,t=s.apply(this,arguments),this._super=e,this._superApply=i,t}):h[e]=s}),o.prototype=c.widget.extend(r,{widgetEventPrefix:n&&r.widgetEventPrefix||t},h,{constructor:o,namespace:a,widgetName:t,widgetFullName:s}),n?(c.each(n._childConstructors,function(t,e){var i=e.prototype;c.widget(i.namespace+"."+i.widgetName,o,e._proto)}),delete n._childConstructors):i._childConstructors.push(o),c.widget.bridge(t,o),o},c.widget.extend=function(t){for(var e,i,s=h.call(arguments,1),n=0,o=s.length;n<o;n++)for(e in s[n])i=s[n][e],s[n].hasOwnProperty(e)&&i!==undefined&&(c.isPlainObject(i)?t[e]=c.isPlainObject(t[e])?c.widget.extend({},t[e],i):c.widget.extend({},i):t[e]=i);return t},c.widget.bridge=function(o,e){var r=e.prototype.widgetFullName||o;c.fn[o]=function(i){var t="string"==typeof i,s=h.call(arguments,1),n=this;return t?this.each(function(){var t,e=c.data(this,r);return"instance"===i?(n=e,!1):e?c.isFunction(e[i])&&"_"!==i.charAt(0)?(t=e[i].apply(e,s))!==e&&t!==undefined?(n=t&&t.jquery?n.pushStack(t.get()):t,!1):void 0:c.error("no such method '"+i+"' for "+o+" widget instance"):c.error("cannot call methods on "+o+" prior to initialization; attempted to call method '"+i+"'")}):(s.length&&(i=c.widget.extend.apply(null,[i].concat(s))),this.each(function(){var t=c.data(this,r);t?(t.option(i||{}),t._init&&t._init()):c.data(this,r,new e(i,this))})),n}},c.Widget=function(){},c.Widget._childConstructors=[],c.Widget.prototype={widgetName:"widget",widgetEventPrefix:"",defaultElement:"<div>",options:{disabled:!1,create:null},_createWidget:function(t,e){e=c(e||this.defaultElement||this)[0],this.element=c(e),this.uuid=i++,this.eventNamespace="."+this.widgetName+this.uuid,this.bindings=c(),this.hoverable=c(),this.focusable=c(),e!==this&&(c.data(e,this.widgetFullName,this),this._on(!0,this.element,{remove:function(t){t.target===e&&this.destroy()}}),this.document=c(e.style?e.ownerDocument:e.document||e),this.window=c(this.document[0].defaultView||this.document[0].parentWindow)),this.options=c.widget.extend({},this.options,this._getCreateOptions(),t),this._create(),this._trigger("create",null,this._getCreateEventData()),this._init()},_getCreateOptions:c.noop,_getCreateEventData:c.noop,_create:c.noop,_init:c.noop,destroy:function(){this._destroy(),this.element.unbind(this.eventNamespace).removeData(this.widgetFullName).removeData(c.camelCase(this.widgetFullName)),this.widget().unbind(this.eventNamespace).removeAttr("aria-disabled").removeClass(this.widgetFullName+"-disabled ui-state-disabled"),this.bindings.unbind(this.eventNamespace),this.hoverable.removeClass("ui-state-hover"),this.focusable.removeClass("ui-state-focus")},_destroy:c.noop,widget:function(){return this.element},option:function(t,e){var i,s,n,o=t;if(0===arguments.length)return c.widget.extend({},this.options);if("string"==typeof t)if(o={},t=(i=t.split(".")).shift(),i.length){for(s=o[t]=c.widget.extend({},this.options[t]),n=0;n<i.length-1;n++)s[i[n]]=s[i[n]]||{},s=s[i[n]];if(t=i.pop(),1===arguments.length)return s[t]===undefined?null:s[t];s[t]=e}else{if(1===arguments.length)return this.options[t]===undefined?null:this.options[t];o[t]=e}return this._setOptions(o),this},_setOptions:function(t){var e;for(e in t)this._setOption(e,t[e]);return this},_setOption:function(t,e){return this.options[t]=e,"disabled"===t&&(this.widget().toggleClass(this.widgetFullName+"-disabled",!!e),e&&(this.hoverable.removeClass("ui-state-hover"),this.focusable.removeClass("ui-state-focus"))),this},enable:function(){return this._setOptions({disabled:!1})},disable:function(){return this._setOptions({disabled:!0})},_on:function(r,h,t){var a,l=this;"boolean"!=typeof r&&(t=h,h=r,r=!1),t?(h=a=c(h),this.bindings=this.bindings.add(h)):(t=h,h=this.element,a=this.widget()),c.each(t,function(t,e){function i(){if(r||!0!==l.options.disabled&&!c(this).hasClass("ui-state-disabled"))return("string"==typeof e?l[e]:e).apply(l,arguments)}"string"!=typeof e&&(i.guid=e.guid=e.guid||i.guid||c.guid++);var s=t.match(/^([\w:-]*)\s*(.*)$/),n=s[1]+l.eventNamespace,o=s[2];o?a.delegate(o,n,i):h.bind(n,i)})},_off:function(t,e){e=(e||"").split(" ").join(this.eventNamespace+" ")+this.eventNamespace,t.unbind(e).undelegate(e),this.bindings=c(this.bindings.not(t).get()),this.focusable=c(this.focusable.not(t).get()),this.hoverable=c(this.hoverable.not(t).get())},_delay:function(t,e){function i(){return("string"==typeof t?s[t]:t).apply(s,arguments)}var s=this;return setTimeout(i,e||0)},_hoverable:function(t){this.hoverable=this.hoverable.add(t),this._on(t,{mouseenter:function(t){c(t.currentTarget).addClass("ui-state-hover")},mouseleave:function(t){c(t.currentTarget).removeClass("ui-state-hover")}})},_focusable:function(t){this.focusable=this.focusable.add(t),this._on(t,{focusin:function(t){c(t.currentTarget).addClass("ui-state-focus")},focusout:function(t){c(t.currentTarget).removeClass("ui-state-focus")}})},_trigger:function(t,e,i){var s,n,o=this.options[t];if(i=i||{},(e=c.Event(e)).type=(t===this.widgetEventPrefix?t:this.widgetEventPrefix+t).toLowerCase(),e.target=this.element[0],n=e.originalEvent)for(s in n)s in e||(e[s]=n[s]);return this.element.trigger(e,i),!(c.isFunction(o)&&!1===o.apply(this.element[0],[e].concat(i))||e.isDefaultPrevented())}},c.each({show:"fadeIn",hide:"fadeOut"},function(o,r){c.Widget.prototype["_"+o]=function(e,t,i){"string"==typeof t&&(t={effect:t});var s,n=t?!0===t||"number"==typeof t?r:t.effect||r:o;"number"==typeof(t=t||{})&&(t={duration:t}),s=!c.isEmptyObject(t),t.complete=i,t.delay&&e.delay(t.delay),s&&c.effects&&c.effects.effect[n]?e[o](t):n!==o&&e[n]?e[n](t.duration,t.easing,i):e.queue(function(t){c(this)[o](),i&&i.call(e[0]),t()})}}),c.widget}),function(t){"function"==typeof define&&define.amd?define(["jquery","./widget"],t):t(jQuery)}(function(n){var o=!1;return n(document).mouseup(function(){o=!1}),n.widget("ui.mouse",{version:"1.11.4",options:{cancel:"input,textarea,button,select,option",distance:1,delay:0},_mouseInit:function(){var e=this;this.element.bind("mousedown."+this.widgetName,function(t){return e._mouseDown(t)}).bind("click."+this.widgetName,function(t){if(!0===n.data(t.target,e.widgetName+".preventClickEvent"))return n.removeData(t.target,e.widgetName+".preventClickEvent"),t.stopImmediatePropagation(),!1}),this.started=!1},_mouseDestroy:function(){this.element.unbind("."+this.widgetName),this._mouseMoveDelegate&&this.document.unbind("mousemove."+this.widgetName,this._mouseMoveDelegate).unbind("mouseup."+this.widgetName,this._mouseUpDelegate)},_mouseDown:function(t){if(!o){this._mouseMoved=!1,this._mouseStarted&&this._mouseUp(t),this._mouseDownEvent=t;var e=this,i=1===t.which,s=!("string"!=typeof this.options.cancel||!t.target.nodeName)&&n(t.target).closest(this.options.cancel).length;return!(i&&!s&&this._mouseCapture(t))||(this.mouseDelayMet=!this.options.delay,this.mouseDelayMet||(this._mouseDelayTimer=setTimeout(function(){e.mouseDelayMet=!0},this.options.delay)),this._mouseDistanceMet(t)&&this._mouseDelayMet(t)&&(this._mouseStarted=!1!==this._mouseStart(t),!this._mouseStarted)?(t.preventDefault(),!0):(!0===n.data(t.target,this.widgetName+".preventClickEvent")&&n.removeData(t.target,this.widgetName+".preventClickEvent"),this._mouseMoveDelegate=function(t){return e._mouseMove(t)},this._mouseUpDelegate=function(t){return e._mouseUp(t)},this.document.bind("mousemove."+this.widgetName,this._mouseMoveDelegate).bind("mouseup."+this.widgetName,this._mouseUpDelegate),t.preventDefault(),o=!0))}},_mouseMove:function(t){if(this._mouseMoved){if(n.ui.ie&&(!document.documentMode||document.documentMode<9)&&!t.button)return this._mouseUp(t);if(!t.which)return this._mouseUp(t)}return(t.which||t.button)&&(this._mouseMoved=!0),this._mouseStarted?(this._mouseDrag(t),t.preventDefault()):(this._mouseDistanceMet(t)&&this._mouseDelayMet(t)&&(this._mouseStarted=!1!==this._mouseStart(this._mouseDownEvent,t),this._mouseStarted?this._mouseDrag(t):this._mouseUp(t)),!this._mouseStarted)},_mouseUp:function(t){return this.document.unbind("mousemove."+this.widgetName,this._mouseMoveDelegate).unbind("mouseup."+this.widgetName,this._mouseUpDelegate),this._mouseStarted&&(this._mouseStarted=!1,t.target===this._mouseDownEvent.target&&n.data(t.target,this.widgetName+".preventClickEvent",!0),this._mouseStop(t)),o=!1},_mouseDistanceMet:function(t){return Math.max(Math.abs(this._mouseDownEvent.pageX-t.pageX),Math.abs(this._mouseDownEvent.pageY-t.pageY))>=this.options.distance},_mouseDelayMet:function(){return this.mouseDelayMet},_mouseStart:function(){},_mouseDrag:function(){},_mouseStop:function(){},_mouseCapture:function(){return!0}})}),function(t){"function"==typeof define&&define.amd?define(["jquery","./core","./mouse","./widget"],t):t(jQuery)}(function(d){return d.widget("ui.sortable",d.ui.mouse,{version:"1.11.4",widgetEventPrefix:"sort",ready:!1,options:{appendTo:"parent",axis:!1,connectWith:!1,containment:!1,cursor:"auto",cursorAt:!1,dropOnEmpty:!0,forcePlaceholderSize:!1,forceHelperSize:!1,grid:!1,handle:!1,helper:"original",items:"> *",opacity:!1,placeholder:!1,revert:!1,scroll:!0,scrollSensitivity:20,scrollSpeed:20,scope:"default",tolerance:"intersect",zIndex:1e3,activate:null,beforeStop:null,change:null,deactivate:null,out:null,over:null,receive:null,remove:null,sort:null,start:null,stop:null,update:null},_isOverAxis:function(t,e,i){return e<=t&&t<e+i},_isFloating:function(t){return/left|right/.test(t.css("float"))||/inline|table-cell/.test(t.css("display"))},_create:function(){this.containerCache={},this.element.addClass("ui-sortable"),this.refresh(),this.offset=this.element.offset(),this._mouseInit(),this._setHandleClassName(),this.ready=!0},_setOption:function(t,e){this._super(t,e),"handle"===t&&this._setHandleClassName()},_setHandleClassName:function(){this.element.find(".ui-sortable-handle").removeClass("ui-sortable-handle"),d.each(this.items,function(){(this.instance.options.handle?this.item.find(this.instance.options.handle):this.item).addClass("ui-sortable-handle")})},_destroy:function(){this.element.removeClass("ui-sortable ui-sortable-disabled").find(".ui-sortable-handle").removeClass("ui-sortable-handle"),this._mouseDestroy();for(var t=this.items.length-1;0<=t;t--)this.items[t].item.removeData(this.widgetName+"-item");return this},_mouseCapture:function(t,e){var i=null,s=!1,n=this;return!this.reverting&&(!this.options.disabled&&"static"!==this.options.type&&(this._refreshItems(t),d(t.target).parents().each(function(){if(d.data(this,n.widgetName+"-item")===n)return i=d(this),!1}),d.data(t.target,n.widgetName+"-item")===n&&(i=d(t.target)),!!i&&(!(this.options.handle&&!e&&(d(this.options.handle,i).find("*").addBack().each(function(){this===t.target&&(s=!0)}),!s))&&(this.currentItem=i,this._removeCurrentsFromItems(),!0))))},_mouseStart:function(t,e,i){var s,n,o=this.options;if((this.currentContainer=this).refreshPositions(),this.helper=this._createHelper(t),this._cacheHelperProportions(),this._cacheMargins(),this.scrollParent=this.helper.scrollParent(),this.offset=this.currentItem.offset(),this.offset={top:this.offset.top-this.margins.top,left:this.offset.left-this.margins.left},d.extend(this.offset,{click:{left:t.pageX-this.offset.left,top:t.pageY-this.offset.top},parent:this._getParentOffset(),relative:this._getRelativeOffset()}),this.helper.css("position","absolute"),this.cssPosition=this.helper.css("position"),this.originalPosition=this._generatePosition(t),this.originalPageX=t.pageX,this.originalPageY=t.pageY,o.cursorAt&&this._adjustOffsetFromHelper(o.cursorAt),this.domPosition={prev:this.currentItem.prev()[0],parent:this.currentItem.parent()[0]},this.helper[0]!==this.currentItem[0]&&this.currentItem.hide(),this._createPlaceholder(),o.containment&&this._setContainment(),o.cursor&&"auto"!==o.cursor&&(n=this.document.find("body"),this.storedCursor=n.css("cursor"),n.css("cursor",o.cursor),this.storedStylesheet=d("<style>*{ cursor: "+o.cursor+" !important; }</style>").appendTo(n)),o.opacity&&(this.helper.css("opacity")&&(this._storedOpacity=this.helper.css("opacity")),this.helper.css("opacity",o.opacity)),o.zIndex&&(this.helper.css("zIndex")&&(this._storedZIndex=this.helper.css("zIndex")),this.helper.css("zIndex",o.zIndex)),this.scrollParent[0]!==this.document[0]&&"HTML"!==this.scrollParent[0].tagName&&(this.overflowOffset=this.scrollParent.offset()),this._trigger("start",t,this._uiHash()),this._preserveHelperProportions||this._cacheHelperProportions(),!i)for(s=this.containers.length-1;0<=s;s--)this.containers[s]._trigger("activate",t,this._uiHash(this));return d.ui.ddmanager&&(d.ui.ddmanager.current=this),d.ui.ddmanager&&!o.dropBehaviour&&d.ui.ddmanager.prepareOffsets(this,t),this.dragging=!0,this.helper.addClass("ui-sortable-helper"),this._mouseDrag(t),!0},_mouseDrag:function(t){var e,i,s,n,o=this.options,r=!1;for(this.position=this._generatePosition(t),this.positionAbs=this._convertPositionTo("absolute"),this.lastPositionAbs||(this.lastPositionAbs=this.positionAbs),this.options.scroll&&(this.scrollParent[0]!==this.document[0]&&"HTML"!==this.scrollParent[0].tagName?(this.overflowOffset.top+this.scrollParent[0].offsetHeight-t.pageY<o.scrollSensitivity?this.scrollParent[0].scrollTop=r=this.scrollParent[0].scrollTop+o.scrollSpeed:t.pageY-this.overflowOffset.top<o.scrollSensitivity&&(this.scrollParent[0].scrollTop=r=this.scrollParent[0].scrollTop-o.scrollSpeed),this.overflowOffset.left+this.scrollParent[0].offsetWidth-t.pageX<o.scrollSensitivity?this.scrollParent[0].scrollLeft=r=this.scrollParent[0].scrollLeft+o.scrollSpeed:t.pageX-this.overflowOffset.left<o.scrollSensitivity&&(this.scrollParent[0].scrollLeft=r=this.scrollParent[0].scrollLeft-o.scrollSpeed)):(t.pageY-this.document.scrollTop()<o.scrollSensitivity?r=this.document.scrollTop(this.document.scrollTop()-o.scrollSpeed):this.window.height()-(t.pageY-this.document.scrollTop())<o.scrollSensitivity&&(r=this.document.scrollTop(this.document.scrollTop()+o.scrollSpeed)),t.pageX-this.document.scrollLeft()<o.scrollSensitivity?r=this.document.scrollLeft(this.document.scrollLeft()-o.scrollSpeed):this.window.width()-(t.pageX-this.document.scrollLeft())<o.scrollSensitivity&&(r=this.document.scrollLeft(this.document.scrollLeft()+o.scrollSpeed))),!1!==r&&d.ui.ddmanager&&!o.dropBehaviour&&d.ui.ddmanager.prepareOffsets(this,t)),this.positionAbs=this._convertPositionTo("absolute"),this.options.axis&&"y"===this.options.axis||(this.helper[0].style.left=this.position.left+"px"),this.options.axis&&"x"===this.options.axis||(this.helper[0].style.top=this.position.top+"px"),e=this.items.length-1;0<=e;e--)if(s=(i=this.items[e]).item[0],(n=this._intersectsWithPointer(i))&&i.instance===this.currentContainer&&!(s===this.currentItem[0]||this.placeholder[1===n?"next":"prev"]()[0]===s||d.contains(this.placeholder[0],s)||"semi-dynamic"===this.options.type&&d.contains(this.element[0],s))){if(this.direction=1===n?"down":"up","pointer"!==this.options.tolerance&&!this._intersectsWithSides(i))break;this._rearrange(t,i),this._trigger("change",t,this._uiHash());break}return this._contactContainers(t),d.ui.ddmanager&&d.ui.ddmanager.drag(this,t),this._trigger("sort",t,this._uiHash()),this.lastPositionAbs=this.positionAbs,!1},_mouseStop:function(t,e){if(t){if(d.ui.ddmanager&&!this.options.dropBehaviour&&d.ui.ddmanager.drop(this,t),this.options.revert){var i=this,s=this.placeholder.offset(),n=this.options.axis,o={};n&&"x"!==n||(o.left=s.left-this.offset.parent.left-this.margins.left+(this.offsetParent[0]===this.document[0].body?0:this.offsetParent[0].scrollLeft)),n&&"y"!==n||(o.top=s.top-this.offset.parent.top-this.margins.top+(this.offsetParent[0]===this.document[0].body?0:this.offsetParent[0].scrollTop)),this.reverting=!0,d(this.helper).animate(o,parseInt(this.options.revert,10)||500,function(){i._clear(t)})}else this._clear(t,e);return!1}},cancel:function(){if(this.dragging){this._mouseUp({target:null}),"original"===this.options.helper?this.currentItem.css(this._storedCSS).removeClass("ui-sortable-helper"):this.currentItem.show();for(var t=this.containers.length-1;0<=t;t--)this.containers[t]._trigger("deactivate",null,this._uiHash(this)),this.containers[t].containerCache.over&&(this.containers[t]._trigger("out",null,this._uiHash(this)),this.containers[t].containerCache.over=0)}return this.placeholder&&(this.placeholder[0].parentNode&&this.placeholder[0].parentNode.removeChild(this.placeholder[0]),"original"!==this.options.helper&&this.helper&&this.helper[0].parentNode&&this.helper.remove(),d.extend(this,{helper:null,dragging:!1,reverting:!1,_noFinalSort:null}),this.domPosition.prev?d(this.domPosition.prev).after(this.currentItem):d(this.domPosition.parent).prepend(this.currentItem)),this},serialize:function(e){var t=this._getItemsAsjQuery(e&&e.connected),i=[];return e=e||{},d(t).each(function(){var t=(d(e.item||this).attr(e.attribute||"id")||"").match(e.expression||/(.+)[\-=_](.+)/);t&&i.push((e.key||t[1]+"[]")+"="+(e.key&&e.expression?t[1]:t[2]))}),!i.length&&e.key&&i.push(e.key+"="),i.join("&")},toArray:function(t){var e=this._getItemsAsjQuery(t&&t.connected),i=[];return t=t||{},e.each(function(){i.push(d(t.item||this).attr(t.attribute||"id")||"")}),i},_intersectsWith:function(t){var e=this.positionAbs.left,i=e+this.helperProportions.width,s=this.positionAbs.top,n=s+this.helperProportions.height,o=t.left,r=o+t.width,h=t.top,a=h+t.height,l=this.offset.click.top,c=this.offset.click.left,u="x"===this.options.axis||h<s+l&&s+l<a,f="y"===this.options.axis||o<e+c&&e+c<r,d=u&&f;return"pointer"===this.options.tolerance||this.options.forcePointerForContainers||"pointer"!==this.options.tolerance&&this.helperProportions[this.floating?"width":"height"]>t[this.floating?"width":"height"]?d:o<e+this.helperProportions.width/2&&i-this.helperProportions.width/2<r&&h<s+this.helperProportions.height/2&&n-this.helperProportions.height/2<a},_intersectsWithPointer:function(t){var e="x"===this.options.axis||this._isOverAxis(this.positionAbs.top+this.offset.click.top,t.top,t.height),i="y"===this.options.axis||this._isOverAxis(this.positionAbs.left+this.offset.click.left,t.left,t.width),s=e&&i,n=this._getDragVerticalDirection(),o=this._getDragHorizontalDirection();return!!s&&(this.floating?o&&"right"===o||"down"===n?2:1:n&&("down"===n?2:1))},_intersectsWithSides:function(t){var e=this._isOverAxis(this.positionAbs.top+this.offset.click.top,t.top+t.height/2,t.height),i=this._isOverAxis(this.positionAbs.left+this.offset.click.left,t.left+t.width/2,t.width),s=this._getDragVerticalDirection(),n=this._getDragHorizontalDirection();return this.floating&&n?"right"===n&&i||"left"===n&&!i:s&&("down"===s&&e||"up"===s&&!e)},_getDragVerticalDirection:function(){var t=this.positionAbs.top-this.lastPositionAbs.top;return 0!==t&&(0<t?"down":"up")},_getDragHorizontalDirection:function(){var t=this.positionAbs.left-this.lastPositionAbs.left;return 0!==t&&(0<t?"right":"left")},refresh:function(t){return this._refreshItems(t),this._setHandleClassName(),this.refreshPositions(),this},_connectWith:function(){var t=this.options;return t.connectWith.constructor===String?[t.connectWith]:t.connectWith},_getItemsAsjQuery:function(t){function e(){r.push(this)}var i,s,n,o,r=[],h=[],a=this._connectWith();if(a&&t)for(i=a.length-1;0<=i;i--)for(s=(n=d(a[i],this.document[0])).length-1;0<=s;s--)(o=d.data(n[s],this.widgetFullName))&&o!==this&&!o.options.disabled&&h.push([d.isFunction(o.options.items)?o.options.items.call(o.element):d(o.options.items,o.element).not(".ui-sortable-helper").not(".ui-sortable-placeholder"),o]);for(h.push([d.isFunction(this.options.items)?this.options.items.call(this.element,null,{options:this.options,item:this.currentItem}):d(this.options.items,this.element).not(".ui-sortable-helper").not(".ui-sortable-placeholder"),this]),i=h.length-1;0<=i;i--)h[i][0].each(e);return d(r)},_removeCurrentsFromItems:function(){var i=this.currentItem.find(":data("+this.widgetName+"-item)");this.items=d.grep(this.items,function(t){for(var e=0;e<i.length;e++)if(i[e]===t.item[0])return!1;return!0})},_refreshItems:function(t){this.items=[],this.containers=[this];var e,i,s,n,o,r,h,a,l=this.items,c=[[d.isFunction(this.options.items)?this.options.items.call(this.element[0],t,{item:this.currentItem}):d(this.options.items,this.element),this]],u=this._connectWith();if(u&&this.ready)for(e=u.length-1;0<=e;e--)for(i=(s=d(u[e],this.document[0])).length-1;0<=i;i--)(n=d.data(s[i],this.widgetFullName))&&n!==this&&!n.options.disabled&&(c.push([d.isFunction(n.options.items)?n.options.items.call(n.element[0],t,{item:this.currentItem}):d(n.options.items,n.element),n]),this.containers.push(n));for(e=c.length-1;0<=e;e--)for(o=c[e][1],i=0,a=(r=c[e][0]).length;i<a;i++)(h=d(r[i])).data(this.widgetName+"-item",o),l.push({item:h,instance:o,width:0,height:0,left:0,top:0})},refreshPositions:function(t){var e,i,s,n;for(this.floating=!!this.items.length&&("x"===this.options.axis||this._isFloating(this.items[0].item)),this.offsetParent&&this.helper&&(this.offset.parent=this._getParentOffset()),e=this.items.length-1;0<=e;e--)(i=this.items[e]).instance!==this.currentContainer&&this.currentContainer&&i.item[0]!==this.currentItem[0]||(s=this.options.toleranceElement?d(this.options.toleranceElement,i.item):i.item,t||(i.width=s.outerWidth(),i.height=s.outerHeight()),n=s.offset(),i.left=n.left,i.top=n.top);if(this.options.custom&&this.options.custom.refreshContainers)this.options.custom.refreshContainers.call(this);else for(e=this.containers.length-1;0<=e;e--)n=this.containers[e].element.offset(),this.containers[e].containerCache.left=n.left,this.containers[e].containerCache.top=n.top,this.containers[e].containerCache.width=this.containers[e].element.outerWidth(),this.containers[e].containerCache.height=this.containers[e].element.outerHeight();return this},_createPlaceholder:function(i){var s,n=(i=i||this).options;n.placeholder&&n.placeholder.constructor!==String||(s=n.placeholder,n.placeholder={element:function(){var t=i.currentItem[0].nodeName.toLowerCase(),e=d("<"+t+">",i.document[0]).addClass(s||i.currentItem[0].className+" ui-sortable-placeholder").removeClass("ui-sortable-helper");return"tbody"===t?i._createTrPlaceholder(i.currentItem.find("tr").eq(0),d("<tr>",i.document[0]).appendTo(e)):"tr"===t?i._createTrPlaceholder(i.currentItem,e):"img"===t&&e.attr("src",i.currentItem.attr("src")),s||e.css("visibility","hidden"),e},update:function(t,e){s&&!n.forcePlaceholderSize||(e.height()||e.height(i.currentItem.innerHeight()-parseInt(i.currentItem.css("paddingTop")||0,10)-parseInt(i.currentItem.css("paddingBottom")||0,10)),e.width()||e.width(i.currentItem.innerWidth()-parseInt(i.currentItem.css("paddingLeft")||0,10)-parseInt(i.currentItem.css("paddingRight")||0,10)))}}),i.placeholder=d(n.placeholder.element.call(i.element,i.currentItem)),i.currentItem.after(i.placeholder),n.placeholder.update(i,i.placeholder)},_createTrPlaceholder:function(t,e){var i=this;t.children().each(function(){d("<td>&#160;</td>",i.document[0]).attr("colspan",d(this).attr("colspan")||1).appendTo(e)})},_contactContainers:function(t){var e,i,s,n,o,r,h,a,l,c,u=null,f=null;for(e=this.containers.length-1;0<=e;e--)if(!d.contains(this.currentItem[0],this.containers[e].element[0]))if(this._intersectsWith(this.containers[e].containerCache)){if(u&&d.contains(this.containers[e].element[0],u.element[0]))continue;u=this.containers[e],f=e}else this.containers[e].containerCache.over&&(this.containers[e]._trigger("out",t,this._uiHash(this)),this.containers[e].containerCache.over=0);if(u)if(1===this.containers.length)this.containers[f].containerCache.over||(this.containers[f]._trigger("over",t,this._uiHash(this)),this.containers[f].containerCache.over=1);else{for(s=1e4,n=null,o=(l=u.floating||this._isFloating(this.currentItem))?"left":"top",r=l?"width":"height",c=l?"clientX":"clientY",i=this.items.length-1;0<=i;i--)d.contains(this.containers[f].element[0],this.items[i].item[0])&&this.items[i].item[0]!==this.currentItem[0]&&(h=this.items[i].item.offset()[o],a=!1,t[c]-h>this.items[i][r]/2&&(a=!0),Math.abs(t[c]-h)<s&&(s=Math.abs(t[c]-h),n=this.items[i],this.direction=a?"up":"down"));if(!n&&!this.options.dropOnEmpty)return;if(this.currentContainer===this.containers[f])return void(this.currentContainer.containerCache.over||(this.containers[f]._trigger("over",t,this._uiHash()),this.currentContainer.containerCache.over=1));n?this._rearrange(t,n,null,!0):this._rearrange(t,null,this.containers[f].element,!0),this._trigger("change",t,this._uiHash()),this.containers[f]._trigger("change",t,this._uiHash(this)),this.currentContainer=this.containers[f],this.options.placeholder.update(this.currentContainer,this.placeholder),this.containers[f]._trigger("over",t,this._uiHash(this)),this.containers[f].containerCache.over=1}},_createHelper:function(t){var e=this.options,i=d.isFunction(e.helper)?d(e.helper.apply(this.element[0],[t,this.currentItem])):"clone"===e.helper?this.currentItem.clone():this.currentItem;return i.parents("body").length||d("parent"!==e.appendTo?e.appendTo:this.currentItem[0].parentNode)[0].appendChild(i[0]),i[0]===this.currentItem[0]&&(this._storedCSS={width:this.currentItem[0].style.width,height:this.currentItem[0].style.height,position:this.currentItem.css("position"),top:this.currentItem.css("top"),left:this.currentItem.css("left")}),i[0].style.width&&!e.forceHelperSize||i.width(this.currentItem.width()),i[0].style.height&&!e.forceHelperSize||i.height(this.currentItem.height()),i},_adjustOffsetFromHelper:function(t){"string"==typeof t&&(t=t.split(" ")),d.isArray(t)&&(t={left:+t[0],top:+t[1]||0}),"left"in t&&(this.offset.click.left=t.left+this.margins.left),"right"in t&&(this.offset.click.left=this.helperProportions.width-t.right+this.margins.left),"top"in t&&(this.offset.click.top=t.top+this.margins.top),"bottom"in t&&(this.offset.click.top=this.helperProportions.height-t.bottom+this.margins.top)},_getParentOffset:function(){this.offsetParent=this.helper.offsetParent();var t=this.offsetParent.offset();return"absolute"===this.cssPosition&&this.scrollParent[0]!==this.document[0]&&d.contains(this.scrollParent[0],this.offsetParent[0])&&(t.left+=this.scrollParent.scrollLeft(),t.top+=this.scrollParent.scrollTop()),(this.offsetParent[0]===this.document[0].body||this.offsetParent[0].tagName&&"html"===this.offsetParent[0].tagName.toLowerCase()&&d.ui.ie)&&(t={top:0,left:0}),{top:t.top+(parseInt(this.offsetParent.css("borderTopWidth"),10)||0),left:t.left+(parseInt(this.offsetParent.css("borderLeftWidth"),10)||0)}},_getRelativeOffset:function(){if("relative"===this.cssPosition){var t=this.currentItem.position();return{top:t.top-(parseInt(this.helper.css("top"),10)||0)+this.scrollParent.scrollTop(),left:t.left-(parseInt(this.helper.css("left"),10)||0)+this.scrollParent.scrollLeft()}}return{top:0,left:0}},_cacheMargins:function(){this.margins={left:parseInt(this.currentItem.css("marginLeft"),10)||0,top:parseInt(this.currentItem.css("marginTop"),10)||0}},_cacheHelperProportions:function(){this.helperProportions={width:this.helper.outerWidth(),height:this.helper.outerHeight()}},_setContainment:function(){var t,e,i,s=this.options;"parent"===s.containment&&(s.containment=this.helper[0].parentNode),"document"!==s.containment&&"window"!==s.containment||(this.containment=[0-this.offset.relative.left-this.offset.parent.left,0-this.offset.relative.top-this.offset.parent.top,"document"===s.containment?this.document.width():this.window.width()-this.helperProportions.width-this.margins.left,("document"===s.containment?this.document.width():this.window.height()||this.document[0].body.parentNode.scrollHeight)-this.helperProportions.height-this.margins.top]),/^(document|window|parent)$/.test(s.containment)||(t=d(s.containment)[0],e=d(s.containment).offset(),i="hidden"!==d(t).css("overflow"),this.containment=[e.left+(parseInt(d(t).css("borderLeftWidth"),10)||0)+(parseInt(d(t).css("paddingLeft"),10)||0)-this.margins.left,e.top+(parseInt(d(t).css("borderTopWidth"),10)||0)+(parseInt(d(t).css("paddingTop"),10)||0)-this.margins.top,e.left+(i?Math.max(t.scrollWidth,t.offsetWidth):t.offsetWidth)-(parseInt(d(t).css("borderLeftWidth"),10)||0)-(parseInt(d(t).css("paddingRight"),10)||0
)-this.helperProportions.width-this.margins.left,e.top+(i?Math.max(t.scrollHeight,t.offsetHeight):t.offsetHeight)-(parseInt(d(t).css("borderTopWidth"),10)||0)-(parseInt(d(t).css("paddingBottom"),10)||0)-this.helperProportions.height-this.margins.top])},_convertPositionTo:function(t,e){e||(e=this.position);var i="absolute"===t?1:-1,s="absolute"!==this.cssPosition||this.scrollParent[0]!==this.document[0]&&d.contains(this.scrollParent[0],this.offsetParent[0])?this.scrollParent:this.offsetParent,n=/(html|body)/i.test(s[0].tagName);return{top:e.top+this.offset.relative.top*i+this.offset.parent.top*i-("fixed"===this.cssPosition?-this.scrollParent.scrollTop():n?0:s.scrollTop())*i,left:e.left+this.offset.relative.left*i+this.offset.parent.left*i-("fixed"===this.cssPosition?-this.scrollParent.scrollLeft():n?0:s.scrollLeft())*i}},_generatePosition:function(t){var e,i,s=this.options,n=t.pageX,o=t.pageY,r="absolute"!==this.cssPosition||this.scrollParent[0]!==this.document[0]&&d.contains(this.scrollParent[0],this.offsetParent[0])?this.scrollParent:this.offsetParent,h=/(html|body)/i.test(r[0].tagName);return"relative"!==this.cssPosition||this.scrollParent[0]!==this.document[0]&&this.scrollParent[0]!==this.offsetParent[0]||(this.offset.relative=this._getRelativeOffset()),this.originalPosition&&(this.containment&&(t.pageX-this.offset.click.left<this.containment[0]&&(n=this.containment[0]+this.offset.click.left),t.pageY-this.offset.click.top<this.containment[1]&&(o=this.containment[1]+this.offset.click.top),t.pageX-this.offset.click.left>this.containment[2]&&(n=this.containment[2]+this.offset.click.left),t.pageY-this.offset.click.top>this.containment[3]&&(o=this.containment[3]+this.offset.click.top)),s.grid&&(e=this.originalPageY+Math.round((o-this.originalPageY)/s.grid[1])*s.grid[1],o=this.containment?e-this.offset.click.top>=this.containment[1]&&e-this.offset.click.top<=this.containment[3]?e:e-this.offset.click.top>=this.containment[1]?e-s.grid[1]:e+s.grid[1]:e,i=this.originalPageX+Math.round((n-this.originalPageX)/s.grid[0])*s.grid[0],n=this.containment?i-this.offset.click.left>=this.containment[0]&&i-this.offset.click.left<=this.containment[2]?i:i-this.offset.click.left>=this.containment[0]?i-s.grid[0]:i+s.grid[0]:i)),{top:o-this.offset.click.top-this.offset.relative.top-this.offset.parent.top+("fixed"===this.cssPosition?-this.scrollParent.scrollTop():h?0:r.scrollTop()),left:n-this.offset.click.left-this.offset.relative.left-this.offset.parent.left+("fixed"===this.cssPosition?-this.scrollParent.scrollLeft():h?0:r.scrollLeft())}},_rearrange:function(t,e,i,s){i?i[0].appendChild(this.placeholder[0]):e.item[0].parentNode.insertBefore(this.placeholder[0],"down"===this.direction?e.item[0]:e.item[0].nextSibling),this.counter=this.counter?++this.counter:1;var n=this.counter;this._delay(function(){n===this.counter&&this.refreshPositions(!s)})},_clear:function(t,e){function i(e,i,s){return function(t){s._trigger(e,t,i._uiHash(i))}}this.reverting=!1;var s,n=[];if(!this._noFinalSort&&this.currentItem.parent().length&&this.placeholder.before(this.currentItem),this._noFinalSort=null,this.helper[0]===this.currentItem[0]){for(s in this._storedCSS)"auto"!==this._storedCSS[s]&&"static"!==this._storedCSS[s]||(this._storedCSS[s]="");this.currentItem.css(this._storedCSS).removeClass("ui-sortable-helper")}else this.currentItem.show();for(this.fromOutside&&!e&&n.push(function(t){this._trigger("receive",t,this._uiHash(this.fromOutside))}),!this.fromOutside&&this.domPosition.prev===this.currentItem.prev().not(".ui-sortable-helper")[0]&&this.domPosition.parent===this.currentItem.parent()[0]||e||n.push(function(t){this._trigger("update",t,this._uiHash())}),this!==this.currentContainer&&(e||(n.push(function(t){this._trigger("remove",t,this._uiHash())}),n.push(function(e){return function(t){e._trigger("receive",t,this._uiHash(this))}}.call(this,this.currentContainer)),n.push(function(e){return function(t){e._trigger("update",t,this._uiHash(this))}}.call(this,this.currentContainer)))),s=this.containers.length-1;0<=s;s--)e||n.push(i("deactivate",this,this.containers[s])),this.containers[s].containerCache.over&&(n.push(i("out",this,this.containers[s])),this.containers[s].containerCache.over=0);if(this.storedCursor&&(this.document.find("body").css("cursor",this.storedCursor),this.storedStylesheet.remove()),this._storedOpacity&&this.helper.css("opacity",this._storedOpacity),this._storedZIndex&&this.helper.css("zIndex","auto"===this._storedZIndex?"":this._storedZIndex),this.dragging=!1,e||this._trigger("beforeStop",t,this._uiHash()),this.placeholder[0].parentNode.removeChild(this.placeholder[0]),this.cancelHelperRemoval||(this.helper[0]!==this.currentItem[0]&&this.helper.remove(),this.helper=null),!e){for(s=0;s<n.length;s++)n[s].call(this,t);this._trigger("stop",t,this._uiHash())}return this.fromOutside=!1,!this.cancelHelperRemoval},_trigger:function(){!1===d.Widget.prototype._trigger.apply(this,arguments)&&this.cancel()},_uiHash:function(t){var e=t||this;return{helper:e.helper,placeholder:e.placeholder||d([]),position:e.position,originalPosition:e.originalPosition,offset:e.positionAbs,item:e.currentItem,sender:t?t.element:null}}})});