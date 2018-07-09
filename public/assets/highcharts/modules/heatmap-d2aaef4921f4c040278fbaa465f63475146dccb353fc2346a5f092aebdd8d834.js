"use strict";!function(t){"object"==typeof module&&module.exports?module.exports=t:t(Highcharts)}(function(t){var c,e,r,i,h,p,u,n,o,g,f,d,m,s,a,l,x,y,v,b,C,L,M,A,w,I,P,S,z,k;r=(c=t).Axis,i=c.Chart,h=c.color,p=c.each,u=c.extend,n=c.isNumber,o=c.Legend,g=c.LegendSymbolMixin,f=c.noop,d=c.merge,m=c.pick,s=c.wrap,c.ColorAxis||(e=c.ColorAxis=function(){this.init.apply(this,arguments)},u(e.prototype,r.prototype),u(e.prototype,{defaultColorAxisOptions:{lineWidth:0,minPadding:0,maxPadding:0,gridLineWidth:1,tickPixelInterval:72,startOnTick:!0,endOnTick:!0,offset:0,marker:{animation:{duration:50},width:.01,color:"#999999"},labels:{overflow:"justify",rotation:0},minColor:"#e6ebf5",maxColor:"#003399",tickLength:5,showInLegend:!0},keepProps:["legendGroup","legendItemHeight","legendItemWidth","legendItem","legendSymbol"].concat(r.prototype.keepProps),init:function(t,i){var e,o="vertical"!==t.options.legend.layout;this.coll="colorAxis",e=d(this.defaultColorAxisOptions,{side:o?2:1,reversed:!o},i,{opposite:!o,showEmpty:!1,title:null}),r.prototype.init.call(this,t,e),i.dataClasses&&this.initDataClasses(i),this.initStops(),this.horiz=o,this.zoomEnabled=!1,this.defaultLegendLength=200},initDataClasses:function(t){var o,s=this.chart,n=0,a=s.options.chart.colorCount,r=this.options,l=t.dataClasses.length;this.dataClasses=o=[],this.legendItems=[],p(t.dataClasses,function(t,i){var e;t=d(t),o.push(t),t.color||("category"===r.dataClassColor?(e=s.options.colors,a=e.length,t.color=e[n],t.colorIndex=n,++n===a&&(n=0)):t.color=h(r.minColor).tweenTo(h(r.maxColor),l<2?.5:i/(l-1)))})},setTickPositions:function(){if(!this.dataClasses)return r.prototype.setTickPositions.call(this)},initStops:function(){this.stops=this.options.stops||[[0,this.options.minColor],[1,this.options.maxColor]],p(this.stops,function(t){t.color=h(t[1])})},setOptions:function(t){r.prototype.setOptions.call(this,t),this.options.crosshair=this.options.marker},setAxisSize:function(){var t,i,e,o,s=this.legendSymbol,n=this.chart,a=n.options.legend||{};s?(this.left=t=s.attr("x"),this.top=i=s.attr("y"),this.width=e=s.attr("width"),this.height=o=s.attr("height"),this.right=n.chartWidth-t-e,this.bottom=n.chartHeight-i-o,this.len=this.horiz?e:o,this.pos=this.horiz?t:i):this.len=(this.horiz?a.symbolWidth:a.symbolHeight)||this.defaultLegendLength},normalizedValue:function(t){return this.isLog&&(t=this.val2lin(t)),1-(this.max-t)/(this.max-this.min||1)},toColor:function(t,i){var e,o,s,n,a,r,l=this.stops,h=this.dataClasses;if(h){for(r=h.length;r--;)if(o=(a=h[r]).from,s=a.to,(o===undefined||o<=t)&&(s===undefined||t<=s)){n=a.color,i&&(i.dataClass=r,i.colorIndex=a.colorIndex);break}}else{for(e=this.normalizedValue(t),r=l.length;r--&&!(e>l[r][0]););o=l[r]||l[r+1],e=1-((s=l[r+1]||o)[0]-e)/(s[0]-o[0]||1),n=o.color.tweenTo(s.color,e)}return n},getOffset:function(){var t=this.legendGroup,i=this.chart.axisOffset[this.side];t&&(this.axisParent=t,r.prototype.getOffset.call(this),this.added||(this.added=!0,this.labelLeft=0,this.labelRight=this.width),this.chart.axisOffset[this.side]=i)},setLegendColor:function(){var t,i=this.horiz,e=this.reversed,o=e?1:0,s=e?0:1;t=i?[o,0,s,0]:[0,s,0,o],this.legendColor={linearGradient:{x1:t[0],y1:t[1],x2:t[2],y2:t[3]},stops:this.stops}},drawLegendSymbol:function(t,i){var e=t.padding,o=t.options,s=this.horiz,n=m(o.symbolWidth,s?this.defaultLegendLength:12),a=m(o.symbolHeight,s?12:this.defaultLegendLength),r=m(o.labelPadding,s?16:30),l=m(o.itemDistance,10);this.setLegendColor(),i.legendSymbol=this.chart.renderer.rect(0,t.baseline-11,n,a).attr({zIndex:1}).add(i.legendGroup),this.legendItemWidth=n+e+(s?l:r),this.legendItemHeight=a+e+(s?r:0)},setState:f,visible:!0,setVisible:f,getSeriesExtremes:function(){var t=this.series,i=t.length;for(this.dataMin=Infinity,this.dataMax=-Infinity;i--;)t[i].valueMin!==undefined&&(this.dataMin=Math.min(this.dataMin,t[i].valueMin),this.dataMax=Math.max(this.dataMax,t[i].valueMax))},drawCrosshair:function(t,i){var e,o=i&&i.plotX,s=i&&i.plotY,n=this.pos,a=this.len;i&&((e=this.toPixels(i[i.series.colorKey]))<n?e=n-2:n+a<e&&(e=n+a+2),i.plotX=e,i.plotY=this.len-e,r.prototype.drawCrosshair.call(this,t,i),i.plotX=o,i.plotY=s,this.cross&&(this.cross.addClass("highcharts-coloraxis-marker").add(this.legendGroup),this.cross.attr({fill:this.crosshair.color})))},getPlotLinePath:function(t,i,e,o,s){return n(s)?this.horiz?["M",s-4,this.top-6,"L",s+4,this.top-6,s,this.top,"Z"]:["M",this.left,s,"L",this.left-6,s+6,this.left-6,s-6,"Z"]:r.prototype.getPlotLinePath.call(this,t,i,e,o)},update:function(t,i){var e=this.chart,o=e.legend;p(this.series,function(t){t.isDirtyData=!0}),t.dataClasses&&o.allItems&&(p(o.allItems,function(t){t.isDataClass&&t.legendGroup&&t.legendGroup.destroy()}),e.isDirtyLegend=!0),e.options[this.coll]=d(this.userOptions,t),r.prototype.update.call(this,t,i),this.legendItem&&(this.setLegendColor(),o.colorizeItem(this,!0))},remove:function(){this.legendItem&&this.chart.legend.destroyItem(this),r.prototype.remove.call(this)},getDataClassLegendSymbols:function(){var n,a=this,r=this.chart,l=this.legendItems,t=r.options.legend,h=t.valueDecimals,d=t.valueSuffix||"";return l.length||p(this.dataClasses,function(t,i){var e=!0,o=t.from,s=t.to;n="",o===undefined?n="< ":s===undefined&&(n="> "),o!==undefined&&(n+=c.numberFormat(o,h)+d),o!==undefined&&s!==undefined&&(n+=" - "),s!==undefined&&(n+=c.numberFormat(s,h)+d),l.push(u({chart:r,name:n,options:{},drawLegendSymbol:g.drawRectangle,visible:!0,setState:f,isDataClass:!0,setVisible:function(){e=this.visible=!e,p(a.series,function(t){p(t.points,function(t){t.dataClass===i&&t.setVisible(e)})}),r.legend.colorizeItem(this,e)}},t))}),l},name:""}),p(["fill","stroke"],function(t){c.Fx.prototype[t+"Setter"]=function(){this.elem.attr(t,h(this.start).tweenTo(h(this.end),this.pos),null,!0)}}),s(i.prototype,"getAxes",function(t){var i=this.options.colorAxis;t.call(this),this.colorAxis=[],i&&new e(this,i)}),s(o.prototype,"getAllItems",function(t){var i=[],e=this.chart.colorAxis[0];return e&&e.options&&(e.options.showInLegend&&(e.options.dataClasses?i=i.concat(e.getDataClassLegendSymbols()):i.push(e)),p(e.series,function(t){t.options.showInLegend=!1})),i.concat(t.call(this))}),s(o.prototype,"colorizeItem",function(t,i,e){t.call(this,i,e),e&&i.legendColor&&i.legendSymbol.attr({fill:i.legendColor})}),s(o.prototype,"update",function(t,i,e){t.apply(this,[].slice.call(arguments,1)),this.chart.colorAxis[0]&&this.chart.colorAxis[0].update({},e)})),l=(a=t).defined,x=a.each,y=a.noop,v=a.seriesTypes,a.colorPointMixin={isValid:function(){return null!==this.value},setVisible:function(t){var i=this,e=t?"show":"hide";x(["graphic","dataLabel"],function(t){i[t]&&i[t][e]()})},setState:function(t){a.Point.prototype.setState.call(this,t),this.graphic&&this.graphic.attr({zIndex:"hover"===t?1:0})}},a.colorSeriesMixin={pointArrayMap:["value"],axisTypes:["xAxis","yAxis","colorAxis"],optionalAxis:"colorAxis",trackerGroups:["group","markerGroup","dataLabelsGroup"],getSymbol:y,parallelArrays:["x","y","value"],colorKey:"value",pointAttribs:v.column.prototype.pointAttribs,translateColors:function(){var o=this,s=this.options.nullColor,n=this.colorAxis,a=this.colorKey;x(this.data,function(t){var i,e=t[a];(i=t.options.color||(t.isNull?s:n&&e!==undefined?n.toColor(e,t):t.color||o.color))&&(t.color=i)})},colorAttribs:function(t){var i={};return l(t.color)&&(i[this.colorProp||"fill"]=t.color),i}},C=(b=t).colorPointMixin,L=b.colorSeriesMixin,M=b.each,A=b.LegendSymbolMixin,w=b.merge,I=b.noop,P=b.pick,S=b.Series,z=b.seriesType,k=b.seriesTypes,z("heatmap","scatter",{animation:!1,borderWidth:0,nullColor:"#f7f7f7",dataLabels:{formatter:function(){return this.point.value},inside:!0,verticalAlign:"middle",crop:!1,overflow:!1,padding:0},marker:null,pointRange:null,tooltip:{pointFormat:"{point.x}, {point.y}: {point.value}<br/>"},states:{normal:{animation:!0},hover:{halo:!1,brightness:.2}}},w(L,{pointArrayMap:["y","value"],hasPointSpecificOptions:!0,getExtremesFromAll:!0,directTouch:!0,init:function(){var t;k.scatter.prototype.init.apply(this,arguments),(t=this.options).pointRange=P(t.pointRange,t.colsize||1),this.yAxis.axisPointRange=t.rowsize||1},translate:function(){var t=this,l=t.options,h=t.xAxis,d=t.yAxis,c=l.pointPadding||0,p=function(t,i,e){return Math.min(Math.max(i,t),e)};t.generatePoints(),M(t.points,function(t){var i=(l.colsize||1)/2,e=(l.rowsize||1)/2,o=p(Math.round(h.len-h.translate(t.x-i,0,1,0,1)),-h.len,2*h.len),s=p(Math.round(h.len-h.translate(t.x+i,0,1,0,1)),-h.len,2*h.len),n=p(Math.round(d.translate(t.y-e,0,1,0,1)),-d.len,2*d.len),a=p(Math.round(d.translate(t.y+e,0,1,0,1)),-d.len,2*d.len),r=P(t.pointPadding,c);t.plotX=t.clientX=(o+s)/2,t.plotY=(n+a)/2,t.shapeType="rect",t.shapeArgs={x:Math.min(o,s)+r,y:Math.min(n,a)+r,width:Math.abs(s-o)-2*r,height:Math.abs(a-n)-2*r}}),t.translateColors()},drawPoints:function(){k.column.prototype.drawPoints.call(this),M(this.points,function(t){t.graphic.attr(this.colorAttribs(t))},this)},animate:I,getBox:I,drawLegendSymbol:A.drawRectangle,alignDataLabel:k.column.prototype.alignDataLabel,getExtremes:function(){S.prototype.getExtremes.call(this,this.valueData),this.valueMin=this.dataMin,this.valueMax=this.dataMax,S.prototype.getExtremes.call(this)}}),b.extend({haloPath:function(t){if(!t)return[];var i=this.shapeArgs;return["M",i.x-t,i.y-t,"L",i.x-t,i.y+i.height+t,i.x+i.width+t,i.y+i.height+t,i.x+i.width+t,i.y-t,"Z"]}},C))});