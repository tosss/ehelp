({
    searchProducts : function(component, event, helper) {
        try {
            var action = component.get("c.getProductsData");
            var catalogNo = component.get("v.catalogNo");
            var country = component.get("v.selectedCountry");
            component.set("v.showLoadingIcon",true);
            /* if(country.length == component.get("v.countries").length) {
            country = "BOTH";
        }
        else if(country.length == 0) {
            country = "";
        }*/
            console.log('catalog no' + catalogNo + 'country' + component.get("v.selectedCountry"));
            action.setParams({
                catalogNo : catalogNo,
                country : country
            });
            action.setCallback(this,function(actionResult) {
                var result = actionResult.getReturnValue();
                component.set("v.showLoadingIcon",false);
                if(component.isValid() && action.getState() == 'SUCCESS' && result != null) {
                    component.set('v.productsList', result);
                    
                    console.log('success');
                    if(result.length > 0) {
                        component.set('v.noRecords', false);
                    }
                    else {
                        component.set('v.noRecords', true);
                        component.set('v.displayMsg','No records found to display');
                    }
                }
                else {
                    console.log('error');
                    component.set('v.productsList', []);
                    component.set('v.noRecords', true);
                    component.set('v.displayMsg',action.getError());
                }
                
            });
            $A.enqueueAction(action);
        }
        catch(err) {
            component.set('v.productsList', []);
            component.set('v.noRecords', true);
            component.set('v.displayMsg','Please try the search again');
        }
    },
    
    resetFields : function(component,event) {
        component.set('v.productsList', []);
        component.set('v.noRecords', false);
        component.set('v.catalogNo','');
        component.set('v.selectedCountry',"");
        console.log('firing');
        var appEvent = $A.get("e.c:ALL_reset");
        
        appEvent.fire();
        
    },
   
    
    sortColumn : function(component,event,helper) {
        var column = jQuery(event.target).parents('th');
        var columnName = column.attr('id');
        var columnWithExistingSort = jQuery(event.target).parents('tr').find('.sort');
        var columnNameWithExistingSort = columnWithExistingSort.attr('id');
        console.log(columnName , columnNameWithExistingSort);
        var recordsList = component.get('v.productsList');
        
        if(columnNameWithExistingSort != 'undefined' && columnName == columnNameWithExistingSort) {
            component.set('v.productsList',recordsList.reverse());
            column.find('.sortImage').toggle();
            
        }
        
        else {
            
            recordsList.sort(function(cmp1, cmp2) {
                var firstVal = cmp1[columnName];
                var secondVal = cmp2[columnName];
                if((firstVal == 'undefined' && secondVal == 'undefined') || (firstVal == secondVal)) {
                    return 0;
                }
                else if(firstVal == 'undefined') {
                    return -1; 
                }
                    else if(secondVal == 'undefined') {                        
                        return 1;
                    }
                        else {
                            return (firstVal > secondVal ) ? 1 : -1;
                        }
                
                
            });
            
            columnWithExistingSort.find('.upImage').css('display','block');
            columnWithExistingSort.find('.downImage').css('display','none');
            columnWithExistingSort.removeClass('sort').addClass('slds-is-sortable');
            column.addClass('sort').removeClass('slds-is-sortable');
            
        }
        
    },
    
    getDetails : function(component,event,helper) {
        var recId = jQuery(event.target).attr('id');
        console.log('recordId' + recId + component.get("v.hardware"));
        component.set('v.showCatalogDetail',true);
        component.set("v.showLoadingIcon",true);
        var action = component.get('c.getRecordDetails');
        action.setParams({
            recId : recId
        });
        action.setCallback(this, function(actionResult) {
            var result = actionResult.getReturnValue();
            console.log('result is ' , result);
            component.set("v.showLoadingIcon",false);
            if(component.isValid() && action.getState() == 'SUCCESS' && result != null) {
                if(result.length >  0) {
                    component.set('v.recordDetails',result);
                }
            }
            else {
                
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    navigateBack : function(component,event,helper) {
        component.set('v.showCatalogDetail',false);
        component.set('v.selectedRecordId','');
        
    }
})