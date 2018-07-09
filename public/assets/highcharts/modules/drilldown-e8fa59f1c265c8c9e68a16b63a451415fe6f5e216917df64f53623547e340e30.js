"use strict";!function(t){"object"==typeof module&&module.exports?module.exports=t:t(Highcharts)}(function(t){!function(u){var m=u.noop,g=u.color,t=u.defaultOptions,w=u.each,f=u.extend,e=u.format,o=u.objectEach,n=u.pick,i=u.wrap,l=u.Chart,r=u.seriesTypes,s=r.pie,a=r.column,d=u.Tick,h=u.fireEvent,v=u.inArray,y=1;f(t.lang,{drillUpText:"\u25c1 Back to {series.name}"}),t.drilldown={activeAxisLabelStyle:{cursor:"pointer",color:"#003399",fontWeight:"bold",textDecoration:"underline"},activeDataLabelStyle:{cursor:"pointer",color:"#003399",fontWeight:"bold",textDecoration:"underline"},animation:{duration:500},drillUpButton:{position:{align:"right",x:-10,y:10}}},u.SVGRenderer.prototype.Element.prototype.fadeIn=function(t){this.attr({opacity:.1,visibility:"inherit"}).animate({opacity:n(this.newOpacity,1)},t||{duration:250})},l.prototype.addSeriesAsDrilldown=function(t,i){this.addSingleSeriesAsDrilldown(t,i),this.applyDrilldown()},l.prototype.addSingleSeriesAsDrilldown=function(t,i){var e,o,l,r,n,s,a=t.series,d=a.xAxis,p=a.yAxis,h=[],c=[];s={color:t.color||a.color},this.drilldownLevels||(this.drilldownLevels=[]),r=a.options._levelNumber||0,(n=this.drilldownLevels[this.drilldownLevels.length-1])&&n.levelNumber!==r&&(n=undefined),i=f(f({_ddSeriesId:y++},s),i),o=v(t,a.points),w(a.chart.series,function(t){t.xAxis!==d||t.isDrilling||(t.options._ddSeriesId=t.options._ddSeriesId||y++,t.options._colorIndex=t.userOptions._colorIndex,t.options._levelNumber=t.options._levelNumber||r,n?(h=n.levelSeries,c=n.levelSeriesOptions):(h.push(t),c.push(t.options)))}),l=f({levelNumber:r,seriesOptions:a.options,levelSeriesOptions:c,levelSeries:h,shapeArgs:t.shapeArgs,bBox:t.graphic?t.graphic.getBBox():{},color:t.isNull?new u.Color(g).setOpacity(0).get():g,lowerSeriesOptions:i,pointOptions:a.options.data[o],pointIndex:o,oldExtremes:{xMin:d&&d.userMin,xMax:d&&d.userMax,yMin:p&&p.userMin,yMax:p&&p.userMax},resetZoomButton:this.resetZoomButton},s),this.drilldownLevels.push(l),d&&d.names&&(d.names.length=0),(e=l.lowerSeries=this.addSeries(i,!1)).options._levelNumber=r+1,d&&(d.oldPos=d.pos,d.userMin=d.userMax=null,p.userMin=p.userMax=null),a.type===e.type&&(e.animate=e.animateDrilldown||m,e.options.animation=!0)},l.prototype.applyDrilldown=function(){var i,t=this.drilldownLevels;t&&0<t.length&&(i=t[t.length-1].levelNumber,w(this.drilldownLevels,function(t){t.levelNumber===i&&w(t.levelSeries,function(t){t.options&&t.options._levelNumber===i&&t.remove(!1)})})),this.resetZoomButton&&(this.resetZoomButton.hide(),delete this.resetZoomButton),this.pointer.reset(),this.redraw(),this.showDrillUpButton()},l.prototype.getDrilldownBackText=function(){var t,i=this.drilldownLevels;if(i&&0<i.length)return(t=i[i.length-1]).series=t.seriesOptions,e(this.options.lang.drillUpText,t)},l.prototype.showDrillUpButton=function(){var t,i,e=this,o=this.getDrilldownBackText(),l=e.options.drilldown.drillUpButton;this.drillUpButton?this.drillUpButton.attr({text:o}).align():(i=(t=l.theme)&&t.states,this.drillUpButton=this.renderer.button(o,null,null,function(){e.drillUp()},t,i&&i.hover,i&&i.select).addClass("highcharts-drillup-button").attr({align:l.position.align,zIndex:7}).add().align(l.position,!1,l.relativeTo||"plotBox"))},l.prototype.drillUp=function(){for(var t,o,l,r,i,n=this,e=n.drilldownLevels,s=e[e.length-1].levelNumber,a=e.length,d=n.series,p=function(i){var e;w(d,function(t){t.options._ddSeriesId===i._ddSeriesId&&(e=t)}),(e=e||n.addSeries(i,!1)).type===l.type&&e.animateDrillupTo&&(e.animate=e.animateDrillupTo),i===o.seriesOptions&&(r=e)};a--;)if((o=e[a]).levelNumber===s){if(e.pop(),!(l=o.lowerSeries).chart)for(t=d.length;t--;)if(d[t].options.id===o.lowerSeriesOptions.id&&d[t].options._levelNumber===s+1){l=d[t];break}l.xData=[],w(o.levelSeriesOptions,p),h(n,"drillup",{seriesOptions:o.seriesOptions}),r.type===l.type&&(r.drilldownLevel=o,r.options.animation=n.options.drilldown.animation,l.animateDrillupFrom&&l.chart&&l.animateDrillupFrom(o)),r.options._levelNumber=s,l.remove(!1),r.xAxis&&(i=o.oldExtremes,r.xAxis.setExtremes(i.xMin,i.xMax,!1),r.yAxis.setExtremes(i.yMin,i.yMax,!1)),o.resetZoomButton&&(n.resetZoomButton=o.resetZoomButton,n.resetZoomButton.show())}h(n,"drillupall"),this.redraw(),0===this.drilldownLevels.length?this.drillUpButton=this.drillUpButton.destroy():this.drillUpButton.attr({text:this.getDrilldownBackText()}).align(),this.ddDupes.length=[]},i(l.prototype,"showResetZoom",function(t){this.drillUpButton||t.apply(this,Array.prototype.slice.call(arguments,1))}),a.prototype.animateDrillupTo=function(t){if(!t){var i=this,r=i.drilldownLevel;w(this.points,function(t){var i=t.dataLabel;t.graphic&&t.graphic.hide(),i&&(i.hidden="hidden"===i.attr("visibility"),i.hidden||(i.hide(),t.connector&&t.connector.hide()))}),setTimeout(function(){i.points&&w(i.points,function(t,i){var e=i===(r&&r.pointIndex)?"show":"fadeIn",o="show"===e||undefined,l=t.dataLabel;t.graphic&&t.graphic[e](o),l&&!l.hidden&&(l[e](o),t.connector&&t.connector[e](o))})},Math.max(this.chart.options.drilldown.animation.duration-50,0)),this.animate=m}},a.prototype.animateDrilldown=function(t){var i,e=this,o=this.chart.drilldownLevels,l=this.chart.options.drilldown.animation,r=this.xAxis;t||(w(o,function(t){e.options._ddSeriesId===t.lowerSeriesOptions._ddSeriesId&&((i=t.shapeArgs).fill=t.color)}),i.x+=n(r.oldPos,r.pos)-r.pos,w(this.points,function(t){t.shapeArgs.fill=t.color,t.graphic&&t.graphic.attr(i).animate(f(t.shapeArgs,{fill:t.color||e.color}),l),t.dataLabel&&t.dataLabel.fadeIn(l)}),this.animate=null)},a.prototype.animateDrillupFrom=function(l){var r=this.chart.options.drilldown.animation,n=this.group,s=n!==this.chart.columnGroup,i=this;w(i.trackerGroups,function(t){i[t]&&i[t].on("mouseover")}),s&&delete this.group,w(this.points,function(t){var i=t.graphic,e=l.shapeArgs,o=function(){i.destroy(),n&&s&&(n=n.destroy())};i&&(delete t.graphic,e.fill=l.color,r?i.animate(e,u.merge(r,{complete:o})):(i.attr(e),o()))})},s&&f(s.prototype,{animateDrillupTo:a.prototype.animateDrillupTo,animateDrillupFrom:a.prototype.animateDrillupFrom,animateDrilldown:function(t){var o=this.chart.drilldownLevels[this.chart.drilldownLevels.length-1],l=this.chart.options.drilldown.animation,r=o.shapeArgs,n=r.start,s=(r.end-n)/this.points.length;t||(w(this.points,function(t,i){var e=t.shapeArgs;r.fill=o.color,e.fill=t.color,t.graphic&&t.graphic.attr(u.merge(r,{start:n+i*s,end:n+(i+1)*s}))[l?"animate":"attr"](e,l)}),this.animate=null)}}),u.Point.prototype.doDrilldown=function(o,t,i){var e,l=this.series.chart,r=l.options.drilldown,n=(r.series||[]).length;for(l.ddDupes||(l.ddDupes=[]);n--&&!e;)r.series[n].id===this.drilldown&&-1===v(this.drilldown,l.ddDupes)&&(e=r.series[n],l.ddDupes.push(this.drilldown));h(l,"drilldown",{point:this,seriesOptions:e,category:t,originalEvent:i,points:t!==undefined&&this.series.xAxis.getDDPoints(t).slice(0)},function(t){var i=t.point.series&&t.point.series.chart,e=t.seriesOptions;i&&e&&(o?i.addSingleSeriesAsDrilldown(t.point,e):i.addSeriesAsDrilldown(t.point,e))})},u.Axis.prototype.drilldownCategory=function(i,e){o(this.getDDPoints(i),function(t){t&&t.series&&t.series.visible&&t.doDrilldown&&t.doDrilldown(!0,i,e)}),this.chart.applyDrilldown()},u.Axis.prototype.getDDPoints=function(l){var r=[];return w(this.series,function(t){var i,e=t.xData,o=t.points;for(i=0;i<e.length;i++)if(e[i]===l&&t.options.data[i]&&t.options.data[i].drilldown){r.push(!o||o[i]);break}}),r},d.prototype.drillable=function(){var i=this.pos,t=this.label,e=this.axis,o="xAxis"===e.coll&&e.getDDPoints,l=o&&e.getDDPoints(i);o&&(t&&l.length?(t.drillable=!0,t.basicStyles||(t.basicStyles=u.merge(t.styles)),t.addClass("highcharts-drilldown-axis-label").css(e.chart.options.drilldown.activeAxisLabelStyle).on("click",function(t){e.drilldownCategory(i,t)})):t&&t.drillable&&(t.styles={},t.css(t.basicStyles),t.on("click",null),t.removeClass("highcharts-drilldown-axis-label")))},i(d.prototype,"addLabel",function(t){t.call(this),this.drillable()}),i(u.Point.prototype,"init",function(t,i,e,o){var l=t.call(this,i,e,o),r=i.xAxis,n=r&&r.ticks[o];return l.drilldown&&u.addEvent(l,"click",function(t){i.xAxis&&!1===i.chart.options.drilldown.allowPointDrilldown?i.xAxis.drilldownCategory(l.x,t):l.doDrilldown(undefined,undefined,t)}),n&&n.drillable(),l}),i(u.Series.prototype,"drawDataLabels",function(t){var o=this.chart.options.drilldown.activeDataLabelStyle,l=this.chart.renderer;t.call(this),w(this.points,function(t){var i=t.options.dataLabels,e=n(t.dlOptions,i&&i.style,{});t.drilldown&&t.dataLabel&&("contrast"===o.color&&(e.color=l.getContrast(t.color||this.color)),i&&i.color&&(e.color=i.color),t.dataLabel.addClass("highcharts-drilldown-data-label"),t.dataLabel.css(o).css(e))},this)});var p=function(t,i,e){t[e?"addClass":"removeClass"]("highcharts-drilldown-point"),t.css({cursor:i})},c=function(t){t.call(this),w(this.points,function(t){t.drilldown&&t.graphic&&p(t.graphic,"pointer",!0)})},x=function(t,i){var e=t.apply(this,Array.prototype.slice.call(arguments,1));return this.drilldown&&this.series.halo&&"hover"===i?p(this.series.halo,"pointer",!0):this.series.halo&&p(this.series.halo,"auto",!1),e};o(r,function(t){i(t.prototype,"drawTracker",c),i(t.prototype.pointClass.prototype,"setState",x)})}(t)});