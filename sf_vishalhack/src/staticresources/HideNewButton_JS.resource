Sfdc.onReady(function()
             {
                 if(document.title.indexOf('Deal State: Home')>-1)
                 {
                     var toRemove=document.getElementsByName('new');
                     toRemove[0].style.display='none';
                 }
                 
                 var sidebarLinks=document.getElementsByClassName("sidebarModuleBody");
                 for(var i=0; i<sidebarLinks.length; i++)
                 {
                     if(sidebarLinks[i].innerHTML.indexOf('Hide New Button')>-1)
                     {
                         var anchorElements = sidebarLinks[i].getElementsByTagName("A");
                         for(var j=0; j<anchorElements.length; j++)
                         {
                             if(anchorElements[j].innerHTML=='Hide New Button')
                             {
                                 anchorElements[j].style.display='none';
                                 break;
                             }
                         }
                     }
                 }
             });