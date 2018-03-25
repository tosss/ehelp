// Add or remove placeholder values
var PLACEHOLDER = 'Enter Name Here'; 
var projectObjects;
var queryTerm;



function autoCompleteReInitialization(){

    $('[id$=projectTextBox]').autocomplete({
            minLength: 2,
            source: function(request, response) {
                        queryTerm = request.term;
                        var accountId = $('[id$=searchAccountId]').val();
                        
                        TRV_ResourceManagement_Helper.searchProject(request.term, accountId,function(result, event){
                            if(event.type == 'exception') {
                                  alert(event.message);
                            } else {
                                
                                 projectObjects = result;
                                 response(projectObjects);
                            }
                        });
                   },
            focus: function( event, ui ) {
                    $('[id$=projectTextBox]').val( ui.item.TRV_Consulting_Project_Name__c );
                    return false;
                    },
            select: function( event, ui ) {
                    
                        $('[id$=theButton]').prop( "disabled", false);
                        $('[id$=theButton]').removeClass('btnDisabled');
                        $('[id$=projectTextBox]').val( ui.item.TRV_Consulting_Project_Name__c );
                        $('[id$=searchProjectId]').val( ui.item.Id );   
                        return false;
                    },
         })
         .data( "autocomplete" )._renderItem = function( ul, item ) {
            var entry = "<a>" + item.TRV_Consulting_Project_Name__c;
           
            entry = entry + "</a>";
            entry = entry.replace(queryTerm, "<b>" + queryTerm + "</b>");
            return $( "<li></li>" )
                .data( "item.autocomplete", item )
                .append( entry )
                .appendTo( ul );
        };
            
        // Add or remove placeholder values
        $('[id$=projectTextBox]').val(PLACEHOLDER);
        $('[id$=projectTextBox]').on("focus",  function(event){
            $tgt = $(event.target);
            if($tgt.val() === PLACEHOLDER ){
                $tgt.val('');
                $tgt.removeClass('placeHolder');
            }
        });
        $('[id$=projectTextBox]').on( "blur",  function(event){
            $tgt = $(event.target);
            if($tgt.val() === '' ){
                $tgt.val(PLACEHOLDER);
                $tgt.addClass('placeHolder');
            }
        });

        // For Account Autocomplete
        $('[id$=accountTextBox]').autocomplete({
            minLength: 2,
            source: function(request, response) {
                
                        queryTerm = request.term;
                        TRV_ResourceManagement_Helper.searchAccount(request.term, function(result, event){
                            if(event.type == 'exception') {
                                  alert(event.message);
                            } else {
                                
                                 projectObjects = result;
                                 response(projectObjects);
                            }
                        });
                   },
            focus: function( event, ui ) {
                    $('[id$=accountTextBox]').val( ui.item.Name );
                    return false;
                    },
            select: function( event, ui ) {
                    
                        $('[id$=accountTextBox]').val( ui.item.Name );
                        $('[id$=searchAccountId]').val( ui.item.Id );

                        TRV_ResourceManagement_Helper.five_Star_Gaurantee_B4B(ui.item.Id, resourceId,function(result, event){
                            
                            if(event.type == 'exception') {
                                  alert(event.message);
                            } else {
                                
                                if(result){
                                    var result = confirm("Consultant has previous 5 Star event at this account. Are you sure you want to proceed? Click Ok to proceed or Cancel to close window.");
                                    if(!result)
                                        window.close();
                                    else
                                        $('[id$=projectBlockId]').css('display','block');    

                                }
                                else
                                    $('[id$=projectBlockId]').css('display','block');
                            }
                        });


                        
                        return false;
                    },
         })
         .data( "autocomplete" )._renderItem = function( ul, item ) {
            var entry = "<a>" + item.Name;
           
            entry = entry + "</a>";
            entry = entry.replace(queryTerm, "<b>" + queryTerm + "</b>");
            return $( "<li></li>" )
                .data( "item.autocomplete", item )
                .append( entry )
                .appendTo( ul );
        };

        // Add or remove placeholder values
        $('[id$=accountTextBox]').val('Enter Account Name');
        $('[id$=accountTextBox]').on("focus",  function(event){
            $tgt = $(event.target);
            if($tgt.val() === 'Enter Account Name' ){
                $tgt.val('');
                $tgt.removeClass('placeHolder');
            }
        });
        $('[id$=accountTextBox]').on( "blur",  function(event){
            $tgt = $(event.target);
            if($tgt.val() === '' ){
                $tgt.val('Enter Account Name');
                $tgt.addClass('placeHolder');
            }
        });
    
}


$(function(){

    
    if(b4BCreation == 'true'){
        alert('We are unable to create a B4B record for this resource on the date selected.  Please contact the resource’s manager.');
        window.close();
    }    
    autoCompleteReInitialization();       
});