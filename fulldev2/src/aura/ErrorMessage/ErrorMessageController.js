({
    hideErr: function(component, event, helper)
    {
		component.set("v.body", []);
        jQuery(".leadLinkErr").toggle();
        jQuery(".leadLinkErr").css('height: normalHeight');
	}
})