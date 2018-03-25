function getRecordsToBeSearched(startKey, recordMap) {
    var properties = Object.keys(recordMap);
    var recordsToBeSearched = [];
    for(var i = 0;i < properties.length;i++) {
        //checking if the prefix matches with key
        var key = properties[i];
        if(key.substring(0,3) == startKey) {
            recordsToBeSearched.push(recordMap[key].parentRec);
        }
    }
    console.log('record map' ,recordsToBeSearched);
    return recordsToBeSearched;
    
   
    
   
}

//formatting date in the way salesforce accepts it
function formatDate(date) {
    //console.log('date sent is ' + date);
    var d = new Date(date),
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();
    
    if (month.length < 2) month = '0' + month;
    if (day.length < 2) day = '0' + day;
    
    return [year, month, day].join('-');
    
}


function validateContactObject(contactObject, requiredKeys) {
    
    for(var i = 0;i < requiredKeys.length;i++) {
        if(contactObject[requiredKeys[i]].length == 0) {
            return 'Please fill the mandatory fields';
        }
    }
    return '';
}


function recordsWithPSRValue(records, objectKeyMap, PSRValue) {
  return records.map(function(record){
      if(objectKeyMap.hasOwnProperty(record.substring(0,3))) {
          return {attributes : {type: objectKeyMap[record.substring(0,3)]}, id : record , Display_on_PSR__c : PSRValue};
      }
    });
}

function getIdOfChildRecordsToUpdatePSR(childInfoMap,totalObjects,selectedRecords) {
    var recordIdList = selectedRecords;
   
    for(var i = 0;i < totalObjects-1;i++) {
        
       var newSet = [];
        selectedRecords.forEach(function(record) {
          newSet = newSet.concat(childInfoMap[record].split(',')); 
        });
       
        recordIdList = recordIdList.concat(newSet);
        selectedRecords = newSet;
     
   
    }
    return recordIdList;
    
}

   //adjusts the height of the rootDiv based on the browser height
             var setDimensions = function() {
             
                 try {
                     
                           // console.log('setHeight called');
                     //  console.log('height if div' , document.getElementById('allHeaders').clientHeight, document.getElementById('buttonHolder').clientHeight,document.getElementById('pagination').clientHeight, document.getElementsByClassName('contentHolder')[0].clientHeight,window.getComputedStyle(document.getElementById('views'), null).getPropertyValue('padding-left')); 
                     var paddingLeft = parseFloat(window.getComputedStyle(document.getElementById('views'), null).getPropertyValue('padding-left'));
                     // paddingLeft = paddingLeft.substring(0,paddingLeft.indexOf('px'));
                     var paddingRight = parseFloat(window.getComputedStyle(document.getElementById('views'), null).getPropertyValue('padding-right'));
                     //paddingRight = paddingLeft.substring(0,paddingRight.indexOf('px'));
                     //  console.log('height if div' + paddingRight);
                     var rootDivHeight = window.innerHeight - document.getElementById('allHeaders').clientHeight-document.getElementById('buttonHolder').clientHeight-document.getElementById('pagination').clientHeight-paddingLeft-paddingRight;
                   
                     //  console.log('height of div' +  document.getElementById('rootDiv').style.height);
                     //  console.log('width if div befire' , document.getElementById('allHeaders').clientWidth, parseFloat(document.getElementById('rootDiv').clientWidth)); 
                     var computedWidth = parseFloat(window.getComputedStyle(document.getElementById('flowDiv')).getPropertyValue("clientWidth"));
                     var difference = Math.round(computedWidth) - computedWidth;
         			 //     console.log('width with decimal' + window.getComputedStyle(document.getElementById('rootDiv')).getPropertyValue("width") ,  window.getComputedStyle(document.getElementById('allHeaders')).width);
                     //     console.log('width if div after' , document.getElementById('allHeaders').clientWidth, document.getElementById('rootDiv').clientWidth , document.getElementById('rootDiv').scrollHeight); 
                     // 	 console.log('alert message height' +  document.getElementById('alertMsg') );
                     //console.log('rootDivHeight' + rootDivHeight)
                     if(document.getElementById('alertMsg') != null) {
                        rootDivHeight = rootDivHeight - document.getElementById('alertMsg').clientHeight 
                                                      - parseFloat(window.getComputedStyle(document.getElementById('alertMsg'), null).getPropertyValue('margin-top'))
                         							  - parseFloat(window.getComputedStyle(document.getElementById('alertMsg'), null).getPropertyValue('margin-bottom'))	
                         							  + 'px';
                         	console.log('element is not null' + rootDivHeight);  
                        
                         
                     }
                     
                     document.getElementById('rootDiv').style.maxHeight = rootDivHeight + 'px';
                    document.getElementById('fixDiv').style.maxHeight = rootDivHeight + 'px';
                     document.getElementById('flowDiv').style.maxHeight = rootDivHeight + 'px';
                     document.getElementById('rootDiv').style.height = rootDivHeight + 'px';
                     document.getElementById('fixDiv').style.height = rootDivHeight + 'px';
                     document.getElementById('flowDiv').style.height = rootDivHeight + 'px';
                     
                     if(jQuery('#searchTxt').val().length < 3) {
                         var width = jQuery('#flowDiv')[0]['clientWidth'];
                         jQuery('.flowDiv').css({'width':width+'px'});
                     }
                      setHeight();
                 }
                 catch(err) {
                     console.log('errors' + err.message);
                 }
              
                            
            };
   			
            var jQuery = jQuery.noConflict();
            jQuery(document).ready(function() {
            	
                jQuery('#flowDiv').on('scroll',function(){
                   
                	scrollFired();
                });
               
                        var MOUSE_OVER = false;
                jQuery('body').bind('mousewheel', function(e){
                    if(MOUSE_OVER){
                        if(e.preventDefault) { e.preventDefault(); } 
                        e.returnValue = false; 
                        return false; 
                    }
                });
                
                jQuery('#rootDiv').mouseenter(function(){ MOUSE_OVER=true; });
                jQuery('#rootDiv').mouseleave(function(){ MOUSE_OVER=false; });
                
                jQuery('#rootDiv').bind('mousewheel', function(e){
                    if(jQuery('#flowDiv').hasScrollBar('vertical')) {
                        var delta = e.originalEvent.wheelDelta;
                       setScrollPosition(delta);
                        
                    }
                });
            
                              
            });
            
            function setHeight() {
                
              	var heightMap = {};
                
                jQuery('#rootDiv').find('.record').each(function() {
					
                    if(heightMap.hasOwnProperty(this.id)) {
                       heightMap[this.id] = (heightMap[this.id] < jQuery(this).height()) ? jQuery(this).height() : heightMap[this.id];
                       }
                    else {
                        heightMap[this.id] = jQuery(this).height();
                    }
                });
             
                
                jQuery('#rootDiv').find('.record').each(function() {
					jQuery(this).height(heightMap[this.id]);
                    
                });
             
                  document.getElementById('fixDiv').style.height = window.getComputedStyle(document.getElementById('flowDiv')).getPropertyValue("height");
                var height = jQuery('#flowDiv')[0]['clientHeight'];
                jQuery('#fixDiv').css({'height':height+'px','max-height':height+'px'}); 
               
          
            }
            
              function setScrollPosition(delta) {
                var scrollValue = jQuery('#flowDiv').scrollTop() - delta;
                if(scrollValue < 0) {
                    scrollValue = 0;    
                }
                else if(scrollValue > jQuery('#flowDiv').get(0).scrollHeight) {
                    scrollValue = jQuery('#flowDiv').get(0).scrollHeight;   
                }
                jQuery('#flowDiv').scrollTop(scrollValue);
				scrollFired();
            }
            jQuery.fn.hasScrollBar = function(direction)
            {
                if (direction == 'vertical')
                {
                    return this.get(0).scrollHeight > this.innerHeight();
                }
                else if (direction == 'horizontal')
                {
                    return this.get(0).scrollWidth > this.innerWidth();
                }
                return false;
                
            }
    		function scrollFired() {
                //console.log('scroll fired');
              
                jQuery('#fixDiv').scrollTop(jQuery('#flowDiv').scrollTop());
                jQuery('.flowDiv').scrollLeft(jQuery('#flowDiv').scrollLeft());
                setHeight();    
            }
            function addScrollEventListener() {
                jQuery('#flowDiv').on('scroll',function(){
                    //console.log('add event listener');
                	scrollFired();
                });
           }






