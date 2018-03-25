({
    doInit: function(component, event, helper) {
        var aspectRatioMap = {'square': '1:1', 'medium-rectangle':'4:2','large-rectangle':'16:9', 'wide-rectangle':'21:9', 'vertical-rectangle': '3:6' };

        var aspectRatioOptions = component.get("v.aspectRatioOptions");
        var aspectRatio= '4:3';
        if(aspectRatioOptions == 'custom'){
        	var customAspectRatio = component.get("v.customAspectRatio");
        	if(customAspectRatio !=null && customAspectRatio !='')
        	{
        		aspectRatio = customAspectRatio;
        	}
        } else if(aspectRatioMap[aspectRatioOptions] !=null ){
        	aspectRatio = aspectRatioMap[aspectRatioOptions];
        }
        if (aspectRatio != null) {
            var aspectRatioSplit = aspectRatio.split(':', 2);
            if (aspectRatioSplit != null && aspectRatioSplit.length == 2) {
                component.set("v.aspectRatioPercentage", (aspectRatioSplit[1] / aspectRatioSplit[0]) * 100);
            }
        }

    }
})