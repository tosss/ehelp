({
    //Salesforce Attachment Body supports only Base64 File Type.
    //1,000,000 * 3/4 to account for base64.
    MAX_FILE_SIZE: 750000,
    initializeComponent: function(component, event, helper)
    {
        if(typeof jQuery!=='undefined' && typeof j$==='undefined')
        {
            j$=jQuery.noConflict(true);
        }
        
        j$('#ideasSpinnerDiv').modal('show');
        
        helper.fetchIdeaRecordsList(component, event, helper);
    },
    fetchIdeaRecordsList: function(component, event, helper)
    {
        var communityNameVal=component.get("v.ideasZone");
        
        var action=component.get('c.fetchIdeaRecordsList');
        action.setParams({
            "communityName": communityNameVal
        });
        
        action.setCallback(this, function(response)
        {
            if(component.isValid() && response.getState()==='SUCCESS')
            {
                component.set('v.ideasList', response.getReturnValue());
                helper.initializeTimeAgo(component);
                helper.initializeIsotope(component, 'freshFilterInput');
                helper.alignNumComments(component);
                helper.initializeVoteChart(component);
                helper.bindModalEvents(component, helper);
                helper.bindInputEvents(component);
            }
            else
            {
                component.set('v.ideasList', null);
            }
        });
        
        $A.enqueueAction(action);
        
        helper.fetchCurrentUserImgUrl(component, event, helper);
    },
    fetchCurrentUserImgUrl: function(component, event, helper)
    {
        var currentUserImgElement=j$('.currentUserImg');
        if(currentUserImgElement.val()==undefined || currentUserImgElement.val()=='' || currentUserImgElement.val()==null)
        {
            var action=component.get('c.fetchCurrentUserProfilePhotoUrl');
            
            action.setCallback(this, function(response)
            {
                if(component.isValid() && response.getState()==='SUCCESS')
                {
                    var currentUserImgSrc=response.getReturnValue();
                    j$('.currentUserImg').prop('value', currentUserImgSrc);
                    j$('.newCommentUserImgDiv').find('img').prop('src', currentUserImgSrc);
                    j$('#ideasSpinnerDiv').modal('hide');
                }
            });
            
            $A.enqueueAction(action);
        }
    },
    openIdeaDetail: function(component, event, helper)
    {
        j$('#ideasSpinnerDiv').modal('show');
        
        var selectedIdeaId=j$(event.target).closest('.ideaCard').find('.ideaId').val();
        j$('.currentIdeaId').prop('value', selectedIdeaId);
        
        var action=component.get('c.fetchIdeaRecordDetail');
        action.setParams({
            'selectedIdeaId': selectedIdeaId
        });
        
        action.setCallback(this, function(response)
        {
            if(component.isValid() && response.getState()==='SUCCESS')
            {
                var fetchedIdeaDetails=response.getReturnValue();
                component.set("v.selectedIdea", fetchedIdeaDetails);
                component.set("v.ideaCommentsList", fetchedIdeaDetails.Comments);
                
                var ideaDetailModalDialog=j$('#ideaDetailModalDialog');
                helper.highlightIdeaVoteElement(component, event, helper, fetchedIdeaDetails, ideaDetailModalDialog);
                helper.processIdeaDetailComments(component, fetchedIdeaDetails, ideaDetailModalDialog);
                helper.initializeTimeAgo(component);
                
                ideaDetailModalDialog.modal('toggle');
                j$('#ideasSpinnerDiv').modal('hide');
            }
        });
        
        $A.enqueueAction(action);
    },
    highlightIdeaVoteElement: function(component, event, helper, fetchedIdeaDetails, ideaDetailModalDialog)
    {
        if(fetchedIdeaDetails.Votes!=null && fetchedIdeaDetails.Votes!=undefined && fetchedIdeaDetails.Votes!=''
           && fetchedIdeaDetails.Votes.length>0)
        {
            var ideaVotedType=fetchedIdeaDetails.Votes[0].Type;
            if(ideaVotedType.toLowerCase()=='up')
            {
                ideaDetailModalDialog.find('.voteUpIcon').addClass('highlightUpVote');
                ideaDetailModalDialog.find('.voteDownIcon').removeClass('highlightDownVote');
            }
            else
            {
                ideaDetailModalDialog.find('.voteUpIcon').removeClass('highlightUpVote');
                ideaDetailModalDialog.find('.voteDownIcon').addClass('highlightDownVote');
            }
        }
        else
        {
            ideaDetailModalDialog.find('.voteUpIcon').removeClass('highlightUpVote');
            ideaDetailModalDialog.find('.voteDownIcon').removeClass('highlightDownVote');
        }
    },
    processIdeaDetailComments: function(component, fetchedIdeaDetails, ideaDetailModalDialog)
    {
        if(fetchedIdeaDetails.Comments!=null && fetchedIdeaDetails.Comments!=undefined && fetchedIdeaDetails.Comments.length>0)
        {
            ideaDetailModalDialog.find('.modal-body').removeClass('noModalBodyPadding');
            ideaDetailModalDialog.find('.modal-body').addClass('modifiedModalBodyPadding');
        }
        else
        {
            ideaDetailModalDialog.find('.modal-body').removeClass('modifiedModalBodyPadding');
            ideaDetailModalDialog.find('.modal-body').addClass('noModalBodyPadding');
        }
    },
    submitVote: function(component, event, helper, voteType)
    {
        j$('#ideasSpinnerDiv').modal('show');
        
        var communityNameVal=component.get("v.ideasZone");
        var ideaDetailModalDialog=j$('.ideaDetailModalDialog');
        var ideaVoteDiv=ideaDetailModalDialog.find('.ideaVoteDiv');
        
        if(ideaVoteDiv.find('.highlightUpVote').length==0 && ideaVoteDiv.find('.highlightDownVote').length==0)
        {
            var selectedIdeaId=j$('.currentIdeaId').val();
            
            var action=component.get("c.createVote");
            action.setParams({
                "ideaId": selectedIdeaId,
                "voteType": voteType,
                "communityName": communityNameVal
            });
            
            action.setCallback(this, function(response)
            {
                if(component.isValid() && response.getState()==="SUCCESS")
                {
                    var responseRef=response.getReturnValue();
                    
                    if(responseRef.errorMessage=="")
                    {
                        var ideaVoteCountNumberEl=ideaVoteDiv.find('.ideaVoteCountNumber');
                        var ideaVoteCountNumberVal=parseInt(ideaVoteCountNumberEl.prop('innerText'));
                        
                        if(voteType=='up')
                        {
                            ideaVoteCountNumberEl.prop('innerText', (ideaVoteCountNumberVal+10));
                            ideaDetailModalDialog.find('.voteUpIcon').addClass('highlightUpVote');
                            ideaDetailModalDialog.find('.voteDownIcon').removeClass('highlightDownVote');
                        }
                        else
                        {
                            ideaVoteCountNumberEl.prop('innerText', (ideaVoteCountNumberVal-10));
                            ideaDetailModalDialog.find('.voteUpIcon').removeClass('highlightUpVote');
                            ideaDetailModalDialog.find('.voteDownIcon').addClass('highlightDownVote');
                        }
                        
                        /*j$('.ideaCard').each(function()
						{
                            var ideaCardEl=j$(this);
                            var ideaId=ideaCardEl.find('.ideaId').val();
                            
                            if(ideaId==selectedIdeaId)
                            {
                                ideaCardEl.find('.voteTotalFilterInput').prop('value', ideaVoteCountNumberEl.prop('innerText'));
                            }
                        });*/
                        component.set('v.ideasList', responseRef.ideasList);
                        helper.initializeTimeAgo(component);
                        helper.alignNumComments(component);
                        helper.initializeVoteChart(component);
                        
                        j$('.ideasListDiv').isotope('destroy');
                        var selectedFilterValue=j$('.filterButtonsUl').find('.active').find('a').data('sortValue');
                        helper.initializeIsotope(component, selectedFilterValue);
                        
                        helper.showUserMessage(component, ideaVoteDiv, 'success', 'You have successfully voted for this Idea!');
                        j$('#ideasSpinnerDiv').modal('hide');
                    }
                    else
                    {
                        helper.showUserMessage(component, ideaVoteDiv, 'error', 'Some error occured. Please contact System Adminstrator.');
                        j$('#ideasSpinnerDiv').modal('hide');
                    }
                }
                else
                {
                    if(response.error[0].message=='Disconnected or Canceled')
                    {
                        helper.showUserMessage(component, ideaVoteDiv, 'error', 'Network Interrupted or Disconnected. Please try again once network connection is established.');
                    }
                    else
                    {
                        helper.showUserMessage(component, ideaVoteDiv, 'error', 'Some error occured. Please contact System Adminstrator.');
                    }
                    j$('#ideasSpinnerDiv').modal('hide');
                }
            });
            
            $A.enqueueAction(action);
        }
        else
        {
            helper.showUserMessage(component, ideaVoteDiv, 'info', 'Sorry, you have already voted for this Idea.');
            j$('#ideasSpinnerDiv').modal('hide');
        }
    },
    saveIdeaComment: function(component, event, helper)
    {
        j$('#ideasSpinnerDiv').modal('show');
        
        var selectedIdeaId=j$('.currentIdeaId').val();
        var ideaDesc=component.get("v.newIdeaComment.CommentBody");
        
        var ideaDetailModalDialog=j$('.ideaDetailModalDialog');
        var newCommentDescParent=ideaDetailModalDialog.find('.newCommentDesc');
        
        if(ideaDesc!=null && ideaDesc!='' && ideaDesc!=undefined)
        {
            var action=component.get("c.saveIdeaComment");
            action.setParams({
                "selectedIdeaId": selectedIdeaId,
                "newIdeaComment": ideaDesc
            });
            
            action.setCallback(this, function(response)
            {
                if(component.isValid() && response.getState()==="SUCCESS")
                {
                    if(response.getReturnValue().errorMessage=="")
                    {
                        //Reset the newIdeaComment CommentBody field on the form.
                        component.set("v.newIdeaComment.CommentBody", "");
                        
                        var ideaCommentsList=response.getReturnValue().ideaCommentsList;
                        component.set("v.ideaCommentsList", ideaCommentsList);
                        
                        if(ideaCommentsList.length>0)
                        {
                            ideaDetailModalDialog.find('.modal-body').addClass('modifiedModalBodyPadding');
                            ideaDetailModalDialog.find('.modal-body').removeClass('noModalBodyPadding');
                            
                            j$('.ideaCard').each(function()
                            {
                                var ideaCardEl=j$(this);
                                var ideaId=ideaCardEl.find('.ideaId').val();
                                
                                if(ideaId==selectedIdeaId)
                                {
                                    ideaCardEl.find('.commentsFilterInput').prop('value', ideaCommentsList.length);
                                }
                            });
                        }
                        
                        helper.initializeTimeAgo(component);
                        helper.processInputTitles(component, ideaDetailModalDialog);
                        
                        var modalToBeHiddenTime=(ideaCommentsList.length+1)*100;
                        setTimeout(function()
						{
                            //Scroll to bottom to show the added row.
                            ideaDetailModalDialog.find('.modal-body').scrollTop(ideaDetailModalDialog.find('.modal-body').get(0).scrollHeight);
                            
                            helper.showUserMessage(component, newCommentDescParent, 'success', 'Idea comment successfully saved!');
                            
                            j$('.ideasListDiv').isotope('destroy');
                            var selectedFilterValue=j$('.filterButtonsUl').find('.active').find('.filterbutton').data('sortValue');
                            helper.initializeIsotope(component, selectedFilterValue);
                            
                            j$('#ideasSpinnerDiv').modal('hide');
                        }, modalToBeHiddenTime);
                    }
                    else
                    {
                        helper.showUserMessage(component, newCommentDescParent, 'error', 'Some error occured. Please contact System Adminstrator.');
                        j$('#ideasSpinnerDiv').modal('hide');
                    }
                }
                else
                {
                    if(response.error[0].message=='Disconnected or Canceled')
                    {
                        helper.showUserMessage(component, newCommentDescParent, 'error', 'Network Interrupted or Disconnected. Please try again once network connection is established.');
                    }
                    else
                    {
                        helper.showUserMessage(component, newCommentDescParent, 'error', 'Some error occured. Please contact System Adminstrator.');
                    }
                    j$('#ideasSpinnerDiv').modal('hide');
                }
            });
            
            $A.enqueueAction(action);
        }
        else
        {
            helper.showUserMessage(component, newCommentDescParent, 'error', 'Please enter a valid value.');
            j$('#ideasSpinnerDiv').modal('hide');
        }
    },
    saveIdea: function(component, event, helper)
    {
        j$('#ideasSpinnerDiv').modal('show');
        
        var newIdea=component.get("v.newIdea");
        if(newIdea.Title!=null && newIdea.Title!=undefined && newIdea.Title!='')
        {
            helper.processFile(component, helper, newIdea);
        }
        else
        {
            var newIdeaTitleDiv=j$('.newIdeaTitle').closest('.inputDiv');
            helper.showUserMessage(component, newIdeaTitleDiv, 'error', 'This is a required field.');
            j$('#ideasSpinnerDiv').modal('hide');
        }
    },
    processFile: function(component, helper, newIdea)
    {
        var inputFileEl=component.find('file').getElement();
    	var inputFile=inputFileEl.files[0];
        
        if(inputFile!=undefined)
        {
            //If file has to be uploaded.
            var inputFileSize=inputFile.size;
            
            if(inputFileSize<this.MAX_FILE_SIZE)
            {
                if(j$('.messageTextDiv').length>0)
                {
                    j$('.messageTextDiv').remove();
                }
                
                var fileReaderRef=new FileReader();
                fileReaderRef.onload=function()
                {
                    var fileContents=fileReaderRef.result;
                    var base64Mark='base64,';
                    var dataStart=fileContents.indexOf(base64Mark)+base64Mark.length;
                    fileContents=fileContents.substring(dataStart);
                    
                    helper.executeIdeaSave(component, helper, newIdea, inputFile, fileContents);
                };
                fileReaderRef.readAsDataURL(inputFile);
            }
            else
            {
                var ideaFileDivEl=j$('.createIdeaModal').find('.ideaFileDiv');
                helper.showUserMessage(component, ideaFileDivEl, 'error', ('File size cannot exceed '+this.MAX_FILE_SIZE+' bytes. Selected file size: '+inputFileSize));
                j$('#ideasSpinnerDiv').modal('hide');
            }
        }
        else
        {
            //If no file has to be uploaded.
            if(j$('.messageTextDiv').length>0)
            {
                j$('.messageTextDiv').remove();
            }
            
            helper.executeIdeaSave(component, helper, newIdea, '', '');
        }
    },
    executeIdeaSave: function(component, helper, newIdea, inputFile, fileContents)
    {
        var communityNameVal=component.get("v.ideasZone");
        var createIdeaModalEl=j$('#createIdeaModal');
        var createIdeaErrorDiv=createIdeaModalEl.find('.modal-header');
        
        var inputFileName='';
        var inputFileType='';
        if(inputFile!='')
        {
            inputFileName=inputFile.name;
            inputFileType=inputFile.type;
        }
        
        var modifiedFileContent='';
        if(fileContents!='')
        {
            modifiedFileContent=encodeURIComponent(fileContents);
        }
        
        var action=component.get("c.createIdea");
        action.setParams({
            "newIdea": newIdea,
            "communityName": communityNameVal,
            "fileName": inputFileName,
            "base64Data": modifiedFileContent, 
            "contentType": inputFileType
        });
        
        action.setCallback(this, function(response)
        {
            if(component.isValid() && response.getState()==="SUCCESS")
            {
                if(response.getReturnValue().errorMessage=="")
                {
                    component.set("v.ideasList", response.getReturnValue().ideasList);
                    
                    //Reset the newIdea on the form.
                    component.set("v.newIdea.Title", "");
                    component.set("v.newIdea.Body", "");
                    
                    helper.showUserMessage(component, createIdeaErrorDiv, 'success', 'Idea successfully saved!');
                    helper.initializeTimeAgo(component);
                    helper.alignNumComments(component);
                    helper.initializeVoteChart(component);
                    helper.processInputTitles(component, createIdeaModalEl);
                    
                    j$('.ideasListDiv').isotope('destroy');
                    var selectedFilterValue=j$('.filterButtonsUl').find('.active').find('.filterbutton').data('sortValue');
                    helper.initializeIsotope(component, selectedFilterValue);
                    
                    j$('#ideasSpinnerDiv').modal('hide');
                    createIdeaModalEl.modal('hide');
                }
                else
                {
                    helper.showUserMessage(component, createIdeaErrorDiv, 'error', 'Some error occured. Please contact System Adminstrator.');
                    j$('#ideasSpinnerDiv').modal('hide');
                }
            }
            else
            {
                if(response.error[0].message=='Disconnected or Canceled')
                {
                    helper.showUserMessage(component, createIdeaErrorDiv, 'error', 'Network Interrupted or Disconnected. Please try again once network connection is established.');
                }
                else
                {
                    helper.showUserMessage(component, createIdeaErrorDiv, 'error', 'Some error occured. Please contact System Adminstrator.');
                }
                j$('#ideasSpinnerDiv').modal('hide');
            }
        });
        
        $A.run(function()
        {
            $A.enqueueAction(action); 
        });
    },
    showUserMessage: function(component, msgTextParentDiv, msgScenario, messageText)
    {
        if(j$('.messageTextDiv').length>0)
        {
            j$('.messageTextDiv').remove();
        }
        
        if(msgScenario=='success')
        {
            j$(msgTextParentDiv).append('<div class="alert alert-success messageTextDiv">'+messageText+'</div>');
        }
        else if(msgScenario=='info')
        {
            j$(msgTextParentDiv).append('<div class="alert alert-info messageTextDiv">'+messageText+'</div>');
        }
        else
        {
            j$(msgTextParentDiv).append('<div class="alert alert-danger messageTextDiv">'+messageText+'</div>');
        }
    },
    initializeTimeAgo: function(component)
    {
        setTimeout(function()
		{
            j$('.timeago').timeago();
            
            j$('.timeago').each(function()
			{
                var createdDateEl=j$(this);
                
                var dateDivEl=createdDateEl.closest('.dateDiv');
                var createdDateVal=dateDivEl.find('.createdDate').prop('innerText');
                var dateDivTitleVal='Created on '+createdDateVal+'\n - '+createdDateEl.prop('innerText');
                
                createdDateEl.removeAttr('title');
                dateDivEl.prop('title', dateDivTitleVal);
            });
        }, 10);
    },
    initializeIsotope: function(component, sortByValue)
    {
        if(sortByValue=='')
        {
            sortByValue='freshFilterInput';
        }
        
        setTimeout(function()
		{
            var deviceImageUl=j$('.ideasListDiv').isotope({
                itemSelector: '.ideaCard',
                layoutMode: 'fitRows',
                sortAscending: false,
                sortBy: sortByValue,
                getSortData: 
                {
                    freshFilterInput: function(itemElem)
                    {
                        var freshFilterInputVal=j$(itemElem).find('.freshFilterInput').val();
                        return Date.parse(freshFilterInputVal);
                    },
                    trendingFilterInput: function(itemElem)
                    {
                        var trendingFilterInputVal=j$(itemElem).find('.trendingFilterInput').val();
                        return parseFloat(trendingFilterInputVal.replace(/[\(\)]/g, ''));
                    },
                    commentsFilterInput: function(itemElem)
                    {
                        var commentsFilterInputVal=j$(itemElem).find('.commentsFilterInput').val();
                        return parseFloat(commentsFilterInputVal.replace(/[\(\)]/g, ''));
                    },
                    voteTotalFilterInput: function(itemElem)
                    {
                        var voteTotalFilterInputVal=j$(itemElem).find('.voteTotalFilterInput').val();
                        return parseFloat(voteTotalFilterInputVal.replace(/[\(\)]/g, ''));
                    }
                }
            });
            
            //Bind sort button click.
            j$('.filterbutton').on('click', function()
			{
                var thisFilterBtn=j$(this);
                
                //Highlight Selected Button.
                thisFilterBtn.closest('.filterButtonsUl').find('.active').removeClass('active');
                thisFilterBtn.closest('li').addClass('active');
                
                var sortValue=thisFilterBtn.attr('data-sort-value');
                deviceImageUl.isotope({sortBy: sortValue});
            });
        }, 10);
    },
    alignNumComments: function(component)
    {
        setTimeout(function()
		{
            var ideaNoCommentsDivEls=j$('.ideaNoCommentsDiv');
            
            ideaNoCommentsDivEls.each(function()
			{
                var thisIdeaNoCommentsDiv=j$(this);
                var cardDetailsHeight=thisIdeaNoCommentsDiv.closest('.cardDetails').prop('offsetHeight');
                var thisIdeaNoCommentsDivHeight=thisIdeaNoCommentsDiv.prop('offsetHeight');
                cardDetailsHeight=(cardDetailsHeight-20-thisIdeaNoCommentsDivHeight)/2;
                thisIdeaNoCommentsDiv.css({'padding-top': cardDetailsHeight});
            });
        }, 10);
    },
    initializeVoteChart: function(component)
    {
        setTimeout(function()
        {
            var maxVote=null;
            
            j$('div.progress-bar').each(function()
            {
                var ideavotescore=j$(this).data('ideavotescore');
                
                if((maxVote===null) || (ideavotescore>maxVote))
                {
                    maxVote=ideavotescore;
                }
            });
            
            j$('div.progress-bar').each(function()
            {
                var actualScore=j$(this).attr('aria-valuenow');
                var calculateScore=actualScore/maxVote;
                calculateScore=calculateScore*100;
                
                j$(this).attr('aria-valuemax', maxVote);
                j$(this).css('width', calculateScore+'%').attr('aria-valuenow', actualScore);
            });
        }, 500);
    },
    bindModalEvents: function(component, helper)
    {
        j$("#ideaDetailModalDialog").on('hide.bs.modal', function()
		{
            var thisModalEl=j$(this);
            component.set('v.newIdeaComment.CommentBody', '');
            
            //Scroll top of modal body.
            thisModalEl.find('.modal-body').scrollTop(0);
            
            helper.processInputTitles(component, j$(this));
            
            if(j$('.messageTextDiv').length>0)
            {
                j$('.messageTextDiv').remove();
            }
            
            //Add new Comment Number.
            var ideaCommentsTable=thisModalEl.find('.ideaCommentsTable');
            if(ideaCommentsTable.length>0)
            {
                var noOfComments=ideaCommentsTable.find('tr').length;
                
                if(noOfComments>0)
                {
                    var currentIdeaId=j$('.currentIdeaId').val();
                    
                    j$('.ideaCard').each(function()
					{
                        var thisIdea=j$(this);
                        var thisIdeaId=thisIdea.find('.ideaId').val();
                        
                        if(currentIdeaId==thisIdeaId)
                        {
                            var ideaNoCommentsSpan=thisIdea.find('.ideaNoCommentsSpan');
                            if(ideaNoCommentsSpan.length>0)
                            {
                                ideaNoCommentsSpan.prop('innerText', noOfComments);
                            }
                            else
                            {
                                var newNumCommentsDiv='<div class="ideaNoCommentsDiv">'
                                +'<span class="ideaNoCommentsArrow"></span>'
                                +'<span class="ideaNoCommentsSpan">'+noOfComments+'</span>'
                                +'</div>';
                                
                                thisIdea.find('.cardDetails').prepend(newNumCommentsDiv);
                                
                                newNumCommentsDiv=thisIdea.find('.ideaNoCommentsDiv');
                                var cardDetailsHeight=newNumCommentsDiv.closest('.cardDetails').prop('offsetHeight');
                                var newNumCommentsDivHeight=newNumCommentsDiv.prop('offsetHeight');
                                cardDetailsHeight=(cardDetailsHeight-20-newNumCommentsDivHeight)/2;
                                newNumCommentsDiv.css({'padding-top': cardDetailsHeight});
                            }
                        }
                    });
                }
            }
        });
        
        j$("#createIdeaModal").on('hide.bs.modal', function()
		{
            helper.processInputTitles(component, j$(this));
            
            if(j$('.messageTextDiv').length>0)
            {
                j$('.messageTextDiv').remove();
            }
        });
    },
    bindInputEvents: function(component)
    {
        setTimeout(function()
		{
            var inputElements=j$('.form-control');
            
            inputElements.on('focus', function()
			{
                var thisElement=j$(this);
                var parentDiv=thisElement.closest('.inputDiv');
                
                var inputTitleVal=thisElement.prop('placeholder');
                thisElement.removeAttr('placeholder');
                
                if(parentDiv.find('.inputTitle').length==0)
                {
                    parentDiv.prepend('<div class="inputTitle">'+inputTitleVal+'</div>');
                }
                
                if(j$('.messageTextDiv').length>0)
                {
                    j$('.messageTextDiv').remove();
                }
            });
            
            inputElements.on('blur', function()
			{
                var thisElement=j$(this);
                var thisElementVal=thisElement.val();
                
                if(thisElementVal==null || thisElementVal=='' || thisElementVal==undefined)
                {
                    var inputTitle=thisElement.closest('.inputDiv').find('.inputTitle');
                    if(inputTitle.length>0)
                    {
                        var placeholderText=inputTitle.prop('innerText');
                        inputTitle.remove();
                        thisElement.prop('placeholder', placeholderText);
                    }
                }
            });
        }, 10);
    },
    processInputTitles: function(component, thisModal)
    {
        thisModal.find('.form-control').each(function()
		{
            var inputElement=j$(this);
            inputElement.val('');
            var inputTitleEl=inputElement.closest('.inputDiv').find('.inputTitle');
            
            if(inputTitleEl.length>0)
            {
                var placeholderText=inputTitleEl.prop('innerText');
                inputTitleEl.remove();
                inputElement.prop('placeholder', placeholderText);
            }
        });
    }
})