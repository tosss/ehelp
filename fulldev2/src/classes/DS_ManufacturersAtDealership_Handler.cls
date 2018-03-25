//2016-01-07- anirudh.singh@cdk.com- Created this handler class for the Trigger DS_CreateCompositeIDforManufacturersAtDealership.
public class DS_ManufacturersAtDealership_Handler
{
    //This method is being invoked from ALL_ManufacturersAtDealership Trigger.
    //All the processing of the Trigger has been done in this method.
    public static void processRecords(List<Manufacturer_at_Dealership__c> triggerNewRecords,  
                                      Map<Id, Manufacturer_at_Dealership__c> triggerOldRecordsMap)
    {
        system.debug('Start processRecords---->');
        createCompositeId(triggerNewRecords, triggerOldRecordsMap);
        system.debug('End processRecords---->');
    }
    
    //This method is being invoked from DS_CreateCompositeIDforManufacturersAtDealership Trigger.
    //All the processing of the Trigger has been done in this method.
    public static void createCompositeId(List<Manufacturer_at_Dealership__c> triggerNewRecords, 
                                         Map<Id, Manufacturer_at_Dealership__c> triggerOldRecordsMap)
    {
        system.debug('Start createCompositeId---->');
        //List to store updated records.
        List<Manufacturer_at_Dealership__c> updatedManufacturers=new List<Manufacturer_at_Dealership__c>();
        
        //List that stores newly inserted/updated records
        List<Manufacturer_at_Dealership__c> insertedManufacturers=new List<Manufacturer_at_Dealership__c>();
        
        if(triggerNewRecords!=Null)
        {
            insertedManufacturers=[
                SELECT Account__c, Manufacturer__r.Id, Manufacturer__r.Ora_Manufacturers_Code__c, 
                Manufacturer__r.Segment_Code__c, CompositeExtID__c, Id, Manufacturer_Dealer_Code__c 
                FROM Manufacturer_at_Dealership__c m 
                WHERE Id IN :triggerNewRecords
            ];
        }
        
        if(insertedManufacturers!=Null && insertedManufacturers.size()>0)
        {
            for(Manufacturer_at_Dealership__c md: insertedManufacturers)
            {
                if(md.Manufacturer__r!=Null)
                {
                    Manufacturer_at_dealership__c md_old=Null;
                    
                    if(triggerOldRecordsMap==Null)
                    {
                        md_old=new Manufacturer_at_dealership__c();
                    }
                    else
                    {
                        md_old=triggerOldRecordsMap.get(md.Id);
                    }
                    
                    // condition to make update trigger work only when there is a change in Account__c or Manufacturer__c
                    if((md.Account__c!=md_old.Account__c) || (md.Manufacturer__c!=md_old.Manufacturer__c))
                    {
                        md.CompositeExtID__c=
                            md.Account__c + '' + 
                            md.Manufacturer__r.Ora_Manufacturers_Code__c + '' +
                            md.Manufacturer__r.Segment_Code__c ; // added segment_code__c 
                        updatedManufacturers.add(md);
                    }
                }
            }
        }
        
        if(updatedManufacturers.size()>0)
        {
            update updatedManufacturers;
        }
        system.debug('End createCompositeId---->');
    }
}