document.observe("click",function(e,t){if(t=e.findElement("form a.add_nested_fields")){var d=t.readAttribute("data-association"),r=t.readAttribute("data-target"),a=$(t.readAttribute("data-blueprint-id")).readAttribute("data-blueprint"),n=(t.getOffsetParent(".fields").firstDescendant().readAttribute("name")||"").replace(new RegExp("[[a-z_]+]$"),"");if(n){var f=n.match(/[a-z_]+_attributes(?=\]\[(new_)?\d+\])/g)||[],l=n.match(/[0-9]+/g)||[];for(i=0;i<f.length;i++)l[i]&&(a=(a=a.replace(new RegExp("(_"+f[i]+")_.+?_","g"),"$1_"+l[i]+"_")).replace(new RegExp("(\\["+f[i]+"\\])\\[.+?\\]","g"),"$1["+l[i]+"]"))}var s,o=new RegExp("new_"+d,"g"),u=(new Date).getTime();return a=a.replace(o,u),(s=r?$$(r)[0].insert(a):t.insert({before:a})).fire("nested:fieldAdded",{field:s}),s.fire("nested:fieldAdded:"+d,{field:s}),!1}}),document.observe("click",function(e,t){if(t=e.findElement("form a.remove_nested_fields")){var i=t.previous(0),d=t.readAttribute("data-association");i&&(i.value="1");var r=t.up(".fields").hide();return r.fire("nested:fieldRemoved",{field:r}),r.fire("nested:fieldRemoved:"+d,{field:r}),!1}});