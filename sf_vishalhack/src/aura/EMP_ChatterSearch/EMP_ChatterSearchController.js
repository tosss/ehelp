/* ************************************************************************
 * 12/23/2016 created vijay.manimaran@cdk.com chattersearch for communities

************************************************************************ */

({
	doInit : function(component, event, helper) {
        
        var action = component.get("c.retrieveAllPosts");
        action.setParams({
            searchTerm :component.get("v.searchterm")        });
        action.setCallback(this, function(response){
            console.log('inside callback',response.state);
            var state = response.state;
            
            if (state === "SUCCESS")
            {
                component.set("v.feedvalues", response.returnValue);
                component.set("v.commentvalues", response.returnValue);
                console.log(component.get("v.feedvalues"));
                console.log(component.get("v.commentvalues"));
                
            }
        });
        $A.enqueueAction(action);
    }
})