//2016-01-07- anirudh.singh@cdk.com- Created this handler class for the Trigger DS_CreateCompositeIDforManufacturersAtDealership.
//2016-04-07- fsalwen@salesforce.com- Updated to add in handling for syncing up the BrandRelationship records

public class DS_ManufacturersAtDealership_Handler
{
    //This method is being invoked from ALL_ManufacturersAtDealership Trigger.
    //All the processing of the Trigger has been done in this method.
    public static void processRecords(List<Manufacturer_at_Dealership__c> triggerNewRecords,  
                                      Map<Id, Manufacturer_at_Dealership__c> triggerOldRecordsMap)
    {
        system.debug('Start processRecords---->');

        //Query to get additional data, such as from the Account fields
        List<Manufacturer_at_Dealership__c> newManufacturersAtDealership=getFullDataForRecords(triggerNewRecords);

        //Pass that additional data to the methods that do the actual processing
        if(newManufacturersAtDealership!=Null && newManufacturersAtDealership.size()>0)
        {
            createCompositeId(newManufacturersAtDealership, triggerOldRecordsMap);
            createOrUpdateBrandRelationshipRecords(newManufacturersAtDealership);
        }

        system.debug('End processRecords---->');
    }

    //This method is to query to get additional data, such as from the Account fields, to be used by other methods
    public static List<Manufacturer_at_Dealership__c> getFullDataForRecords(List<Manufacturer_at_Dealership__c> triggerNewRecords)
    {
        system.debug('Start getFullDataForRecords---->');
        
        //List that stores newly inserted/updated records
        List<Manufacturer_at_Dealership__c> fullDataForRecords=new List<Manufacturer_at_Dealership__c>();

        if(triggerNewRecords!=Null)
        {
            fullDataForRecords=[
                SELECT Id, Migration_ID__c, CompositeExtID__c, Manufacturer_Dealer_Code__c, Status__c,
                Account__c, Account__r.PartyID__c, Account__r.Migration_ID__c, Manufacturer__r.Id, 
                Manufacturer__r.Ora_Manufacturers_Code__c, Manufacturer__r.Subsegments__c, Manufacturer__r.Segment_Code__c
                FROM Manufacturer_at_Dealership__c m 
                WHERE Id IN :triggerNewRecords
            ];
        }

        system.debug('End getFullDataForRecords---->');
        return fullDataForRecords;
    }


    // Need to create the BrandRelationship when Manufacturer_at_Dealership__c records are created
    // and update the BrandRelationship record when Manufacturer_at_Dealership__c records are updated
    public static void createOrUpdateBrandRelationshipRecords(List<Manufacturer_at_Dealership__c> newManufacturersAtDealership)
    {
        system.debug('Start createOrUpdateBrandRelationshipRecords---->');

        // Map of the Manufacturer_at_Dealership__c records keyed by BrandRelationship__c Migration_ID for each
        Map<String, Manufacturer_at_Dealership__c> MADsByBrandRelationshipIdMap = mapMADsByBrandRelationshipId(newManufacturersAtDealership);
        
        if(MADsByBrandRelationshipIdMap != null)
        {
            //List to store the Id's for the BrandRelationship__c records
            Set<String> brandRelationshipIds = MADsByBrandRelationshipIdMap.keySet();
            
            // Map of BrandRelationship__c records, keyed by Brand_Relationship__c Migration_ID__c
            Map<String, BrandRelationship__c> brandRelationshipMap = ALL_OEMAndBrand_Handler.getBrandRelationshipMapForIds(brandRelationshipIds);
            
            // Now that the data is prepared, use that as parameters to pass in and
            // Call the method that does the actual work to loop through records, preparing each, and then insert or update
            ALL_OEMAndBrand_Handler.createOrUpdateBrandRelationshipRecords(brandRelationshipMap, null, MADsByBrandRelationshipIdMap);
            
            system.debug('End createOrUpdateBrandRelationshipRecords---->');
        }
    }

    // This method takes a list of Manufacturer_at_Dealership__c records and determines the BrandRelationship__c unique id for each
    // Returns the same Manufacturer_at_Dealership__c records, in a map, keyed by the associated BrandRelationship's MigrationID
    public static Map<String, Manufacturer_at_Dealership__c> mapMADsByBrandRelationshipId(List<Manufacturer_at_Dealership__c> newManufacturersAtDealership)

    {
        system.debug('Start mapMADsByBrandRelationshipId---->');
        
         map<String, Account> accountsByMigrationID = getAccountsByMigrationID();

        //String to hold the migration ID for one BrandRelationship__c record
        String brandRelId;

        //Map of Manufacturer_At_Dealership__c records, keyed by Brand_Relationship__c Migration_ID__c
        Map<String, Manufacturer_At_Dealership__c> MADsByBrandRelationshipIdMap = new Map<String, Manufacturer_At_Dealership__c>();

        // If BrandBrandRelationship records do not exist for the Account and Brand, 
        // then create them (one per unique Account and Manufacturer code + Subsegments)
        for (Manufacturer_at_Dealership__c md : newManufacturersAtDealership)
        {
            String subSegment;
            String oracleManufacturerCode;
            Manufacturer__c currentManufacturer = md.Manufacturer__r;
            
            if(currentManufacturer != null){ subSegment = currentManufacturer.Subsegments__c; oracleManufacturerCode = currentManufacturer.Ora_Manufacturers_Code__c; }
            
            string migrationIDkey = oracleManufacturerCode + '-' + subSegment;
            
            Account brandAccount = accountsByMigrationID.get(migrationIDkey);
            
            //system.debug(brandAccount.Migration_ID__c); 
            //system.debug(md.Account__r.Migration_ID__c);
            // Migration ID format for BrandRelationships__c is AC-Auto@9000733    // brandAccount.Migration_ID__c + '@' + DealershipPartyId;
            if(brandAccount != null && md.Account__r != null)
            {
                brandRelId = brandAccount.Migration_ID__c + '@' + md.Account__r.Migration_ID__c;//dealershippartyId
                MADsByBrandRelationshipIdMap.put(brandRelId, md);
            }
        }
        return MADsByBrandRelationshipIdMap;
    }
    
    //This method is querying the accounts with record type CDK OEM/Brand
    public static map<String, Account> getAccountsByMigrationID()
    {
        Map<String, Account> migrationToAccountMap = new Map<String, Account>();
        
        List<Account> Accounts = [
            Select Id, Name, Franchise__c, Migration_ID__c, Brand_OEM__c 
            From Account 
            Where RecordType.Name = 'CDK OEM/Brand'
            AND (Site_Type__r.Name = 'Brand' OR Site_Type__r.Name = 'OEM/Brand')
        ];
        
        for(Account acc: Accounts)
        {
            migrationToAccountMap.put(acc.Migration_ID__c, acc);
        }
        
        return migrationToAccountMap;
    }
    
    //This method is used to create or update the CompositeExtID__c field on Manufacturer_at_Dealership__c
    public static void createCompositeId(List<Manufacturer_at_Dealership__c> insertedManufacturers, 
                                         Map<Id, Manufacturer_at_Dealership__c> triggerOldRecordsMap)
    {
        system.debug('Start createCompositeId---->');

        //List to store updated records.
        List<Manufacturer_at_Dealership__c> updatedManufacturers=new List<Manufacturer_at_Dealership__c>();
        
        if(insertedManufacturers != null)
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