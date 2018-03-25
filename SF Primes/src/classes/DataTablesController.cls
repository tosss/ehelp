public with sharing class DataTablesController
{
    public class DataWithSelection
    {
        public Boolean Selected {get;set;}
        public sObject Obj {get;set;}
        
        public DataWithSelection(sObject s) {
            Obj = s; Selected = false;
        }
    }
    
    public Boolean DisplayDataInitialized; // to determine whether or not DisplayData has been set
    public List<DataWithSelection> DisplayData {get;set;} // the data to display (with checkboxes)
    
    public List<String> DisplayFieldAPINames {get;set;} // to maintain sort order
    public Map<String,String> DisplayFields {get;set;} // to store field labels and API names
    
    // determines whether or not to display checkboxes
    public Boolean DisplayCheckboxes { get; set { if(value == null) { value = false; } } }
    
    public String DisplayColumns { 
        get; 
        set { 
            if(value != null) { 
                DisplayFieldAPINames = new List<String>();
                DisplayFields = new Map<String,String>();
                for(String s : value.split(',')) { 
                    // put the API name as the key and the value (as a default)
                    String t = s.trim();
                    DisplayFieldAPINames.add(t); 
                    DisplayFields.put(t,t); 
                } 
                //system.debug(DisplayFields); 
            } 
        } 
    } 
    
    public sObject[] OriginalData {
        get; 
        set { 
            //system.debug('original data set');
            // loop through all sObjects and build a list of data with selection capabilities
            
            if(value != null)
            {
	            //if(DisplayDataInitialized != true)
	            {
	                DisplayData = new List<DataWithSelection>();
	                for(sObject s : value) { DisplayData.add(new DataWithSelection(s)); }
	                DisplayDataInitialized = true;
	            }
	            
	            // describe the sObject to get all of its fields
	            Map<String, Schema.SObjectField> describes = new Map<String, Schema.SObjectField>();
	            if(value != null) { 
	                if(value.size() > 0) { 
	                    describes = value[0].getsObjectType().getDescribe().fields.getMap();
	                } 
	            } 
	            
	            // loop through all of the fields and describe to get the labels
	            if(DisplayFields != null) {
                    for(String s : DisplayFields.keyset()) {
                        Schema.SObjectField f = describes.get(s);
                        // update the key/value pair with the field label
                        try { DisplayFields.put(s,f.getDescribe().getLabel()); } 
                        // if updating fails (for example, if too many describes occur), 
                        // do nothing (keeping the previously set API name)
                        catch (Exception e) { } 
                    }
	            }
            }
        }
    }
}