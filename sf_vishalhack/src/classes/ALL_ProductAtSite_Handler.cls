/*--------------------------------------------------------
 * 2016-12-07 -venkata.shrivol@cdk.com -Created 
 * Description - Handler for ALL_ProductAtSite Trigger
 * 
----------------------------------------------------------*/
public class ALL_ProductAtSite_Handler 
{
    public static void afterInsert(list<Product_At_Site__c> newList)
    {
        // creating a map of opportunity location site Id to the parent product names initially
        // from the products that are getting inserted
        map<string, ProductAtSiteWrapper> oppLocToProductNames = new map<string, ProductAtSiteWrapper>();
        set<string> parentProductIdsToRemove = new set<string>(); 
        map<string, ALL_DiscoveryProducts__c> customSettingsMap = ALL_DiscoveryProducts__c.getAll();
        for(Product_at_Site__c prs:newList)
        {	
            for(String str:customSettingsMap.keySet())
            {
                if(prs.Product_Definition_Name__c !=null
                   && prs.Product_Definition_Name__c != str
                   && customSettingsMap.get(str).Related_Product_Names__c != null
                   && customSettingsMap.get(str).Related_Product_Names__c.contains(prs.Product_Definition_Name__c))
                {
                    ProductAtSiteWrapper pw = new ProductAtSiteWrapper();
                    pw.current = prs.Current__c;
                    pw.proposed = prs.Proposed__c;
                    pw.proposedAndSold = prs.Proposed_and_Sold__c;
                    pw.includeQuestions = prs.Include_Questions__c;
                    pw.productName = str;
                    oppLocToProductNames.put((string)prs.Opportunity_Location__c+str, pw);
                    break;
                }
                else if(prs.Product_Definition_Name__c == str)
                {
                    parentProductIdsToRemove.add((string)prs.Opportunity_Location__c + str);
                    break;
                }
                
            }							
        }
        if(!oppLocToProductNames.keySet().isEmpty())
        {
            oppLocToProductNames.keySet().removeAll(parentProductIdsToRemove);
        }
        
        if(oppLocToProductNames.keySet().size() > 0)
        {
            // creating another map of opportunity location site Id to the existing product names initially
            // reason for this map creation is to check whether existing site has already parent products in it
            map<string, string> existingProductNames = new map<string, string>(); 
            for(Product_at_Site__c pd: [select Id, 
                                        Product_Definition_Name__c, Opportunity_Location__c
                                        from Product_at_Site__c 
                                        where Opportunity_Location__c IN : oppLocToProductNames.keySet()
                                       ])
            {
                existingProductNames.put((string)pd.Opportunity_Location__c + pd.Product_Definition_Name__c, pd.Product_Definition_Name__c);
            }
            
            //Runnning a quick compare between the above two maps and removing the existing duplicates
            for(string uniqueId: oppLocToProductNames.keySet())
            {
                if(existingProductNames.containsKey(uniqueId))
                {
                    if(oppLocToProductNames.get(uniqueId).productName == existingProductNames.get(uniqueId))
                    {
                        oppLocToProductNames.remove(uniqueId);
                    }
                    
                }
            }
            map<string, string> productNameToIdMap = new map<string, string>();
            for(Discovery_Product_Definition__c dpd:[select Id, Name from Discovery_Product_Definition__c where 
                                                     Name IN :customSettingsMap.keySet()])
            {
                productNameToIdMap.put(dpd.Name, dpd.Id);
            }
            
            list<Product_at_Site__c> productsToInsert = new list<Product_at_Site__c>();
            for(string uniqueId:oppLocToProductNames.keySet())
            {
                
                ProductAtSiteWrapper Pw = oppLocToProductNames.get(uniqueId);
                Product_at_Site__c prs = new Product_at_Site__c();
                prs.Discovery_Product_Definition__c = productNameToIdMap.get(Pw.productName);
                prs.Opportunity_Location__c = uniqueId.substring(0,15);
                prs.Proposed__c = Pw.proposed;
                prs.Current__c = Pw.current;
                prs.Proposed_and_Sold__c = Pw.proposedAndSold;
                prs.Include_Questions__c = pw.includeQuestions;
                productsToInsert.add(prs);
                
            }
            insert productsToInsert;
            system.debug('-------->'+oppLocToProductNames);
        }
        
        
    }
    
    public class ProductAtSiteWrapper
    {
        public boolean current;
        public boolean proposed;
        public boolean proposedAndSold;
        public boolean includeQuestions;
        public string  productName;
    }    
}