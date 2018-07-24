!function(t){if("object"==typeof exports&&"undefined"!=typeof module)module.exports=t();else if("function"==typeof define&&define.amd)define([],t);else{("undefined"!=typeof window?window:"undefined"!=typeof global?global:"undefined"!=typeof self?self:this).svg2pdf=t()}}(function(){var o;return function g(n,s,o){function c(r,t){if(!s[r]){if(!n[r]){var e="function"==typeof require&&require;if(!t&&e)return e(r,!0);if(h)return h(r,!0);var a=new Error("Cannot find module '"+r+"'");throw a.code="MODULE_NOT_FOUND",a}var i=s[r]={exports:{}};n[r][0].call(i.exports,function(t){var e=n[r][1][t];return c(e||t)},i,i.exports,g,n,s,o)}return s[r].exports}for(var h="function"==typeof require&&require,t=0;t<o.length;t++)c(o[t]);return c}({1:[function(t,e){"use strict";e.exports=t("./lib/svgpath")},{"./lib/svgpath":6}],2:[function(t,e){"use strict";function C(t,e,r,a){var i=t*a-e*r<0?-1:1,n=(t*r+e*a)/(Math.sqrt(t*t+e*e)*Math.sqrt(t*t+e*e));return 1<n&&(n=1),n<-1&&(n=-1),i*Math.acos(n)}function y(t,e,r,a,i,n,s,o,c,h){var u=h*(t-r)/2+c*(e-a)/2,f=-c*(t-r)/2+h*(e-a)/2,l=s*s,d=o*o,g=u*u,p=f*f,x=l*d-l*p-d*g;x<0&&(x=0),x/=l*p+d*g;var b=(x=Math.sqrt(x)*(i===n?-1:1))*s/o*f,m=x*-o/s*u,v=h*b-c*m+(t+r)/2,y=c*b+h*m+(e+a)/2,k=(u-b)/s,M=(f-m)/o,w=(-u-b)/s,A=(-f-m)/o,F=C(1,0,k,M),S=C(k,M,w,A);return 0===n&&0<S&&(S-=I),1===n&&S<0&&(S+=I),[v,y,F,S]}function k(t,e){var r=4/3*Math.tan(e/4),a=Math.cos(t),i=Math.sin(t),n=Math.cos(t+e),s=Math.sin(t+e);return[a,i,a-i*r,i+a*r,n+s*r,s-n*r,n,s]}var I=2*Math.PI;e.exports=function r(t,e,r,a,i,n,s,o,c){var h=Math.sin(c*I/360),u=Math.cos(c*I/360),f=u*(t-r)/2+h*(e-a)/2,l=-h*(t-r)/2+u*(e-a)/2;if(0===f&&0===l)return[];if(0===s||0===o)return[];s=Math.abs(s),o=Math.abs(o);var d=f*f/(s*s)+l*l/(o*o);1<d&&(s*=Math.sqrt(d),o*=Math.sqrt(d));var g=y(t,e,r,a,i,n,s,o,h,u),p=[],x=g[2],b=g[3],m=Math.max(Math.ceil(Math.abs(b)/(I/4)),1);b/=m;for(var v=0;v<m;v++)p.push(k(x,b)),x+=b;return p.map(function(t){for(var e=0;e<t.length;e+=2){var r=t[e+0],a=t[e+1],i=u*(r*=s)-h*(a*=o),n=h*r+u*a;t[e+0]=i+g[0],t[e+1]=n+g[1]}return t})}},{}],3:[function(t,e){"use strict";function a(t,e,r){if(!(this instanceof a))return new a(t,e,r);this.rx=t,this.ry=e,this.ax=r}var f=1e-10,l=Math.PI/180;a.prototype.transform=function(t){var e=Math.cos(this.ax*l),r=Math.sin(this.ax*l),a=[this.rx*(t[0]*e+t[2]*r),this.rx*(t[1]*e+t[3]*r),this.ry*(-t[0]*r+t[2]*e),this.ry*(-t[1]*r+t[3]*e)],i=a[0]*a[0]+a[2]*a[2],n=a[1]*a[1]+a[3]*a[3],s=((a[0]-a[3])*(a[0]-a[3])+(a[2]+a[1])*(a[2]+a[1]))*((a[0]+a[3])*(a[0]+a[3])+(a[2]-a[1])*(a[2]-a[1])),o=(i+n)/2;if(s<f*o)return this.rx=this.ry=Math.sqrt(o),this.ax=0,this;var c=a[0]*a[1]+a[2]*a[3],h=o+(s=Math.sqrt(s))/2,u=o-s/2;return this.ax=Math.abs(c)<f&&Math.abs(h-n)<f?90:180*Math.atan(Math.abs(c)>Math.abs(h-n)?(h-i)/c:c/(h-n))/Math.PI,0<=this.ax?(this.rx=Math.sqrt(h),this.ry=Math.sqrt(u)):(this.ax+=90,this.rx=Math.sqrt(u),this.ry=Math.sqrt(h)),this},a.prototype.isDegenerate=function(){return this.rx<f*this.ry||this.ry<f*this.rx},e.exports=a},{}],4:[function(t,e){"use strict";function r(t,e){return[t[0]*e[0]+t[2]*e[1],t[1]*e[0]+t[3]*e[1],t[0]*e[2]+t[2]*e[3],t[1]*e[2]+t[3]*e[3],t[0]*e[4]+t[2]*e[5]+t[4],t[1]*e[4]+t[3]*e[5]+t[5]]}function a(){if(!(this instanceof a))return new a;this.queue=[],this.cache=null}a.prototype.matrix=function(t){return 1===t[0]&&0===t[1]&&0===t[2]&&1===t[3]&&0===t[4]&&0===t[5]||(this.cache=null,this.queue.push(t)),this},a.prototype.translate=function(t,e){return 0===t&&0===e||(this.cache=null,this.queue.push([1,0,0,1,t,e])),this},a.prototype.scale=function(t,e){return 1===t&&1===e||(this.cache=null,this.queue.push([t,0,0,e,0,0])),this},a.prototype.rotate=function(t,e,r){var a,i,n;return 0!==t&&(this.translate(e,r),a=t*Math.PI/180,i=Math.cos(a),n=Math.sin(a),this.queue.push([i,n,-n,i,0,0]),this.cache=null,this.translate(-e,-r)),this},a.prototype.skewX=function(t){return 0!==t&&(this.cache=null,this.queue.push([1,0,Math.tan(t*Math.PI/180),1,0,0])),this},a.prototype.skewY=function(t){return 0!==t&&(this.cache=null,this.queue.push([1,Math.tan(t*Math.PI/180),0,1,0,0])),this},a.prototype.toArray=function(){if(this.cache)return this.cache;if(!this.queue.length)return this.cache=[1,0,0,1,0,0],this.cache;if(this.cache=this.queue[0],1===this.queue.length)return this.cache;for(var t=1;t<this.queue.length;t++)this.cache=r(this.cache,this.queue[t]);return this.cache},a.prototype.calc=function(t,e,r){var a;return this.queue.length?(this.cache||(this.cache=this.toArray()),[t*(a=this.cache)[0]+e*a[2]+(r?0:a[4]),t*a[1]+e*a[3]+(r?0:a[5])]):[t,e]},e.exports=a},{}],5:[function(t,e){"use strict";function r(t){return 10===t||13===t||8232===t||8233===t||32===t||9===t||11===t||12===t||160===t||5760<=t&&0<=l.indexOf(t)}function n(t){switch(32|t){case 109:case 122:case 108:case 104:case 118:case 99:case 115:case 113:case 116:case 97:case 114:return!0}return!1}function h(t){return 48<=t&&t<=57}function s(t){return 48<=t&&t<=57||43===t||45===t||46===t}function a(t){this.index=0,this.path=t,this.max=t.length,this.result=[],this.param=0,this.err="",this.segmentStart=0,this.data=[]}function o(t){for(;t.index<t.max&&r(t.path.charCodeAt(t.index));)t.index++}function c(t){var e,r=t.index,a=r,i=t.max,n=!1,s=!1,o=!1,c=!1;if(i<=a)t.err="SvgPath: missed param (at pos "+a+")";else if(43!==(e=t.path.charCodeAt(a))&&45!==e||(e=++a<i?t.path.charCodeAt(a):0),h(e)||46===e){if(46!==e){if(n=48===e,e=++a<i?t.path.charCodeAt(a):0,n&&a<i&&e&&h(e))return void(t.err="SvgPath: numbers started with `0` such as `09` are ilegal (at pos "+r+")");for(;a<i&&h(t.path.charCodeAt(a));)a++,s=!0;e=a<i?t.path.charCodeAt(a):0}if(46===e){for(c=!0,a++;h(t.path.charCodeAt(a));)a++,o=!0;e=a<i?t.path.charCodeAt(a):0}if(101===e||69===e){if(c&&!s&&!o)return void(t.err="SvgPath: invalid float exponent (at pos "+a+")");if(43!==(e=++a<i?t.path.charCodeAt(a):0)&&45!==e||a++,!(a<i&&h(t.path.charCodeAt(a))))return void(t.err="SvgPath: invalid float exponent (at pos "+a+")");for(;a<i&&h(t.path.charCodeAt(a));)a++}t.index=a,t.param=parseFloat(t.path.slice(r,a))+0}else t.err="SvgPath: param should start with 0..9 or `.` (at pos "+a+")"}function u(t){var e,r;r=(e=t.path[t.segmentStart]).toLowerCase();var a=t.data;if("m"===r&&2<a.length&&(t.result.push([e,a[0],a[1]]),a=a.slice(2),r="l",e="m"===e?"l":"L"),"r"===r)t.result.push([e].concat(a));else for(;a.length>=f[r]&&(t.result.push([e].concat(a.splice(0,f[r]))),f[r]););}function i(t){var e,r,a,i=t.max;if(t.segmentStart=t.index,n(t.path.charCodeAt(t.index)))if(r=f[t.path[t.index].toLowerCase()],t.index++,o(t),t.data=[],r){for(e=!1;;){for(a=r;0<a;a--){if(c(t),t.err.length)return;t.data.push(t.param),o(t),e=!1,t.index<i&&44===t.path.charCodeAt(t.index)&&(t.index++,o(t),e=!0)}if(!e){if(t.index>=t.max)break;if(!s(t.path.charCodeAt(t.index)))break}}u(t)}else u(t);else t.err="SvgPath: bad command "+t.path[t.index]+" (at pos "+t.index+")"}var f={a:7,c:6,h:1,l:2,m:2,r:4,q:4,s:4,t:2,v:1,z:0},l=[5760,6158,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8239,8287,12288,65279];e.exports=function d(t){var e=new a(t),r=e.max;for(o(e);e.index<r&&!e.err.length;)i(e);return e.err.length?e.result=[]:e.result.length&&("mM".indexOf(e.result[0][0])<0?(e.err="SvgPath: string should start with `M` or `m`",e.result=[]):e.result[0][0]="M"),{err:e.err,segments:e.result}}},{}],6:[function(t,e){"use strict";function r(t){if(!(this instanceof r))return new r(t);var e=a(t);this.segments=e.segments,this.err=e.err,this.__stack=[]}var a=t("./path_parse"),i=t("./transform_parse"),n=t("./matrix"),h=t("./a2c"),d=t("./ellipse");r.prototype.__matrix=function(u){var f,l=this;u.queue.length&&this.iterate(function(t,e,r,a){var i,n,s,o;switch(t[0]){case"v":n=0===(i=u.calc(0,t[1],!0))[0]?["v",i[1]]:["l",i[0],i[1]];break;case"V":n=(i=u.calc(r,t[1],!1))[0]===u.calc(r,a,!1)[0]?["V",i[1]]:["L",i[0],i[1]];break;case"h":n=0===(i=u.calc(t[1],0,!0))[1]?["h",i[0]]:["l",i[0],i[1]];break;case"H":n=(i=u.calc(t[1],a,!1))[1]===u.calc(r,a,!1)[1]?["H",i[0]]:["L",i[0],i[1]];break;case"a":case"A":var c=u.toArray(),h=d(t[1],t[2],t[3]).transform(c);if(c[0]*c[3]-c[1]*c[2]<0&&(t[5]=t[5]?"0":"1"),i=u.calc(t[6],t[7],"a"===t[0]),"A"===t[0]&&t[6]===r&&t[7]===a||"a"===t[0]&&0===t[6]&&0===t[7]){n=["a"===t[0]?"l":"L",i[0],i[1]];break}n=h.isDegenerate()?["a"===t[0]?"l":"L",i[0],i[1]]:[t[0],h.rx,h.ry,h.ax,t[4],t[5],i[0],i[1]];break;case"m":o=0<e,n=["m",(i=u.calc(t[1],t[2],o))[0],i[1]];break;default:for(n=[s=t[0]],o=s.toLowerCase()===s,f=1;f<t.length;f+=2)i=u.calc(t[f],t[f+1],o),n.push(i[0],i[1])}l.segments[e]=n},!0)},r.prototype.__evaluateStack=function(){var t,e;if(this.__stack.length){if(1===this.__stack.length)return this.__matrix(this.__stack[0]),void(this.__stack=[]);for(t=n(),e=this.__stack.length;0<=--e;)t.matrix(this.__stack[e].toArray());this.__matrix(t),this.__stack=[]}},r.prototype.toString=function(){var t,e,r=[];this.__evaluateStack();for(var a=0;a<this.segments.length;a++)e=this.segments[a][0],t=0<a&&"m"!==e&&"M"!==e&&e===this.segments[a-1][0],r=r.concat(t?this.segments[a].slice(1):this.segments[a]);return r.join(" ").replace(/ ?([achlmqrstvz]) ?/gi,"$1").replace(/ \-/g,"-").replace(/zm/g,"z m")},r.prototype.translate=function(t,e){return this.__stack.push(n().translate(t,e||0)),this},r.prototype.scale=function(t,e){return this.__stack.push(n().scale(t,e||0===e?e:t)),this},r.prototype.rotate=function(t,e,r){return this.__stack.push(n().rotate(t,e||0,r||0)),this},r.prototype.skewX=function(t){return this.__stack.push(n().skewX(t)),this},r.prototype.skewY=function(t){return this.__stack.push(n().skewY(t)),this},r.prototype.matrix=function(t){return this.__stack.push(n().matrix(t)),this},r.prototype.transform=function(t){return t.trim()&&this.__stack.push(i(t)),this},r.prototype.round=function(a){var e,i=0,n=0,s=0,o=0;return a=a||0,this.__evaluateStack(),this.segments.forEach(function(r){var t=r[0].toLowerCase()===r[0];switch(r[0]){case"H":case"h":return t&&(r[1]+=s),s=r[1]-r[1].toFixed(a),void(r[1]=+r[1].toFixed(a));case"V":case"v":return t&&(r[1]+=o),o=r[1]-r[1].toFixed(a),void(r[1]=+r[1].toFixed(a));case"Z":case"z":return s=i,void(o=n);case"M":case"m":return t&&(r[1]+=s,r[2]+=o),s=r[1]-r[1].toFixed(a),o=r[2]-r[2].toFixed(a),i=s,n=o,r[1]=+r[1].toFixed(a),void(r[2]=+r[2].toFixed(a));case"A":case"a":return t&&(r[6]+=s,r[7]+=o),s=r[6]-r[6].toFixed(a),o=r[7]-r[7].toFixed(a),r[1]=+r[1].toFixed(a),r[2]=+r[2].toFixed(a),r[3]=+r[3].toFixed(a+2),r[6]=+r[6].toFixed(a),void(r[7]=+r[7].toFixed(a));default:return e=r.length,t&&(r[e-2]+=s,r[e-1]+=o),s=r[e-2]-r[e-2].toFixed(a),o=r[e-1]-r[e-1].toFixed(a),void r.forEach(function(t,e){e&&(r[e]=+r[e].toFixed(a))})}}),this},r.prototype.iterate=function(i,t){var e,r,a,n=this.segments,s={},o=!1,c=0,h=0,u=0,f=0;if(t||this.__evaluateStack(),n.forEach(function(t,e){var r=i(t,e,c,h);Array.isArray(r)&&(s[e]=r,o=!0);var a=t[0]===t[0].toLowerCase();switch(t[0]){case"m":case"M":return c=t[1]+(a?c:0),h=t[2]+(a?h:0),u=c,void(f=h);case"h":case"H":return void(c=t[1]+(a?c:0));case"v":case"V":return void(h=t[1]+(a?h:0));case"z":case"Z":return c=u,void(h=f);default:c=t[t.length-2]+(a?c:0),h=t[t.length-1]+(a?h:0)}}),!o)return this;for(a=[],e=0;e<n.length;e++)if("undefined"!=typeof s[e])for(r=0;r<s[e].length;r++)a.push(s[e][r]);else a.push(n[e]);return this.segments=a,this},r.prototype.abs=function(){return this.iterate(function(t,e,r,a){var i,n=t[0],s=n.toUpperCase();if(n!==s)switch(t[0]=s,n){case"v":return void(t[1]+=a);case"a":return t[6]+=r,void(t[7]+=a);default:for(i=1;i<t.length;i++)t[i]+=i%2?r:a}},!0),this},r.prototype.rel=function(){return this.iterate(function(t,e,r,a){var i,n=t[0],s=n.toLowerCase();if(n!==s&&(0!==e||"M"!==n))switch(t[0]=s,n){case"V":return void(t[1]-=a);case"A":return t[6]-=r,void(t[7]-=a);default:for(i=1;i<t.length;i++)t[i]-=i%2?r:a}},!0),this},r.prototype.unarc=function(){return this.iterate(function(t,e,r,a){var i,n,s,o=[],c=t[0];return"A"!==c&&"a"!==c?null:("a"===c?(n=r+t[6],s=a+t[7]):(n=t[6],s=t[7]),0===(i=h(r,a,n,s,t[4],t[5],t[1],t[2],t[3])).length?[["a"===t[0]?"l":"L",t[6],t[7]]]:(i.forEach(function(t){o.push(["C",t[2],t[3],t[4],t[5],t[6],t[7]])}),o))}),this},r.prototype.unshort=function(){var o,c,h,u,f,l=this.segments;return this.iterate(function(t,e,r,a){var i,n=t[0],s=n.toUpperCase();e&&("T"===s?(i="t"===n,"Q"===(h=l[e-1])[0]?(o=h[1]-r,c=h[2]-a):"q"===h[0]?(o=h[1]-h[3],c=h[2]-h[4]):c=o=0,u=-o,f=-c,i||(u+=r,f+=a),l[e]=[i?"q":"Q",u,f,t[1],t[2]]):"S"===s&&(i="s"===n,"C"===(h=l[e-1])[0]?(o=h[3]-r,c=h[4]-a):"c"===h[0]?(o=h[3]-h[5],c=h[4]-h[6]):c=o=0,u=-o,f=-c,i||(u+=r,f+=a),l[e]=[i?"c":"C",u,f,t[1],t[2],t[3],t[4]]))}),this},e.exports=r},{"./a2c":2,"./ellipse":3,"./matrix":4,"./path_parse":5,"./transform_parse":7}],7:[function(t,e){"use strict";var i=t("./matrix"),n={matrix:!0,scale:!0,rotate:!0,translate:!0,skewX:!0,skewY:!0},s=/\s*(matrix|translate|scale|rotate|skewX|skewY)\s*\(\s*(.+?)\s*\)[\s,]*/,o=/[\s,]+/;e.exports=function r(t){var e,r,a=new i;return t.split(s).forEach(function(t){if(t.length)if("undefined"==typeof n[t])switch(r=t.split(o).map(function(t){return+t||0}),e){case"matrix":return void(6===r.length&&a.matrix(r));case"scale":return void(1===r.length?a.scale(r[0],r[0]):2===r.length&&a.scale(r[0],r[1]));case"rotate":return void(1===r.length?a.rotate(r[0],0,0):3===r.length&&a.rotate(r[0],r[1],r[2]));case"translate":return void(1===r.length?a.translate(r[0],0):2===r.length&&a.translate(r[0],r[1]));case"skewX":return void(1===r.length&&a.skewX(r[0]));case"skewY":return void(1===r.length&&a.skewY(r[0]))}else e=t}),a}},{"./matrix":4}],8:[function(t,e){!function(t){function l(t){this.ok=!1,"#"==t.charAt(0)&&(t=t.substr(1,6)),t=(t=t.replace(/ /g,"")).toLowerCase();var u={aliceblue:"f0f8ff",antiquewhite:"faebd7",aqua:"00ffff",aquamarine:"7fffd4",azure:"f0ffff",beige:"f5f5dc",bisque:"ffe4c4",black:"000000",blanchedalmond:"ffebcd",blue:"0000ff",blueviolet:"8a2be2",brown:"a52a2a",burlywood:"deb887",cadetblue:"5f9ea0",chartreuse:"7fff00",chocolate:"d2691e",coral:"ff7f50",cornflowerblue:"6495ed",cornsilk:"fff8dc",crimson:"dc143c",cyan:"00ffff",darkblue:"00008b",darkcyan:"008b8b",darkgoldenrod:"b8860b",darkgray:"a9a9a9",darkgreen:"006400",darkkhaki:"bdb76b",darkmagenta:"8b008b",darkolivegreen:"556b2f",darkorange:"ff8c00",darkorchid:"9932cc",darkred:"8b0000",darksalmon:"e9967a",darkseagreen:"8fbc8f",darkslateblue:"483d8b",darkslategray:"2f4f4f",darkturquoise:"00ced1",darkviolet:"9400d3",deeppink:"ff1493",deepskyblue:"00bfff",dimgray:"696969",dodgerblue:"1e90ff",feldspar:"d19275",firebrick:"b22222",floralwhite:"fffaf0",forestgreen:"228b22",fuchsia:"ff00ff",gainsboro:"dcdcdc",ghostwhite:"f8f8ff",gold:"ffd700",goldenrod:"daa520",gray:"808080",green:"008000",greenyellow:"adff2f",honeydew:"f0fff0",hotpink:"ff69b4",indianred:"cd5c5c",indigo:"4b0082",ivory:"fffff0",khaki:"f0e68c",lavender:"e6e6fa",lavenderblush:"fff0f5",lawngreen:"7cfc00",lemonchiffon:"fffacd",lightblue:"add8e6",lightcoral:"f08080",lightcyan:"e0ffff",lightgoldenrodyellow:"fafad2",lightgrey:"d3d3d3",lightgreen:"90ee90",lightpink:"ffb6c1",lightsalmon:"ffa07a",lightseagreen:"20b2aa",lightskyblue:"87cefa",lightslateblue:"8470ff",lightslategray:"778899",lightsteelblue:"b0c4de",lightyellow:"ffffe0",lime:"00ff00",limegreen:"32cd32",linen:"faf0e6",magenta:"ff00ff",maroon:"800000",mediumaquamarine:"66cdaa",mediumblue:"0000cd",mediumorchid:"ba55d3",mediumpurple:"9370d8",mediumseagreen:"3cb371",mediumslateblue:"7b68ee",mediumspringgreen:"00fa9a",mediumturquoise:"48d1cc",mediumvioletred:"c71585",midnightblue:"191970",mintcream:"f5fffa",mistyrose:"ffe4e1",moccasin:"ffe4b5",navajowhite:"ffdead",navy:"000080",oldlace:"fdf5e6",olive:"808000",olivedrab:"6b8e23",orange:"ffa500",orangered:"ff4500",orchid:"da70d6",palegoldenrod:"eee8aa",palegreen:"98fb98",paleturquoise:"afeeee",palevioletred:"d87093",papayawhip:"ffefd5",peachpuff:"ffdab9",peru:"cd853f",pink:"ffc0cb",plum:"dda0dd",powderblue:"b0e0e6",purple:"800080",red:"ff0000",rosybrown:"bc8f8f",royalblue:"4169e1",saddlebrown:"8b4513",salmon:"fa8072",sandybrown:"f4a460",seagreen:"2e8b57",seashell:"fff5ee",sienna:"a0522d",silver:"c0c0c0",skyblue:"87ceeb",slateblue:"6a5acd",slategray:"708090",snow:"fffafa",springgreen:"00ff7f",steelblue:"4682b4",tan:"d2b48c",teal:"008080",thistle:"d8bfd8",tomato:"ff6347",turquoise:"40e0d0",violet:"ee82ee",violetred:"d02090",wheat:"f5deb3",white:"ffffff",whitesmoke:"f5f5f5",yellow:"ffff00",yellowgreen:"9acd32"};for(var e in u)t==e&&(t=u[e]);for(var f=[{re:/^rgb\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3})\)$/,example:["rgb(123, 234, 45)","rgb(255,234,245)"],process:function(t){return[parseInt(t[1]),parseInt(t[2]),parseInt(t[3])]}},{re:/^(\w{2})(\w{2})(\w{2})$/,example:["#00ff00","336699"],process:function(t){return[parseInt(t[1],16),parseInt(t[2],16),parseInt(t[3],16)]}},{re:/^(\w{1})(\w{1})(\w{1})$/,example:["#fb0","f0f"],process:function(t){return[parseInt(t[1]+t[1],16),parseInt(t[2]+t[2],16),parseInt(t[3]+t[3],16)]}}],r=0;r<f.length;r++){var a=f[r].re,i=f[r].process,n=a.exec(t);if(n){var s=i(n);this.r=s[0],this.g=s[1],this.b=s[2],this.ok=!0}}this.r=this.r<0||isNaN(this.r)?0:255<this.r?255:this.r,this.g=this.g<0||isNaN(this.g)?0:255<this.g?255:this.g,this.b=this.b<0||isNaN(this.b)?0:255<this.b?255:this.b,this.toRGB=function(){return"rgb("+this.r+", "+this.g+", "+this.b+")"},this.toHex=function(){var t=this.r.toString(16),e=this.g.toString(16),r=this.b.toString(16);return 1==t.length&&(t="0"+t),1==e.length&&(e="0"+e),1==r.length&&(r="0"+r),"#"+t+e+r},this.getHelpXML=function(){for(var t=new Array,e=0;e<f.length;e++)for(var r=f[e].example,a=0;a<r.length;a++)t[t.length]=r[a];for(var i in u)t[t.length]=i;var n=document.createElement("ul");n.setAttribute("id","rgbcolor-examples");for(e=0;e<t.length;e++)try{var s=document.createElement("li"),o=new l(t[e]),c=document.createElement("div");c.style.cssText="margin: 3px; border: 1px solid black; background:"+o.toHex()+"; color:"+o.toHex(),c.appendChild(document.createTextNode("test"));var h=document.createTextNode(" "+t[e]+" -> "+o.toRGB()+" -> "+o.toHex());s.appendChild(c),s.appendChild(h),n.appendChild(s)}catch(g){}return n}}"function"==typeof o&&o.amd?o(function(){return l}):void 0!==e&&e.exports?e.exports=l:t.RGBColor=l}("undefined"!=typeof self&&self||"undefined"!=typeof window&&window||this)},{}],9:[function(i,n){!function(t){function L(t){var e=Math.sqrt(t[0]*t[0]+t[1]*t[1]);return[t[0]/e,t[1]/e]}function O(t,e){return L([e[0]-t[0],e[1]-t[1]])}function T(t,e){return[t[0]+e[0],t[1]+e[1]]}function q(){this.markers=[]}function N(t,e,r){this.id=t,this.anchor=e,this.angle=r}function h(t,e,r,a,i,n){var s,o,c=e[0],h=e[1],u=e[2],f=e[3],l=i/u,d=n/f,g=t.getAttribute("preserveAspectRatio");if(g){var p=g.split(" ");s=p[0],o=p[1]||"meet"}else s="xMidYMid",o="meet";"none"!==s&&("meet"===o?l=d=Math.min(l,d):"slice"===o&&(l=d=Math.max(l,d)));var x=r-c*l,b=a-h*d;0<=s.indexOf("xMid")?x+=(i-u*l)/2:0<=s.indexOf("xMax")&&(x+=i-u*l),0<=s.indexOf("yMid")?b+=(n-f*d)/2:0<=s.indexOf("yMax")&&(b+=n-f*d);var m=new D.Matrix(1,0,0,1,x,b),v=new D.Matrix(l,0,0,d,0,0);return D.matrixMult(v,m)}function V(t,e){var r,a=B(t,"font-family");a&&D.setFont(a),e&&e.ok&&D.setTextColor(e.r,e.g,e.b);var i=B(t,"font-weight");i&&"bold"===i&&(r="bold");var n=B(t,"font-style");n&&"italic"===n&&(r+="italic"),D.setFontType(r);var s=16,o=B(t,"font-size");o&&(s=parseFloat(o),D.setFontSize(s))}var Y,u,D,r=2/3,H=/url\(#([^)]+)\)/,P=function(t){var e=t.getAttribute("d");u&&(e=u(e).unshort().unarc().abs().toString(),t.setAttribute("d",e));var r=t.pathSegList;if(r)return r;r=[];for(var a,i=/([a-df-zA-DF-Z])([^a-df-zA-DF-Z]*)/g;a=i.exec(e);){var n=R(a[2]),s=a[1],o=0<="zZ".indexOf(s)?0:0<="hHvV".indexOf(s)?1:0<="mMlLtT".indexOf(s)?2:0<="sSqQ".indexOf(s)?4:0<="aA".indexOf(s)?7:0<="cC".indexOf(s)?6:-1,c=0;do{var h={pathSegTypeAsLetter:s};switch(s){case"h":case"H":h.x=n[c];break;case"v":case"V":h.y=n[c];break;case"c":case"C":h.x1=n[c+o-6],h.y1=n[c+o-5];case"s":case"S":h.x2=n[c+o-4],h.y2=n[c+o-3];case"t":case"T":case"l":case"L":case"m":case"M":h.x=n[c+o-2],h.y=n[c+o-1];break;case"q":case"Q":h.x1=n[c],h.y1=n[c+1],h.x=n[c+2],h.y=n[c+3];break;case"a":case"A":throw new Error("Cannot convert Arcs without SvgPath package")}r.push(h),"m"===s?s="l":"M"===s&&(s="L"),c+=o}while(c<n.length)}return r.getItem=function(t){return this[t]},r.numberOfItems=r.length,r},B=function(t,e,r){return r=r||e,t.getAttribute(e)||t.style[r]},U=function(t,e){return 0<=e.split(",").indexOf(t.tagName.toLowerCase())},_=function(t,e){for(var r=[],a=0;a<t.childNodes.length;a++){var i=t.childNodes[a];"#"!==i.nodeName.charAt(0)&&r.push(i)}for(a=0;a<r.length;a++)e(a,r[a])},E=function(t,e){return Math.atan2(e[1]-t[1],e[0]-t[0])},s=function(t,e){var r=e[0]-t[0],a=e[1]-t[1];return[t[0]+2*r,t[1]+2*a]},j=function(t,e){return[r*(e[0]-t[0])+t[0],r*(e[1]-t[1])+t[1]]},G=function(t,e,r,a,i){var n=r.getItem(t-1);return 0<t&&("C"===n.pathSegTypeAsLetter||"S"===n.pathSegTypeAsLetter)?s([n.x2,n.y2],e):0<t&&("c"===n.pathSegTypeAsLetter||"s"===n.pathSegTypeAsLetter)?s([n.x2+a,n.y2+i],e):[e[0],e[1]]},c=function(t){this.prefix=t,this.id=0,this.nextChild=function(){return new c("_"+this.id+++"_"+this.get())},this.get=function(){return this.prefix}},f=function(){this.fillMode="F",this.strokeMode="",this.color=new Y("rgb(0, 0, 0)"),this.fill=new Y("rgb(0, 0, 0)"),this.fillOpacity=1,this.fontFamily="times",this.fontSize=16,this.opacity=1,this.stroke=null,this.strokeDasharray=null,this.strokeDashoffset=null,this.strokeLinecap="butt",this.strokeLinejoin="miter",this.strokeMiterlimit=4,this.strokeOpacity=1,this.strokeWidth=1,this.textAnchor="start",this.visibility="visible"};f.prototype.clone=function(){var e=new f;return Object.getOwnPropertyNames(this).forEach(function(t){e[t]=this[t]},this),e},q.prototype.addMarker=function e(t){this.markers.push(t)},q.prototype.draw=function(t,e){for(var r=0;r<this.markers.length;r++){var a,i=this.markers[r],n=i.angle,s=i.anchor,o=Math.cos(n),c=Math.sin(n);a=new D.Matrix(o,c,-c,o,s[0],s[1]),a=D.matrixMult(new D.Matrix(e.strokeWidth,0,0,e.strokeWidth,0,0),a),a=D.matrixMult(a,t),D.saveGraphicsState(),D.setLineWidth(1),D.doFormObject(i.id,a),D.restoreGraphicsState()}};var Q=function(t,e){for(var r=/_\d+_/;!e[t]&&r.exec(t);)t=t.replace(r,"");return e[t]},m=function(t){return t.replace(/[\n\s\r]+/," ").trim()},l=function(t){var e={};for(var r in t)t.hasOwnProperty(r)&&(e[r]=t[r]);return e},X=function(t){var e,r,a,i=D.unitMatrix;if(U(t,"svg,g"))if(r=parseFloat(t.getAttribute("x"))||0,a=parseFloat(t.getAttribute("y"))||0,e=t.getAttribute("viewBox")){var n=parseFloat(t.getAttribute("width")),s=parseFloat(t.getAttribute("height"));i=h(t,R(e),r,a,n,s)}else i=new D.Matrix(1,0,0,1,r,a);else if(U(t,"marker"))if(r=parseFloat(t.getAttribute("refX"))||0,a=parseFloat(t.getAttribute("refY"))||0,e=t.getAttribute("viewBox")){var o=R(e);o[0]=o[1]=0,i=h(t,o,0,0,t.getAttribute("markerWidth"),t.getAttribute("markerHeight")),i=D.matrixMult(new D.Matrix(1,0,0,1,-r,-a),i)}else i=new D.Matrix(1,0,0,1,-r,-a);var c=t.getAttribute("transform");return c?D.matrixMult(i,W(c)):i},z=function(t){for(var e=R(t),r=[],a=0;a<e.length-1;a+=2){var i=e[a],n=e[a+1];r.push([i,n])}return r},W=function(t){if(!t)return D.unitMatrix;for(var e,r=/^\s*matrix\(([^\)]+)\)\s*/,a=/^\s*translate\(([^\)]+)\)\s*/,i=/^\s*rotate\(([^\)]+)\)\s*/,n=/^\s*scale\(([^\)]+)\)\s*/,s=/^\s*skewX\(([^\)]+)\)\s*/,o=/^\s*skewY\(([^\)]+)\)\s*/,c=D.unitMatrix;0<t.length;){var h=r.exec(t);if(h&&(e=R(h[1]),c=D.matrixMult(new D.Matrix(e[0],e[1],e[2],e[3],e[4],e[5]),c),t=t.substr(h[0].length)),h=i.exec(t)){e=R(h[1]);var u=Math.PI*e[0]/180;if(c=D.matrixMult(new D.Matrix(Math.cos(u),Math.sin(u),-Math.sin(u),Math.cos(u),0,0),c),e[1]&&e[2]){var f=new D.Matrix(1,0,0,1,e[1],e[2]),l=new D.Matrix(1,0,0,1,-e[1],-e[2]);c=D.matrixMult(l,D.matrixMult(c,f))}t=t.substr(h[0].length)}(h=a.exec(t))&&(e=R(h[1]),c=D.matrixMult(new D.Matrix(1,0,0,1,e[0],e[1]||0),c),t=t.substr(h[0].length)),(h=n.exec(t))&&((e=R(h[1]))[1]||(e[1]=e[0]),c=D.matrixMult(new D.Matrix(e[0],0,0,e[1],0,0),c),t=t.substr(h[0].length)),(h=s.exec(t))&&(e=parseFloat(h[1]),c=D.matrixMult(new D.Matrix(1,0,Math.tan(e),1,0,0),c),t=t.substr(h[0].length)),(h=o.exec(t))&&(e=parseFloat(h[1]),c=D.matrixMult(new D.Matrix(1,Math.tan(e),0,1,0,0),c),t=t.substr(h[0].length))}return c},R=function(t){for(var e,r=[],a=/[+-]?(?:(?:\d+\.?\d*)|(?:\d*\.?\d+))(?:[eE][+-]?\d+)?/g;e=a.exec(t);)r.push(parseFloat(e[0]));return r},Z=function(t){var e=/\s*rgba\(((?:[^,\)]*,){3}[^,\)]*)\)\s*/.exec(t);if(e){var r=R(e[1]),a=new Y("rgb("+r.slice(0,3).join(",")+")");return a.a=r[3],a}return new Y(t)},$=function(t,e){var r=t[0],a=t[1];return[e.a*r+e.c*a+e.e,e.b*r+e.d*a+e.f]},J=function(t){if("none"===B(t,"display"))return[0,0,0,0];var e,r,a,i,n,s,o,c,h=parseFloat;if(U(t,"polygon")){var u=z(t.getAttribute("points"));for(r=Number.POSITIVE_INFINITY,a=Number.POSITIVE_INFINITY,i=Number.NEGATIVE_INFINITY,n=Number.NEGATIVE_INFINITY,e=0;e<u.length;e++){var f=u[e];r=Math.min(r,f[0]),i=Math.max(i,f[0]),a=Math.min(a,f[1]),n=Math.max(n,f[1])}c=[r,a,i-r,n-a]}else if(U(t,"path")){var l=P(t);r=Number.POSITIVE_INFINITY,a=Number.POSITIVE_INFINITY,i=Number.NEGATIVE_INFINITY,n=Number.NEGATIVE_INFINITY;var d,g,p,x,b,m,v,y=0,k=0;for(e=0;e<l.numberOfItems;e++){var M=l.getItem(e),w=M.pathSegTypeAsLetter;switch(w){case"H":p=M.x,x=k;break;case"h":p=M.x+y,x=k;break;case"V":p=y,x=M.y;break;case"v":p=y,x=M.y+k;break;case"C":b=[M.x1,M.y1],m=[M.x2,M.y2],v=[M.x,M.y];break;case"c":b=[M.x1+y,M.y1+k],m=[M.x2+y,M.y2+k],v=[M.x+y,M.y+k];break;case"S":b=G(e,[y,k],l,d,g),m=[M.x2,M.y2],v=[M.x,M.y];break;case"s":b=G(e,[y,k],l,d,g),m=[M.x2+y,M.y2+k],v=[M.x+y,M.y+k];break;case"Q":h=[M.x1,M.y1],b=j([y,k],h),m=j([M.x,M.y],h),v=[M.x,M.y];break;case"q":h=[M.x1+y,M.y1+k],b=j([y,k],h),m=j([y+M.x,k+M.y],h),v=[M.x+y,M.y+k];break;case"T":b=G(e,[y,k],l,d,g),b=j([y,k],h),m=j([M.x,M.y],h),v=[M.x,M.y];break;case"t":h=G(e,[y,k],l,d,g),b=j([y,k],h),m=j([y+M.x,k+M.y],h),v=[M.x+y,M.y+k]}0<="sScCqQtT".indexOf(w)&&(d=y,g=k),0<="MLCSQT".indexOf(w)?(y=M.x,k=M.y):0<="mlcsqt".indexOf(w)?(y=M.x+y,k=M.y+k):"zZ".indexOf(w)<0&&(y=p,k=x),0<="CSQTcsqt".indexOf(w)?(r=Math.min(r,y,b[0],m[0],v[0]),i=Math.max(i,y,b[0],m[0],v[0]),a=Math.min(a,k,b[1],m[1],v[1]),n=Math.max(n,k,b[1],m[1],v[1])):(r=Math.min(r,y),i=Math.max(i,y),a=Math.min(a,k),n=Math.max(n,k))}c=[r,a,i-r,n-a]}else{if(U(t,"svg"))return(s=t.getAttribute("viewBox"))&&(o=R(s)),[h(t.getAttribute("x"))||o&&o[0]||0,h(t.getAttribute("y"))||o&&o[1]||0,h(t.getAttribute("width"))||o&&o[2]||0,h(t.getAttribute("height"))||o&&o[3]||0];if(U(t,"g"))c=[0,0,0,0],_(t,function(t,e){var r=J(e);c=[Math.min(c[0],r[0]),Math.min(c[1],r[1]),Math.max(c[0]+c[2],r[0]+r[2])-Math.min(c[0],r[0]),Math.max(c[1]+c[3],r[1]+r[3])-Math.min(c[1],r[1])]});else{if(U(t,"marker"))return(s=t.getAttribute("viewBox"))&&(o=R(s)),[o&&o[0]||0,o&&o[1]||0,o&&o[2]||h(t.getAttribute("marker-width"))||0,o&&o[3]||h(t.getAttribute("marker-height"))||0];if(U(t,"pattern"))return[h(t.getAttribute("x"))||0,h(t.getAttribute("y"))||0,h(t.getAttribute("width"))||0,h(t.getAttribute("height"))||0];var A=h(t.getAttribute("x1"))||h(t.getAttribute("x"))||h(t.getAttribute("cx")-h(t.getAttribute("r")))||0,F=h(t.getAttribute("x2"))||A+h(t.getAttribute("width"))||h(t.getAttribute("cx"))+h(t.getAttribute("r"))||0,S=h(t.getAttribute("y1"))||h(t.getAttribute("y"))||h(t.getAttribute("cy"))-h(t.getAttribute("r"))||0,C=h(t.getAttribute("y2"))||S+h(t.getAttribute("height"))||h(t.getAttribute("cy"))+h(t.getAttribute("r"))||0;c=[Math.min(A,F),Math.min(S,C),Math.max(A,F)-Math.min(A,F),Math.max(S,C)-Math.min(S,C)]}}if(!U(t,"marker,svg,g")){var I=B(t,"stroke-width")||1;return B(t,"stroke-miterlimit")&&(I*=.5/Math.sin(Math.PI/12)),[c[0]-I,c[1]-I,c[2]+2*I,c[3]+2*I]}return c},K=function(t,e,r,a,i,n,s){var o,c,h=z(t.getAttribute("points")),u=[{op:"m",c:$(h[0],e)}];for(o=1;o<h.length;o++){var f=h[o],l=$(f,e);u.push({op:"l",c:l})}u.push({op:"h"}),D.path(u,r,a,i);var d=t.getAttribute("marker-end"),g=t.getAttribute("marker-start"),p=t.getAttribute("marker-mid");if(g||p||d){var x=u.length,b=new q;if(g&&(g=n.get()+H.exec(g)[1],c=T(O(u[0].c,u[1].c),O(u[x-2].c,u[0].c)),b.addMarker(new N(g,u[0].c,Math.atan2(c[1],c[0])))),p){p=n.get()+H.exec(p)[1];var m,v=O(u[0].c,u[1].c);for(o=1;o<u.length-2;o++)c=T(v,m=O(u[o].c,u[o+1].c)),b.addMarker(new N(p,u[o].c,Math.atan2(c[1],c[0]))),v=m;c=T(v,m=O(u[x-2].c,u[0].c)),b.addMarker(new N(p,u[x-2].c,Math.atan2(c[1],c[0])))}d&&(d=n.get()+H.exec(d)[1],c=T(O(u[0].c,u[1].c),O(u[x-2].c,u[0].c)),b.addMarker(new N(d,u[0].c,Math.atan2(c[1],c[0])))),b.draw(D.unitMatrix,s)}},tt=function(t){var e=t.getAttribute("xlink:href")||t.getAttribute("href"),r=new Image;r.src=e;var a=document.createElement("canvas"),i=parseFloat(t.getAttribute("width")),n=parseFloat(t.getAttribute("height")),s=parseFloat(t.getAttribute("x")||0),o=parseFloat(t.getAttribute("y")||0);a.width=i,a.height=n;var c=a.getContext("2d");c.fillStyle="#fff",c.fillRect(0,0,i,n),c.drawImage(r,0,0,i,n);try{var h=a.toDataURL("image/jpeg");D.addImage(h,"jpeg",s,o,i,n)}catch(g){"object"==typeof console&&console.warn&&console.warn('svg2pdfjs: Images with external resource link are not supported! ("'+e+'")')}},et=function(t,e,r,a,i,n,s){var S=P(t),C=t.getAttribute("marker-end"),I=t.getAttribute("marker-start"),_=t.getAttribute("marker-mid");C&&(C=r.get()+H.exec(C)[1]),I&&(I=r.get()+H.exec(I)[1]),_&&(_=r.get()+H.exec(_)[1]);var o=function(t,e){for(var r,a,i,n,s,o,c,h,u,f,l=0,d=0,g=l,p=d,x=[],b=new q,m=[0,0],v=0;v<S.numberOfItems;v++){var y=S.getItem(v),k=y.pathSegTypeAsLetter;switch(k){case"M":g=l,p=d,s=[y.x,y.y],u="m";break;case"m":g=l,p=d,s=[y.x+l,y.y+d],u="m";break;case"L":s=[y.x,y.y],u="l";break;case"l":s=[y.x+l,y.y+d],u="l";break;case"H":s=[y.x,d],u="l",i=y.x,n=d;break;case"h":s=[y.x+l,d],u="l",i=y.x+l,n=d;break;case"V":s=[l,y.y],u="l",i=l,n=y.y;break;case"v":s=[l,y.y+d],u="l",i=l,n=y.y+d;break;case"C":c=[y.x1,y.y1],h=[y.x2,y.y2],s=[y.x,y.y];break;case"c":c=[y.x1+l,y.y1+d],h=[y.x2+l,y.y2+d],s=[y.x+l,y.y+d];break;case"S":c=G(v,[l,d],S,r,a),h=[y.x2,y.y2],s=[y.x,y.y];break;case"s":c=G(v,[l,d],S,r,a),h=[y.x2+l,y.y2+d],s=[y.x+l,y.y+d];break;case"Q":o=[y.x1,y.y1],c=j([l,d],o),h=j([y.x,y.y],o),s=[y.x,y.y];break;case"q":o=[y.x1+l,y.y1+d],c=j([l,d],o),h=j([l+y.x,d+y.y],o),s=[y.x+l,y.y+d];break;case"T":c=G(v,[l,d],S,r,a),c=j([l,d],o),h=j([y.x,y.y],o),s=[y.x,y.y];break;case"t":o=G(v,[l,d],S,r,a),c=j([l,d],o),h=j([l+y.x,d+y.y],o),s=[y.x+l,y.y+d];break;case"Z":case"z":l=g,d=p,x.push({op:"h"})}var M=I&&(1===v||"mM".indexOf(k)<0&&0<="mM".indexOf(S.getItem(v-1).pathSegTypeAsLetter)),w=C&&(v===S.numberOfItems-1||"mM".indexOf(k)<0&&0<="mM".indexOf(S.getItem(v+1).pathSegTypeAsLetter)),A=_&&0<v&&!(1===v&&0<="mM".indexOf(S.getItem(v-1).pathSegTypeAsLetter));if(0<="sScCqQtT".indexOf(k))M&&b.addMarker(new N(I,[l,d],E([l,d],c))),w&&b.addMarker(new N(C,s,E(h,s))),A&&(f=O([l,d],c),f=0<="mM".indexOf(S.getItem(v-1).pathSegTypeAsLetter)?f:L(T(m,f)),b.addMarker(new N(_,[l,d],Math.atan2(f[1],f[0])))),m=O(h,s),r=l,a=d,c=$(c,e),h=$(h,e),o=$(s,e),x.push({op:"c",c:[c[0],c[1],h[0],h[1],o[0],o[1]]});else if(0<="lLhHvVmM".indexOf(k)){if(f=O([l,d],s),M&&b.addMarker(new N(I,[l,d],Math.atan2(f[1],f[0]))),w&&b.addMarker(new N(C,s,Math.atan2(f[1],f[0]))),A){var F=0<="mM".indexOf(k)?m:0<="mM".indexOf(S.getItem(v-1).pathSegTypeAsLetter)?f:L(T(m,f));b.addMarker(new N(_,[l,d],Math.atan2(F[1],F[0])))}m=f,o=$(s,e),x.push({op:u,c:o})}0<="MLCSQT".indexOf(k)?(l=y.x,d=y.y):0<="mlcsqt".indexOf(k)?(l=y.x+l,d=y.y+d):"zZ".indexOf(k)<0&&(l=i,d=n)}return{lines:x,markers:b}}(S,e);0<o.lines.length&&D.path(o.lines,a,i,n),(C||I||_)&&o.markers.draw(e,s)},rt=function(t,e,r){var a=t.getAttribute("href")||t.getAttribute("xlink:href");if(a){var i=D.getFormObject(r.get()+a.substring(1)),n=t.getAttribute("x")||0,s=t.getAttribute("y")||0,o=t.getAttribute("width")||i.width,c=t.getAttribute("height")||i.height,h=new D.Matrix(o/i.width||0,0,0,c/i.height||0,n,s);h=D.matrixMult(h,e),D.doFormObject(r.get()+a.substring(1),h)}},at=function(t,e,r,a){var i=$([parseFloat(t.getAttribute("x1")),parseFloat(t.getAttribute("y1"))],e),n=$([parseFloat(t.getAttribute("x2")),parseFloat(t.getAttribute("y2"))],e);"D"===a.strokeMode&&D.line(i[0],i[1],n[0],n[1]);var s=t.getAttribute("marker-start"),o=t.getAttribute("marker-end");if(s||o){var c=new q,h=E(i,n);s&&c.addMarker(new N(r.get()+H.exec(s)[1],i,h)),o&&c.addMarker(new N(r.get()+H.exec(o)[1],n,h)),c.draw(D.unitMatrix,a)}},it=function(t,e,r,a){D.roundedRect(parseFloat(t.getAttribute("x"))||0,parseFloat(t.getAttribute("y"))||0,parseFloat(t.getAttribute("width")),parseFloat(t.getAttribute("height")),parseFloat(t.getAttribute("rx"))||0,parseFloat(t.getAttribute("ry"))||0,e,r,a)},nt=function(t,e,r,a){D.ellipse(parseFloat(t.getAttribute("cx"))||0,parseFloat(t.getAttribute("cy"))||0,parseFloat(t.getAttribute("rx")),parseFloat(t.getAttribute("ry")),e,r,a)},st=function(t,e,r,a){var i=parseFloat(t.getAttribute("r"))||0;D.ellipse(
parseFloat(t.getAttribute("cx"))||0,parseFloat(t.getAttribute("cy"))||0,i,i,e,r,a)},v=function(t,e){switch(B(t,"text-transform")){case"uppercase":return e.toUpperCase();case"lowercase":return e.toLowerCase();default:return e}},ot=function(i,t,e,r,a){D.saveGraphicsState(),V(i,r);var n=function(t,e){var r=0;switch(t){case"end":r=e;break;case"middle":r=e/2}return r},s=function(t,e){var r;return(r=t&&t.toString().match(/^([\-0-9.]+)em$/))?parseFloat(r[1])*e:(r=t&&t.toString().match(/^([\-0-9.]+)(px|)$/))?parseFloat(r[1]):0},o=document.createElementNS("http://www.w3.org/2000/svg","svg");o.appendChild(i),o.setAttribute("visibility","hidden"),document.body.appendChild(o);var c,h,u=i.getBBox(),f=0,l=B(i,"text-anchor");l&&(f=n(l,u.width));var d=D.getFontSize(),g=s(i.getAttribute("x"),d),p=s(i.getAttribute("y"),d),x=D.matrixMult(new D.Matrix(1,0,0,1,g,p),t);c=s(i.getAttribute("dx"),d),h=s(i.getAttribute("dy"),d);var b=B(i,"visibility")||a.visibility;0===i.childElementCount?"visible"===b&&D.text(c-f,h,v(i,m(i.textContent)),void 0,x):_(i,function(t,e){if(e.textContent&&!U(e,"title,desc,metadata")){D.saveGraphicsState();var r=B(e,"fill");V(e,r&&new Y(r));var a=e.getExtentOfChar(0);"visible"===(B(e,"visibility")||b)&&D.text(a.x-g,a.y+.7*a.height-p,v(i,m(e.textContent)),void 0,x),D.restoreGraphicsState()}}),document.body.removeChild(o),D.restoreGraphicsState()},ct=function(t,r,a,i,n,s){_(t,function(t,e){"defs"===e.tagName.toLowerCase()&&(d(e,r,a,i,n,s),e.parentNode.removeChild(e))})},ht=function(t,e,r,a,i,n){var s=a.nextChild(),o=l(r);ct(t,e,o,s,i,n),ut(t,e,o,s,i,n)},ut=function(t,r,a,i,n,s){_(t,function(t,e){d(e,r,a,i,n,s)})},ft=function(t,e,r,a,i){var n,s=[],o=0,c=!1;_(t,function(t,e){if("stop"===e.tagName.toLowerCase()){var r=new Y(B(e,"stop-color"));s.push({offset:parseFloat(e.getAttribute("offset")),color:[r.r,r.g,r.b]});var a=B(e,"stop-opacity");a&&1!=a&&(o+=parseFloat(a),c=!0)}}),c&&(n=new D.GState({opacity:o/r.length}));var h=new D.ShadingPattern(e,r,s,n),u=i.get()+t.getAttribute("id");D.addShadingPattern(u,h),a[u]=t},lt=function(t,e,r,a){var i=r.get()+t.getAttribute("id");e[i]=t;var n=J(t),s=new D.TilingPattern([n[0],n[1],n[0]+n[2],n[1]+n[3]],n[2],n[3],null,X(t));D.beginTilingPattern(s),ut(t,D.unitMatrix,e,r,!1,a),D.endTilingPattern(i,s)},d=function(t,e,r,a,i,n){function s(){u=new Y("rgb(0, 0, 0)"),h=!0,f="F"}if((n=n.clone(),"none"!==B(t,"display"))&&("hidden"!==(n.visibility=B(t,"visibility")||n.visibility)||U(t,"svg,g,marker,a,pattern,defs,text"))){var o,c,h=!1,u=null,f="inherit",l="inherit",d=null,g=null,p=i&&!U(t,"lineargradient,radialgradient,pattern");if(p?(o=X(t),c=J(t),D.beginFormObject(c[0],c[1],c[2],c[3],o),o=D.unitMatrix,i=!1):(o=D.matrixMult(X(t),e),D.saveGraphicsState()),U(t,"g,path,rect,text,ellipse,line,circle,polygon")){var x=B(t,"fill");if(x){var b=H.exec(x);if(b){d=a.get()+b[1];var m=Q(d,r);if(m&&U(m,"lineargradient,radialgradient")){var v=o;if(!m.hasAttribute("gradientUnits")||"objectboundingbox"===m.getAttribute("gradientUnits").toLowerCase()){c||(c=J(t)),v=new D.Matrix(c[2],0,0,c[3],c[0],c[1]);var y=X(t);v=D.matrixMult(v,y)}var k=W(m.getAttribute("gradientTransform"));g=D.matrixMult(k,v),f=""}else if(m&&U(m,"pattern")){var M,w,A,F,S;g={};var C=D.unitMatrix;m.hasAttribute("patternUnits")&&"objectboundingbox"!==m.getAttribute("patternUnits").toLowerCase()||(c||(c=J(t)),C=new D.Matrix(1,0,0,1,c[0],c[1]),S=(M=J(m))[0]*c[0],w=M[1]*c[1],A=M[2]*c[2],F=M[3]*c[3],g.boundingBox=[S,w,S+A,w+F],g.xStep=A,g.yStep=F);var I=D.unitMatrix;m.hasAttribute("patternContentUnits")&&"objectboundingbox"===m.getAttribute("patternContentUnits").toLowerCase()&&(c||(c=J(t)),I=new D.Matrix(c[2],0,0,c[3],0,0),S=(M=g.boundingBox||J(m))[0]/c[0],w=M[1]/c[1],A=M[2]/c[2],F=M[3]/c[3],g.boundingBox=[S,w,S+A,w+F],g.xStep=A,g.yStep=F),g.matrix=D.matrixMult(D.matrixMult(I,C),o),f="F"}else d=m=null,s()}else(u=Z(x)).ok?(h=!0,f="F"):f=""}var _=1,L=B(t,"opacity")||B(t,"fill-opacity")||B(t,"stroke-opacity");L&&(_*=parseFloat(L)),u&&"number"==typeof u.a&&(_*=u.a),D.setGState(new D.GState({opacity:_}))}if(U(t,"g,path,rect,ellipse,line,circle,polygon")){h&&(n.fill=u,D.setFillColor(u.r,u.g,u.b));var O=B(t,"stroke");if(O){var T=B(t,"stroke-width");void 0!==T&&""!==T&&(T=Math.abs(parseFloat(T)),n.strokeWidth=T,D.setLineWidth(T));var q=new Y(O);q.ok&&(n.color=q,D.setDrawColor(q.r,q.g,q.b),l=0!==T?"D":"");var N=B(t,"stroke-linecap");N&&D.setLineCap(n.strokeLinecap=N);var P=B(t,"stroke-linejoin");P&&D.setLineJoin(n.strokeLinejoin=P);var E=B(t,"stroke-dasharray");if(E){E=R(E);var j=parseInt(B(t,"stroke-dashoffset"))||0;n.strokeDasharray=E,n.strokeDashoffset=j,D.setLineDashPattern(E,j)}var G=B(t,"stroke-miterlimit");void 0!==G&&""!==G&&D.setLineMiterLimit(n.strokeMiterlimit=parseFloat(G))}}f=n.fillMode="inherit"===f?n.fillMode:f,l=n.strokeMode="inherit"===l?n.strokeMode:l;var z=f+l;switch(V(t,u),t.tagName.toLowerCase()){case"svg":ht(t,o,r,a,i,n);break;case"g":ct(t,o,r,a,i,n);case"a":case"marker":ut(t,o,r,a,i,n);break;case"defs":ut(t,o,r,a,!0,n);break;case"use":rt(t,o,a);break;case"line":at(t,o,a,n);break;case"rect":D.setCurrentTransformationMatrix(o),it(t,z,d,g);break;case"ellipse":D.setCurrentTransformationMatrix(o),nt(t,z,d,g);break;case"circle":D.setCurrentTransformationMatrix(o),st(t,z,d,g);break;case"text":ot(t,o,h,u,n);break;case"path":et(t,o,a,z,d,g,n);break;case"polygon":K(t,o,z,d,g,a,n);break;case"image":D.setCurrentTransformationMatrix(o),tt(t);break;case"lineargradient":ft(t,"axial",[t.getAttribute("x1"),t.getAttribute("y1"),t.getAttribute("x2"),t.getAttribute("y2")],r,a);break;case"radialgradient":ft(t,"radial",[t.getAttribute("fx")||t.getAttribute("cx"),t.getAttribute("fy")||t.getAttribute("cy"),0,t.getAttribute("cx")||0,t.getAttribute("cy")||0,t.getAttribute("r")||0],r,a);break;case"pattern":lt(t,r,a,n)}p?D.endFormObject(a.get()+t.getAttribute("id")):D.restoreGraphicsState()}},a=function(t,e,r){D=e;var a=r.scale||1,i=r.xOffset||0,n=r.yOffset||0;D.saveGraphicsState(),D.setCurrentTransformationMatrix(new D.Matrix(a,0,0,a,i,n));var s=new f;D.setLineWidth(s.strokeWidth);var o=s.fill;return D.setFillColor(o.r,o.g,o.b),D.setFont(s.fontFamily),D.setFontSize(s.fontSize),d(t.cloneNode(!0),D.unitMatrix,{},new c(""),!1,s),D.restoreGraphicsState(),D};"function"==typeof o&&o.amd?o(["./rgbcolor","SvgPath"],function(t,e){return Y=t,u=e,a}):void 0!==n&&n.exports?(Y=i("./rgbcolor.js"),u=i("SvgPath"),n.exports=a):(u=t.SvgPath,Y=t.RGBColor,t.svg2pdf=a,t.svgElementToPdf=a)}("undefined"!=typeof self&&self||"undefined"!=typeof window&&window||this)},{"./rgbcolor.js":8,SvgPath:1}]},{},[9])(9)});