var Attachments, rcpSchema, runningObjectId , languageSubjectandBody, deleteRcpList,newRcpsList,deletedAttachments,currentRcpObj, newContact,selectedAttachmentIds, dealId, attachments, documents, libraries, templates, feedattachments, selectedOption = '';
function initDocuments()
{
    formAttachments();
    formDocuments();
    formLibraries();
    formFeedAttachments();
}
jQuery(document).on('change','#language',function(){
    var selectedLanguage = jQuery(this).val();
    jQuery('#envelopeSubject').val(languageSubjectandBody[selectedLanguage]['Subject__c']);
    jQuery('#envelopeMessage').text(languageSubjectandBody[selectedLanguage]['Message__c']);
});

jQuery(function() {
    jQuery( ".sortable" ).sortable({ 
        cancel: ".ui-state-disabled",
        update: sortDocuments
    });
});
jQuery(document).on('click','#searchAccount',function(){
    jQuery("#AccountResults").html('');
    Docusign_EditEnvelope_CustomController.getOptions('Account',jQuery('#searchStringAccount').val(),function(result){
        var options = '';
        result = JSON.parse(result);
        if(result.length>0)
        {
            for(var i = 0; i< result.length;i++)
            {
                options +=  '<li class="AccountOption" id="'+result[i]['Id']+'"><a href="#">'+result[i]['Name']+'</a></li>';
            }
        }
        else
        {
            options +=  '<li class="AccountOption" ><a href="#" style="color:red;">No Items</a></li>';
        }
        jQuery("#AccountResults").html(options);
        console.log(result.length);
        if(result.length == 1)
        {
            jQuery('#searchStringAccount').val(result[0].Name);
            jQuery('#searchStringAccountId').val(result[0].Id);
        }
        else
        {
            jQuery('#searchStringAccount').val('');
            jQuery('#searchStringAccountId').val('');
        }
    },{escape:false});
});
jQuery(document).on('click','.editRcp',function(){
    var Id = jQuery(this).attr('rcpId');
    var editingObj;
    if(jQuery(this).hasClass('newRecipient'))
    {
        editingObj = newRcpsList[Id];
        setForEditing(editingObj,Id,true);
    }
    else
    {
        
        Docusign_EditEnvelope_CustomController.getRecipient(Id,function(result){
            editingObj = JSON.parse(result);
            setForEditing(editingObj,Id,false);
        },{escape:false});
    }
    
});
function setForEditing(editingObj,Id,isNew)
{
    jQuery('#rcpName').val(Id);
    jQuery('#rcpEmail').val(isNew);
    jQuery('#rcpRole').val(editingObj['dsfs__DocuSign_Recipient_Role__c']);
    jQuery('#signer').val(editingObj['dsfs__DocuSign_Signer_Type__c']);
    jQuery('#accessCode').val(editingObj['dsfs__Access_Code__c']);
    jQuery('#NoteForRcp').val(editingObj['dsfs__Recipient_Note_Long__c']);
    jQuery('.progress').hide();
    jQuery('.general').hide();
    jQuery('.options').hide();
    jQuery('#newContact').hide();
    jQuery('.quickAdd').hide();
    jQuery('.modal-header').find('.modal-title').html('Edit Recipient');
    jQuery('.add').hide();
    jQuery('.next').hide();
    jQuery('.saveRcp').show();
    if(jQuery('#signer').val()!='Signer')
    {
        jQuery('#signerDependent').hide();
        jQuery('#rcpRole').val('--None--');
    }
    jQuery('#popup').modal('show');
}
jQuery(document).on('click','.saveRcp',function(){
    var isNew = jQuery('#rcpEmail').val();
    var Id = jQuery('#rcpName').val();
    var editedRcp = new Object();
    if(isNew == 'true')
    {
        editedRcp = newRcpsList[Id];
    }
    editedRcp['dsfs__DocuSign_Recipient_Role__c']= jQuery('#rcpRole').val();
    editedRcp['dsfs__DocuSign_Signer_Type__c'] = jQuery('#signer').val();
    if(editedRcp['dsfs__DocuSign_Signer_Type__c']!='Signer')
    {
        editedRcp['dsfs__DocuSign_Recipient_Role__c'] = '';
    }
    else
    {
        jQuery('#rcpRole').show();
    }
    editedRcp['dsfs__Access_Code__c'] =jQuery('#accessCode').val();
    editedRcp['dsfs__Recipient_Note_Long__c'] =jQuery('#NoteForRcp').val();
    Id = '#'+Id;
    jQuery(Id).find('tr td:nth-child(3)').html(editedRcp['dsfs__DocuSign_Signer_Type__c']);
    jQuery(Id).find('tr td:nth-child(4)').html(editedRcp['dsfs__DocuSign_Recipient_Role__c']);
    if(isNew == 'false')
    {  
        editedRcp['Id'] = Id.replace('#','');
        editedRcp  = JSON.stringify(editedRcp);
        Docusign_EditEnvelope_CustomController.saveRecipient(editedRcp,function(result){
        });
    }    
    jQuery('#popup').modal('hide'); 
});
jQuery(document).on('change','#rcpName',function(){
    jQuery('#Signature').val(jQuery(this).val());
});
jQuery(document).on('change','#signer',function(){
    jQuery('#signerDependent').hide();
    if(jQuery(this).val()=='Signer')
    {
        jQuery('#signerDependent').show();
        jQuery('#signerDependent').val('--None--');
    }
});
jQuery(document).on('click','#refresh',function(){
    Docusign_EditEnvelope_CustomController.init(dealId,function(result){
        Attachments = JSON.parse(result);
        initDocuments();
    }, { escape: false});
});

function sortDocuments()
{
    var order=1;
    jQuery('.attachedList').find('.docOrder').each(function(){
        jQuery(this).html(order);
        order++;
    });
}
jQuery(document).on('change','.rcpOrder',function(){
    var orderMap = new Array();
    var changedValue = jQuery(this).val();
    var changedValueTableId = '#'+jQuery(this).parents('table').attr('id');
    jQuery('.recipientsList table').each(function(){
        var lastElement = jQuery(this).find('.rcpOrder');
        var order;
        var Id = jQuery(this).attr('Id');
        if(lastElement.prop("tagName")=='INPUT')
        {
            order = lastElement.val();
        }
        else
        {
            order = lastElement.html()
        }
        orderMap.push([Id,order]);
    });
    orderMap.sort(function(a,b){return a[1]-b[1];});
    var orderedRcps = '';
    jQuery.each(orderMap,function(key,value){
        var element = document.getElementById(value[0]);
        orderedRcps += element.outerHTML;
    });
    jQuery('.recipientsList').html(orderedRcps);
    jQuery(changedValueTableId).find('.rcpOrder').attr('value',changedValue);
});
jQuery(window).on('click',document,function(){
    jQuery('.alert').fadeOut(10000);
});

jQuery(document).on('click','#save',function(){
    SaveCurrentState();
});
jQuery(document).on('blur','input[type=email]',function(){
    if(!validateEmail(jQuery(this).val()))
    {
        jQuery(this).parents('.form-group, .input-group').addClass('has-error');
    }
    else
    {
        jQuery(this).parents('.form-group, .input-group').removeClass('has-error');
    }
});
jQuery(document).on('click','.add',function(){
    if(selectedOption == 'Attachments'|| selectedOption == 'Libraries' || selectedOption == 'Documents' || selectedOption == 'Feed Attachments')
    {
        var docKey  = selectedOption == 'Libraries' ? jQuery('.Libraries').val(): selectedOption == 'Documents'?jQuery('.Documents').val():undefined ;
        var list = '';
        var order = jQuery('.attachedList > table').length + 1;
        var attachmentList = (selectedOption == 'Attachments'?attachments:selectedOption == 'Libraries'?libraries[docKey]:selectedOption == 'Documents'?documents[docKey]:feedattachments);
        
        var size =  (selectedOption == 'Feed Attachments' || selectedOption == 'Libraries' ? 'ContentSize':'BodyLength');
        var name =  (selectedOption == 'Feed Attachments' || selectedOption == 'Libraries' ? 'Title':'Name');
        
        jQuery('.docOptions:checked').each(function(){
            list += '<table class="table" style="background-color: #eee;">'
            +' <tr>'
            +' <td width="20%" style="color: #7B7676;border-top:0px;"><i class="fa fa-arrows-v"></i> &nbsp;<span class="docOrder">'+order+'</span><input style="visibility:hidden;width:1%;" /></td>'
            +' <td style="color: #7B7676;border-top:0px;"><span style="font-size:1em;">'+attachmentList[jQuery(this).attr('id')][name]+'</span> &nbsp;<span style="font-size:0.7em;"> '+attachmentList[jQuery(this).attr('id')][size]+'KB</span></td>'
            +' <td width="2%" style="color: #7B7676;border-top:0px;"><a style="font-size:1.2em;color:#6D6B6B;"><i class="fa fa-times newAttachment attach" parentId="'+jQuery(this).attr('parentid')+'" doctype="'+jQuery(this).attr('doctype')+'"  id="'+attachmentList[jQuery(this).attr('id')]['Id']+'"></i></a></td>'
            +' </tr>'
            +' </table>';
            selectedAttachmentIds += jQuery(this).attr('id')+','; 
            order++;
        });
        jQuery('.attachedList').append(list);
        jQuery("#popup").modal('hide');
    }
    else
    {
        var email = jQuery('#rcpEmail').val();
        var valid= true;
        if(selectedOption == 'Add Me')
        {
            jQuery("#popup").modal('hide');
            jQuery('.quickAdd').show();
            jQuery('.searchbar').show();
            jQuery('.options').show();
            jQuery('#newContact').show();
            jQuery('#RcpForm').show();
            jQuery(".next").show();
            jQuery(".add").show();
        }
        else if(selectedOption == 'Add Recipient')
        {
            if(!validateEmail(email))
            {
                valid= false;
                jQuery('#rcpEmail').parents('.form-group').addClass('has-error');
            }
            else
            {
                jQuery('#rcpEmail').parents('.form-group').removeClass('has-error');
                
                jQuery('.quickAdd').show();
                jQuery('.searchbar').show();
                jQuery('.options').show();
                jQuery('#newContact').show();
                jQuery('#RcpForm').show();
                jQuery(".next").show();
                jQuery(".add").show();
                jQuery("#popup").modal('hide');
                
            }
        }
            else
            { 
                
                jQuery('.quickAdd').show();
                jQuery('.searchbar').show();
                jQuery('.options').show();
                jQuery('#newContact').show();
                jQuery('#RcpForm').show();
                jQuery(".next").show();
                jQuery(".add").show();
                jQuery("#popup").modal('hide');
            }
        if(valid)
        {
            var objId = Math.random();
            objId = objId.toString().replace('0.','');
            currentRcpObj = currentRcpObj==undefined?JSON.parse(rcpSchema):currentRcpObj;
            var lastElement = jQuery('.recipientsList table:last-child').find('.rcpOrder');
            var order;
            if(lastElement.prop("tagName")=='INPUT')
            {
                order = lastElement.val();
            }
            else
            {
                order = lastElement.html()
            }
            currentRcpObj['dsfs__Routing_Order__c'] = parseInt(order) + 1;
            currentRcpObj['dsfs__SignInPersonName__c'] = jQuery('#rcpName').val();
            currentRcpObj['dsfs__SignInPersonEmail__c'] = email;   
            currentRcpObj['dsfs__DocuSign_Signature_Name__c'] = jQuery('#Signature').val();
            currentRcpObj['dsfs__DocuSign_Recipient_Role__c'] = jQuery('#rcpRole').val()=='--None--'?'':jQuery('#rcpRole').val();
            currentRcpObj['dsfs__DocuSign_Signer_Type__c'] = jQuery('#signer').val();
            currentRcpObj['dsfs__Access_Code__c'] = jQuery('#accessCode').val();
            currentRcpObj['dsfs__Recipient_Note_Long__c'] = jQuery('#NoteForRcp').val();
            var rcpElement = '';
            rcpElement = '<table class="table ui-state-disabled" style="background-color: #eee;" id="'+objId+'">'
            +'<tbody>'
            +'<tr>'
            +'<td style="color: #7B7676;border-top:0px;" width="10%"><input class="rcpOrder" value="'+currentRcpObj['dsfs__Routing_Order__c']+'" />'
            +'</td>'
            +'<td style="color: #7B7676;border-top:0px;" width="30%">'+currentRcpObj['dsfs__SignInPersonName__c']+'<br><span style="font-size:0.7em;">'+(currentRcpObj['dsfs__SignInPersonEmail__c']==null?'':currentRcpObj['dsfs__SignInPersonEmail__c'])+'</span>'
            +'</td>'
            +'<td style="color: #7B7676;border-top:0px;" width="20%">'+(currentRcpObj['dsfs__DocuSign_Signer_Type__c']==null || currentRcpObj['dsfs__DocuSign_Signer_Type__c']=='--None--'?'':currentRcpObj['dsfs__DocuSign_Signer_Type__c'])+'</td>'					  
            +'<td style="color: #7B7676;border-top:0px;" width="20%">'+(currentRcpObj['dsfs__DocuSign_Recipient_Role__c']==null || currentRcpObj['dsfs__DocuSign_Recipient_Role__c']=='--None--'?'':currentRcpObj['dsfs__DocuSign_Recipient_Role__c'])+'</td>'  
            +'<td align="right" style="color: #7B7676;border-top:0px;" width="18%"><a rcpid="'+objId+'" style="font-size:1.2em;color:#6D6B6B;" class="newRecipient editRcp">Edit</a>'
            +'</td>'
            +'<td style="color: #7B7676;border-top:0px;" width="2%"><a style="font-size:1.2em;color:#6D6B6B;"><i class="fa fa-times newRecipient rcp" rcpid="'+objId+'" ></i></a>'
            +'</td>'
            +'</tr>'
            +'</tbody>'
            +'</table>';
            jQuery('.recipientsList').append(rcpElement);
            newRcpsList[objId] = currentRcpObj;
        }
    }
});
jQuery(document).on('click','.newContact',function(){
    jQuery(this).hide();
    jQuery('.searchbar').hide();
    jQuery('.next').show();
    jQuery('#newContact').show();
});
function validateEmail(emailId)
{
    var emailRegex = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i;
    return emailRegex.test(emailId);
}
function validatePhone(phone)
{
    var phoneRegex = /[+]?([\d][ ][-])*$/i;
    phoneRegex.test(phone);
}
jQuery(document).on('click','.next',function(){
    if(selectedOption = 'Contacts')
    {
        var options = jQuery('input:radio[name="searchresult"]:checked');
        if(options.length==0)
        {
            var firstName = jQuery('#newContactFirstName').val();
            var lastName = jQuery('#newContactLastName').val();
            var email = jQuery('#newContactEmail').val();
            
            var phone = jQuery('#newContactPhone').val();
            var validate = true;
            if(firstName=='')
            {
                jQuery('#newContactFirstName').parents('.form-group').addClass('has-error');
                validate =false;
            }
            else
            {
                jQuery('#newContactFirstName').parents('.form-group').removeClass('has-error');
            }
            if(lastName=='')
            {
                jQuery('#newContactLastName').parents('.form-group').addClass('has-error');
                validate =false;
            }
            else
            {
                jQuery('#newContactLastName').parents('.form-group').removeClass('has-error');
            }
            if(!validateEmail(email))
            {
                jQuery('#newContactEmail').parents('.form-group').addClass('has-error');
                validate =false;
            }
            else
            {
                jQuery('#newContactEmail').parents('.form-group').removeClass('has-error');
            }
            if(!(validatePhone(phone) || phone==''))
            {
                jQuery('#newContactPhone').parents('.form-group').addClass('has-error');
                validate =false;
            }
            else
            {
                jQuery('#newContactPhone').parents('.form-group').removeClass('has-error');
            }
            if(validate)
            {
                newContact['FirstName']=firstName;
                newContact['LastName']=lastName;
                newContact['MailingStreet']=jQuery('#newContactStreet').val();
                newContact['MailingCity']=jQuery('#newContactCity').val();
                newContact['MailingState']=jQuery('#newContactState').val();
                newContact['MailingPostalCode']=jQuery('#newContactPin').val();
                newContact['MailingCountry']=jQuery('#newContactCountry').val();
                newContact['Fax']=jQuery('#newContactFax').val();
                newContact['Phone']=phone;
                newContact['Email']=email;
                Docusign_EditEnvelope_CustomController.insertNewContact(JSON.stringify(newContact), function(result){
                    if(result='200')
                    {
                        jQuery('.quickAdd').hide();
                        jQuery('#Signature').val(firstName+' '+lastName);
                        jQuery('#newContact').hide();
                        jQuery('#RcpForm').show();
                        jQuery(".next").hide();
                        jQuery(".add").show();
                    }
                });
            }
            
        }
        else
        {
            var nameAndEmail = options.parents('.list-group-item').find('.rcpdetail').html();
            var name = nameAndEmail.indexOf(' ,')>0?nameAndEmail.substring(0,nameAndEmail.indexOf(' ,')):nameAndEmail;
            var email = nameAndEmail.indexOf(' ,')>0?nameAndEmail.replace(name+' , ',''):'';
            var rcpObj = {
                Id:options.attr('Id'),
                type:options.attr('rcptype'),
                name:name,
                email:email
            };
            currentRcpObj =JSON.parse(rcpSchema);
            var rcpType= options.attr('rcpType');
            currentRcpObj['dsfs__Salesforce_Recipient_Type__c'] = rcpType;
            rcpType= 'dsfs__DSER_'+rcpType+'Id__c';
            currentRcpObj[rcpType] = options.attr('Id');
            jQuery('#rcpName').val(name);
            jQuery('#rcpEmail').val(email);            
            jQuery('.quickAdd').hide();
            jQuery('.searchbar').hide();
            jQuery('.options').hide();
            jQuery('#Signature').val(name);
            jQuery('#newContact').hide();
            jQuery('#RcpForm').show();
            jQuery(".next").hide();
            jQuery(".add").show();
        }
    }
});
jQuery(document).on('click','#documentDropDown',function(){
    jQuery('.alert').removeClass('alert-warning').removeClass('alert-success').removeClass('alert-danger').addClass('alert-info');
    jQuery('.alert').find('.fa').removeClass('fa-times-circle').removeClass('fa-check-circle-o').removeClass('fa-exclamation-circle').addClass('fa-info-circle');
    jQuery('.alert').find('span').html('<strong>Info!</strong>  Please Click Refresh to get Latest Document');
    jQuery('.alert').show();    
});
jQuery(document).on('change','#ClientSigner1',function(){
    var email = jQuery(this).find(":selected").attr('email');
    jQuery('#ClientSigner1Email').val(email);
});
jQuery(document).on('change','#ClientSigner2',function(){
    var email = jQuery(this).find(":selected").attr('email');
    jQuery('#ClientSigner2Email').val(email);
});
jQuery(document).on('click','.collapseIcon',function(){
    jQuery(this).parents('.well').find('.collapseIcon').toggle();
    jQuery(this).parents('.well').find('.well-body').toggle();
});
jQuery(document).on('click','#addAttachment',function(){
    SaveCurrentState();
    window.open(jQuery(this).attr('href'),jQuery(this).attr('target'),'height=600,width=600');
});
jQuery(document).on('click','.editEmail',function(){
    jQuery(this).find('i').toggle();
    var clientsigner = jQuery(this).parents('table').find('select');
    var email = jQuery(clientsigner).find(":selected").attr('email');
    jQuery(this).prev().val(email);
    if(jQuery(this).prev().attr('disabled') == undefined)
    {
        jQuery(this).prev().attr('disabled','disabled');
        jQuery(this).parents('.form-group, .input-group').removeClass('has-error');
    }
    else
    {
        jQuery(this).prev().removeAttr('disabled');
    }
    
});
jQuery(document).on('click','.fa-times',function(){
    if(jQuery(this).hasClass('attach'))
    {
        selectedAttachmentIds = selectedAttachmentIds.replace(jQuery(this).attr('id')+',','');
        deletedAttachments += jQuery(this).attr('id')+',';
        jQuery(this).parents('table').remove();
        sortDocuments();
    }
    else
    {
        if(jQuery(this).hasClass('newRecipient'))
        {
            newRcpsList[jQuery(this).attr('rcpid')] = null;
        }
        else
        {
            deleteRcpList = jQuery(this).attr('rcpid')+',';
        }
        jQuery(this).parents('table').remove();
    }
});
jQuery(document).on('click','.dropdown-menu > li',function(){
    if(!jQuery(this).hasClass('AccountOption'))
    {
        viewPopup(jQuery(this));
    }
    else
    {
        jQuery('#searchStringAccount').val(jQuery(this).find('a').html());
        jQuery('#searchStringAccountId').val(jQuery(this).attr('Id'));
    }
});
jQuery(document).on('click','#search',function(){
    var ObjectName = selectedOption.substring(0,selectedOption.length -1);
    var searchString = jQuery('#searchString').val();
    jQuery('.progress').show();
    Docusign_EditEnvelope_CustomController.getOptions(ObjectName,searchString,function(result){
        var options = '';
        jQuery('.progress').hide();
        result = JSON.parse(result);
        jQuery('.newContact').hide();
        if(result.length>0)
        {
            for(var i = 0; i< result.length;i++)
            {
                options +=  '<a  class="list-group-item"><input type="radio" id="'+result[i]['Id']+'" rcptype="'+result[i]['attributes']['type']+'" name="searchresult" style="margin-right:2%;"/><span class="rcpdetail">'+result[i]['Name']+(result[i]['Email'] != undefined ? ' , '+result[i]['Email']:'')+'</span></a>';
            }
            jQuery(".next").show();
        }
        else
        {
            options +=  '<a  class="list-group-item" style="color:red;font-weight: bold;font-size: 1.1em;">No '+ObjectName+' found</a>';
        }
        
        jQuery(".modal-body").find('.options > .list-group').html(options);
        jQuery(".modal-body").find('.options').show();
    },{escape:false});
});
jQuery(document).on('change','.Libraries, .Documents',function(){
    formLibraryOrDocumentOptions(jQuery(this).val(),jQuery(this).attr('type'));
});
function formAttachments()
{
    attachments = new Object();
    var attachment = Attachments['Attachments']['all'];
    for(var i=0;i<attachment.length;i++)
    {
        attachment[i]['BodyLength'] = parseInt(attachment[i]['BodyLength'] /1024);
        attachments[attachment[i]['Id']] = attachment[i];
    }  
}

function formDocuments()
{
    documents = new Object();
    var document = Attachments['Documents'];
    var options = '<option>--None--</option>';
    for(var key in document)
    {
        var documentObject = new Object();
        var documentsArray = document[key];
        if(documentsArray != null)
        {
            for(var i=0;i<documentsArray.length;i++)
            {
                documentsArray[i]['BodyLength'] = parseInt(documentsArray[i]['BodyLength'] /1024); 
                documentObject[documentsArray[i]['Id']] =documentsArray[i];
            }
        }
        options += '<option value="'+key.substring(0,18)+'">'+key.substring(18,key.length)+'</option>';
        documents[key.substring(0,18)] = documentObject;
    }
    jQuery('.Documents').html(options);
}
function formLibraries()
{
    libraries = new Object();
    var library = Attachments['Libraries'];
    var options = '<option>--None--</option>';
    for(var key in library)
    {
        var libraryObject = new Object();
        var libraryArray = library[key];
        if(libraryArray != null)
        {
            for(var i=0;i<libraryArray.length;i++)
            {
                libraryArray[i]['ContentSize'] = parseInt(libraryArray[i]['ContentSize'] /1024); 
                libraryObject[libraryArray[i]['Id']] = libraryArray[i];
            }
        }
        options += '<option value="'+key.substring(0,18)+'">'+key.substring(18,key.length)+'</option>';
        libraries[key.substring(0,18)] = libraryObject;
    }
    jQuery('.Libraries').html(options);
}
function formFeedAttachments()
{
    feedattachments = new Object();
    var feed = Attachments['Feed Attachments']['all'];
    for(var i=0;i<feed.length;i++)
    {
        feed[i]['ContentSize'] = parseInt(feed[i]['ContentSize'] /1024);
        feedattachments[feed[i]['Id']] = feed[i];
    }
    
}
function formAttachmentOrFeedsOptions(type)
{
    var options = '';
    var attachmentList  = type=='Attachments'?attachments:feedattachments;
    var key = type=='Attachments'?'Name':'Title';
    if(!jQuery.isEmptyObject(attachmentList))
    {
        jQuery.each(attachmentList,function(mapKey,value)
                    { 
                        if(selectedAttachmentIds.indexOf(mapKey+',')<0)
                        {
                            options +=  '<a  class="list-group-item"><input type="checkbox" class="docOptions" id="'+mapKey+'"  doctype="'+type+'" style="margin-right:2%;"/>'+value[key]+'</a>';
                        }
                        else
                        {
                            var Id = '#'+mapKey+'size';
                            var size =  (selectedOption == 'Feed Attachments' || selectedOption == 'Libraries' ? 'ContentSize':'BodyLength');
                            jQuery(Id).html(value[size]);
                        }
                    });
    } 
    else
    {
        options = '<a  class="list-group-item" style="color:red;font-weight: bold;font-size: 1.1em;">No Attachments found</a>';
    }
    if(options=='')
    {
        options = '<a  class="list-group-item" style="color:red;font-weight: bold;font-size: 1.1em;">All Attachments are already added</a>';
    }
    jQuery(".modal-body").find('.options > .list-group').html(options);
    jQuery(".modal-body").find('.options').show();
}
function formLibraryOrDocumentOptions(selectedValue,type)
{
    if(selectedValue=='--None--')
    {
        jQuery(".modal-body").find('.options > .list-group').html('');
        jQuery(".modal-body").find('.options').hide();
    }
    else
    {
        var document= (type=='Libraries'?libraries[selectedValue]:documents[selectedValue]);
        var key = (type=='Libraries'?'Title':'Name');
        var options = '';
        if(!jQuery.isEmptyObject(document))
        {
            for(var keyId in document)
            {
                if(selectedAttachmentIds.indexOf(document[keyId]['Id']+',')<0)
                {
                    options +=  '<a  class="list-group-item"><input type="checkbox" class="docOptions" id="'+document[keyId]['Id']+'" parentId="'+selectedValue+'" doctype="'+type+'" style="margin-right:2%;"/>'+document[keyId][key]+'</a>';
                }
                else
                {
                    var Id = '#'+document[keyId]['Id']+'size';
                    var size =  (selectedOption == 'Feed Attachments' || selectedOption == 'Libraries' ? 'ContentSize':'BodyLength');
                    jQuery(Id).html(document[keyId][size]);
                }
            }
        } 
        else
        {
            options = '<a  class="list-group-item" style="color:red;font-weight: bold;font-size: 1.1em;">No Documents in this '+type+'</a>';
        }
        if(options=='')
        {
            options = '<a  class="list-group-item" style="color:red;font-weight: bold;font-size: 1.1em;">Documents already added from this '+type+'</a>';
        }
        jQuery(".modal-body").find('.options > .list-group').html(options);
        jQuery(".modal-body").find('.options').show();
    }
}
function viewPopup(element)
{
    jQuery('.modal-body').find('input').val('');
    jQuery('.saveRcp').hide();
    jQuery('.modal-body').find('#RcpForm').find('select').val('--None--');
    jQuery('.modal-body').find('#RcpForm').find('textarea').val('');
    jQuery('#signer').val('Carbon Copy');
    jQuery('.modal-body').find('input').val('');
    selectedOption = jQuery(element).find('a').html().trim();
    selectedOption = (selectedOption=='Quick Add'?'Add Recipient':selectedOption);
    jQuery(".modal-header > .modal-title").html(selectedOption);
    jQuery('#signerDependent').hide();
    jQuery(".modal-body").find('.options > .list-group').html('');
    jQuery(".modal-body").find('.options').hide();
    jQuery('#RcpForm').hide();
    jQuery('#newContact').hide();
    jQuery('.has-error').removeClass('has-error');
    if(jQuery(element).hasClass('attachment-option'))
    {
        jQuery('.recipient-control').hide();
        jQuery('.attachment-control').show();
        jQuery(".modal-body").find('.Libraries').hide();
        jQuery(".modal-body").find('.Documents').hide();
        jQuery(".add").show();
        if(selectedOption == 'Attachments')
        {
            jQuery('.addAttachment').show();
            var returnUrl = encodeURI('https://adpdealerservices--docusign--c.cs40.visual.force.com/apex/Docusign_EditEnvelope_Custom1?id='+dealId);
            jQuery('#addAttachment').attr('href','https://adpdealerservices--docusign.cs40.my.salesforce.com/p/attach/NoteAttach?pid='+dealId+'&retURL='+returnUrl);
            jQuery('#addAttachment').attr('target','_self');
            formAttachmentOrFeedsOptions('Attachments');
        }
        else if(selectedOption == 'Libraries')
        {
            jQuery('.addAttachment').hide();
            jQuery(".modal-body").find('.Libraries').val('--None--');
            jQuery(".modal-body").find('.Libraries').show();
        }
            else if(selectedOption == 'Documents')
            {
                jQuery('.addAttachment').show();
                jQuery('#addAttachment').attr('href','https://adpdealerservices--docusign.cs40.my.salesforce.com/p/doc/DocumentUploadUi');
                jQuery('#addAttachment').attr('target','_blank');
                jQuery(".modal-body").find('.Documents').val('--None--');
                jQuery(".modal-body").find('.Documents').show();
            }
                else if(selectedOption == 'Feed Attachments')
                {
                    jQuery('.addAttachment').hide();
                    formAttachmentOrFeedsOptions('Feed Attachments');
                }
                    else
                    {
                        jQuery('.addAttachment').hide();
                    }
        jQuery(".modal-body").find(selectedOption).show();
    }
    else if(jQuery(element).hasClass('recipient-option'))
    {
        jQuery('.attachment-control').hide();
        jQuery('.recipient-control').show();
        jQuery('.newContact').hide();
        jQuery('.add').hide();
        jQuery('#rcpName').removeAttr('disabled');
        jQuery('#rcpEmail').removeAttr('disabled');
        if(selectedOption == 'Users' || selectedOption == 'Leads')
        {
            jQuery('.searchbar').show();
        }
        else if(selectedOption == 'Contacts' )
        {
            jQuery('.newContact').show();
        }
            else if(selectedOption == 'Add Me' )
            {
                jQuery('.searchbar').hide();
                jQuery('.quickAdd').show();
                jQuery('#RcpForm').show();
                jQuery('.add').show();
                setCurrnetUserAsRcp();
            }
                else if(selectedOption == 'Add Recipient' )
                {
                    jQuery('.searchbar').hide();
                    jQuery('.quickAdd').show();
                    jQuery('#RcpForm').show();
                    jQuery('.add').show();
                }
        
    }
    
    jQuery(".modal-body").find('#searchString').val('');
    jQuery(".progress").hide();
    jQuery(".next").hide();
    jQuery("#popup").modal('show');
}
var warningInterval = setInterval(function(){ warning() }, 300000);
function SaveCurrentState()
{
    jQuery('.alert').hide();
    var newAttachmentList = new Array();
    clearInterval(warningInterval);
    var IdOrder = new Object();
    jQuery('.newAttachment').each(function(){
        var doctype = jQuery(this).attr('doctype');
        var parentid = jQuery(this).attr('parentid');
        var id = jQuery(this).attr('id');
        jQuery(this).removeClass('newAttachment');
        var attachmentObject;
        if(doctype == 'Attachments' || doctype == 'Feed Attachments')
        {
            attachmentObject= Attachments[doctype]['all'];
        }
        else if(doctype == 'Libraries')
        {
            attachmentObject= libraries[parentid];
        }
            else if(doctype == 'Documents')
            {
                attachmentObject= documents[parentid];
            }
        for(var key in attachmentObject)
        {
            if(attachmentObject[key]['Id'] == id)
            {
                IdOrder[id] = jQuery(this).parents('table').find('.docOrder').html();
                newAttachmentList.push(attachmentObject[key]);
            }
        }
    });
    var json  = JSON.stringify(newAttachmentList);
    jQuery('.attachedList').find('.fa-times').each(function(){
        IdOrder[jQuery(this).attr('Id')] = jQuery(this).parents('table').find('.docOrder').html();
    });
    
    if(deletedAttachments!=',')
    {
        Docusign_EditEnvelope_CustomController.deleteAttachments(runningObjectId,deletedAttachments.split(','),function(){
            
        });
    }
    if(newAttachmentList.length > 0)
    {
        Docusign_EditEnvelope_CustomController.addAttachments(runningObjectId,json,JSON.stringify(IdOrder),function(result)
                                                              {
                                                                  result = JSON.parse(result);
                                                                  jQuery.each(result,function(key,val)
                                                                              {
                                                                                  var elementId = '#'+key;
                                                                                  jQuery(elementId).attr('docId',val);
                                                                              });
                                                              },{escape:false}); 
    }
    
    var rcpList = new Object();
    jQuery.each(newRcpsList,function(key,value){
        if(value!=null)
        {
            value['dsfs__DocuSign_EnvelopeID__c'] = runningObjectId;
            rcpList[key] = value;
        }
    });
    
    if(!jQuery.isEmptyObject(rcpList))
    {
        Docusign_EditEnvelope_CustomController.addRecipients(JSON.stringify(rcpList),function(result){
            newRcpsList = new Object();
            result = JSON.parse(result);
            jQuery.each(result,function(key,value){
                key = '#'+key;
                jQuery(key).attr('id', value['Id']);
                key = key.replace('#','');
                key = '[rcpid='+key+']';
                jQuery(key).attr('rcpid', value['Id']);
            });
            var rcpOrderMap = new Object();
            jQuery('input[class="rcpOrder"]').each(function(){
                rcpOrderMap[jQuery(this).parents('table').attr('id')] = jQuery(this).val();
            });
            Docusign_EditEnvelope_CustomController.saveRcpOrder(JSON.stringify(rcpOrderMap),function(result){
            });
        },{escape:false});
    }
    else
    {
        var rcpOrderMap = new Object();
        jQuery('input[class="rcpOrder"]').each(function(){
            rcpOrderMap[jQuery(this).parents('table').attr('id')] = jQuery(this).val();
        });
        Docusign_EditEnvelope_CustomController.saveRcpOrder(JSON.stringify(rcpOrderMap),function(result){
        });
    }
    
    if(deleteRcpList!='')
    {
        Docusign_EditEnvelope_CustomController.deleteRecipient(deleteRcpList,function(result){});
    }
    Docusign_EditEnvelope_CustomController.updateAttachments(runningObjectId,JSON.stringify(IdOrder),function(){
        
    });
    jQuery('.alert').removeClass('alert-warning').removeClass('alert-info').removeClass('alert-danger').addClass('alert-success');
    jQuery('.alert').find('.fa').removeClass('fa-times-circle').removeClass('fa-info-circle').removeClass('fa-exclamation-circle').addClass('fa-check-circle-o');
    jQuery('.alert').find('span').html('<strong>Success!</strong>  Saved Succesfully');
    jQuery('.alert').show();
    warningInterval = setInterval(function(){ warning() }, 300000);
}
function warning()
{
    jQuery('.alert').removeClass('alert-success').removeClass('alert-info').removeClass('alert-danger').addClass('alert-warning');
    jQuery('.alert').find('.fa').removeClass('fa-times-circle').removeClass('fa-info-circle').removeClass('fa-check-circle-o').addClass('fa-exclamation-circle');
    jQuery('.alert').find('span').html('<strong>Warning!</strong>  Its been too long you have saved, Please Click save button');
    jQuery('.alert').show();
}