// 2016-04-11 - fsalwen@salesforce.com - Created for syncing up the BrandRelationship records
// 2016-09-28 - siva.pragada@cdk.com - made changes to remove Brand__c references and placed Account (Brand) in the same place

public class ALL_OEMAndBrand_Handler
{

    // This method is to query to get additional data, such as from the Account fields, to be used by other methods
    public static List<Business_Site__c> getFullDataForRecords(List<Business_Site__c> triggerNewRecords)
    {
        system.debug('Start getFullDataForRecords---->');
        
        // List that stores newly inserted/updated records
        List<Business_Site__c> fullDataForRecords=new List<Business_Site__c>();

        if(triggerNewRecords!=Null)
        {
            fullDataForRecords=[
                SELECT Id, Name, External_ID__c, Status__c, Address__c, Franchise__c,
                    Account__c, Account__r.Migration_ID__c, 
                    BAC__c, CID__c, Dealer_Code__c, DMA__c, IMR__c, IMR_Change_Date__c, Region__c, 
                    Account_Number__c, LMA_Account__c, 
                    LMA_Ad_Product_Status__c, LMA_Analyst__c, LMA_Code__c, LMA_Strategist__c, 
                    Primary_Division__c, Primary_Division_Name__c 
                FROM Business_Site__c
                WHERE Id IN :triggerNewRecords
            ];
        }
        
        system.debug('End getFullDataForRecords---->');
        return fullDataForRecords;
    }

    // Need to create the BrandRelationship when Business_Site__c records are created
    // and update the BrandRelationship record when Business_Site__c records are updated
    public static void createOrUpdateBrandRelationshipRecords(List<Business_Site__c> newBusinessSites)
    {
        system.debug('Start createOrUpdateBrandRelationshipRecords---->');

        // Map of all Brand__c records that have a Franchise, keyed by the Franchise name
        //Map<String, Brand__c> brandMap = getBrandsByFranchise();
        Map<String, Account> accountsByFranchiseMap = getAccountsByFranchise();
                
        // Map of the Business_Site__c records keyed by BrandRelationship__c Migration_ID for each
        //Map<String, Business_Site__c> sitesByBrandRelationshipIdMap = mapBusinessSitesByBrandRelationshipId(newBusinessSites, brandMap);
        Map<String, Business_Site__c> sitesByBrandRelationshipIdMap = mapBusinessSitesByBrandRelationshipId(newBusinessSites, accountsByFranchiseMap);

        //List to store the Id's for the BrandRelationship__c records
        Set<String> brandRelationshipIds = sitesByBrandRelationshipIdMap.keySet();

        // Map of BrandRelationship__c records, keyed by Brand_Relationship__c Migration_ID__c
        Map<String, BrandRelationship__c> brandRelationshipMap = getBrandRelationshipMapForIds(brandRelationshipIds);
        
        // Now that the data is prepared, use that as parameters to pass in and
        // Call the method that does the actual work to loop through records, preparing each, and then insert or update
        createOrUpdateBrandRelationshipRecords(brandRelationshipMap, sitesByBrandRelationshipIdMap, null);

        system.debug('End createOrUpdateBrandRelationshipRecords---->');
    }

    // This method is to query the Brand data, and create a Map, key'd by Franchise, to be used by other methods
    //public static Map<String, Brand__c> getBrandsByFranchise()
    //{
        //system.debug('Start getBrandsByFranchise---->');

        //Map<String, Brand__c> brandMap = new Map<String, Brand__c>();
        //String brandName; // String to use as key in Map

        //List<Brand__c> brands = [SELECT Active__c, Id, Migration_ID__c, OEM_Account__c, Franchise__c FROM Brand__c WHERE (Franchise__c != null)];
        //for (Brand__c brand : brands) {
            //brandMap.put(brand.Franchise__c, brand);
        //}

        //system.debug('End getBrandsByFranchise---->');
        //return brandMap;
    //}
    
    //This method is querying the accounts with record type CDK OEM/Brand
    public static map<String, Account> getAccountsByFranchise()
    {
        Map<String, Account> franchiseToAccountMap = new Map<String, Account>();
        
        List<Account> Accounts = [
            Select Id, Name, Franchise__c, Migration_ID__c 
            From Account 
            Where RecordType.Name = 'CDK OEM/Brand'
            AND (Site_Type__r.Name = 'Brand' OR Site_Type__r.Name = 'OEM/Brand') AND Franchise__c != null
        ];
        
        for(Account acc: Accounts)
        {
            franchiseToAccountMap.put(acc.Franchise__c, acc);
        }
        
        return franchiseToAccountMap;
    }

    // This method takes a list of Business_Site__c and uses Brand__c records and to determines the BrandRelationship__c unique id for each
    // Returns the same Business_Site__c records, in a map, keyed by the associated BrandRelationship's MigrationID
    public static Map<String, Business_Site__c> mapBusinessSitesByBrandRelationshipId(
        List<Business_Site__c> newBusinessSites, Map<String, Account> accountsByFranchiseMap) 
    {
        system.debug('Start mapBusinessSitesByBrandRelationshipId---->');

        String brandName;   //String to hold the name of one Brand__c record
        String brandRelId;  //String to hold the migration ID for one BrandRelationship__c record
        Account brandAccount;
        
        //Map of Business_Site__c records, keyed by Brand_Relationship__c Migration_ID__c
        Map<String, Business_Site__c> sitesByBrandRelationshipIdMap = new Map<String, Business_Site__c>();

        // Create map of Business_Site__c records, keyed by the unique BrandRelationship__c Migration ID for each
        for (Business_Site__c site : newBusinessSites)
        {
            // Business_Site data has matching data on the Franchise__c and Address__c fields, but one or the other could be null
            brandName = (site.Franchise__c != null) ? site.Franchise__c : site.Address__c;

            if (brandName != null)
            {
                brandAccount = accountsByFranchiseMap.get(brandName);
                if (brandAccount != null) {
                    // Migration ID format for BrandRelationships__c is AC-Auto@9000733
                    // replace brand.Migration_ID__c Account.Migration_ID__c
                    //brandRelId = brand.Migration_ID__c + '@' + site.Account__r.Migration_ID__c;
                    brandRelId = brandAccount.Migration_ID__c + '@' + site.Account__r.Migration_ID__c;
                    sitesByBrandRelationshipIdMap.put(brandRelId, site);
                }   
            }
        }

        system.debug('End mapBusinessSitesByBrandRelationshipId---->');
        return sitesByBrandRelationshipIdMap;
    }

    // This method is to query for the BrandRelationships for a list of IDs and then create a map
    // Returns a map of BrandRelationship records, keyed by the MigrationID
    public static Map<String, BrandRelationship__c> getBrandRelationshipMapForIds(Set<String> brandRelationshipIds) 
    {
        system.debug('Start getBrandRelationshipMapForIds---->');

        //Map of BrandRelationship__c records, keyed by Brand_Relationship__c Migration_ID__c
        Map<String, BrandRelationship__c> brandRelationshipMap = new Map<String, BrandRelationship__c>();

        //Query for existing BrandRelationships
        List<BrandRelationship__c> existingBrandRelationships = [
            SELECT Id, Migration_ID__c, Name, Dealership__c, Active__c, Is_Primary__c, REF_Mfg_At_Dealership_ID__c, Type__c
            FROM BrandRelationship__c
            WHERE Migration_ID__c IN :brandRelationshipIds
        ];
 
        for (BrandRelationship__c existingBrandRelationship : existingBrandRelationships) {
            brandRelationshipMap.put(existingBrandRelationship.Migration_ID__c, existingBrandRelationship);
        }

        system.debug('End getBrandRelationshipMapForIds---->');
        return brandRelationshipMap;
    }

    // Need to create the BrandRelationship when Business_Site__c and Manufacturer_At_Dealership__c records are created
    // and update the BrandRelationship record when Business_Site__c and Manufacturer_At_Dealership__c records are updated
    public static void createOrUpdateBrandRelationshipRecords
            (Map<String, BrandRelationship__c> updatedBrandRelationshipMap, Map<String, Business_Site__c> sitesByBrandRelationshipIdMap, Map<String, Manufacturer_At_Dealership__c> MADsByBrandRelationshipIdMap)
    {
        system.debug('Start createOrUpdateBrandRelationshipRecords---->');
        system.debug('updatedBrandRelationshipMap: ' + updatedBrandRelationshipMap);
        system.debug('sitesByBrandRelationshipIdMap: ' + sitesByBrandRelationshipIdMap);
        system.debug('MADsByBrandRelationshipIdMap: ' + MADsByBrandRelationshipIdMap);
       
        Manufacturer_At_Dealership__c updatedMAD;
        Business_Site__c updatedSite;
        BrandRelationship__c updatedBrandRelationship;
        BrandRelationship__c newBrandRelationship;
        List<BrandRelationship__c> updatedBrandRelationships = new List<BrandRelationship__c>();
        List<BrandRelationship__c> newBrandRelationships = new List<BrandRelationship__c>();
        
        Set<String> brandRelationshipIDSet = sitesByBrandRelationshipIdMap != null ? sitesByBrandRelationshipIdMap.keySet() : MADsByBrandRelationshipIdMap.keySet();
        
        if(brandRelationshipIDSet != null)
        {
            for (String brandRelationshipId : brandRelationshipIDSet) 
            {
                updatedMAD = (MADsByBrandRelationshipIdMap != null) ? MADsByBrandRelationshipIdMap.get(brandRelationshipId) : null;
                updatedSite = (sitesByBrandRelationshipIdMap != null) ? sitesByBrandRelationshipIdMap.get(brandRelationshipId) : null;
                updatedBrandRelationship = updatedBrandRelationshipMap.get(brandRelationshipId);
                                 
                if (updatedBrandRelationship != null)
                { 
                    // If BrandRelationship record does exist for the Account and Brand, then update it                              
                    updatedBrandRelationship = (updatedMAD != null) ? 
                        setFieldsOnBrandRelationship(updatedBrandRelationship, updatedMAD) :
                    setFieldsOnBrandRelationship(updatedBrandRelationship, updatedSite);
                   
                    // Add to the list of records to be updated
                    updatedBrandRelationships.add(updatedBrandRelationship);
                } else
                {
                    // If BrandRelationship record does not exist for the Account and Brand,
                    // then create it (one per unique Account and Manufacturer code + Subsegment)
                    
                    // Create an in-memory instance of Brand__c, with the Migration_ID__c set, to use for relationship
                    // Brand__r.Migration__ID__c is of the form 'CVLT-Auto'
                    String brandMigrationId = brandRelationshipId.substringBefore('@');
                    //Brand__c brand = new Brand__c(Migration_ID__c = brandMigrationId);
                    Account brandAccount = new Account(Migration_ID__c = brandMigrationId);
                    
                    newBrandRelationship = new BrandRelationship__c(
                        Migration_ID__c=brandRelationshipId, 
                        Type__c='BrandAtDealership',
                        Brand_Account__r=brandAccount
                    ); 
                    
                    if (updatedMAD != null) {
                        // Set fields based on the updated Manufacturer_At_Dealership__c
                        newBrandRelationship.Dealership__c = updatedMAD.Account__c;
                        newBrandRelationship = setFieldsOnBrandRelationship(newBrandRelationship, updatedMAD);
                    } else {
                        // Set fields based on the updated Business_Site__c
                        newBrandRelationship.Dealership__c = updatedSite.Account__c; 
                        newBrandRelationship = setFieldsOnBrandRelationship(newBrandRelationship, updatedSite);
                    }
                    
                    // If a new record was just created, then assume that the relationship should be active
                    //newBrandRelationship.Active__c=TRUE;
                    //commented out above line after DaveH has reported all newly insrted BR's have active status even though
                    //corresponding BS is inactive status.
                    // Add to the list of records to be inserted
                    newBrandRelationships.add(newBrandRelationship);
                }
            }
        }
        
        if(newBrandRelationships.size()>0)
        {
            List<Database.SaveResult> results = Database.insert(newBrandRelationships);  
            //system.assertEquals(newBrandRelationships, new List<BrandRelationship__c>());
        }
        
        if(updatedBrandRelationships.size()>0)
        {//system.assertEquals(updatedBrandRelationships[0].ID,'a0D3300000X3Y27'); a5R230000008rVm , a5R230000008rVBEAY, a0D3300000X3Y27EAF
            List<Database.SaveResult> results = Database.update(updatedBrandRelationships);
        }
        system.debug('End createOrUpdateBrandRelationshipRecords---->');
    }

    // Use a Manufacturer_At_Dealership as the source to populate a BrandRelationship__c record
    public static BrandRelationship__c setFieldsOnBrandRelationship (BrandRelationship__c rel, Manufacturer_At_Dealership__c sourceMAD)
    {
        System.debug('Setting fields on BrandRelationship__c: ' + rel.Migration_ID__c + ' using ' + sourceMAD);
        rel.REF_Mfg_At_Dealership_ID__c = sourceMAD.Migration_ID__C;
        rel.Active__c = (sourceMAD.Status__c == 'Active' || sourceMAD.Status__c == 'A') ? true : false;             
        return rel;
    }
    
    // Use a Business_Site__c as the source to populate a BrandRelationship__c record
    public static BrandRelationship__c setFieldsOnBrandRelationship (BrandRelationship__c rel, Business_Site__c sourceSite)
    {
        System.debug('Setting fields on BrandRelationship__c: ' + rel.Migration_ID__c + ' using ' + sourceSite);
        
        // Business_Site data has matching data on the Franchise__c and Address__c fields, but one or the other could be null
        String brandName = (sourceSite.Franchise__c != null) ? sourceSite.Franchise__c : sourceSite.Address__c;

        // Set the generic fields
        rel.LMA_Account__c = sourceSite.LMA_Account__c;
        rel.ORA_PartySite_ID__c = sourceSite.External_ID__c;
        rel.Active__c = (sourceSite.Status__c == 'Active' || sourceSite.Status__c == 'A') ? true : false;
             
        // Set the Region, if it has a value
        if (sourceSite.Region__c != null) {
            String base = sourceSite.Region__c.substringBeforeLast(' ').toLowerCase();
            String modified = '';
            for (String s : base.split(' ')) {
                modified += s.capitalize() + ' ';
            }
            rel.Site_Region__c = modified.trim();
        }

        // Set the GM-specific fields (if they exist)
        rel.Primary__c = (sourceSite.Primary_Division_Name__c == brandName) ? 'true' : 'false'; //system.assertEquals(sourceSite.BAC__c,'88888');
        rel.GM_BAC__c = sourceSite.BAC__c;
        rel.GM_DMA__c = sourceSite.DMA__c;
        if (sourceSite.CID__c != null) {
            rel.GM_CID__c = (sourceSite.CID__c == 'Yes') ? 'true' : 'false';
        }
        if (sourceSite.IMR__c != null) {
            rel.GM_IMR__c = (sourceSite.IMR__c == 'Yes') ? 'true' : 'false';
        }
        rel.GM_IMR_ChangeDate__c = sourceSite.IMR_Change_Date__c;
        return rel;
    }
}