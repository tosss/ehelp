public class DS_CompetitiveProductsExtension
{
    // variables
    public ApexPages.StandardController Controller;
    public Competitive_Products_At_Dealership__c Record;
    public List<Competitive_Vendor__c> Vendors;
    
    // properties
    public String ProductName {get;set;}
    public List<SelectOption> VendorOptions {get;set;}
    
    // constructor
    public DS_CompetitiveProductsExtension(ApexPages.StandardController ctr) 
    { 
        Controller = ctr; 
        
        // get the current record from the standard controller of the visualforce page
        Record = (Competitive_Products_At_Dealership__c)Controller.getRecord();
        
        // get the name of the Product Solution from the current record
        if(Record != null)
        {
            if(Record.ADP_Product_Name__c != null) { 
                ADP_Product_Solution__c p = [Select Name From ADP_Product_Solution__c Where Id = :Record.ADP_Product_Name__c Limit 1]; 
                if(p != null) { ProductName = p.Name; }
            }
        }
        
        String AccountId = ApexPages.currentPage().getParameters().get('aid');
        if(AccountId != null) { Record.Account__c = AccountId; }
        
        RefreshVendorOptions();
    }
    
    // Refresh Vendor method
    //  - called by an action function to refresh the picklist of Vendor options
    public void RefreshVendorOptions()
    {
    	// get all of the Competitive Vendors
    	Vendors = [Select Id, Name, Competitive_Vendor_Name__c, ADP_Product_Solution__r.Name, ADP_Product_Solution__c From Competitive_Vendor__c];
    	
        // get the current record from the standard controller of the visualforce page
        Record = (Competitive_Products_At_Dealership__c)Controller.getRecord();
        
        // if the record is not null, and the list of vendors is not null
        if(Record != null && Vendors != null)
        {
            VendorOptions = new List<SelectOption>();
            
            // loop through all vendors
            for(Competitive_Vendor__c v : Vendors)
            {
                if(v.ADP_Product_Solution__c != null)
                {
                    // if the vendor Product Solution equals the selected Product Solution on the
                    // Competitive Product at Dealership, add an option the the picklist
                    if(v.ADP_Product_Solution__r.Name == ProductName)
                    {
                        SelectOption opt = new SelectOption(v.Id, v.Competitive_Vendor_Name__c);
                        VendorOptions.add(opt);
                    }
                }
            }
        }
    }
    
    // Save and New functionality
    //  - There is no default Save and New action on Standard Controllers; so it must be custom
    public PageReference SaveAndNew()
    {
        try { this.Controller.Save(); }
        catch (Exception ex) { ApexPages.addMessages(ex); }
        
        // if there are error messages, return the current page (null)
        if(ApexPages.hasMessages()) { 
            return null; 
        }
        // if there were no error messages
        else { 
            // get the edit page URL for a new record, and return a PageReference for that URL
            String prefix = Competitive_Products_At_Dealership__c.sObjectType.getDescribe().getKeyPrefix(); 
            return new PageReference('/' + prefix + '/e?retURL=/' + prefix + (Record.Account__c != null ? '&aid=' + Record.Account__c : '')); 
        } 
    }
}