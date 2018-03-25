({
	initializeComponent: function(component, event, helper)
    {
        j$('.editMembershipModal').hide();
        j$('.delMemberModal').hide();
        j$('.grpMembrsSpinnerDiv').show();
        
        helper.fetchGrpMembrsFields(component, helper);
    },
    fetchGrpMembrsFields: function(component, helper)
    {
        var grpMembrMsgTextDiv=j$('.grpMembrMsgTextDiv');
        grpMembrMsgTextDiv.hide();
        
        var grpMembrTableDiv=j$('.grpMembrTableDiv');
        
        var action=component.get('c.fetchGrpMembrsFieldsList');
        action.setCallback(this, function(response)
        {
            var grpMembrsFieldsList=[];
            var msgText='';
            
            if(component.isValid() && response.getState()==='SUCCESS')
            {
                var resultVal=response.getReturnValue();
                if(resultVal.communityUrl!=null)
                {
                    component.set('v.communityUrl', resultVal.communityUrl);
                }
                console.log(resultVal);
                
                grpMembrsFieldsList=resultVal.grpMembrsFieldsList;
                var grpMembrsFieldsListSize=grpMembrsFieldsList.length;
                
                if(grpMembrsFieldsListSize>0)
                {
                    component.set('v.grpMembrsFieldsList', grpMembrsFieldsList);
                    helper.fetchGrpMembrs(component, helper);
                }
                else
                {
                    msgText='There are no fields set for Group Members. Please contact your System Administrator.'
                    helper.showUserMessage(component, 'error', msgText);
                    grpMembrTableDiv.hide();
                    j$('.grpMembrsSpinnerDiv').hide();
                }
            }
            else
            {
                component.set('v.grpMembrsFieldsList', grpMembrsFieldsList);
                msgText='Some error occured while fetching Group Members. Please contact your System Administrator.';
                helper.showUserMessage(component, 'error', msgText);
                grpMembrTableDiv.hide();
                j$('.grpMembrsSpinnerDiv').hide();
            }
        });
        
        $A.enqueueAction(action);
    },
    fetchGrpMembrs :function(component, helper)
    {
    	var groupIdVal=component.get("v.groupId");
        
        var grpMembrMsgTextDiv=j$('.grpMembrMsgTextDiv');
        grpMembrMsgTextDiv.hide();
        
        var grpMembrTableDiv=j$('.grpMembrTableDiv');
        
        var action=component.get('c.fetchGrpMembrsList');
        action.setParams({
            "groupId": groupIdVal
        });
        
        action.setCallback(this, function(response)
        {
            var grpMembrsList=[];
            var msgText='';
            
            if(component.isValid() && response.getState()==='SUCCESS')
            {
                grpMembrsList=response.getReturnValue();
                var grpMembrsListSize=grpMembrsList.length;
                
                if(grpMembrsListSize>0)
                {
                    component.set('v.grpMembrsList', grpMembrsList);
                    
                    var currentDate=new Date(j$.now()); 
                    var currentDatetime=currentDate.getFullYear()+'-'+(currentDate.getMonth()+1)+'-'+currentDate.getDate()+' '
                    +currentDate.getHours()+":"+currentDate.getMinutes()+":"+currentDate.getSeconds();
                    
                    var subHeadingText='';
                    subHeadingText+=(grpMembrsListSize==1) ? '1 item ' : grpMembrsListSize+' items ';
                    subHeadingText+='<i class="fa fa-circle circleIcon" aria-hidden="true"></i>';
                    subHeadingText+=' <span class="sortBySpan"></span>';
                    subHeadingText+=' Last updated <span class="timeago" title="'+currentDatetime+'">'
                    subHeadingText+=currentDatetime+'</span>';
                    j$('.subHeadingText').prop('innerHTML', subHeadingText);
                    grpMembrTableDiv.show();
                    
                    helper.initializeTableSorter(component);
                    helper.initializeTimeAgo(component);
                    
                    j$('.grpMembrsSpinnerDiv').hide();
                }
                else
                {
                    msgText='Sorry, there are no Group Members existing for this Group.'
                    helper.showUserMessage(component, 'error', msgText);
                    grpMembrTableDiv.hide();
                    j$('.grpMembrsSpinnerDiv').hide();
                }
            }
            else
            {
                component.set('v.grpMembrsList', grpMembrsList);
                msgText='Some error occured while fetching Group Members. Please contact your System Administrator.';
                helper.showUserMessage(component, 'error', msgText);
                grpMembrTableDiv.hide();
                j$('.grpMembrsSpinnerDiv').hide();
            }
        });
        
        $A.enqueueAction(action);
    },
    openEditMembershipModal: function(component, event)
    {
        var grpMembrMsgTextDiv=j$('.grpMembrMsgTextDiv');
        grpMembrMsgTextDiv.empty();
        
        var recId=j$(event.target).closest('.grpMembrTr').data('recid');
        var grpMemberIdInput='<input type="hidden" class="grpMemberId" value="'+recId+'">';
        
        var editMembershipModal=j$('.editMembershipModal');
        editMembershipModal.find('.grpMemberId').remove();
        editMembershipModal.find('.slds-modal__content').append(j$(grpMemberIdInput));
        editMembershipModal.show();
    },
    openDeleteMemberModal: function(component, event)
    {
        var grpMembrMsgTextDiv=j$('.grpMembrMsgTextDiv');
        grpMembrMsgTextDiv.empty();
        
        var recId=j$(event.target).closest('.grpMembrTr').data('recid');
        var grpMemberIdInput='<input type="hidden" class="grpMemberId" value="'+recId+'">';
        
        var delMemberModal=j$('.delMemberModal');
        delMemberModal.find('.grpMemberId').remove();
        delMemberModal.find('.slds-modal__content').append(j$(grpMemberIdInput));
        delMemberModal.show();
    },
    changeMembership: function(component, event, helper)
    {
        j$('.editMembershipModal').hide();
        j$('.grpMembrsSpinnerDiv').show();
        
        var newMembershipType=j$(event.target).data('type');
        var grpMemberIdVal=j$(event.target).closest('.slds-modal__container').find('.grpMemberId').val();
        
        var action=component.get('c.saveMembership');
        action.setParams({
            "membershipType": newMembershipType,
            "grpMemberId": grpMemberIdVal
        });
        
        action.setCallback(this, function(response)
        {
            var msgText='';
            if(component.isValid() && response.getState()==='SUCCESS')
            {
                var resultVal=response.getReturnValue();
                if(resultVal=='')
                {
                    helper.initializeComponent(component, event, helper);
                    //j$('.grpMembrsSpinnerDiv').hide();
                }
                else
                {
                    msgText=resultVal;
                    if(msgText.indexOf('You can\'t convert a group owner')>-1)
                    {
                        msgText='You can\'t convert a group owner to a standard group member until you assign a new owner for the group.';
                    }
                    else
                    {
                        msgText='Some error occurred while trying to Save Membership changes. Please contact your System Administrator.';
                    }
                    
                    helper.showUserMessage(component, 'error', msgText);
                    j$('.grpMembrsSpinnerDiv').hide();
                }
            }
            else
            {
                msgText='Some error occurred while trying to Save Membership changes. Please contact your System Administrator.';
                helper.showUserMessage(component, 'error', msgText);
                j$('.grpMembrsSpinnerDiv').hide();
            }
        });
        
        $A.enqueueAction(action);
    },
    deleteGrpMember: function(component, event, helper)
    {
        j$('.delMemberModal').hide();
        j$('.grpMembrsSpinnerDiv').show();
        var grpMemberIdVal=j$(event.target).closest('.slds-modal__container').find('.grpMemberId').val();
        
        var action=component.get('c.deleteMember');
        action.setParams({
            "grpMemberId": grpMemberIdVal
        });
        
        action.setCallback(this, function(response)
        {
            var msgText='';
            if(component.isValid() && response.getState()==='SUCCESS')
            {
                var resultVal=response.getReturnValue();
                if(resultVal=='')
                {
                    helper.initializeComponent(component, event, helper);
                    //j$('.grpMembrsSpinnerDiv').hide();
                }
                else
                {
                    msgText=resultVal;
                    if(msgText.indexOf('You cannot delete the owner')>-1)
                    {
                        msgText='You cannot delete the owner from a group of type collaboration. '
                        +'If you want to remove this owner from the group, transfer ownership to another member first.';
                    }
                    else
                    {
                        msgText='Some error occurred while trying to Delete Member. Please contact your System Administrator.';
                    }
                    helper.showUserMessage(component, 'error', msgText);
                    j$('.grpMembrsSpinnerDiv').hide();
                }
            }
            else
            {
                msgText='Some error occurred while trying to Delete Member. Please contact your System Administrator.';
                helper.showUserMessage(component, 'error', msgText);
                j$('.grpMembrsSpinnerDiv').hide();
            }
        });
        
        $A.enqueueAction(action);
    },
    initializeTableSorter: function(component)
    {
        setTimeout(function()
		{
            var headerArray={};
            
            j$(".grpMembrsTable th").each(function(index, value)
			{
                var colname=j$(value).data('colname');
                if(colname=='SrNo' || colname=='Photo' || colname=='Action')
                {
                    headerArray[index]={sorter: false};
                    if(colname=='Photo')
                    {
                        j$(value).addClass('photoTh');
                    }
                }
            });
            
            j$(".grpMembrsTable").tablesorter({
                headers: headerArray,
                sortMultiSortKey: 'none'
            });
                       
            j$(".grpMembrsTable").bind("sortEnd", function()
			{ 
                var thisTable=j$(this);
                thisTable.find('tbody').find('tr').each(function(index, value)
				{
                    j$(value).find('.srNoTd').prop('innerText', (index+1));
                });
                
                var sortedByColName='';
                thisTable.find('th').each(function(index, value)
                {
                    var thisTh=j$(value);
                    if(thisTh.hasClass('headerSortDown') || thisTh.hasClass('headerSortUp'))
                    {
                        sortedByColName=thisTh.data('colname');
                    }
                });
                
                var sortByText='Sorted By '+sortedByColName;
                sortByText+=' <i class="fa fa-circle circleIcon" aria-hidden="true"></i>';
                var sortBySpanEl=j$('.sortBySpan').prop('innerHTML', sortByText);
            });
        }, 10);
    },
    initializeTimeAgo: function(component)
    {
        setTimeout(function()
		{
            j$('.timeago').timeago();
        }, 10);
    },
    showUserMessage: function(component, msgScenario, msgText)
    {
        var grpMembrMsgTextDiv=j$('.grpMembrMsgTextDiv');
        
        if(msgScenario=='success')
        {
            grpMembrMsgTextDiv.append('<div class="slds-notify slds-notify--alert slds-theme_alert-texture slds-theme--success msgTextDiv">'+msgText+'</div>');
        }
        else if(msgScenario=='info')
        {
            grpMembrMsgTextDiv.append('<div class="slds-notify slds-notify--alert slds-theme_alert-texture slds-theme--info msgTextDiv">'+msgText+'</div>');
        }
        else
        {
            grpMembrMsgTextDiv.append('<div class="slds-notify slds-notify--alert slds-theme_alert-texture slds-theme--error msgTextDiv">'+msgText+'</div>');
        }
        grpMembrMsgTextDiv.show();
    }
})