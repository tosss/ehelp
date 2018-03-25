// by Lalitha Adduru on March 31st 2015

trigger DS_CreateCompositeIDforManufacturersAtDealership on Manufacturer_at_Dealership__c (after insert, after update) {

    // List to store updated records 
    list<Manufacturer_at_Dealership__c> updatedManufs = new List<Manufacturer_at_Dealership__c>();
    
    // List that stores newly inserted/updated records
    list<Manufacturer_at_Dealership__c> insertedManufs = new List<Manufacturer_at_Dealership__c>();
    insertedManufs = [
        select Account__c, Manufacturer__r.id, Manufacturer__r.Ora_Manufacturers_Code__c, 
            Manufacturer__r.Segment_Code__c, CompositeExtID__c, Id, Manufacturer_Dealer_Code__c 
        from Manufacturer_at_Dealership__c m 
        where id in :trigger.new
    ];
    
    for(Manufacturer_at_Dealership__c md : insertedManufs)
    {
        if(md.Manufacturer__r != null)
        {
            Manufacturer_at_dealership__c md_old = null;
            
            if(trigger.oldmap == null) { md_old = new Manufacturer_at_dealership__c(); } 
            else { md_old = trigger.oldmap.get(md.id); }
            
            // condition to make update trigger work only when there is a change in Account__c or Manufacturer__c
            if( ( md.Account__c != md_old.Account__c ) || ( md.Manufacturer__c != md_old.Manufacturer__c) )
            {
                md.CompositeExtID__c = 
                    md.Account__c + '' + 
                    md.Manufacturer__r.Ora_Manufacturers_Code__c + '' +
                    md.Manufacturer__r.Segment_Code__c ; // added segment_code__c 
                updatedManufs.add(md);
            }
        }
    }
    
    if (updatedManufs.size() > 0){
        update updatedManufs;   
    }
}