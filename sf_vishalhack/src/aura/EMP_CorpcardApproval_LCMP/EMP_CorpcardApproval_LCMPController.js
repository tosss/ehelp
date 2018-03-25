({
    doInit : function(component, event, helper) {
        var vars = [],
            hash;
        var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
        for (var i = 0; i < hashes.length; i++) {
            hash = hashes[i].split('=');
            console.log(hash[1]);
        }
        var validationMessage= component.find("validationMessage");
        var approvalReject = component.find("approvalReject");
        var action = component.get("c.fetchPortalForm");
        console.log('am here');
        action.setParams({
            "recordId": hash[1]
        });
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.set("v.portalForms",response.returnValue);
                console.log('************',response.returnValue);
                if(response.returnValue == null){
                    $A.util.removeClass(validationMessage,"hide-form");
                    component.set("v.validationMessage","Sorry you do not access to approve this employee or you do not have any employees to approve");
                }else{
                    $A.util.removeClass(approvalReject,"hide-form");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    managerDecision: function(component, event, helper){
        var clickedButton = event.target.id;
        var rejectionPanel = component.find('rejectionPanel');

        if(clickedButton === 'Approve'){
            helper.requestApproval_Helper(component,clickedButton);     
        }else if(clickedButton === 'Reject'){
            document.getElementById("newModalId").style.display = "block";
            $A.util.removeClass(rejectionPanel,"hide-form");
        }
    },
    
    searchRequest: function(component, event){
        var action = component.get("c.searchResults");
        var searchVal = component.find('searchVal').get("v.value");
        var searchRequest = component.find('searchRequest');
        var searchResult = component.find('searchResults');

        action.setParams({
            "searchVal": searchVal
        });
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.set("v.searchResults",response.returnValue);
                console.log(' response.returnValue  : ',response.returnValue);
                component.set("v.searchValue" , searchVal);
                  $A.util.addClass(searchRequest,"hide-form");
                  $A.util.removeClass(searchResult,"hide-form");
            }
        });
        $A.enqueueAction(action);
    },
    
    updatePortalForm: function(component, event, helper){
        var clickedButton = event.target.id;
        helper.requestApproval_Helper(component, clickedButton);     
    },

    showSpinner: function(component) {
        component.set("v.toggleSpinner", true);
    },
    
    hideSpinner: function(component) {
        component.set("v.toggleSpinner", false);
    },
    hideModal: function(component, event, helper) {
        document.getElementById("newModalId").style.display = "none";
    },
     gotoHomePage: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "https://mycdk.force.com/intranet/s/corporate-credit-cards"
        });
        urlEvent.fire();
    }
})