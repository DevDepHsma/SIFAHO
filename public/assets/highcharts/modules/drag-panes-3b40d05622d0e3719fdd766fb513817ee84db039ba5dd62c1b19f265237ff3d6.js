"use strict";!function(t){"object"==typeof module&&module.exports?module.exports=t:t(Highcharts)}(function(t){var n,a,e,o,i,z,h,A,s,r,c,p;a=(n=t).hasTouch,e=n.merge,o=n.wrap,i=n.each,z=n.isNumber,h=n.addEvent,A=n.relativeLength,s=n.objectEach,r=n.Axis,c=n.Pointer,p={minLength:"10%",maxLength:"100%",resize:{controlledAxis:{next:[],prev:[]},enabled:!1,cursor:"ns-resize",lineColor:"#cccccc",lineDashStyle:"Solid",lineWidth:4,x:0,y:0}},e(!0,r.prototype.defaultYAxisOptions,p),n.AxisResizer=function(t){this.init(t)},n.AxisResizer.prototype={init:function(t,e){this.axis=t,this.options=t.options.resize,this.render(),e||this.addMouseEvents()},render:function(){var t,e=this,o=e.axis,i=o.chart,s=e.options,n=s.x,r=s.y,a=Math.min(Math.max(o.top+o.height+r,i.plotTop),i.plotTop+i.plotHeight),h={};h={cursor:s.cursor,stroke:s.lineColor,"stroke-width":s.lineWidth,dashstyle:s.lineDashStyle},e.lastPos=a-r,e.controlLine||(e.controlLine=i.renderer.path().addClass("highcharts-axis-resizer")),e.controlLine.add(o.axisGroup),t=s.lineWidth,h.d=i.renderer.crispLine(["M",o.left+n,a,"L",o.left+o.width+n,a],t),e.controlLine.attr(h)},addMouseEvents:function(){var t,e,o,i=this,s=i.controlLine.element,n=i.axis.chart.container,r=[];i.mouseMoveHandler=t=function(t){i.onMouseMove(t)},i.mouseUpHandler=e=function(t){i.onMouseUp(t)},i.mouseDownHandler=o=function(t){i.onMouseDown(t)},r.push(h(n,"mousemove",t),h(n.ownerDocument,"mouseup",e),h(s,"mousedown",o)),a&&r.push(h(n,"touchmove",t),h(n.ownerDocument,"touchend",e),h(s,"touchstart",o)),i.eventsToUnbind=r},onMouseMove:function(t){t.touches&&0===t.touches[0].pageX||this.grabbed&&(this.hasDragged=!0,this.updateAxes(this.axis.chart.pointer.normalize(t).chartY-this.options.y))},onMouseUp:function(t){this.hasDragged&&this.updateAxes(this.axis.chart.pointer.normalize(t).chartY-this.options.y),this.grabbed=this.hasDragged=this.axis.chart.activeResizer=null},onMouseDown:function(){this.axis.chart.pointer.reset(!1,0),this.grabbed=this.axis.chart.activeResizer=!0},updateAxes:function(u){var l,d=this,x=d.axis.chart,t=d.options.controlledAxis,e=0===t.next.length?[n.inArray(d.axis,x.yAxis)+1]:t.next,o=[d.axis].concat(t.prev),y=[],m=!1,f=x.plotTop,g=x.plotHeight,v=f+g,M=function(t,e,o){return Math.round(Math.min(Math.max(t,e),o))};u=Math.max(Math.min(u,v),f),(l=u-d.lastPos)*l<1||(i([o,e],function(t,p){i(t,function(t,e){var o,i,s,n,r=z(t)?x.yAxis[t]:p||e?x.get(t):t,a=r&&r.options,h={},c=0;a&&(i=r.top,s=Math.round(A(a.minLength,g)),n=Math.round(A(a.maxLength,g)),p?(l=u-d.lastPos,o=M(r.len-l,s,n),i=r.top+l,v<i+o&&(u+=c=v-o-i,i+=c),i<f&&v<(i=f)+o&&(o=g),o===s&&(m=!0),y.push({axis:r,options:{top:Math.round(i),height:o}})):((o=M(u-i,s,n))===n&&(m=!0),u=i+o,y.push({axis:r,options:{height:o}})),h.height=o)})}),m||(i(y,function(t){t.axis.update(t.options,!1)}),x.redraw(!1)))},destroy:function(){var o=this;delete o.axis.resizer,this.eventsToUnbind&&i(this.eventsToUnbind,function(t){t()}),o.controlLine.destroy(),s(o,function(t,e){o[e]=null})}},r.prototype.keepProps.push("resizer"),o(r.prototype,"render",function(t){t.apply(this,Array.prototype.slice.call(arguments,1));var e,o=this,i=o.resizer,s=o.options.resize;s&&(e=!1!==s.enabled,i?e?i.init(o,!0):i.destroy():e&&(o.resizer=new n.AxisResizer(o)))}),o(r.prototype,"destroy",function(t,e){!e&&this.resizer&&this.resizer.destroy(),t.apply(this,Array.prototype.slice.call(arguments,1))}),o(c.prototype,"runPointActions",function(t){this.chart.activeResizer||t.apply(this,Array.prototype.slice.call(arguments,1))})});