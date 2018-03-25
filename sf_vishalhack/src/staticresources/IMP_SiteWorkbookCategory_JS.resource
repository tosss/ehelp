//06/28/15    Vishal Bandari          RQ-04849: saveAndClose method navigation to IMP_SubProjectManagement Page
	var j$; if(!j$) { j$ = jQuery.noConflict(); }
        j$(init);
        
        j$(window).scroll(
            function(e)
            { 
                j$el=j$("[id$='quickSavebutton']"); 
                if(j$(this).scrollTop() > 100 && j$el.css('position')!= 'fixed')
                { 
                    j$("[id$='quickSavebutton']").removeAttr("class");
                    j$("[id$='quickSavebutton']").addClass("divScrollDown");
                }
                if(j$(this).scrollTop() < 100 && j$el.css('position')=='fixed')
                {
                    j$("[id$='quickSavebutton']").removeAttr("class");
                    j$("[id$='quickSavebutton']").addClass("divScrollUp");
                } 
            }
        );
        function displayQuickSave()
        {
            j$("[id$='quickSavebutton']").css({'visibility': 'visible'});
        }
        function hideQuickSave()
        {
            j$("[id$='quickSavebutton']").css({'visibility': 'hidden'});
        }
        
        // global variable used to set previous value when N/A is checked
        var prevValueList = new Array();
        
        function init() {


            j$("body").on("change",".notApplicabletrue,.notApplicablefalse",function(){
                if(j$(this).is(":checked"))
                {
                    prevValueList[getRowNumber(j$(this))] = j$(this).parent().siblings(".AnswerURL").val();
                    j$(this).parent().siblings(".AnswerURL").val("");
                    j$(this).parent().siblings(".AnswerURL").prop("disabled","disabled");
                    j$(this).parent().siblings(".AnswerURL").removeClass("error");
                    j$(this).parent().siblings(".AnswerURL").next(".errorAppend").remove();
                }
                else
                {
                    j$(this).parent().siblings(".AnswerURL").val(prevValueList[getRowNumber(j$(this))]);
                    j$(this).parent().siblings(".AnswerURL").removeProp("disabled");
                    ValidateURL(j$(this).parent().siblings(".AnswerURL"));
                }
            });
            
            j$(document).on("mousemove","body",function(){
                j$(".notApplicabletrue").each(function(){
                    j$(this).parent().siblings(".AnswerURL").prop("disabled","disabled");
                    j$(this).removeClass("notApplicabletrue");
                    j$(this).addClass("notApplicablefalse");
                });
            });
            
            j$(document).on("keydown","body",function(){
                j$(".notApplicabletrue").each(function(){
                    j$(this).parent().siblings(".AnswerURL").prop("disabled","disabled");
                    j$(this).removeClass("notApplicabletrue");
                    j$(this).addClass("notApplicablefalse");
                });
            });
            
            j$(".AnswerURL").on("change", function() {
                ValidateURL(j$(this));
            });
            
            //only enable the auto save and dependent question in edit mode only
            
            if (__isEditMode == "true") 
            {
                //this is initialize when the page is loaded
                //If the parent question have no answer search all its child and clear the value and disabled it 
                //If the parent question have answer search all its child and enabled it
                
                //iterate all the answer fields in the page
                var a = j$("input[type='hidden'][id$='DependentId']").each(function(i,v){
                    // if the Dependent Question is set (v.value is not undefined)
                    if(v.value) 
                    { 
                        var parentQuestion = findAnswerById("QuestionId",v.value);
                        var parentQuestionValue = parentQuestion ? parentQuestion.val() : null; // this is the value the current answer depends on
                        if (parentQuestion && parentQuestion.prop("type") == 'checkbox') 
                        {                        
                            parentQuestionValue =  parentQuestion.prop('checked');                       
                        }
                        var parentToggleAnswer = findToggleAnswer("QuestionId",v.value);
                        
                        if(isBlank(parentQuestionValue)  || (!isBlank(parentToggleAnswer) && parentQuestionValue.toLowerCase() != parentToggleAnswer.toLowerCase()))
                        {
                            
                            var AnswerField = findAnswer(j$(v));                          
                            
                            if(AnswerField)
                            { 
                                //checkbox have different way of clearing the value, do not use val("") in checkbox
                                //the controller will not get the value of it
                                if (AnswerField.prop("type") == 'checkbox') 
                                {
                                    AnswerField.attr("disabled","disabled").prop("checked",false); 
                                } else 
                                {
                                    AnswerField.attr("disabled","disabled").val(""); 
                                }
                            }
                        }
                    }
                }); 
                //set the time when the auto save will trigger
                //Uncomment below line to enable autosave functionality
                var timerInMilliSecs = __autoSaveTimer * 1000;
                setInterval(function () {  displayQuickSave(); }, timerInMilliSecs); 
            }
        }    
        
        //Added by Vishal Bandari vishal.bandari@cdk.com on 29/Feb/2015
        //Returns the answer number of given element
        function getRowNumber(element)
        {
            var row = j$(element).closest('tr').children('.rowNumber_td').html();
            row = row.replace('.','');
            return row;
        }
       
        //Added by Vishal Bandari vishal.bandari@cdk.com on 29/Feb/2015
        //function to validate all URL answers when save or save and close is pressed
        function saveAnswer()
        {
            var allValuesValid = true;
            
            j$(".AnswerURL").each(function(){
                allValuesValid = allValuesValid && ValidateURL(j$(this));
            });
            if(allValuesValid)
            {
                saveAnswers();
            }
        }
        
        //Added by Vishal Bandari vishal.bandari@cdk.com on 29/Feb/2015
        //Validates given textbox URL answer and appends error if needed
        function ValidateURL(element)
        {
            prevValueList[getRowNumber(element)] = j$(element).val();
            
            if(j$(element).next().attr("class")=="errorAppend")
            {
                j$(element).removeClass("error");
                j$(element).next().remove();
            }
            
            if(!URLIsValid(j$(element).val()) && j$(element).val()!='')
            {
                j$(element).addClass("error");
                j$(element).after("<span class='errorAppend' style='color:red;font-weight:bold;margin-left:1%;'>Not a valid URL</span>");
                return false;	
            }
            if(j$(element).val()!='')
            {
                if(j$(element).val().indexOf('http://')==0)
                {
                    var value = j$(element).val();
                    value = value.replace('http://','');
                    j$(element).val(value);
                }
                else if(j$(element).val().indexOf('https://')==0)
                {
                    var value = j$(element).val();
                    value = value.replace('https://','');
                    j$(element).val(value);
                }
            }
            return true;
        }
        
        //Added by Vishal Bandari vishal.bandari@cdk.com on 29/Feb/2015
        //Checks for the URL Pattern Match
        function URLIsValid(url)
        {
            var urlPattern = 
                /^(http[s]?:\/\/)?[a-zA-Z0-9](([a-zA-Z0-9-\.])*[a-zA-Z0-9])?\.([a-zA-Z]){2,}(([\/\/][a-zA-Z0-9\-\._]+)+)?([\/?][a-zA-Z0-9\-\._]+[=][a-zA-Z0-9\-\._]+(([&][a-zA-Z0-9\-\._]+[=][a-zA-Z0-9\-\._]+)+)?)?$/i;
            
            return urlPattern.test(url);
        }
        
        function disableWhenPostBack() {
            if (__isEditMode == 'true')
            {
                //this method is called when filter or save button is click
                //the postback will enable all the controls that needed to be disable that is why this function need to call again
                
                //iterate all the answer fields in the page
                var ctr  = 1;
                var a = j$("input[type='hidden'][id$='DependentId']").each(function(i,v){
                    
                    // if the Dependent Question is set (v.value is not undefined)
                    if(v.value) 
                    { 
                        //If the parent question have no answer search all its child and clear the value and disabled it 
                        //If the parent question have answer search all its child and enabled it
                        var parentQuestion = findAnswerById("QuestionId",v.value);
                        var parentQuestionValue = parentQuestion ? parentQuestion.val().toLowerCase() : null; // this is the value the current answer depends on
                        if (parentQuestion && parentQuestion.prop("type") == 'checkbox') 
                        {                        
                            parentQuestionValue =  parentQuestion.prop('checked');                       
                        }
                        var parentToggleAnswer = findToggleAnswer("QuestionId",v.value);                   
                        
                        if ( parentQuestion.prop("type") == 'select-one') 
                        {
                            var id = parentQuestion.prop("id");                       
                        }
                        ctr = ctr + 1;
                        
                        if(isBlank(parentQuestionValue) || (!isBlank(parentToggleAnswer) && parentQuestionValue.toLowerCase() != parentToggleAnswer.toLowerCase()))
                        {                       
                            var AnswerField = findAnswer(j$(v)); 
                            if(AnswerField){ 
                                //checkbox have different way of clearing the value, do not use val("") in checkbox
                                //the controller will not get the value of it
                                if (AnswerField.prop("type") == 'checkbox') 
                                {
                                    AnswerField.attr("disabled","disabled"); 
                                } else 
                                {
                                    AnswerField.attr("disabled","disabled"); 
                                }
                            }
                        }
                    }
                }); 
            }
        }
        
        function isBlank(v)
        {
            //function to determine if the selected answer is blank
            //return (!v || v == "" || v == "-- None --" || v == "No");
            return (!v || v == "" || v == "-- None --");
        }
        
        function toggleDependent(sender, QuestionId, QuestionToggleAnswer, answerType) 
        {
            //this function is trigger when the answer field have been updated
            var SenderValue = j$(sender).val();
            if (answerType == 'Checkbox') 
            {
                SenderValue = j$(sender).prop("checked");
            }
            
            //validate the value if it is correct based on the answer type
            if (SenderValue != '') 
            {
                saveSelectedQuestion(sender.id,QuestionId, SenderValue, answerType);
            } 
            else 
            {          
                removeError(sender);
            }
            
            //get all the field that is dependent with the current question
            var DependentIdField = findAnswerById("DependentId", QuestionId);
            //If the parent question have no answer search all its child and clear the value and disabled it 
            //If the parent question have answer search all its child and enabled it 
            if(isBlank(SenderValue) || (!isBlank(QuestionToggleAnswer) && SenderValue.toString().toLowerCase()  != QuestionToggleAnswer.toString().toLowerCase())) 
            {            
                //checkbox have different way of clearing the value, do not use val("") in checkbox
                //the controller will not get the value of it           
                if (DependentIdField.length != 0) 
                {
                    if (DependentIdField.prop("type") == 'checkbox') 
                    {
                        DependentIdField.attr("disabled","disabled").prop("checked",false);                      
                    } 
                    else 
                    {
                        DependentIdField.attr("disabled","disabled").val("");  
                    }
                    //This will fire another event to disable the child questions of 
                    //above disabled question
                    DependentIdField.trigger("change");
                }       
            }
            else 
            {           
                //checkbox have different way of clearing the value, do not use val("") in checkbox
                //the controller will not get the value of it
                if (DependentIdField.length != 0) 
                {               
                    if (DependentIdField.prop("type") == 'checkbox') 
                    {
                        DependentIdField.removeAttr("disabled");
                    } 
                    else 
                    {
                        DependentIdField.removeAttr("disabled");              
                    }
                }   
            }  
        }
        
        function findAnswerById(IdType, QuestionId) 
        {
            // get the QuestionId hidden field for the current question
            var QuestionIdField = j$("input[id$='"+IdType+"'][value='"+QuestionId+"'][type='hidden']");
            
            //getting the question input based on the hidden field
            if(QuestionIdField) 
            {
                return findAnswer(QuestionIdField); 
            }
            else 
            {
                return null; 
            }
        }
        
        function findAnswer(QuestionIdField) 
        {     
            //this function will find the question input  
            if(QuestionIdField) 
            {
                return QuestionIdField.parent() // select the td               
                .find("select, input[type!='hidden'], textarea"); // inside the question container, select any non-hidden inputs or selects or textarea
            }
            else 
            { 
                return null; 
            }
        }
        
        function findToggleAnswer(IdType, QuestionId) 
        {
            var QuestionIdField = j$("input[id$='"+IdType+"'][value='"+QuestionId+"'][type='hidden']");
            if(QuestionIdField) 
            {
                var parentToggle = QuestionIdField
                .parent() // select the td               
                .find("input[id$='DependentAnswer'][type='hidden']"); // inside the question container, select any non-hidden inputs or selects
                return parentToggle ? parentToggle.val() : null;
            }
            else 
            { 
                return null; 
            }    
        }
        
        function noenter(e)
        {          
            //this function is to stop enter key to trigger the filter button   
            if(window.event)
            {                    
                key = window.event.keyCode;     //IE               
            } 
            else
            {                    
                key = e.which;     //firefox               
            }               
            if(key == 13) 
            {   
                e.preventDefault(); 
                e.key = 9;
                return false;               
            }         
        }   
        
      
        
        function populateProduct() 
        {     
            //var generatedJSON = __generatedJSON;
            // This method is used to load product list based on the selected solution
            //Javascript is used rather that server side to load the product item faster with no postback
            
            //get the solution control
            var obj = document.getElementById(__populateProduct);       
            //get the product
            var options = document.getElementById("ddProduct"); 
            //reset the value of product
            options.length = 0;
            
            var tempOptions = new Array();
            var ctr =0;
            //iterate the items in the solutions
            for (var x=0;x<obj.length;x++) 
            {
                //check if the item is selected
                if(obj[x].selected) 
                {
                    //check if the value of the selected is '--None--'
                    if(obj[x].value != '') 
                    {
                        //get the all the product of the selected solution 
                        //the key value of generatedJSON is the solution id , the value of the generatedJSON are the product 
                        j$.each(__generatedJSON.productsList[obj[x].value], function() 
                                {
                                    tempOptions[ctr] = new Array();
                                    tempOptions[ctr][0] = this.Name;
                                    tempOptions[ctr][1] = this.Id;
                                    ctr++;                 
                                });
                    }
                }
            }
            
            //sort the product by name
            tempOptions.sort();
            //this will populate the product list
            
            //create an option control and append in the list
            //the first value must be --None--
            //the loop is seperated because we need to sort first the value before appending in the product list
            var option = document.createElement("option");
            option.text = '-- None --';
            option.value ='';
            options.appendChild(option);  
            
            for(var cnt=0;cnt<tempOptions.length;cnt++) 
            {
                var option = document.createElement("option");
                option.text = tempOptions[cnt][0];
                option.value = tempOptions[cnt][1];
                options.appendChild(option);          
            }     
        }
        
        function executeFilterFunction() 
        {
            //this function is called when the user click the filter button        
            //Get Selected Product type id and pass to the controller       
            var obj = document.getElementById("ddProduct");
            var ids = '';
            for (var x=0;x<obj.length;x++) 
            {
                if(obj[x].selected) 
                {
                    if(obj[x].value != '') 
                    {                    
                        ids += obj[x].value;
                        if (x !=0) 
                        {
                            ids += ',';
                        }
                    }
                }
            }       
            //Call actionFunction to process the filter       
            filterQuestion(ids);
            //console.log(ids); 
            //filterQuestionIds(ids);   
        }
        
        function saveAndClose() 
        {
            
            //check first if there is no error before redirecting 
            var elemError = j$('.message.errorM3');
            if (elemError.length == 0) {
                //28-June-2015 : Vishal Bandari changed navigtion to IMP_SubProjectManagement Page
                window.location = '/apex/IMP_SubProjectManagement?id='+__subProjectId+'&tab=discoveryTab';  
            }
        }