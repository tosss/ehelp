/*------------------------------------------------------
04/20/2015 - Venkata Shrivol - Created
Description: used to create SiteProducts junction object
--HISTORY---
08/10/15 - Venkata Shrivol - Added null check to solve the null-pointer exception emails
09/24/15 - Venkata Shrivol - Modified getSites method to remove the account duplicates on sites.
 -------------------------------------------------------*/

global class IMP_AddProductsToSite_Extension {

    public list<String> siteRecIds {get;set;}
    public list<String> prodRecsIds {get;set;}
    public list<SubProjectSite__c> siteRecs {get;set;}
    public Map<id,Product__c> prodRecs {get;set;}
    public list<ProductDetail> productList {get;set;}
    set<string> allProdIds {get; set;}
    public list<SiteProductDetail> siteProductList{get; set;} 
    public SubProject__c subProject {get;set;}
    public String prodId {get;set;}

    public list<SubProjectSite__c> allSites {get;set;}

    public IMP_AddProductsToSite_Extension()
    {

        siteRecIds = new list<String>();
        prodRecsIds = new list<String>();
        allProdIds = new set<String>();
        siteRecs = new list<SubProjectSite__c>();
        prodRecs = new Map<id,Product__c>();
        productList = new list<ProductDetail>();
        siteProductList = new list<SiteProductDetail>();

        prodId = '';
        try
        {
            Id subProjId = ApexPages.currentPage().getParameters().get('id');
            if(subProjId !=null)
            {
                list<SubProject__c> subProjLst = [
                    Select Id, Name, (
                        Select Id, Account__r.Name 
                        from SubProjectSites__r
                    ) 
                    from SubProject__c 
                    where id = :subProjId
                ];
                
                if(subProjLst != null && !subProjLst.isEmpty()){
                    subProject = subProjLst[0];
                    allSites = subProject.SubProjectSites__r;
                    system.debug('allSites--' + allSites);
                }
            }
        }
        catch (Exception ex){
            system.debug('-----Exception Caught-----'+ex);
        }
    }
    
    // Get Sites from the SubProject
    public List<SelectOption> getSites() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('','-- None --'));
        set<Id> duplicateAccountIds = new set<Id>();
        if(allSites!=null)
        {
        	for(SubProjectSite__c site : allSites)
        	{
        		if(site.Account__c!=null)
        		{
        			if(!duplicateAccountIds.contains(site.Account__c))
        			{
        				options.add(new SelectOption(site.Id, site.Account__r.Name));
        				duplicateAccountIds.add(site.Account__c);
        			}
        			
        		}
        	}    
        }
        duplicateAccountIds.clear();       
        //system.debug('allSites- in getter-' + allSites);
        return options;
    }
    
    //For Displaying the Product table 
    public void updateProductList(){
        try
        {
            prodId = ApexPages.currentPage().getparameters().get('prodId');
            system.debug('-------------prodId--'+prodId);

            if(productList == null){
                productList = new list<ProductDetail>();
            }
            
            list<Product__c> products = [
                select Id,Name, Solution__c, Solution__r.Name, Solution__r.Question_Category__c, Solution__r.Question_Category__r.Name 
                from Product__c 
                where id= :prodId
            ];
            
            for(Product__c prod : products)
            {
                if(!allProdIds.contains(prodId)){
                    ProductDetail pd = new ProductDetail();
                    pd.prodId = prod.id;
                    pd.prodName = prod.Name;
                    pd.solutionId = prod.Solution__r.id;
                    pd.solutionName = prod.Solution__r.Name;
                    pd.dealershipNeedId = prod.Solution__r.Question_Category__r.Id;
                    pd.dealershipNeedName = prod.Solution__r.Question_Category__r.Name;
                    productList.add(pd);
                    allProdIds.add(pd.prodId);
                }

                system.debug('-------------prod--'+prod);
            }
            system.debug('-------------prodLst--'+productList);            
        }
        catch(Exception ex) { system.debug('---Excpetion----'+ex); }
        //return null;
    }

   
	
	// Auto-complete form method for displaying the matched products
    @RemoteAction
    global static list<Product__c> findProduct(string ProductSearchTerm)
    {
        list<sObject> searchList = null;
        if(ProductSearchTerm!=null)
        {
            ProductSearchTerm = '%' + ProductSearchTerm + '%';
            searchList = [
                select Id, Name, Solution__r.Name, Solution__r.Question_Category__r.Name 
                from Product__c 
                where Active__c = true 
                and Number_of_Questions__c > 0 
                and (
                    Name like :ProductSearchTerm OR 
                    Solution__r.Name like :ProductSearchTerm OR 
                    Solution__r.Question_Category__r.Name like :ProductSearchTerm
                )
                order by Name
            ];
        }    
        return searchList;
    }
    
    // Removing the Product from Product table
    public void removeProduct()
    {
        try
        {
            prodId = ApexPages.currentPage().getparameters().get('prodId');
            system.debug('-------------prodId--'+prodId);
            Integer i=0;
            while(i<productList.size()){
                if(productList.get(i).prodId == prodId){
                    productList.remove(i);
                    allProdIds.remove(prodId);
                    break;
                }
                else{
                    i++;
                }
            }

            system.debug('-------------prodLst--'+productList);            
        }
        catch(Exception ex) { system.debug('---Excpetion----'+ex); }
        //return null;
    }
    
    
    public Pagereference addSiteProducts()
    {
        list<Site_Product__c> siteProdsToInsert = new list<Site_Product__c>();
        list<SubProjectSite__c> sitesToAdd = new list<SubProjectSite__c>();
        list<Site_Product__c> existingSiteProds = new list<Site_Product__c>();
        set<String> existingSiteProdIds = new set<String>();
        //set<Id> existingSiteProdIds = new set<Id>();
        //map<Id, Site_Product__c> existingSiteProds = map<Id, Site_Product__c>();
        set<Site_Product__c> tempSiteProdSet = new set<Site_Product__c>();

        system.debug('-------siteRecIds--------'+siteRecIds);
        system.debug('---productList------'+productList);    
        if((siteRecIds!=null && !siteRecIds.isEmpty()) && (productList!=null && !productList.isEmpty()))
        {
            sitesToAdd = [select Id, Name, CMF_Name__r.Name, SubProject__c from SubProjectSite__c where Id IN: siteRecIds];
            //list<Product__c> prodsToAdd = [select Id, Name  from Product__c where Id IN: allProdIds and Active__c = true and Number_of_Questions__c > 0];

            existingSiteProds = [select Id, Product__c, SubProjectSite__c,SiteProduct_Ext_Id__c from Site_Product__c where Product__c IN: allProdIds and SubProjectSite__c IN: siteRecIds];
            if(existingSiteProds!=null && !existingSiteProds.isEmpty())
            {
            	for(Site_Product__c spd:existingSiteProds)
            	{
            		existingSiteProdIds.add(spd.SiteProduct_Ext_Id__c);
            	}
            }

            if(sitesToAdd!=null && !sitesToAdd.isEmpty())
            {
                for(SubProjectSite__c site: sitesToAdd)
                {
                    for(ProductDetail pdetail: productList)
                    {
                    	if(!existingSiteProdIds.contains(site.Id+pdetail.prodId))
                    	{
                    		Site_Product__c siteprod = new Site_Product__c();
	                        siteprod.SubProjectSite__c = site.Id;
	                        siteprod.Product__c = pdetail.prodId;
	                        siteprod.SiteProduct_Ext_Id__c = site.Id+pdetail.prodId;
	                        siteprod.SubProject__c = site.SubProject__c;
	                        siteProdsToInsert.add(siteprod);
	                        existingSiteProdIds.add(site.Id+pdetail.prodId);
                    	}
                    }
                }
            }

            

            system.debug('-----siteProdsToInsert-----------'+siteProdsToInsert);

            if(siteProdsToInsert!=null && !siteProdsToInsert.isEmpty())
            {        
                try 
                { 
                    insert siteProdsToInsert;
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Site Product record(s) have been created'));
                }
                catch(Exception e) { system.debug('----EXCEPTION-------'+e);}
            }
            siteProdsToInsert.addAll(existingSiteProds);
            showSiteProducts(siteProdsToInsert);

            //siteProdsToInsert.clear();
            //siteProdsToInsert.addAll(tempSiteProdSet);
            //allSiteProds.addAll(siteProdsToInsert);

        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Atleast One Sub-Project Site and One Product should be added'));
        }
        return null;
    }
    
    public Pagereference showSiteProducts(list<Site_Product__c> insertedSiteProducts)
    {
        system.debug('------insertedSiteProducts-----'+insertedSiteProducts);
        set<Id> siteProdIds = new Set<Id>();

        if(insertedSiteProducts!=null){
            for(Site_Product__c sproduct: insertedSiteProducts){
                siteProdIds.add(sproduct.id);
            }
            siteProductList = new list<SiteProductDetail>();
            for(Site_Product__c sproduct: [Select Id, Name,Product__r.Name, SubProjectSite__r.Account__r.Name  from  Site_Product__c where id in :siteProdIds])
            {
                SiteProductDetail spd = new SiteProductDetail();
                spd.sprodId = sproduct.id;
                spd.toDelete = false;
                spd.productName = sproduct.Product__r.Name;
                spd.siteCMFName = sproduct.SubProjectSite__r.Account__r.Name;
                siteProductList.add(spd);    
            }    
            productList = new list<ProductDetail>();
            allProdIds = new set<String>();
            //Clearing Products list & comparison set
        }
        system.debug('--------siteProductList---------'+siteProductList);
        return null;
    }

    public Pagereference deleteSiteProducts()
    {
        system.debug('------siteProductList-----'+siteProductList);
        list<Site_Product__c> siteProdLst = new list<Site_Product__c>();

        list<SiteProductDetail> tempLst = new list<SiteProductDetail>();

        for(SiteProductDetail sproduct: siteProductList)
        {
            if(sproduct.toDelete)
            {
                Site_Product__c sp = new Site_Product__c();
                sp.id = sproduct.sprodId;
                siteProdLst.add(sp);
            }else
            {
                tempLst.add(sproduct);
            }
        }
        try
        {
        	system.debug('-----siteProdLst--'+siteProdLst.size());
            if(!siteProdLst.isEmpty())
            {
               delete siteProdLst; 
            }
            else{
            	ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'No SiteProducts were selected'));
            }
            	
        }catch(Exception e){
            system.debug('----e-----'+e);
        }
        siteProductList = new list<SiteProductDetail>();
        siteProductList.addAll(tempLst);
        system.debug('--------siteProductList---------'+siteProductList);
        return null;
    }

    //Wrapper Classes Used
    public class ProductDetail
    {
        public String prodId {get;set;}
        public String prodName{get;set;}
        public String solutionId {get;set;}
        public String solutionName {get;set;}
        public String dealershipNeedId {get;set;}
        public String dealershipNeedName {get;set;}
    }

    public class SiteProductDetail
    {
        public string sprodId {get;set;}
        public boolean toDelete {get;set;}
        public String productName {get;set;}
        public String siteCMFName {get; set;} 
    }
    
    //-------OBSELETE CODE-----------
    /*public List<SelectOption> getProducts() {
    List<SelectOption> options = new List<SelectOption>();
    //options.add(new SelectOption('','-- None --'));
    prodRecs = new Map<id,Product__c>([
        select Id,Name, Solution__c, Solution__r.Name, Solution__r.Question_Category__c, Solution__r.Question_Category__r.Name 
        from Product__c where Active__c = true and Number_of_Questions__c > 0
    ]);
    
    system.debug('------------Products----'+prodRecs.values());
    for(Product__c prod : prodRecs.values()){
        options.add(new SelectOption(prod.Id, prod.Name + ' - '+ prod.Solution__r.Name + ' - '+ prod.Solution__r.Question_Category__r.Name ));
    }
    return options;
    }
   //-------Code - If there is no use of SiteProd EXT ID to check the duplicates of siteprod List 
   if(existingSiteProds!=null && !existingSiteProds.isEmpty())
            {
                for(Site_Product__c spd: existingSiteProds)
                {
                    Integer i=0;
                    while(i<siteProdsToInsert.size())
                    {
                        if(siteProdsToInsert[i].Product__c == spd.Product__c && siteProdsToInsert[i].SubProjectSite__c ==spd.SubProjectSite__c){
                            siteProdsToInsert.remove(i);
                            break;
                        }
                        else
                        {
                            i++;
                        }    
                    }    
                }
            }
    public PageReference displayErrorMessage()
    {
        ApexPages.addmessage(
            new ApexPages.message(
                ApexPages.Severity.Error, 
                'At least 1 SubProject-Site and 1-Product should be selected'
            )
        );
        
        return null;
    }*/
}