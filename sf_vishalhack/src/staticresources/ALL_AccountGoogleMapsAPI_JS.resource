
var j$ = jQuery.noConflict();

j$(document).ready(function ()
                   {
                       var myOptions =
                           {
                               zoom : 19,
                               mapTypeId : google.maps.MapTypeId.HYBRID,
                               mapTypeControl : true
                           }
                       
                       var map;
                       var marker;
                       var geocoder = new google.maps.Geocoder();
                       var addressGenerated = generateAddress();
                       //console.log(addressGenerated);
                       var address = addressGenerated.BillingStreet + addressGenerated.BillingCity +  addressGenerated.BillingPostalCode;
                       
                       var infowindow = new google.maps.InfoWindow( { content : "<b>"+ addressGenerated.AccountName +"</b>" } );
                       
                       geocoder.geocode( { address : address }, function (results, status)
                                        {
                                            if (status == google.maps.GeocoderStatus.OK && results.length)
                                            {
                                                if (status != google.maps.GeocoderStatus.ZERO_RESULTS)
                                                {
                                                    //create map
                                                    map = new google.maps.Map(document.getElementById("map"), myOptions);
                                                    
                                                    //center map
                                                    map.setCenter(results[0].geometry.location);
                                                    
                                                    //create marker
                                                    marker = new google.maps.Marker({
                                                        position : results[0].geometry.location,
                                                        map : map,
                                                        title : addressGenerated.AccountName
                                                    });
                                                    
                                                    //add listeners
                                                    google.maps.event.addListener(marker, 'click', function ()
                                                                                  {
                                                                                      infowindow.open(map, marker);
                                                                                  });
                                                    
                                                    google.maps.event.addListener(infowindow, 'closeclick', function ()
                                                                                  {
                                                                                      map.setCenter(marker.getPosition());
                                                                                  });
                                                }
                                            }
                                            else
                                            {
                                                j$('#map').css({
                                                    'height' : '15px'
                                                });
                                                
                                                j$('#map').html("<h4>Oops!"+ addressGenerated.AccountName + "'s address could not be found, please make sure the address is correct.</h4>");
                                                resizeIframe();
                                            }
                                        });
                       
                       function resizeIframe()
                       {
                           var me = window.name;
                           if (me)
                           {
                               var iframes = parent.document.getElementsByName(me);
                               if (iframes && iframes.length == 1)
                               {
                                   height = document.body.offsetHeight;
                                   iframes[0].style.height = height + "px";
                               }
                           }
                       }
                   });


