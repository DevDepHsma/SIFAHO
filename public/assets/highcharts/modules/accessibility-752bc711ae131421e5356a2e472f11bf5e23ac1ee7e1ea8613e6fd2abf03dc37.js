"use strict";!function(e){"object"==typeof module&&module.exports?module.exports=e:e(Highcharts)}(function(e){!function(g){function m(e){return e.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&#x27;").replace(/\//g,"&#x2F;")}function f(e){return"string"==typeof e?e.replace(/<\/?[^>]+(>|$)/g,""):e}function n(e){for(var t=e.childNodes.length;t--;)e.appendChild(e.childNodes[t])}var x=g.win.document,b=g.each,r=g.erase,t=g.addEvent,a=g.dateFormat,y=g.merge,u={position:"absolute",left:"-9999px",top:"auto",width:"1px",height:"1px",overflow:"hidden"},v={"default":["series","data point","data points"],line:["line","data point","data points"],spline:["line","data point","data points"],area:["line","data point","data points"],areaspline:["line","data point","data points"],pie:["pie","slice","slices"],column:["column series","column","columns"],bar:["bar series","bar","bars"],scatter:["scatter series","data point","data points"],boxplot:["boxplot series","box","boxes"],arearange:["arearange series","data point","data points"],areasplinerange:["areasplinerange series","data point","data points"],bubble:["bubble series","bubble","bubbles"],columnrange:["columnrange series","column","columns"],errorbar:["errorbar series","errorbar","errorbars"],funnel:["funnel","data point","data points"],pyramid:["pyramid","data point","data points"],waterfall:["waterfall series","column","columns"],map:["map","area","areas"],mapline:["line","data point","data points"],mappoint:["point series","data point","data points"],mapbubble:["bubble series","bubble","bubbles"]},i={boxplot:" Box plot charts are typically used to display groups of statistical data. Each data point in the chart can have up to 5 values: minimum, lower quartile, median, upper quartile and maximum. ",arearange:" Arearange charts are line charts displaying a range between a lower and higher value for each point. ",areasplinerange:" These charts are line charts displaying a range between a lower and higher value for each point. ",bubble:" Bubble charts are scatter charts where each data point also has a size value. ",columnrange:" Columnrange charts are column charts displaying a range between a lower and higher value for each point. ",errorbar:" Errorbar series are used to display the variability of the data. ",funnel:" Funnel charts are used to display reduction of data in stages. ",pyramid:" Pyramid charts consist of a single pyramid with item heights corresponding to each point value. ",waterfall:" A waterfall chart is a column chart where each column contributes towards a total end value. "};g.Series.prototype.commonKeys=["name","id","category","x","value","y"],g.Series.prototype.specialKeys=["z","open","high","q3","median","q1","low","close"],g.seriesTypes.pie&&(g.seriesTypes.pie.prototype.specialKeys=[]),g.setOptions({accessibility:{enabled:!0,pointDescriptionThreshold:30}}),g.wrap(g.Series.prototype,"render",function(e){e.apply(this,Array.prototype.slice.call(arguments,1)),this.chart.options.accessibility.enabled&&this.setA11yDescription()}),g.Series.prototype.setA11yDescription=function(){var t=this.chart.options.accessibility,e=this.points&&this.points.length&&this.points[0].graphic&&this.points[0].graphic.element,i=e&&e.parentNode||this.graph&&this.graph.element||this.group&&this.group.element;i&&(i.lastChild===e&&n(i),this.points&&(this.points.length<t.pointDescriptionThreshold||!1===t.pointDescriptionThreshold)&&b(this.points,function(e){e.graphic&&(e.graphic.element.setAttribute("role","img"),e.graphic.element.setAttribute("tabindex","-1"),e.graphic.element.setAttribute("aria-label",f(e.series.options.pointDescriptionFormatter&&e.series.options.pointDescriptionFormatter(e)||t.pointDescriptionFormatter&&t.pointDescriptionFormatter(e)||e.buildPointInfoString())))}),(1<this.chart.series.length||t.describeSingleSeries)&&(i.setAttribute("role",this.options.exposeElementToA11y?"img":"region"),i.setAttribute("tabindex","-1"),i.setAttribute("aria-label",f(t.seriesDescriptionFormatter&&t.seriesDescriptionFormatter(this)||this.buildSeriesInfoString()))))},g.Series.prototype.buildSeriesInfoString=function(){var e=v[this.type]||v["default"],t=this.description||this.options.description;return(this.name?this.name+", ":"")+(1===this.chart.types.length?e[0]:"series")+" "+(this.index+1)+" of "+this.chart.series.length+(1===this.chart.types.length?" with ":". "+e[0]+" with ")+this.points.length+" "+(1===this.points.length?e[1]:e[2])+(t?". "+t:"")+(1<this.chart.yAxis.length&&this.yAxis?". Y axis, "+this.yAxis.getDescription():"")+(1<this.chart.xAxis.length&&this.xAxis?". X axis, "+this.xAxis.getDescription():"")},g.Point.prototype.buildPointInfoString=function(){var t=this,e=t.series,i=e.chart.options.accessibility,n="",r=e.xAxis&&e.xAxis.isDatetimeAxis,o=r&&a(i.pointDateFormatter&&i.pointDateFormatter(t)||i.pointDateFormat||g.Tooltip.prototype.getXDateFormat(t,e.chart.options.tooltip,e.xAxis),t.x);return g.find(e.specialKeys,function(e){return t[e]!==undefined})?(r&&(n=o),b(e.commonKeys.concat(e.specialKeys),function(e){t[e]===undefined||r&&"x"===e||(n+=(n?". ":"")+e+", "+t[e])})):n=(this.name||o||this.category||this.id||"x, "+this.x)+", "+(this.value!==undefined?this.value:this.y),this.index+1+". "+n+"."+(this.description?" "+this.description:"")},g.Axis.prototype.getDescription=function(){return this.userOptions&&this.userOptions.description||this.axisTitle&&this.axisTitle.textStr||this.options.id||this.categories&&"categories"||"values"},g.wrap(g.Series.prototype,"init",function(e){e.apply(this,Array.prototype.slice.call(arguments,1));var n=this.chart;n.options.accessibility.enabled&&(n.types=n.types||[],n.types.indexOf(this.type)<0&&n.types.push(this.type),t(this,"remove",function(){var t=this,i=!1;b(n.series,function(e){e!==t&&n.types.indexOf(t.type)<0&&(i=!0)}),i||r(n.types,t.type)}))}),g.Chart.prototype.getTypeDescription=function(){var e=this.types&&this.types[0],t=this.series[0]&&this.series[0].mapTitle;return e?"map"===e?t?"Map of "+t:"Map of unspecified region.":1<this.types.length?"Combination chart.":-1<["spline","area","areaspline"].indexOf(e)?"Line chart.":e+" chart."+(i[e]||""):"Empty chart."},g.Chart.prototype.getAxesDescription=function(){var e,t=this.xAxis.length,i=this.yAxis.length,n={};if(t)if(n.xAxis="The chart has "+t+(1<t?" X axes":" X axis")+" displaying ",t<2)n.xAxis+=this.xAxis[0].getDescription()+".";else{for(e=0;e<t-1;++e)n.xAxis+=(e?", ":"")+this.xAxis[e].getDescription();n.xAxis+=" and "+this.xAxis[e].getDescription()+"."}if(i)if(n.yAxis="The chart has "+i+(1<i?" Y axes":" Y axis")+" displaying ",i<2)n.yAxis+=this.yAxis[0].getDescription()+".";else{for(e=0;e<i-1;++e)n.yAxis+=(e?", ":"")+this.yAxis[e].getDescription();n.yAxis+=" and "+this.yAxis[e].getDescription()+"."}return n},g.Chart.prototype.addAccessibleContextMenuAttribs=function(){var e=this.exportDivElements;e&&(b(e,function(e){"DIV"!==e.tagName||e.children&&e.children.length||(e.setAttribute("role","menuitem"),e.setAttribute("tabindex",-1))}),e[0].parentNode.setAttribute("role","menu"),e[0].parentNode.setAttribute("aria-label","Chart export"))},g.Chart.prototype.addScreenReaderRegion=function(e,t){var i=this,n=i.series,r=i.options,o=r.accessibility,a=i.screenReaderRegion=x.createElement("div"),s=x.createElement("h4"),h=x.createElement("a"),l=x.createElement("h4"),p=i.types||[],d=(1===p.length&&"pie"===p[0]||"map"===p[0])&&{}||i.getAxesDescription(),c=n[0]&&v[n[0].type]||v["default"];a.setAttribute("id",e),a.setAttribute("role","region"),a.setAttribute("aria-label","Chart screen reader information."),a.innerHTML=o.screenReaderSectionFormatter&&o.screenReaderSectionFormatter(i)||"<div>Use regions/landmarks to skip ahead to chart"+(1<n.length?" and navigate between data series":"")+".</div><h3>"+(r.title.text?m(r.title.text):"Chart")+(r.subtitle&&r.subtitle.text?". "+m(r.subtitle.text):"")+"</h3><h4>Long description.</h4><div>"+(r.chart.description||"No description available.")+"</div><h4>Structure.</h4><div>Chart type: "+(r.chart.typeDescription||i.getTypeDescription())+"</div>"+(1===n.length?"<div>"+c[0]+" with "+n[0].points.length+" "+(1===n[0].points.length?c[1]:c[2])+".</div>":"")+(d.xAxis?"<div>"+d.xAxis+"</div>":"")+(d.yAxis?"<div>"+d.yAxis+"</div>":""),i.getCSV&&(h.innerHTML="View as data table.",h.href="#"+t,h.setAttribute("tabindex","-1"),h.onclick=o.onTableAnchorClick||function(){i.viewData(),x.getElementById(t).focus()},s.appendChild(h),a.appendChild(s)),l.innerHTML="Chart graphic.",i.renderTo.insertBefore(l,i.renderTo.firstChild),i.renderTo.insertBefore(a,i.renderTo.firstChild),y(!0,l.style,u),y(!0,a.style,u)},g.Chart.prototype.callbacks.push(function(i){var e=i.options;if(e.accessibility.enabled){var t=x.createElementNS("http://www.w3.org/2000/svg","title"),n=x.createElementNS("http://www.w3.org/2000/svg","g"),r=i.container.getElementsByTagName("desc")[0],o=i.container.getElementsByTagName("text"),a="highcharts-title-"+i.index,h="highcharts-data-table-"+i.index,s="highcharts-information-region-"+i.index,l=e.title.text||"Chart",p=e.exporting&&e.exporting.csv&&e.exporting.csv.columnHeaderFormatter,d=[];if(t.textContent=m(l),t.id=a,r.parentNode.insertBefore(t,r),i.renderTo.setAttribute("role","region"),i.renderTo.setAttribute("aria-label",f("Interactive chart. "+l+". Use up and down arrows to navigate with most screen readers.")),i.exportSVGElements&&i.exportSVGElements[0]&&i.exportSVGElements[0].element){var c=i.exportSVGElements[0].element.onclick,u=i.exportSVGElements[0].element.parentNode;i.exportSVGElements[0].element.onclick=function(){c.apply(this,Array.prototype.slice.call(arguments)),i.addAccessibleContextMenuAttribs(),i.highlightExportItem(0)},i.exportSVGElements[0].element.setAttribute("role","button"),i.exportSVGElements[0].element.setAttribute("aria-label","View export menu"),n.appendChild(i.exportSVGElements[0].element),n.setAttribute("role","region"),n.setAttribute("aria-label","Chart export menu"),u.appendChild(n)}i.rangeSelector&&b(["minInput","maxInput"],function(e,t){i.rangeSelector[e]&&(i.rangeSelector[e].setAttribute("tabindex","-1"),i.rangeSelector[e].setAttribute("role","textbox"),i.rangeSelector[e].setAttribute("aria-label","Select "+(t?"end":"start")+" date."))}),b(o,function(e){e.setAttribute("aria-hidden","true")}),i.addScreenReaderRegion(s,h),y(!0,e.exporting,{csv:{columnHeaderFormatter:function(e,t,i){if(!e)return"Category";if(e instanceof g.Axis)return e.options.title&&e.options.title.text||(e.isDatetimeAxis?"DateTime":"Category");var n=d[d.length-1];return 1<i&&(n&&n.text)!==e.name&&d.push({text:e.name,span:i}),p?p.call(this,e,t,i):1<i?t:e.name}}}),g.wrap(i,"getTable",function(e){return e.apply(this,Array.prototype.slice.call(arguments,1)).replace("<table>",'<table id="'+h+'" summary="Table representation of chart"><caption>'+l+"</caption>")}),g.wrap(i,"viewData",function(e){if(!this.dataTableDiv){e.apply(this,Array.prototype.slice.call(arguments,1));var t,i,n=x.getElementById(h),r=n.getElementsByTagName("thead")[0],o=n.getElementsByTagName("tbody")[0],a=r.firstChild.children,s="<tr><td></td>";n.setAttribute("tabindex","-1"),b(o.children,function(e){t=e.firstChild,(i=x.createElement("th")).setAttribute("scope","row"),i.innerHTML=t.innerHTML,t.parentNode.replaceChild(i,t)}),b(a,function(e){"TH"===e.tagName&&e.setAttribute("scope","col")}),d.length&&(b(d,function(e){s+='<th scope="col" colspan="'+e.span+'">'+e.text+"</th>"}),r.insertAdjacentHTML("afterbegin",s))}})}})}(e),function(t){function i(e){return"string"==typeof e?e.replace(/<\/?[^>]+(>|$)/g,""):e}function n(e,t){this.chart=e,this.id=t.id,this.keyCodeMap=t.keyCodeMap,this.validate=t.validate,this.init=t.init,this.terminate=t.terminate}function o(e){var t;e&&e.onclick&&a.createEvent&&((t=a.createEvent("Events")).initEvent("click",!0,!1),e.onclick(t))}function c(e){return e.isNull&&e.series.chart.options.accessibility.keyboardNavigation.skipNullPoints||e.series.options.skipKeyboardNavigation||!e.series.visible}function s(e,t,i,n){var r,o,a,s=Infinity,h=t.points.length;if(e.plotX!==undefined&&e.plotY!==undefined){for(;h--;){if((r=t.points[h]).plotX===undefined||r.plotY===undefined)return;(a=(e.plotX-r.plotX)*(e.plotX-r.plotX)*(i||1)+(e.plotY-r.plotY)*(e.plotY-r.plotY)*(n||1))<s&&(s=a,o=h)}return t.points[o||0]}}var r=t.win,a=r.document,l=t.each,h=t.addEvent,p=t.fireEvent,d=t.merge,u=t.pick;t.extend(t.SVGElement.prototype,{addFocusBorder:function(e,t){this.focusBorder&&this.removeFocusBorder();var i=this.getBBox(),n=u(e,3);this.focusBorder=this.renderer.rect(i.x-n,i.y-n,i.width+2*n,i.height+2*n,t&&t.borderRadius).addClass("highcharts-focus-border").attr({stroke:t&&t.stroke,"stroke-width":t&&t.strokeWidth}).attr({zIndex:99}).add(this.parentGroup)},removeFocusBorder:function(){this.focusBorder&&(this.focusBorder.destroy(),delete this.focusBorder)}}),t.Series.prototype.keyboardMoveVertical=!0,l(["column","pie"],function(e){t.seriesTypes[e]&&(t.seriesTypes[e].prototype.keyboardMoveVertical=!1)}),t.setOptions({accessibility:{keyboardNavigation:{enabled:!0,focusBorder:{enabled:!0,style:{color:"#000000",lineWidth:1,borderRadius:2},margin:2}}}}),n.prototype={run:function(t){var i=this,n=t.which||t.keyCode,r=!1,o=!1;return l(this.keyCodeMap,function(e){-1<e[0].indexOf(n)&&(o=!(r=!0)!==e[1].call(i,n,t))}),r||9!==n||(o=this.move(t.shiftKey?-1:1)),o},move:function(e){var t=this.chart;this.terminate&&this.terminate(e),t.keyboardNavigationModuleIndex+=e;var i=t.keyboardNavigationModules[t.keyboardNavigationModuleIndex];if(t.focusElement&&t.focusElement.removeFocusBorder(),i){if(i.validate&&!i.validate())return this.move(e);if(i.init)return i.init(e),!0}return(t.keyboardNavigationModuleIndex=0)<e?(this.chart.exiting=!0,this.chart.tabExitAnchor.focus()):this.chart.renderTo.focus(),!1}},t.Axis.prototype.panStep=function(e,t){var i=t||3,n=this.getExtremes(),r=(n.max-n.min)/i*e,o=n.max+r,a=n.min+r,s=o-a;e<0&&a<n.dataMin?o=(a=n.dataMin)+s:0<e&&o>n.dataMax&&(a=(o=n.dataMax)-s),this.setExtremes(a,o)},t.Chart.prototype.setFocusToElement=function(e,t){var i=this.options.accessibility.keyboardNavigation.focusBorder;i.enabled&&e!==this.focusElement&&(this.focusElement&&this.focusElement.removeFocusBorder(),t&&t.element&&t.element.focus?t.element.focus():e.element.focus&&e.element.focus(),e.addFocusBorder(i.margin,{stroke:i.style.color,strokeWidth:i.style.lineWidth,borderRadius:i.style.borderRadius}),this.focusElement=e)},t.Point.prototype.highlight=function(){var e=this.series.chart;return this.isNull?e.tooltip&&e.tooltip.hide(0):this.onMouseOver(),this.graphic&&e.setFocusToElement(this.graphic),e.highlightedPoint=this},t.Chart.prototype.highlightAdjacentPoint=function(e){var t,i,n=this,r=n.series,o=n.highlightedPoint,a=o&&o.index||0,s=o&&o.series.points,h=n.series&&n.series[n.series.length-1],l=h&&h.points&&h.points[h.points.length-1],p=o&&o.series.connectEnds&&a>s.length-3?2:1;if(!r[0]||!r[0].points)return!1;if(o){if(s[a]!==o)for(var d=0;d<s.length;++d)if(s[d]===o){a=d;break}if(t=r[o.series.index+(e?1:-1)],(i=s[a+(e?p:-1)]||t&&t.points[e?0:t.points.length-(t.connectEnds?2:1)])===undefined)return!1}else i=e?r[0].points[0]:l;return c(i)?(n.highlightedPoint=i,n.highlightAdjacentPoint(e)):i.highlight()},t.Series.prototype.highlightFirstValidPoint=function(){for(var e=this.chart.highlightedPoint,t=e.series===this?e.index:0,i=this.points,n=t,r=i.length;n<r;++n)if(!c(i[n]))return i[n].highlight();for(var o=t;0<=o;--o)if(!c(i[o]))return i[o].highlight();return!1},t.Chart.prototype.highlightAdjacentSeries=function(e){var t,i,n=this,r=n.highlightedPoint,o=n.series&&n.series[n.series.length-1],a=o&&o.points&&o.points[o.points.length-1];return n.highlightedPoint?!!(t=n.series[r.series.index+(e?-1:1)])&&(!!(i=s(r,t,4))&&(t.visible?(i.highlight(),i.series.highlightFirstValidPoint()):(i.highlight(),n.highlightAdjacentSeries(e)||(r.highlight(),!1)))):(t=e?n.series&&n.series[0]:o,!!(i=e?t&&t.points&&t.points[0]:a)&&i.highlight())},t.Chart.prototype.highlightAdjacentPointVertical=function(o){var a,s=this.highlightedPoint,h=Infinity;return s.plotX!==undefined&&s.plotY!==undefined&&(l(this.series,function(r){l(r.points,function(e){if(e.plotY!==undefined&&e.plotX!==undefined&&e!==s){var t=e.plotY-s.plotY,i=Math.abs(e.plotX-s.plotX),n=Math.abs(t)*Math.abs(t)+i*i*4;r.yAxis.reversed&&(t*=-1),t<0&&o||0<t&&!o||n<5||c(e)||n<h&&(h=n,a=e)}})}),!!a&&a.highlight())},t.Chart.prototype.showExportMenu=function(){this.exportSVGElements&&this.exportSVGElements[0]&&(this.exportSVGElements[0].element.onclick(),this.highlightExportItem(0))},t.Chart.prototype.hideExportMenu=function(){var e=this.exportDivElements;e&&(l(e,function(e){p(e,"mouseleave")}),e[this.highlightedExportItem]&&e[this.highlightedExportItem].onmouseout&&e[this.highlightedExportItem].onmouseout(),this.highlightedExportItem=0,this.renderTo.focus())},t.Chart.prototype.highlightExportItem=function(e){var t=this.exportDivElements&&this.exportDivElements[e],i=this.exportDivElements&&this.exportDivElements[this.highlightedExportItem];if(t&&"DIV"===t.tagName&&(!t.children||!t.children.length))return t.focus&&t.focus(),i&&i.onmouseout&&i.onmouseout(),t.onmouseover&&t.onmouseover(),this.highlightedExportItem=e,!0},t.Chart.prototype.highlightRangeSelectorButton=function(e){var t=this.rangeSelector.buttons;return t[this.highlightedRangeSelectorItemIx]&&t[this.highlightedRangeSelectorItemIx].setState(this.oldRangeSelectorItemState||0),!!t[this.highlightedRangeSelectorItemIx=e]&&(this.setFocusToElement(t[e].box,t[e]),this.oldRangeSelectorItemState=t[e].state,t[e].setState(2),!0)},t.Chart.prototype.highlightLegendItem=function(e){var t=this.legend.allItems,i=this.highlightedLegendItemIx;return!!t[e]&&(t[i]&&p(t[i].legendGroup.element,"mouseout"),this.highlightedLegendItemIx=e,this.setFocusToElement(t[e].legendItem,t[e].legendGroup),p(t[e].legendGroup.element,"mouseover"),!0)},t.Chart.prototype.addKeyboardNavigationModules=function(){function e(e,t,i){return new n(r,d({keyCodeMap:t},{id:e},i))}var r=this;r.keyboardNavigationModules=[e("entry",[]),e("points",[[[37,39],function(e){return r.highlightAdjacentPoint(39===e),!0}],[[38,40],function(e){var t=r.highlightedPoint&&r.highlightedPoint.series.keyboardMoveVertical?"highlightAdjacentPointVertical":"highlightAdjacentSeries";return r[t](38!==e),!0}],[[13,32],function(){r.highlightedPoint&&r.highlightedPoint.firePointEvent("click")}]],{init:function(){delete r.highlightedPoint;for(var e=0;e<r.series.length;++e)for(var t=0,i=r.series[e].points&&r.series[e].points.length;t<i;++t)if(!c(r.series[e].points[t]))return r.series[e].points[t].highlight()},terminate:function(){r.tooltip&&r.tooltip.hide(0),delete r.highlightedPoint}}),e("exporting",[[[37,38],function(){for(var e=r.highlightedExportItem||0,t=!0;e--;)if(r.highlightExportItem(e)){t=!1;break}if(t)return r.hideExportMenu(),this.move(-1)}],[[39,40],function(){for(var e=!0,t=(r.highlightedExportItem||0)+1;t<r.exportDivElements.length;++t)if(r.highlightExportItem(t)){e=!1;break}if(e)return r.hideExportMenu(),this.move(1)}],[[13,32],function(){o(r.exportDivElements[r.highlightedExportItem])}]],{validate:function(){return r.exportChart&&!(r.options.exporting&&!1===r.options.exporting.enabled)},init:function(e){if(r.highlightedPoint=null,r.showExportMenu(),e<0&&r.exportDivElements)for(var t=r.exportDivElements.length;-1<t&&!r.highlightExportItem(t);--t);},terminate:function(){r.hideExportMenu()}}),e("mapZoom",[[[38,40,37,39],function(e){r[38===e||40===e?"yAxis":"xAxis"][0].panStep(e<39?-1:1)}],[[9],function(e,t){var i;if(r.mapNavButtons[r.focusedMapNavButtonIx].setState(0),t.shiftKey&&!r.focusedMapNavButtonIx||!t.shiftKey&&r.focusedMapNavButtonIx)return r.mapZoom(),this.move(t.shiftKey?-1:1);r.focusedMapNavButtonIx+=t.shiftKey?-1:1,i=r.mapNavButtons[r.focusedMapNavButtonIx],r.setFocusToElement(i.box,i),i.setState(2)}],[[13,32],function(){o(r.mapNavButtons[r.focusedMapNavButtonIx].element)}]],{validate:function(){return r.mapZoom&&r.mapNavButtons&&2===r.mapNavButtons.length},init:function(e){var t=r.mapNavButtons[0],i=r.mapNavButtons[1],n=0<e?t:i;l(r.mapNavButtons,function(e,t){e.element.setAttribute("tabindex",-1),e.element.setAttribute("role","button"),e.element.setAttribute("aria-label","Zoom "+(t?"out ":"")+"chart")}),r.setFocusToElement(n.box,n),n.setState(2),r.focusedMapNavButtonIx=0<e?0:1}}),e("rangeSelector",[[[37,39,38,40],function(e){var t=37===e||38===e?-1:1;if(!r.highlightRangeSelectorButton(r.highlightedRangeSelectorItemIx+t))return this.move(t)}],[[13,32],function(){3!==r.oldRangeSelectorItemState&&o(r.rangeSelector.buttons[r.highlightedRangeSelectorItemIx].element)}]],{validate:function(){return r.rangeSelector&&r.rangeSelector.buttons&&r.rangeSelector.buttons.length},init:function(e){l(r.rangeSelector.buttons,function(e){e.element.setAttribute("tabindex","-1"),e.element.setAttribute("role","button"),e.element.setAttribute("aria-label","Select range "+(e.text&&e.text.textStr))}),r.highlightRangeSelectorButton(0<e?0:r.rangeSelector.buttons.length-1)}}),e("rangeSelectorInput",[[[9,38,40],function(e,t){var i=9===e&&t.shiftKey||38===e?-1:1,n=r.highlightedInputRangeIx=r.highlightedInputRangeIx+i;if(1<n||n<0)return this.move(i);r.rangeSelector[n?"maxInput":"minInput"].focus()}]],{validate:function(){return r.rangeSelector&&r.rangeSelector.inputGroup&&"hidden"!==r.rangeSelector.inputGroup.element.getAttribute("visibility")&&!1!==r.options.rangeSelector.inputEnabled&&r.rangeSelector.minInput&&r.rangeSelector.maxInput},init:function(e){r.highlightedInputRangeIx=0<e?0:1,r.rangeSelector[r.highlightedInputRangeIx?"maxInput":"minInput"].focus()}}),e("legend",[[[37,39,38,40],function(e){var t=37===e||38===e?-1:1;if(!r.highlightLegendItem(r.highlightedLegendItemIx+t))return this.move(t)}],[[13,32],function(){o(r.legend.allItems[r.highlightedLegendItemIx].legendItem.element.parentNode)}]],{validate:function(){return r.legend&&r.legend.allItems&&r.legend.display&&!(r.colorAxis&&r.colorAxis.length)&&!1!==(r.options.legend&&r.options.legend.keyboardNavigation&&r.options.legend.keyboardNavigation.enabled)},init:function(e){l(r.legend.allItems,function(e){e.legendGroup.element.setAttribute("tabindex","-1"),e.legendGroup.element.setAttribute("role","button"),e.legendGroup.element.setAttribute("aria-label",i("Toggle visibility of series "+e.name))}),r.highlightLegendItem(0<e?0:r.legend.allItems.length-1)}})]},t.Chart.prototype.addExitAnchor=function(){var n=this;return n.tabExitAnchor=a.createElement("div"),n.tabExitAnchor.setAttribute("tabindex","0"),d(!0,n.tabExitAnchor.style,{position:"absolute",left:"-9999px",top:"auto",width:"1px",height:"1px",overflow:"hidden"}),n.renderTo.appendChild(n.tabExitAnchor),h(n.tabExitAnchor,"focus",function(e){var t,i=e||r.event;n.exiting?n.exiting=!1:(n.renderTo.focus(),i.preventDefault(),n.keyboardNavigationModuleIndex=n.keyboardNavigationModules.length-1,(t=n.keyboardNavigationModules[n.keyboardNavigationModuleIndex]).validate&&!t.validate()?t.move(-1):t.init(-1))})},t.Chart.prototype.callbacks.push(function(n){var e=n.options.accessibility;e.enabled&&e.keyboardNavigation.enabled&&(n.addKeyboardNavigationModules(),n.keyboardNavigationModuleIndex=0,n.container.hasAttribute&&!n.container.hasAttribute("tabIndex")&&n.container.setAttribute("tabindex","0"),n.tabExitAnchor||(n.unbindExitAnchorFocus=n.addExitAnchor()),n.unbindKeydownHandler=h(n.renderTo,"keydown",function(e){var t=e||r.event,i=n.keyboardNavigationModules[n.keyboardNavigationModuleIndex];i&&i.run(t)&&t.preventDefault()}),h(n,"destroy",function(){n.unbindExitAnchorFocus&&n.tabExitAnchor&&n.unbindExitAnchorFocus(),n.unbindKeydownHandler&&n.renderTo&&n.unbindKeydownHandler()}))})}(e)});