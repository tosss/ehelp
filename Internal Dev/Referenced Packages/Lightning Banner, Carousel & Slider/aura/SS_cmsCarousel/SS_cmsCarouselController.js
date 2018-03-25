({
    doInit: function(component, event, helper) {
        // Init Slide Def - Will have to move to Custom Metadata for more extensibility. Currently supports only Image and Video.

        var aspectRatioMap = {'square': '1:1', 'medium-rectangle':'4:3','large-rectangle':'16:9', 'wide-rectangle':'21:9', 'vertical-rectangle': '3:6' };

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
 	//	component.set("v.slideOptions", {'aspectRatioOptions': aspectRatioOptions, 'height': component.get('v.height'),'customAspectRatio' : component.get("v.customAspectRatio")});
        component.set("v.slideDefMap", {
            'image': { 'component': 'cloudx_cms:SS_uiImageBanner' },
            'video': { 'component': 'cloudx_cms:SS_uiVideoBanner' }
        });

    }
})