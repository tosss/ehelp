({
    afterRender: function(component, helper){
        helper.registerRemoteActionEventHander(component)
        window.eo.init(component.getElement())
    }
})