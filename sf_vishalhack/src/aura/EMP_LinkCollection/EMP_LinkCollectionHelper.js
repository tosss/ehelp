//2016-07-28- anirudh.singh@cdk.com- Created this class for RQ-07332.
({
    responseProcessor: function(component, event, helper, response)
    {
        if(component.isValid() && response.getState()==="SUCCESS")
        {
            component.set("v.linksWrapperList", response.getReturnValue());
        }
        else
        {
            component.set("v.linksWrapperList", null);
        }
    }

})