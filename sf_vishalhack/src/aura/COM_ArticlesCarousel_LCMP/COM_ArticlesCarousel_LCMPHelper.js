({
	initializeComponent: function(component, event, helper)
    {
        helper.fetchArticles(component, helper);
        var articlesCarouselDivWidth=j$('.articlesCarouselDiv').prop('offsetWidth');
        
        var articlesCarouselSpinnerDiv=j$('.articlesCarouselSpinnerDiv');
        articlesCarouselSpinnerDiv.find('.spinnerContainer').css({'width': articlesCarouselDivWidth});
        articlesCarouselSpinnerDiv.show();
    },
    fetchArticles: function(component, helper)
    {
        var action=component.get('c.fetchArticles_LTNG');
        
        action.setParams({
            "topicName": component.get("v.topicName"),
            "communityName": component.get("v.communityName")
        });
        
        action.setCallback(this, function(response)
        {
            if(component.isValid() && response.getState()==='SUCCESS')
            {
                if(response.getReturnValue()!=null)
                {
                    component.set('v.artWrapList', response.getReturnValue());
                    helper.initSlick();
                    j$('.articlesCarouselSpinnerDiv').hide();
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    initSlick: function()
    {
        setTimeout(function()
		{
            j$('.artDiv').slick({
                slidesToShow: 3,
                autoplay: true,
                autoplaySpeed: 2500,
                dots: true,
                arrows: true,
                pauseOnDotsHover: true,
                variableWidth: true
            });
        }, 10);
    }
})