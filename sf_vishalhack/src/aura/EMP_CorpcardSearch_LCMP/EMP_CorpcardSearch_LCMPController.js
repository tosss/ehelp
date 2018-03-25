({
    doInit: function(component, event, helper) {
        var vars = [],
            hash;
        var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
        for (var i = 0; i < hashes.length; i++) {
            hash = hashes[i].split('=');
        }
        component.set("v.pageParam", hash[1]);
        var searchRequest = component.find('searchRequest');
        var pcardAccess = component.find('pcardAccess');
        var validationMessage = component.find('validationMessage');
        var action = component.get("c.pcardEnabledAccess");
        action.setParams({
            "pageParameter": hash[1]
        });
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                console.log('response.returnValue', response.returnValue);
                if (response.returnValue == null) {
                    $A.util.removeClass(validationMessage, "hide-form");
                    component.set("v.validationMessage", "Sorry you do not Access");
                } else {
                    if (hash[1] === 'searchEmployee') {
                        console.log('am here');
                        $A.util.removeClass(searchRequest, "hide-form");
                    }
                    if (hash[1] === 'pcardAccess') {
                        $A.util.removeClass(pcardAccess, "hide-form");
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

    searchRequest: function(component, event) {
        var searchVal = component.find('searchVal').get("v.value");
        var pageParam = component.get("v.pageParam");
        var action = component.get("c.employeePortalResults");
        var searchResults = component.find('searchResults');
        var searchResult = component.find('searchResult').get("v.value");
        var pcardAccessResults = component.find('pcardAccessResults');
        var pcardAccess = component.find('pcardAccess');
        var submitRequest = component.find('submitRequest');
        var validationMessage = component.find('validationMessage');
        var searchRequest = component.find('searchRequest');

        if (pageParam === 'searchEmployee') {
            $A.util.removeClass(searchResults, "hide-form");
            searchVal = searchVal;
        }
        console.log('searchResult', searchResult);
        if (pageParam === 'pcardAccess') {
            $A.util.removeClass(pcardAccessResults, "hide-form");
            searchVal = searchResult;
        }
        action.setParams({
            "searchVal": searchVal,
            "pageParam": pageParam
        });
        component.set("v.searchValue", searchVal);
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                console.log(' response.returnValue  SFASDF : ', response.returnValue);
                if (response.returnValue == null) {
                    $A.util.removeClass(validationMessage, "hide-form");
                    component.set("v.validationMessage", "The Associate PcardAccess flag is already been enabled");
                    $A.util.addClass(searchResults, "hide-form");
                                            $A.util.addClass(searchRequest, "hide-form");
                    

                } else {
                    component.set("v.searchResults", response.returnValue);
                    $A.util.addClass(pcardAccess, "hide-form");
                    $A.util.addClass(submitRequest, "hide-form");
                }

            }
        });
        $A.enqueueAction(action);
    },

    accessToPcard: function(component, event) {
        var accessToPcard = event.target.getAttribute("data-recId");
        var action = component.get("c.updatePortalForm");
        console.log('accessToPcard', accessToPcard);
        action.setParams({
            "portalformID": accessToPcard,
            "updateFlag": 'pcardAccess'
        });
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                document.getElementById(accessToPcard).setAttribute("disabled", "true");
                if (response.returnValue == 'success') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success !",
                        "message": "You have successfully enabled Pcard Access for the employee",
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    showSpinner: function(component) {
        component.set("v.toggleSpinner", true);
    },

    hideSpinner: function(component) {
        component.set("v.toggleSpinner", false);
    }
})