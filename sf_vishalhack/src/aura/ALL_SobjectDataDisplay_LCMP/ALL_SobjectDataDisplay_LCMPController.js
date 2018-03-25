({
	initialize: function(component, event, helper)
    {
		var sObjectRecord=component.get('v.sObjectRecord');
        var fieldAPIName=component.get('v.fieldName');
        var fieldType=component.get('v.fieldType');
        
        var fieldValue;
        if(fieldAPIName.indexOf(".")>=0)
        {
            var parentSobject=sObjectRecord[fieldAPIName.split(".")[0]];
            if(parentSobject!=undefined)
            {
                var parentFieldAPIName=fieldAPIName.split(".")[1];
                fieldValue=parentSobject[fieldAPIName.split(".")[1]];
            }
        }
        else
        {
            fieldValue=sObjectRecord[fieldAPIName];
        }
        
        if(fieldType=='img')
        {
            $A.createComponent(
                "aura:HTML",
                {
                    tag: "img",
                    HTMLAttributes:{"src": fieldValue, "class": "grpMembrImg"}
                },
                function(imgEl)
                {
                    var body=component.get("v.body");
                    body.push(imgEl);
                    component.set("v.body", body);
                }
            );
        }
        else
        {
            var outputTextEl=component.find("outputTextId");
            if(fieldValue!=null && fieldValue!=undefined)
            {
                outputTextEl.set("v.value", fieldValue);
                outputTextEl.set("v.title", fieldValue);
            }
        }        
	}
})