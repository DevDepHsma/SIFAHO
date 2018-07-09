"use strict";!function(t){"object"==typeof module&&module.exports?module.exports=t:t(Highcharts)}(function(t){var i,s,r,c,d,a,u,g,e,p,f,m,y,o,x,b,n,l,h,P,M,k,A,w,L,v,C,S,X,Y,T,R,z,G,I,D,W,B,O,H,N,V,q,E,_,K,U,F,$,Q,Z,j,J,tt,it,at,et,ot,st,rt,nt,lt,ht,pt,ct,dt,ut,gt,ft,mt,yt,xt,bt,Pt,Mt,kt,At,wt,Lt,vt,Ct,St,Xt,Yt,Tt,Rt,zt,Gt,It;s=(i=t).deg2rad,r=i.isNumber,c=i.pick,d=i.relativeLength,i.CenteredSeriesMixin={getCenter:function(){var t,i,a,e=this.options,o=this.chart,s=2*(e.slicedOffset||0),r=o.plotWidth-2*s,n=o.plotHeight-2*s,l=e.center,h=[c(l[0],"50%"),c(l[1],"50%"),e.size||"100%",e.innerSize||0],p=Math.min(r,n);for(i=0;i<4;++i)a=h[i],t=i<2||2===i&&/%$/.test(a),h[i]=d(a,[r,n,p,h[2]][i])+(t?s:0);return h[3]>h[2]&&(h[3]=h[2]),h},getStartAndEndRadians:function(t,i){var a=r(t)?t:0,e=r(i)&&a<i&&i-a<360?i:a+360,o=-90;return{start:s*(a+o),end:s*(e+o)}}},function(t){function i(t,i){this.init(t,i)}var a=t.CenteredSeriesMixin,e=t.each,o=t.extend,s=t.merge,r=t.splat;o(i.prototype,{coll:"pane",init:function(t,i){this.chart=i,this.background=[],i.pane.push(this),this.setOptions(t)},setOptions:function(t){this.options=t=s(this.defaultOptions,this.chart.angular?{background:{}}:undefined,t)},render:function(){var t,i,a=this.options,e=this.options.background,o=this.chart.renderer;if(this.group||(this.group=o.g("pane-group").attr({zIndex:a.zIndex||0}).add()),this.updateCenter(),e)for(e=r(e),t=Math.max(e.length,this.background.length||0),i=0;i<t;i++)e[i]&&this.axis?this.renderBackground(s(this.defaultBackgroundOptions,e[i]),i):this.background[i]&&(this.background[i]=this.background[i].destroy(),this.background.splice(i,1))},renderBackground:function(t,i){var a="animate";this.background[i]||(this.background[i]=this.chart.renderer.path().add(this.group),a="attr"),this.background[i][a]({d:this.axis.getPlotBandPath(t.from,t.to,t)}).attr({fill:t.backgroundColor,stroke:t.borderColor,"stroke-width":t.borderWidth,"class":"highcharts-pane "+(t.className||"")})},defaultOptions:{center:["50%","50%"],size:"85%",startAngle:0},defaultBackgroundOptions:{shape:"circle",borderWidth:1,borderColor:"#cccccc",backgroundColor:{linearGradient:{x1:0,y1:0,x2:0,y2:1},stops:[[0,"#ffffff"],[1,"#e6e6e6"]]},from:-Number.MAX_VALUE,innerRadius:0,to:Number.MAX_VALUE,outerRadius:"105%"},updateCenter:function(t){this.center=(t||this.axis||{}).center=a.getCenter.call(this)},update:function(t,i){s(!0,this.options,t),this.setOptions(this.options),this.render(),e(this.chart.axes,function(t){t.pane===this&&(t.pane=null,t.update({},i))},this)}}),t.Pane=i}(t),e=(a=t).Axis,p=a.each,f=a.extend,m=a.map,y=a.merge,o=a.noop,x=a.pick,b=a.pInt,n=a.Tick,l=a.wrap,h=e.prototype,P=n.prototype,g={defaultRadialGaugeOptions:{labels:{align:"center",x:0,y:null},minorGridLineWidth:0,minorTickInterval:"auto",minorTickLength:10,minorTickPosition:"inside",minorTickWidth:1,tickLength:10,tickPosition:"inside",tickWidth:2,title:{rotation:0},zIndex:2},defaultRadialXOptions:{gridLineWidth:1,labels:{align:null,distance:15,x:0,y:null},maxPadding:0,minPadding:0,showLastLabel:(u={getOffset:o,redraw:function(){this.isDirty=!1},render:function(){this.isDirty=!1},setScale:o,setCategories:o,setTitle:o},!1),tickLength:0},defaultRadialYOptions:{gridLineInterpolation:"circle",labels:{align:"right",x:-3,y:-2},showLastLabel:!1,title:{x:4,text:null,rotation:90}},setOptions:function(t){var i=this.options=y(this.defaultOptions,this.defaultRadialOptions,t);i.plotBands||(i.plotBands=[])},getOffset:function(){h.getOffset.call(this),this.chart.axisOffset[this.side]=0},getLinePath:function(t,i){var a,e,o=this.center,s=this.chart,r=x(i,o[2]/2-this.offset);return this.isCircular||i!==undefined?((e=this.chart.renderer.symbols.arc(this.left+o[0],this.top+o[1],r,r,{start:this.startAngleRad,end:this.endAngleRad,open:!0,innerR:0})).xBounds=[this.left+o[0]],e.yBounds=[this.top+o[1]-r]):(a=this.postTranslate(this.angleRad,r),e=["M",o[0]+s.plotLeft,o[1]+s.plotTop,"L",a.x,a.y]),e},setAxisTranslation:function(){h.setAxisTranslation.call(this),this.center&&(this.isCircular?this.transA=(this.endAngleRad-this.startAngleRad)/(this.max-this.min||1):this.transA=this.center[2]/2/(this.max-this.min||1),this.isXAxis?this.minPixelPadding=this.transA*this.minPointOffset:this.minPixelPadding=0)},beforeSetTickPositions:function(){this.autoConnect=this.isCircular&&x(this.userMax,this.options.max)===undefined&&this.endAngleRad-this.startAngleRad==2*Math.PI,this.autoConnect&&(this.max+=(this.categories?1:this.pointRange)||this.closestPointRange||0)},setAxisSize:function(){h.setAxisSize.call(this),this.isRadial&&(this.pane.updateCenter(this),this.isCircular&&(this.sector=this.endAngleRad-this.startAngleRad),this.len=this.width=this.height=this.center[2]*x(this.sector,1)/2)},getPosition:function(t,i){return this.postTranslate(this.isCircular?this.translate(t):this.angleRad,x(this.isCircular?i:this.translate(t),this.center[2]/2)-this.offset)},postTranslate:function(t,i){var a=this.chart,e=this.center;return t=this.startAngleRad+t,{x:a.plotLeft+e[0]+Math.cos(t)*i,y:a.plotTop+e[1]+Math.sin(t)*i}},getPlotBandPath:function(t,i,a){var e,o,s,r,n=this.center,l=this.startAngleRad,h=n[2]/2,p=[x(a.outerRadius,"100%"),a.innerRadius,x(a.thickness,10)],c=Math.min(this.offset,0),d=/%$/,u=this.isCircular;return"polygon"===this.options.gridLineInterpolation?r=this.getPlotLinePath(t).concat(this.getPlotLinePath(i,!0)):(t=Math.max(t,this.min),i=Math.min(i,this.max),u||(p[0]=this.translate(t),p[1]=this.translate(i)),p=m(p,function(t){return d.test(t)&&(t=b(t,10)*h/100),t}),"circle"!==a.shape&&u?(e=l+this.translate(t),o=l+this.translate(i)):(e=-Math.PI/2,o=1.5*Math.PI,s=!0),p[0]-=c,p[2]-=c,r=this.chart.renderer.symbols.arc(this.left+n[0],this.top+n[1],p[0],p[0],{start:Math.min(e,o),end:Math.max(e,o),innerR:x(p[1],p[0]-p[2]),open:s})),r},getPlotLinePath:function(a,t){var e,o,i,s,r=this,n=r.center,l=r.chart,h=r.getPosition(a);return r.isCircular?s=["M",n[0]+l.plotLeft,n[1]+l.plotTop,"L",h.x,h.y]:"circle"===r.options.gridLineInterpolation?(a=r.translate(a))&&(s=r.getLinePath(0,a)):(p(l.xAxis,function(t){t.pane===r.pane&&(e=t)}),s=[],a=r.translate(a),i=e.tickPositions,e.autoConnect&&(i=i.concat([i[0]])),t&&(i=[].concat(i).reverse()),p(i,function(t,i){o=e.getPosition(t,a),s.push(i?"L":"M",o.x,o.y)})),s},getTitlePosition:function(){var t=this.center,i=this.chart,a=this.options.title;return{x:i.plotLeft+t[0]+(a.x||0),y:i.plotTop+t[1]-{high:.5,middle:.25,low:0}[a.align]*t[2]+(a.y||0)}}},l(h,"init",function(t,i,a){var e,o,s=i.angular,r=i.polar,n=a.isX,l=s&&n,h=i.options,p=a.pane||0,c=this.pane=i.pane&&i.pane[p],d=c&&c.options;s?(f(this,l?u:g),(e=!n)&&(this.defaultRadialOptions=this.defaultRadialGaugeOptions)):r&&(f(this,g),e=n,this.defaultRadialOptions=n?this.defaultRadialXOptions:y(this.defaultYAxisOptions,this.defaultRadialYOptions)),s||r?(this.isRadial=!0,i.inverted=!1,h.chart.zoomType=null):this.isRadial=!1,c&&e&&(c.axis=this),t.call(this,i,a),!l&&c&&(s||r)&&(o=this.options,this.angleRad=(o.angle||0)*Math.PI/180,this.startAngleRad=(d.startAngle-90)*Math.PI/180,this.endAngleRad=(x(d.endAngle,d.startAngle+360)-90)*Math.PI/180,this.offset=o.offset||0,this.isCircular=e)}),l(h,"autoLabelAlign",function(t){if(!this.isRadial)return t.apply(this,[].slice.call(arguments,1))}),l(P,"getPosition",function(t,i,a,e,o){var s=this.axis;return s.getPosition?s.getPosition(a):t.call(this,i,a,e,o)}),l(P,"getLabelPosition",function(t,i,a,e,o,s,r,n,l){var h,p=this.axis,c=s.y,d=20,u=s.align,g=(p.translate(this.pos)+p.startAngleRad+Math.PI/2)/Math.PI*180%360;return p.isRadial?(h=p.getPosition(this.pos,p.center[2]/2+x(s.distance,-25)),"auto"===s.rotation?e.attr({rotation:g}):null===c&&(c=p.chart.renderer.fontMetrics(e.styles.fontSize).b-e.getBBox().height/2),null===u&&(p.isCircular?(this.label.getBBox().width>p.len*p.tickInterval/(p.max-p.min)&&(d=0),u=d<g&&g<180-d?"left":180+d<g&&g<360-d?"right":"center"):u="center",e.attr({align:u})),h.x+=s.x,h.y+=c):h=t.call(this,i,a,e,o,s,r,n,l),h}),l(P,"getMarkPath",function(t,i,a,e,o,s,r){var n,l=this.axis;return l.isRadial?["M",i,a,"L",(n=l.getPosition(this.pos,l.center[2]/2+e)).x,n.y]:t.call(this,i,a,e,o,s,r)}),k=(M=t).each,A=M.noop,w=M.pick,L=M.defined,v=M.Series,C=M.seriesType,S=M.seriesTypes,X=v.prototype,Y=M.Point.prototype,C("arearange","area",{lineWidth:1,threshold:null,tooltip:{pointFormat:'<span style="color:{series.color}">\u25cf</span> {series.name}: <b>{point.low}</b> - <b>{point.high}</b><br/>'},trackByArea:!0,dataLabels:{align:null,verticalAlign:null,xLow:0,xHigh:0,yLow:0,yHigh:0}},{pointArrayMap:["low","high"],dataLabelCollections:["dataLabel","dataLabelUpper"],toYData:function(t){return[t.low,t.high]},pointValKey:"low",deferTranslatePolar:!0,highToXY:function(t){var i=this.chart,a=this.xAxis.postTranslate(t.rectPlotX,this.yAxis.len-t.plotHigh);t.plotHighX=a.x-i.plotLeft,t.plotHigh=a.y-i.plotTop,t.plotLowX=t.plotX},translate:function(){var o=this,s=o.yAxis,r=!!o.modifyValue;S.area.prototype.translate.apply(o),k(o.points,function(t){var i=t.low,a=t.high,e=t.plotY;null===a||null===i?(t.isNull=!0,t.plotY=null):(t.plotLow=e,t.plotHigh=s.translate(r?o.modifyValue(a,t):a,0,1,0,1),r&&(t.yBottom=t.plotHigh))}),this.chart.polar&&k(this.points,function(t){o.highToXY(t),t.tooltipPos=[(t.plotHighX+t.plotLowX)/2,(t.plotHigh+t.plotLow)/2]})},getGraphPath:function(t){var i,a,e,o,s,r,n,l=[],h=[],p=S.area.prototype.getGraphPath,c=this.options,d=this.chart.polar&&!1!==c.connectEnds,u=c.connectNulls,g=c.step;for(i=(t=t||this.points).length,i=t.length;i--;)(a=t[i]).isNull||d||u||t[i+1]&&!t[i+1].isNull||h.push({plotX:a.plotX,plotY:a.plotY,doCurve:!1}),e={polarPlotY:a.polarPlotY,rectPlotX:a.rectPlotX,yBottom:a.yBottom,plotX:w(a.plotHighX,a.plotX),plotY:a.plotHigh,isNull:a.isNull},h.push(e),l.push(e),a.isNull||d||u||t[i-1]&&!t[i-1].isNull||h.push({plotX:a.plotX,plotY:a.plotY,doCurve:!1});return s=p.call(this,t),g&&(!0===g&&(g="left"),c.step={left:"right",center:"center",right:"left"}[g]),r=p.call(this,l),n=p.call(this,h),c.step=g,o=[].concat(s,r),this.chart.polar||"M"!==n[0]||(n[0]="L"),this.graphPath=o,this.areaPath=s.concat(n),o.isArea=!0,o.xMap=s.xMap,this.areaPath.xMap=s.xMap,o},drawDataLabels:function(){var t,i,a,e=this.data,o=e.length,s=[],r=this.options.dataLabels,n=r.align,l=r.verticalAlign,h=r.inside,p=this.chart.inverted;if(r.enabled||this._hasPointLabels){for(t=o;t--;)(i=e[t])&&(a=h?i.plotHigh<i.plotLow:i.plotHigh>i.plotLow,i.y=i.high,i._plotY=i.plotY,i.plotY=i.plotHigh,s[t]=i.dataLabel,i.dataLabel=i.dataLabelUpper,i.below=a,p?n||(r.align=a?"right":"left"):l||(r.verticalAlign=a?"top":"bottom"),r.x=r.xHigh,r.y=r.yHigh);for(X.drawDataLabels&&X.drawDataLabels.apply(this,arguments),t=o;t--;)(i=e[t])&&(a=h?i.plotHigh<i.plotLow:i.plotHigh>i.plotLow,i.dataLabelUpper=i.dataLabel,i.dataLabel=s[t],i.y=i.low,i.plotY=i._plotY,i.below=!a,p?n||(r.align=a?"left":"right"):l||(r.verticalAlign=a?"bottom":"top"),r.x=r.xLow,r.y=r.yLow);X.drawDataLabels&&X.drawDataLabels.apply(this,arguments)}r.align=n,r.verticalAlign=l},alignDataLabel:function(){S.column.prototype.alignDataLabel.apply(this,arguments)},drawPoints:function(){var t,i,a=this,e=a.points.length;for(X.drawPoints.apply(a,arguments),i=0;i<e;)(t=a.points[i]).lowerGraphic=t.graphic,t.graphic=t.upperGraphic,t._plotY=t.plotY,t._plotX=t.plotX,t.plotY=t.plotHigh,L(t.plotHighX)&&(t.plotX=t.plotHighX),i++;for(X.drawPoints.apply(a,arguments),i=0;i<e;)(t=a.points[i]).upperGraphic=t.graphic,t.graphic=t.lowerGraphic,t.plotY=t._plotY,t.plotX=t._plotX,i++},setStackedPoints:A},{setState:function(){var t=this.state,i=this.series,a=i.chart.polar;L(this.plotHigh)||(this.plotHigh=i.yAxis.toPixels(this.high,!0)),L(this.plotLow)||(this.plotLow=this.plotY=i.yAxis.toPixels(this.low,!0)),Y.setState.apply(this,arguments),this.graphic=this.upperGraphic,this.plotY=this.plotHigh,a&&(this.plotX=this.plotHighX),this.state=t,i.stateMarkerGraphic&&(i.lowerStateMarkerGraphic=i.stateMarkerGraphic,i.stateMarkerGraphic=i.upperStateMarkerGraphic),Y.setState.apply(this,arguments),this.plotY=this.plotLow,this.graphic=this.lowerGraphic,a&&(this.plotX=this.plotLowX),i.stateMarkerGraphic&&(i.upperStateMarkerGraphic=i.stateMarkerGraphic,i.stateMarkerGraphic=i.lowerStateMarkerGraphic,i.lowerStateMarkerGraphic=undefined)},haloPath:function(){var t=this.series.chart.polar,i=[];return this.plotY=this.plotLow,t&&(this.plotX=this.plotLowX),i=Y.haloPath.apply(this,arguments),this.plotY=this.plotHigh,t&&(this.plotX=this.plotHighX),i=i.concat(Y.haloPath.apply(this,arguments))},destroy:function(){return this.upperGraphic&&(this.upperGraphic=this.upperGraphic.destroy()),Y.destroy.apply(this,arguments)}}),(0,(T=t).seriesType)("areasplinerange","arearange",null,{getPointSpline:T.seriesTypes.spline.prototype.getPointSpline}),z=(R=t).defaultPlotOptions,G=R.each,I=R.merge,D=R.noop,W=R.pick,B=R.seriesType,O=R.seriesTypes.column.prototype,H={pointRange:null,marker:null,states:{hover:{halo:!1}}},B("columnrange","arearange",I(z.column,z.arearange,H),{translate:function(){function r(t){return Math.min(Math.max(-i,t),i)}var n,l,h=this,p=h.yAxis,c=h.xAxis,d=c.startAngleRad,u=h.chart,g=h.xAxis.isRadial,i=Math.max(u.chartWidth,u.chartHeight)+999;O.translate.apply(h),G(h.points,function(t){var i,a,e,o=t.shapeArgs,s=h.options.minPointLength;t.plotHigh=l=r(p.translate(t.high,0,1,0,1)),t.plotLow=r(t.plotY),e=l,a=W(t.rectPlotY,t.plotY)-l,Math.abs(a)<s?(a+=i=s-a,e-=i/2):a<0&&(e-=a*=-1),g?(n=t.barX+d,t.shapeType="path",t.shapeArgs={d:h.polarArc(e+a,e,n,n+t.pointWidth)}):(o.height=a,o.y=e,t.tooltipPos=u.inverted?[p.len+p.pos-u.plotLeft-e-a/2,c.len+c.pos-u.plotTop-o.x-o.width/2,a]:[c.left-u.plotLeft+o.x+o.width/2,p.pos-u.plotTop+e+a/2,a])})},directTouch:!0,trackerGroups:["group","dataLabelsGroup"],drawGraph:D,getSymbol:D,crispCol:O.crispCol,drawPoints:O.drawPoints,drawTracker:O.drawTracker,getColumnMetrics:O.getColumnMetrics,pointAttribs:O.pointAttribs,animate:function(){return O.animate.apply(this,arguments)},polarArc:function(){return O.polarArc.apply(this,arguments)},translate3dPoints:function(){return O.translate3dPoints.apply(this,arguments)},translate3dShapes:function(){return O.translate3dShapes.apply(this,arguments)}},{setState:O.pointClass.prototype.setState}),V=(N=t).each,q=N.isNumber,E=N.merge,_=N.noop,K=N.pick,U=N.pInt,F=N.Series,$=N.seriesType,Q=N.TrackerMixin,$("gauge","line",{dataLabels:{enabled:!0,defer:!1,y:15,borderRadius:3,crop:!1,verticalAlign:"top",zIndex:2,borderWidth:1,borderColor:"#cccccc"},dial:{},pivot:{},tooltip:{headerFormat:""},showInLegend:!1},{angular:!0,directTouch:!0,drawGraph:_,fixedBox:!0,forceDL:!0,noSharedTooltip:!0,trackerGroups:["group","dataLabelsGroup"],translate:function(){var t=this,h=t.yAxis,p=t.options,c=h.center;t.generatePoints(),V(t.points,function(t){var i=E(p.dial,t.dial),a=U(K(i.radius,80))*c[2]/200,e=U(K(i.baseLength,70))*a/100,o=U(K(i.rearLength,10))*a/100,s=i.baseWidth||3,r=i.topWidth||1,n=p.overshoot,l=h.startAngleRad+h.translate(t.y,null,null,null,!0);q(n)?(n=n/180*Math.PI,l=Math.max(h.startAngleRad-n,Math.min(h.endAngleRad+n,l))):!1===p.wrap&&(l=Math.max(h.startAngleRad,Math.min(h.endAngleRad,l))),l=180*l/Math.PI,t.shapeType="path",t.shapeArgs={d:i.path||["M",-o,-s/2,"L",e,-s/2,a,-r/2,a,r/2,e,s/2,-o,s/2,"z"],translateX:c[0],translateY:c[1],rotation:l},t.plotX=c[0],t.plotY=c[1]})},drawPoints:function(){var s=this,t=s.yAxis.center,i=s.pivot,r=s.options,a=r.pivot,n=s.chart.renderer;V(s.points,function(t){var i=t.graphic,a=t.shapeArgs,e=a.d,o=E(r.dial,t.dial);i?(i.animate(a),a.d=e):(t.graphic=n[t.shapeType](a).attr({rotation:a.rotation,zIndex:1}).addClass("highcharts-dial").add(s.group),t.graphic.attr({stroke:o.borderColor||"none","stroke-width":o.borderWidth||0,fill:o.backgroundColor||"#000000"}))}),i?i.animate({translateX:t[0],translateY:t[1]}):(s.pivot=n.circle(0,0,K(a.radius,5)).attr({zIndex:2}).addClass("highcharts-pivot").translate(t[0],t[1]).add(s.group),s.pivot.attr({"stroke-width":a.borderWidth||0,stroke:a.borderColor||"#cccccc",fill:a.backgroundColor||"#000000"}))},animate:function(t){var a=this;t||(V(a.points,function(t){var i=t.graphic;i&&(i.attr({rotation:180*a.yAxis.startAngleRad/Math.PI}),i.animate({rotation:t.shapeArgs.rotation},a.options.animation))}),a.animate=null)},render:function(){this.group=this.plotGroup("group","series",this.visible?"visible":"hidden",this.options.zIndex,this.chart.seriesGroup),F.prototype.render.call(this),this.group.clip(this.chart.clipRect)},setData:function(t,i){F.prototype.setData.call(this,t,!1),this.processData(),this.generatePoints(),K(i,!0)&&this.chart.redraw()},drawTracker:Q&&Q.drawTrackerPoint},{setState:function(t){this.state=t}}),j=(Z=t).each,J=Z.noop,tt=Z.pick,it=Z.seriesType,at=Z.seriesTypes,it("boxplot","column",{threshold:null,tooltip:{pointFormat:'<span style="color:{point.color}">\u25cf</span> <b> {series.name}</b><br/>Maximum: {point.high}<br/>Upper quartile: {point.q3}<br/>Median: {point.median}<br/>Lower quartile: {point.q1}<br/>Minimum: {point.low}<br/>'},whiskerLength:"50%",fillColor:"#ffffff",lineWidth:1,medianWidth:2,states:{hover:{brightness:-.3}},whiskerWidth:2},{pointArrayMap:["low","q1","median","q3","high"],toYData:function(t){return[t.low,t.q1,t.median,t.q3,t.high]},pointValKey:"high",pointAttribs:function(t){var i=this.options,a=t&&t.color||this.color;return{fill:t.fillColor||i.fillColor||a,stroke:i.lineColor||a,"stroke-width":i.lineWidth||0}},drawDataLabels:J,translate:function(){var t=this,a=t.yAxis,e=t.pointArrayMap;at.column.prototype.translate.apply(t),j(t.points,function(i){j(e,function(t){null!==i[t]&&(i[t+"Plot"]=a.translate(i[t],0,1,0,1))})})},drawPoints:function(){var h,p,c,d,u,g,f,m,y,x,b,P,M,k=this,t=k.points,A=k.options,w=k.chart.renderer,L=0,v=!1!==k.doQuartiles,C=k.options.whiskerLength;j(t,function(t){var i,a=t.graphic,e=a?"animate":"attr",o=t.shapeArgs,s={},r={},n={},l=t.color||k.color;t.plotY!==undefined&&(y=o.width,x=Math.floor(o.x),b=x+y,P=Math.round(y/2),h=Math.floor(v?t.q1Plot:t.lowPlot),p=Math.floor(v?t.q3Plot:t.lowPlot),c=Math.floor(t.highPlot),d=Math.floor(t.lowPlot),a||(t.graphic=a=w.g("point").add(k.group),t.stem=w.path().addClass("highcharts-boxplot-stem").add(a),C&&(t.whiskers=w.path().addClass("highcharts-boxplot-whisker").add(a)),v&&(t.box=w.path(m).addClass("highcharts-boxplot-box").add(a)),t.medianShape=w.path(g).addClass("highcharts-boxplot-median").add(a)),s.stroke=t.stemColor||A.stemColor||l,s["stroke-width"]=tt(t.stemWidth,A.stemWidth,A.lineWidth),s.dashstyle=t.stemDashStyle||A.stemDashStyle,t.stem.attr(s),C&&(r.stroke=t.whiskerColor||A.whiskerColor||l,r["stroke-width"]=tt(t.whiskerWidth,A.whiskerWidth,A.lineWidth),t.whiskers.attr(r)),v&&(i=k.pointAttribs(t),t.box.attr(i)),n.stroke=t.medianColor||A.medianColor||l,n["stroke-width"]=tt(t.medianWidth,A.medianWidth,A.lineWidth),t.medianShape.attr(n),f=t.stem.strokeWidth()%2/2,L=x+P+f,t.stem[e]({d:["M",L,p,"L",L,c,"M",L,h,"L",L,d]}),v&&(f=t.box.strokeWidth()%2/2,h=Math.floor(h)+f,p=Math.floor(p)+f,x+=f,b+=f,t.box[e]({d:["M",x,p,"L",x,h,"L",b,h,"L",b,p,"L",x,p,"z"]})),C&&(f=t.whiskers.strokeWidth()%2/2,c+=f,d+=f,M=/%$/.test(C)?P*parseFloat(C)/100:C/2,t.whiskers[e]({d:["M",L-M,c,"L",L+M,c,"M",L-M,d,"L",L+M,d]})),u=Math.round(t.medianPlot),f=t.medianShape.strokeWidth()%2/2,u+=f,t.medianShape[e]({d:["M",x,u,"L",b,u]}))})},setStackedPoints:J}),ot=(et=t).each,st=et.noop,rt=et.seriesType,nt=et.seriesTypes,rt("errorbar","boxplot",{color:"#000000",grouping:!1,linkedTo:":previous",tooltip:{pointFormat:'<span style="color:{point.color}">\u25cf</span> {series.name}: <b>{point.low}</b> - <b>{point.high}</b><br/>'},whiskerWidth:null},{type:"errorbar",pointArrayMap:["low","high"],toYData:function(t){return[t.low,t.high]},pointValKey:"high",doQuartiles:!1,drawDataLabels:nt.arearange?function(){var i=this.pointValKey;nt.arearange.prototype.drawDataLabels.call(this),ot(this.data,function(t){t.y=t[i]})}:st,getColumnMetrics:function(){return this.linkedParent&&this.linkedParent.columnMetrics||nt.column.prototype.getColumnMetrics.call(this)}}),ht=(lt=t).correctFloat,pt=lt.isNumber,ct=lt.pick,dt=lt.Point,ut=lt.Series,gt=lt.seriesType,ft=lt.seriesTypes,gt("waterfall","column",{dataLabels:{inside:!0},lineWidth:1,lineColor:"#333333",dashStyle:"dot",borderColor:"#333333",states:{hover:{lineWidthPlus:0}}},{pointValKey:"y",translate:function(){var t,i,a,e,o,s,r,n,l,h,p,c,d,u=this,g=u.options,f=u.yAxis,m=ct(g.minPointLength,5),y=m/2,x=g.threshold,b=g.stacking;for(ft.column.prototype.translate.apply(u),l=h=x,i=0,t=(a=u.points).length;i<t;i++)e=a[i],n=u.processedYData[i],o=e.shapeArgs,s=b&&f.stacks[(u.negStacks&&n<x?"-":"")+u.stackKey],c=u.getStackIndicator(c,e.x,u.index),p=s?s[e.x].points[c.key]:[0,n],e.isSum?e.y=ht(n):e.isIntermediateSum&&(e.y=ht(n-h)),r=Math.max(l,l+e.y)+p[0],o.y=f.translate(r,0,1,0,1),e.isSum?(o.y=f.translate(p[1],0,1,0,1),o.height=Math.min(f.translate(p[0],0,1,0,1),f.len)-o.y):e.isIntermediateSum?(o.y=f.translate(p[1],0,1,0,1),o.height=Math.min(f.translate(h,0,1,0,1),f.len)-o.y,h=p[1]):(o.height=0<n?f.translate(l,0,1,0,1)-o.y:f.translate(l,0,1,0,1)-f.translate(l-n,0,1,0,1),l+=s&&s[e.x]?s[e.x].total:n),o.height<0&&(o.y+=o.height,o.height*=-1),e.plotY=o.y=Math.round(o.y)-u.borderWidth%2/2,o.height=Math.max(Math.round(o.height),.001),e.yBottom=o.y+o.height,o.height<=m&&!e.isNull?(o.height=m,o.y-=y,e.plotY=o.y,e.y<0?e.minPointLengthOffset=-y:e.minPointLengthOffset=y):e.minPointLengthOffset=0,d=e.plotY+(e.negative?o.height:0),u.chart.inverted?e.tooltipPos[0]=f.len-d:e.tooltipPos[1]=d},processData:function(t){var i,a,e,o,s,r,n,l=this,h=l.options,p=l.yData,c=l.options.data,d=p.length;for(e=a=o=s=h.threshold||0,n=0;n<d;n++)r=p[n],i=c&&c[n]?c[n]:{},"sum"===r||i.isSum?p[n]=ht(e):"intermediateSum"===r||i.isIntermediateSum?p[n]=ht(a):(e+=r,a+=r),o=Math.min(e,o),s=Math.max(e,s);ut.prototype.processData.call(this,t),l.options.stacking||(l.dataMin=o,l.dataMax=s)},toYData:function(t){return t.isSum?0===t.x?null:"sum":t.isIntermediateSum?0===t.x?null:"intermediateSum":t.y},pointAttribs:function(t,i){var a,e=this.options.upColor;return e&&!t.options.color&&(t.color=0<t.y?e:null),delete(a=ft.column.prototype.pointAttribs.call(this,t,i)).dashstyle,a},getGraphPath:function(){return["M",0,0]},getCrispPath:function(){var t,i,a,e,o=this.data,s=o.length,r=this.graph.strokeWidth()+this.borderWidth,n=Math.round(r)%2/2,l=this.yAxis.reversed,h=[];for(a=1;a<s;a++)i=o[a].shapeArgs,e=["M",(t=o[a-1].shapeArgs).x+t.width,t.y+o[a-1].minPointLengthOffset+n,"L",i.x,t.y+o[a-1].minPointLengthOffset+n],(o[a-1].y<0&&!l||0<o[a-1].y&&l)&&(e[2]+=t.height,e[5]+=t.height),h=h.concat(e);return h},drawGraph:function(){ut.prototype.drawGraph.call(this),this.graph.attr({d:this.getCrispPath()})},setStackedPoints:function(){var t,i,a=this,e=a.options;for(ut.prototype.setStackedPoints.apply(a,arguments),t=a.stackedYData?a.stackedYData.length:0,i=1;i<t;i++)e.data[i].isSum||e.data[i].isIntermediateSum||(a.stackedYData[i]+=a.stackedYData[i-1])},getExtremes:function(){if(this.options.stacking)return ut.prototype.getExtremes.apply(this,arguments)}},{getClassName:function(){var t=dt.prototype.getClassName.call(this);return this.isSum?t+=" highcharts-sum":this.isIntermediateSum&&(t+=" highcharts-intermediate-sum"),t},isValid:function(){return pt(this.y,!0)||this.isSum||this.isIntermediateSum}}),yt=(mt=t).LegendSymbolMixin,xt=mt.noop,bt=mt.Series,Pt=mt.seriesType,Mt=mt.seriesTypes,Pt("polygon","scatter",{marker:{enabled:!1,states:{hover:{enabled:!1}}},stickyTracking:!1,tooltip:{followPointer:!0,pointFormat:""},trackByArea:!0},{type:"polygon",getGraphPath:function(){for(var t=bt.prototype.getGraphPath.call(this),i=t.length+1;i--;)(i===t.length||"M"===t[i])&&0<i&&t.splice(i,0,"z");return this.areaPath=t},drawGraph:function(){this.options.fillColor=this.color,Mt.area.prototype.drawGraph.call(this)},drawLegendSymbol:yt.drawRectangle,drawTracker:bt.prototype.drawTracker,setStackedPoints:xt}),At=(kt=t).arrayMax,wt=kt.arrayMin,Lt=kt.Axis,vt=kt.color,Ct=kt.each,St=kt.isNumber,Xt=kt.noop,Yt=kt.pick,Tt=kt.pInt,Rt=kt.Point,zt=kt.Series,Gt=kt.seriesType,It=kt.seriesTypes,Gt("bubble","scatter",{dataLabels:{formatter:function(){return this.point.z},inside:!0,verticalAlign:"middle"},marker:{lineColor:null,lineWidth:1,radius:null,states:{hover:{radiusPlus:0}},symbol:"circle"},minSize:8,maxSize:"20%",softThreshold:!1,states:{hover:{halo:{size:5}}},tooltip:{pointFormat:"({point.x}, {point.y}), Size: {point.z}"},turboThreshold:0,zThreshold:0,zoneAxis:"z"},{pointArrayMap:["y","z"],parallelArrays:["x","y","z"],trackerGroups:["group","dataLabelsGroup"],specialGroup:"group",bubblePadding:!0,zoneAxis:"z",directTouch:!0,pointAttribs:function(t,i){var a=this.options.marker,e=Yt(a.fillOpacity,.5),o=zt.prototype.pointAttribs.call(this,t,i);return 1!==e&&(o.fill=vt(o.fill).setOpacity(e).get("rgba")),o},getRadii:function(t,i,a,e){var o,s,r,n,l,h=this.zData,p=[],c=this.options,d="width"!==c.sizeBy,u=c.zThreshold,g=i-t;for(s=0,o=h.length;s<o;s++)n=h[s],c.sizeByAbsoluteValue&&null!==n&&(n=Math.abs(n-u),i=Math.max(i-u,Math.abs(t-u)),t=0),null===n?l=null:n<t?l=a/2-1:(r=0<g?(n-t)/g:.5,d&&0<=r&&(r=Math.sqrt(r)),l=Math.ceil(a+r*(e-a))/2),p.push(l);this.radii=p},animate:function(t){var e=this.options.animation;t||(Ct(this.points,function(t){var i,a=t.graphic;a&&a.width&&(i={x:a.x,y:a.y,width:a.width,height:a.height},a.attr({x:t.plotX,y:t.plotY,width:1,height:1}),a.animate(i,e))}),this.animate=null)},translate:function(){var t,i,a,e=this.data,o=this.radii;for(It.scatter.prototype.translate.call(this),t=e.length;t--;)i=e[t],a=o?o[t]:0,St(a)&&a>=this.minPxSize/2?(i.marker=kt.extend(i.marker,{radius:a,width:2*a,height:2*a}),i.dlBox={x:i.plotX-a,y:i.plotY-a,width:2*a,height:2*a}):i.shapeArgs=i.plotY=i.dlBox=undefined},alignDataLabel:It.column.prototype.alignDataLabel,buildKDTree:Xt,applyZones:Xt},{haloPath:function(t){return Rt.prototype.haloPath.call(this,0===t?0:(this.marker&&this.marker.radius||0)+t)},ttBelow:!1}),Lt.prototype.beforePadding=function(){var o=this,t=this.len,a=this.chart,s=0,r=t,n=this.isXAxis,l=n?"xData":"yData",h=this.min,p={},c=Math.min(a.plotWidth,a.plotHeight),d=Number.MAX_VALUE,u=-Number.MAX_VALUE,g=this.max-h,f=t/g,m=[];Ct(this.series,function(t){var i,e=t.options;!t.bubblePadding||!t.visible&&a.options.chart.ignoreHiddenSeries||(o.allowZoomOutside=!0,m.push(t),n&&(Ct(["minSize","maxSize"],function(t){var i=e[t],a=/%$/.test(i);i=Tt(i),p[t]=a?c*i/100:i}),t.minPxSize=p.minSize,t.maxPxSize=Math.max(p.maxSize,p.minSize),(i=t.zData).length&&(d=Yt(e.zMin,Math.min(d,Math.max(wt(i),!1===e.displayNegative?e.zThreshold:-Number.MAX_VALUE))),u=Yt(e.zMax,Math.max(u,At(i))))))}),Ct(m,function(t){var i,a=t[l],e=a.length;if(n&&t.getRadii(d,u,t.minPxSize,t.maxPxSize),0<g)for(;e--;)St(a[e])&&o.dataMin<=a[e]&&a[e]<=o.dataMax&&(i=t.radii[e],s=Math.min((a[e]-h)*f-i,s),r=Math.max((a[e]-h)*f+i,r))}),m.length&&0<g&&!this.isLog&&(f*=(t+s-(r-=t))/t,Ct([["min","userMin",s],["max","userMax",r]],function(t){Yt(o.options[t[0]],o[t[1]])===undefined&&(o[t[0]]+=t[2]/f)}))},function(a){function t(t,i){var a,e=this.chart,o=this.options.animation,s=this.group,r=this.markerGroup,n=this.xAxis.center,l=e.plotLeft,h=e.plotTop;e.polar?e.renderer.isSVG&&(!0===o&&(o={}),i?(a={translateX:n[0]+l,translateY:n[1]+h,scaleX:.001,scaleY:.001},s.attr(a),r&&r.attr(a)):(a={translateX:l,translateY:h,scaleX:1,scaleY:1},s.animate(a,o),r&&r.animate(a,o),this.animate=null)):t.call(this,i)}var i,l=a.each,r=a.pick,e=a.Pointer,o=a.Series,s=a.seriesTypes,n=a.wrap,h=o.prototype,p=e.prototype;h.searchPointByAngle=function(t){var i=this,a=i.chart,e=i.xAxis.pane.center,o=t.chartX-e[0]-a.plotLeft,s=t.chartY-e[1]-a.plotTop;return this.searchKDTree({clientX:180+Math.atan2(o,s)*(-180/Math.PI)})},h.getConnectors=function(t,i,a,e){var o,s,r,n,l,h,p,c,d,u,g,f,m,y,x,b,P,M,k,A,w,L=1.5,v=L+1,C=e?1:0;return s=(o=0<=i&&i<=t.length-1?i:i<0?t.length-1+i:0)-1<0?t.length-(1+C):o-1,r=o+1>t.length-1?C:o+1,n=t[s],l=t[r],h=n.plotX,p=n.plotY,c=l.plotX,d=l.plotY,m=(L*(u=t[o].plotX)+h)/v,y=(L*(g=t[o].plotY)+p)/v,x=(L*u+c)/v,b=(L*g+d)/v,P=Math.sqrt(Math.pow(m-u,2)+Math.pow(y-g,2)),M=Math.sqrt(Math.pow(x-u,2)+Math.pow(b-g,2)),k=Math.atan2(y-g,m-u),A=Math.atan2(b-g,x-u),w=Math.PI/2+(k+A)/2,Math.abs(k-w)>Math.PI/2&&(w-=Math.PI),m=u+Math.cos(w)*P,y=g+Math.sin(w)*P,f={rightContX:x=u+Math.cos(Math.PI+w)*M,rightContY:b=g+Math.sin(Math.PI+w)*M,leftContX:m,leftContY:y,plotX:u,plotY:g},a&&(f.prevPointCont=this.getConnectors(t,s,!1,e)),f},n(h,"buildKDTree",function(t){this.chart.polar&&(this.kdByAngle?this.searchPoint=this.searchPointByAngle:this.options.findNearestPointBy="xy"),t.apply(this)}),h.toXY=function(t){var i,a,e=this.chart,o=t.plotX,s=t.plotY;t.rectPlotX=o,t.rectPlotY=s,i=this.xAxis.postTranslate(t.plotX,this.yAxis.len-s),t.plotX=t.polarPlotX=i.x-e.plotLeft,t.plotY=t.polarPlotY=i.y-e.plotTop,this.kdByAngle?((a=(o/Math.PI*180+this.xAxis.pane.options.startAngle)%360)<0&&(a+=360),t.clientX=a):t.clientX=t.plotX},s.spline&&(n(s.spline.prototype,"getPointSpline",function(t,i,a,e){var o;return this.chart.polar?e?["C",(o=this.getConnectors(i,e,!0,this.connectEnds)).prevPointCont.rightContX,o.prevPointCont.rightContY,o.leftContX,o.leftContY,o.plotX,o.plotY]:["M",a.plotX,a.plotY]:t.call(this,i,a,e)}),s.areasplinerange&&(s.areasplinerange.prototype.getPointSpline=s.spline.prototype.getPointSpline)),n(h,"translate",function(t){var i,a,e=this.chart;if(t.call(this),e.polar&&(this.kdByAngle=e.tooltip&&e.tooltip.shared,!this.preventPostTranslate))for(a=(i=this.points).length;a--;)this.toXY(i[a])}),n(h,"getGraphPath",function(t,i){var a,e,o,s=this;if(this.chart.polar){for(i=i||this.points,a=0;a<i.length;a++)if(!i[a].isNull){e=a;break}!1!==this.options.connectEnds&&e!==undefined&&(this.connectEnds=!0,i.splice(i.length,0,i[e]),o=!0),l(i,function(t){t.polarPlotY===undefined&&s.toXY(t)})}var r=t.apply(this,[].slice.call(arguments,1));return o&&i.pop(),r}),n(h,"animate",t),s.column&&((i=s.column.prototype).polarArc=function(t,i,a,e){var o=this.xAxis.center,s=this.yAxis.len;return this.chart.renderer.symbols.arc(o[0],o[1],s-i,null,{start:a,end:e,innerR:s-r(t,s)})},n(i,"animate",t),n(i,"translate",function(t){var i,a,e,o,s=this.xAxis,r=s.startAngleRad;if(this.preventPostTranslate=!0,t.call(this),s.isRadial)for(o=(a=this.points).length;o--;)i=(e=a[o]).barX+r,e.shapeType="path",e.shapeArgs={d:this.polarArc(e.yBottom,e.plotY,i,i+e.pointWidth)},this.toXY(e),e.tooltipPos=[e.plotX,e.plotY],e.ttBelow=e.plotY>s.center[1]}),n(i,"alignDataLabel",function(t,i,a,e,o,s){if(this.chart.polar){var r,n,l=i.rectPlotX/Math.PI*180;null===e.align&&(r=20<l&&l<160?"left":200<l&&l<340?"right":"center",e.align=r),null===e.verticalAlign&&(n=l<45||315<l?"bottom":135<l&&l<225?"top":"middle",e.verticalAlign=n),h.alignDataLabel.call(this,i,a,e,o,s)}else t.call(this,i,a,e,o,s)})),n(p,"getCoordinates",function(t,s){var r=this.chart,n={xAxis:[],yAxis:[]};return r.polar?l(r.axes,function(t){var i=t.isXAxis,a=t.center,e=s.chartX-a[0]-r.plotLeft,o=s.chartY-a[1]-r.plotTop;n[i?"xAxis":"yAxis"].push({axis:t,value:t.translate(i?Math.PI-Math.atan2(e,o):Math.sqrt(Math.pow(e,2)+Math.pow(o,2)),!0)})}):n=t.call(this,s),n}),n(a.Chart.prototype,"getAxes",function(t){this.pane||(this.pane=[]),l(a.splat(this.options.pane),function(t){new a.Pane(t,this)},this),t.call(this)}),n(a.Chart.prototype,"drawChartBox",function(t){t.call(this),l(this.pane,function(t){t.render()})}),n(a.Chart.prototype,"get",function(t,i){return a.find(this.pane,function(t){return t.options.id===i})||t.call(this,i)})}(t)});