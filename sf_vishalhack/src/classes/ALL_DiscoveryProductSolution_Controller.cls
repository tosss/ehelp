public class ALL_DiscoveryProductSolution_Controller {
    
    //2016-08-22 Sanjay.ghanathey@cdk.com Discovery Project - Third Party Solutions Table.
    //2016-08-25 Sanjay.Ghanathey@cdk.com Updated : Fetch Records.
    //2016-08-26 Sanjay.Ghanathey@cdk.com Updated : Save and Cancel method.  
    //2016-09-05 Sanjay.Ghanathey@cdk.com Updated : Included TPSD and Sol at Site Obj.
    //2016-09-12 Sanjay.Ghanathey@cdk.com Updated : Added Other Solution.
    //2016-09-19 Sanjay.Ghanathey@cdk.com Updated : Show error at row level and existing rows appear first.
    //2016-09-21 venkata.shrivol@cdk.com -Updated : object name from Product_at_Site__c to discovery_Solution__c
    public static List<ALL_solutionsWrapper> solutionsWrapper{get;set;}
    public static List<Third_Party_Solution_Definition__c> existingTPSList{get;set;}
    public static List<Solution_at_Site__c> otherTPSList{get;set;}
    public static List<CDK_Solution_Definition__c> existingDSList{get;set;}
    public static String existingTPSIds{get;set;}
    public static String existingDSIds{get;set;}
    public static String CDK_SOLUTIONS_RT = 'CDK Solutions';
    public static String THIRD_PARTY_SOLUTIONS_RT = 'Third Party Solutions';    
    public static Solution_at_Site__c solutionAtSite{get;set;}
    public static Product_at_Site__c productAtSite{get;set;}
    public static String disableTPSForSoldProposed{get;set;}  
    public static String otherTPSIds{get;set;}         
    public static List<Product_at_Site__c> existingProductsList{get;set;}
    public static String existingProducts{get;set;}     
    public static List<ALL_solutionsWrapper> getRecords(){ 
        String OpportunityLocationId = ApexPages.currentPage().getParameters().get('OppLocId');
        solutionsWrapper = new List<ALL_solutionsWrapper>();
        existingTPSList = new List<Third_Party_Solution_Definition__c>();
        existingDSList = new List<CDK_Solution_Definition__c>();
        solutionAtSite = new Solution_at_Site__c();
        otherTPSList = new List<Solution_at_Site__c>();
        ALL_solutionsWrapper solutionsWrapperObject;
        String query = 'Select Id,Name,RecordTypeId,RecordType.Name,Application_Name__c,Access_Type__c, '+
            ' Application_Area__c,Business_Area__c,Status__c,Vendor__c,('+
            ' Select Id,Opportunity_Location__c,Notes_Comments__c,Proposed_and_Sold__c,Proposed__c,Current__c '+
            ' From Solution_at_Sites__r '+
            ' Where Opportunity_Location__c=:OpportunityLocationId ) '+
            ' From Third_Party_Solution_Definition__c';
        
        Opportunity_Location__c opportunityLocation = [
            Select Id,Opportunity__r.Account.Region__c 
            From Opportunity_Location__c
            Where Id=:OpportunityLocationId
        ];
        
        if(opportunityLocation.Opportunity__r.Account.Region__c.equalsIgnoreCase('Canada'))
        {
            query = query + ' Where RecordType.Name=\'Canada\''+
                ' ORDER BY Application_Name__c ASC';             
        }
        else
        {
            query = query + ' Where RecordType.Name=\'U.S.\'' +
                ' ORDER BY Application_Name__c ASC';              
        }
        
        List<Third_Party_Solution_Definition__c> thirdPartySolutionsList = Database.query(query);  
        List<Id> disableSoldProposed = new List<Id>();
        List<Id> allTPSIds = new List<Id>();
        for(Third_Party_Solution_Definition__c thirdPartyObject : thirdPartySolutionsList)
        {
            solutionsWrapperObject = new ALL_solutionsWrapper();              
            disableSoldProposed.add(thirdPartyObject.Id);
            List<Solution_at_Site__c> thirdPartySolutions = thirdPartyObject.Solution_at_Sites__r;            
            if(thirdPartySolutions!=null && !thirdPartySolutions.isEmpty() && thirdPartySolutions.size()>0)
            {
                existingTPSList.add(removeSpecialCharacterTPSD(thirdPartyObject));
                if(thirdPartySolutions.get(0).Notes_Comments__c != null){
                solutionsWrapperObject.notes = thirdPartySolutions.get(0).Notes_Comments__c.replaceAll('(?i)[^a-z0-9 ]', '');
                }                
                solutionsWrapperObject.isCurrent = thirdPartySolutions.get(0).Current__c;
                solutionsWrapperObject.isProposed = thirdPartySolutions.get(0).Proposed__c;
                solutionsWrapperObject.isSold = thirdPartySolutions.get(0).Proposed_and_Sold__c;
                solutionsWrapperObject.thirdPartyId = thirdPartySolutions.get(0).Id;
            }
            solutionsWrapperObject.tpsdObject = removeSpecialCharacterTPSD(thirdPartyObject);
            solutionsWrapperObject.isChecked = false;      
            solutionsWrapperObject.isCDKProduct = false;
            solutionsWrapper.add(solutionsWrapperObject);
        }
        allTPSIds.addAll(disableSoldProposed);
        //2017-01-30 sanjay.ghanathey@cdk.com Requirements Changes - Need to remove Proposed and Proposed and Sold and only TPS Records
       /* List<CDK_Solution_Definition__c> discoveryProducts = [
            Select Id,Name,Application_Area__c,Dealership_Area__c,Vendor__c,(
                Select Id,Opportunity_Location__c,Notes_Comments__c,Proposed_and_Sold__c,Proposed__c,Current__c 
                From Solution_at_Sites__r 
                Where Opportunity_Location__c=:OpportunityLocationId)
            From CDK_Solution_Definition__c where Active__c = true
        ];                
        
        for(CDK_Solution_Definition__c discoveryProduct : discoveryProducts){
            allTPSIds.add(discoveryProduct.Id);
            solutionsWrapperObject = new ALL_solutionsWrapper();
            Third_Party_Solution_Definition__c tempTpsd = new Third_Party_Solution_Definition__c();            
            List<Solution_at_Site__c> discoverySolutions = discoveryProduct.Solution_at_Sites__r; 
            solutionsWrapperObject.isChecked = false;
            if(discoverySolutions!=null && !discoverySolutions.isEmpty() && discoverySolutions.size()>0)
            {                                
                existingDSList.add(discoveryProduct);
                if(discoverySolutions.get(0).Notes_Comments__c != null){
                solutionsWrapperObject.notes = discoverySolutions.get(0).Notes_Comments__c.replaceAll('(?i)[^a-z0-9 ]', '');
                }
                solutionsWrapperObject.cdkSolutionId = discoverySolutions.get(0).Id;
                solutionsWrapperObject.isCurrent = discoverySolutions.get(0).Current__c;
                solutionsWrapperObject.isProposed = discoverySolutions.get(0).Proposed__c;
                solutionsWrapperObject.isSold = discoverySolutions.get(0).Proposed_and_Sold__c;
                solutionsWrapperObject.isChecked = true;
            }
            tempTpsd.Application_Name__c = discoveryProduct.Name;
            tempTpsd.Vendor__c = discoveryProduct.Vendor__c;
            solutionsWrapperObject.tpsdObject = removeSpecialCharacterTPSD(tempTpsd);             
            solutionsWrapperObject.isCDKProduct = true;
            solutionsWrapperObject.discoverySolutionId = discoveryProduct.Id;
            solutionsWrapper.add(solutionsWrapperObject);
        }
        */
        List<Solution_at_Site__c> solutions = [
            Select Id,Opportunity_Location__c,Notes_Comments__c,Proposed_and_Sold__c,Proposed__c,Current__c,Application_Name__c,Vendor__c
            From Solution_at_Site__c 
            Where Opportunity_Location__c=:OpportunityLocationId AND CDK_Solution_Definition__c NOT IN :allTPSIds AND Third_Party_Solution_Definition__c NOT IN :allTPSIds
        ];
        for(Solution_at_Site__c tps : solutions){
            solutionsWrapperObject = new ALL_solutionsWrapper();                        
            Third_Party_Solution_Definition__c tempTpsd = new Third_Party_Solution_Definition__c();                                
            if(tps.Notes_Comments__c != null){
                solutionsWrapperObject.notes = tps.Notes_Comments__c.replaceAll('(?i)[^a-z0-9 ]', '');
            }
            otherTPSList.add(tps);
            solutionsWrapperObject.cdkSolutionId = tps.Id;
            solutionsWrapperObject.isCurrent = tps.Current__c;
            solutionsWrapperObject.isProposed = tps.Proposed__c;
            solutionsWrapperObject.isSold = tps.Proposed_and_Sold__c;
            solutionsWrapperObject.isChecked = true;            
            tempTpsd.Application_Name__c = tps.Application_Name__c;
            tempTpsd.Vendor__c = tps.Vendor__c;
            solutionsWrapperObject.tpsdObject = removeSpecialCharacterTPSD(tempTpsd);             
            solutionsWrapperObject.isCDKProduct = true;
            solutionsWrapperObject.discoverySolutionId = tps.Id;
            solutionsWrapper.add(solutionsWrapperObject);
        }
        existingDSIds =  JSON.serialize(existingDSList);
        existingTPSIds = JSON.serialize(existingTPSList);
        disableTPSForSoldProposed = JSON.serialize(disableSoldProposed);
        otherTPSIds = JSON.serialize(otherTPSList);
        solutionsWrapper.sort();
        return solutionsWrapper;
    }
    public static Third_Party_Solution_Definition__c removeSpecialCharacterTPSD(Third_Party_Solution_Definition__c tempTpsd){
        if(tempTpsd.Application_Name__c != null){
            tempTpsd.Application_Name__c = tempTpsd.Application_Name__c.replaceAll('(?i)[^a-z0-9 ]', '');
        }
        if(tempTpsd.Vendor__c != null){
            tempTpsd.Vendor__c = tempTpsd.Vendor__c.replaceAll('(?i)[^a-z0-9 ]', '');
        }
        if(tempTpsd.Application_Area__c != null){
            tempTpsd.Application_Area__c = tempTpsd.Application_Area__c.replaceAll('(?i)[^a-z0-9 ]', '');
        }
        if(tempTpsd.Business_Area__c != null){
            tempTpsd.Business_Area__c = tempTpsd.Business_Area__c.replaceAll('(?i)[^a-z0-9 ]', ''); 
        }
        if(tempTpsd.Access_Type__c != null){
            tempTpsd.Access_Type__c = tempTpsd.Access_Type__c.replaceAll('(?i)[^a-z0-9 ]', '');
        }
        return tempTpsd;
    }
    public class ALL_solutionsWrapper implements Comparable{        
        public Boolean isChecked { get;set; } 
        public Boolean isCurrent { get;set; } 
        public Boolean isProposed { get;set; } 
        public Boolean isSold { get;set; }
        public Boolean isIncludeQuestion { get;set; } 
        public Boolean isCDKProduct { get;set; }  
        public Third_Party_Solution_Definition__c tpsdObject { get;set; }
        public String notes{ get;set; }
        public Id discoverySolutionId{ get;set; }
        public Id thirdPartyId{ get;set; }
        public Id cdkSolutionId{ get;set; } 
        public Discovery_Product_Definition__c dpdObject { get;set; }              
        public Id productId{ get;set; }
        public String otherDepartment{ get;set; }
        public String otherWorkflow{ get;set; }
        
        public Integer compareTo(Object compareTo) 
        {
            ALL_solutionsWrapper tpsWrapper = (ALL_solutionsWrapper) compareTo;            
            String currentName = (tpsdObject == null || tpsdObject.Application_Name__c == null ||
                                  String.isEmpty(tpsdObject.Application_Name__c) ? (dpdObject == null || dpdObject.Name == null ? '' : dpdObject.Name) : tpsdObject.Application_Name__c);
            String wrapperName = (tpsWrapper.tpsdObject.Application_Name__c == null || 
                                  tpsWrapper.tpsdObject.Application_Name__c == null || 
                                  String.isEmpty(tpsWrapper.tpsdObject.Application_Name__c) ? (tpsWrapper.dpdObject == null || tpsWrapper.dpdObject.Name == null ? '' : tpsWrapper.dpdObject.Name) : tpsWrapper.tpsdObject.Application_Name__c);
            return currentName.compareTo(wrapperName);
        }
    }   
    
    public static void SaveSolution()
    {        
        try
        {         
            Solution_at_Site__c thirdpartySolution;
            String OpportunityLocationId = ApexPages.currentPage().getParameters().get('OppLocId');            
            List<Solution_at_Site__c> thirdpartySolutionList = new List<Solution_at_Site__c>();                                    
            Schema.DescribeSObjectResult describeObject = Schema.SObjectType.Solution_at_Site__c;
            Map<String,Schema.RecordTypeInfo> rtMapByName = describeObject.getRecordTypeInfosByName(); 
            
            for(ALL_solutionsWrapper tempTpsWrapper : solutionsWrapper)
            {
                if(temptpsWrapper.isChecked)
                {                       
                    Third_Party_Solution_Definition__c tempTpsd = tempTpsWrapper.tpsdObject;
                    thirdPartySolution  = new Solution_at_Site__c();  
                    
                    if(!temptpsWrapper.isCDKProduct){                        
                        thirdPartySolution.Third_Party_Solution_Definition__c = tempTpsd.Id;
                        if(temptpsWrapper.thirdPartyId != null){
                            thirdPartySolution.Id = temptpsWrapper.thirdPartyId;
                        }
                    }
                    else{
                        //2017-01-30 sanjay.ghanathey@cdk.com Requirements Changes - Need to remove Proposed and Proposed and Sold and only TPS Records
                        /*thirdPartySolution.CDK_Solution_Definition__c = tempTpsWrapper.discoverySolutionId;
                        if(temptpsWrapper.cdkSolutionId!= null){
                            thirdPartySolution.Id = temptpsWrapper.cdkSolutionId;                            
                        }*/
                        if(tempTpsWrapper.discoverySolutionId != null)
                        {
                            thirdPartySolution.Id = tempTpsWrapper.discoverySolutionId;
                        }
                    }

                    
                    thirdPartySolution.Opportunity_Location__c = OpportunityLocationId;  
                    //2017-01-30 sanjay.ghanathey@cdk.com Requirements Changes - Needs to be always true
                    //thirdPartySolution.Current__c = tempTpsWrapper.isCurrent;
                    thirdPartySolution.Current__c = true;
                    //2017-01-30 sanjay.ghanathey@cdk.com Requirements Changes - Need to remove Proposed and Proposed and Sold
                    //thirdPartySolution.Proposed__c = tempTpsWrapper.isProposed;
                    //thirdPartySolution.Proposed_and_Sold__c = tempTpsWrapper.isSold;
                    Schema.RecordTypeInfo rtByName = rtMapByName.get(tempTpsd.RecordType.Name);
                    
                    if(!temptpsWrapper.isCDKProduct){
                        rtByName = rtMapByName.get(THIRD_PARTY_SOLUTIONS_RT);                        
                        thirdPartySolution.RecordTypeId = rtByName.getRecordTypeId();
                    }
                    else{
                        rtByName = rtMapByName.get(CDK_SOLUTIONS_RT);
                        thirdPartySolution.RecordTypeId = rtByName.getRecordTypeId();
                    }
                    
                    thirdPartySolution.Notes_Comments__c = temptpsWrapper.notes;
                    thirdpartySolutionList.add(thirdpartySolution); 
                }
            }
            
            if(thirdpartySolutionList != null && !thirdpartySolutionList.isEmpty())
            {                
                upsert thirdpartySolutionList; 
                ApexPages.Message successMessage = new ApexPages.Message(ApexPages.Severity.CONFIRM,
                                                                         'The selected Third Party Solutions have been saved successfully.');
                ApexPages.addMessage(successMessage);
            }
            else
            {
                ApexPages.Message infoMessage = new ApexPages.Message(ApexPages.Severity.WARNING,
                                                                      'Please select atleast one Third Party Solution.');
                ApexPages.addMessage(infoMessage); 
            }
        }
        catch(Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(errorMessage);
            system.debug('Exception in Third Party Solutions -'+e.getMessage()+e.getLineNumber());
        }        
    } 
    
    @RemoteAction
    public static void saveOtherSolution(String opportunityLocationId,String solutionName, String vendorName, 
                                         Boolean sold, Boolean current, Boolean proposed, String notes)
    {
        try{
            Schema.DescribeSObjectResult describeObject = Schema.SObjectType.Solution_at_Site__c;
            Map<String,Schema.RecordTypeInfo> rtMapByName = describeObject.getRecordTypeInfosByName();
            Schema.RecordTypeInfo rtByName = rtMapByName.get('Other Solution');                                 
            solutionAtSite = new Solution_At_Site__c();
            solutionAtSite.RecordTypeId = rtByName.getRecordTypeId();
            solutionAtSite.Other_Solution_Name__c = solutionName;
            solutionAtSite.Other_Vendor_Name__c = vendorName;
            //2017-01-30 sanjay.ghanathey@cdk.com Requirements Changes - Need to remove Proposed and Proposed and Sold
            //solutionAtSite.Proposed_and_Sold__c = sold;
            solutionAtSite.Current__c = current;
            //solutionAtSite.Proposed__c = proposed;
            solutionAtSite.Notes_Comments__c = notes;
            solutionAtSite.Opportunity_Location__c = opportunityLocationId; 
            
            insert solutionAtSite;
        }
        catch(Exception e){
            system.debug('Exception '+e.getMessage() +' line -'+e.getLineNumber());
        }
    } 
    
    @RemoteAction
    public static void deleteTPS(String thirdPartySolutionId,String opportunityLocationId){
        try{
            Solution_at_Site__c thirdPartySolution = [ 
                Select Id,Name 
                From Solution_at_Site__c
                Where (Third_Party_Solution_Definition__c=:thirdPartySolutionId OR CDK_Solution_Definition__c=:thirdPartySolutionId OR Id=:thirdPartySolutionId)
                And Opportunity_Location__c=:opportunityLocationId
                Limit 1
            ];
            delete thirdPartySolution;            
        }
        catch(Exception e){
            system.debug('Exception '+e.getMessage());
        }
    }     
    
    //Methods specifically for Products
    public static void SaveProduct()
    {        
        try
        {
            Product_at_Site__c discoveryProduct;
            String OpportunityLocationId = ApexPages.currentPage().getParameters().get('OppLocId');            
            List<Product_at_Site__c> productsList = new List<Product_at_Site__c>();                                    
            Schema.DescribeSObjectResult describeObject = Schema.SObjectType.Solution_at_Site__c;
            Map<String,Schema.RecordTypeInfo> rtMapByName = describeObject.getRecordTypeInfosByName(); 
            
            for(ALL_solutionsWrapper tempTpsWrapper : solutionsWrapper)
            {
                if(temptpsWrapper.isChecked)
                {                       
                    Discovery_Product_Definition__c tempPD = tempTpsWrapper.dpdObject;
                    discoveryProduct  = new Product_at_Site__c();
                    if(temptpsWrapper.productId != null){
                        discoveryProduct.Id = temptpsWrapper.productId;
                    }                    
                    
                    discoveryProduct.Opportunity_Location__c = OpportunityLocationId;  
                    discoveryProduct.Current__c = tempTpsWrapper.isCurrent;
                    discoveryProduct.Proposed__c = tempTpsWrapper.isProposed;
                    discoveryProduct.Proposed_and_Sold__c = tempTpsWrapper.isSold;
                    discoveryProduct.Discovery_Product_Definition__c = tempPD.Id;                
                    discoveryProduct.Notes__c = temptpsWrapper.notes;
                    discoveryProduct.Include_Questions__c = temptpsWrapper.isIncludeQuestion;
                    productsList.add(discoveryProduct); 
                }
            }
            
            if(productsList != null && !productsList.isEmpty())
            {
                upsert productsList; 
                ApexPages.Message successMessage = new ApexPages.Message(ApexPages.Severity.CONFIRM,
                                                                         'The selected products have been saved successfully.');
                ApexPages.addMessage(successMessage);
            }
            else
            {
                ApexPages.Message infoMessage = new ApexPages.Message(ApexPages.Severity.WARNING,
                                                                      'Please select atleast one product.');
                ApexPages.addMessage(infoMessage); 
            }
        }
        catch(Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(errorMessage);
            system.debug('Exception in products -'+e.getMessage()+e.getLineNumber());
        }      
    } 
    
    
    public static List<ALL_solutionsWrapper> getProducts(){ 
        String OpportunityLocationId = ApexPages.currentPage().getParameters().get('OppLocId');
        solutionsWrapper = new List<ALL_solutionsWrapper>();
        existingProductsList = new List<Product_at_Site__c>();        
        ALL_solutionsWrapper solutionsWrapperObject; 
        List<Id> allProductIds = new List<Id>();
        
        List<Discovery_Product_Definition__c> productsDefinition = [
            Select Id,Name,Department__c,Workflow__c,(
                Select Id,Name,Notes__c,Current__c,Include_Questions__c,Proposed__c,Proposed_and_Sold__c,Other_Department__c,Other_Workflow__c 
                From Discovery_Product_Definitions__r 
                Where Opportunity_Location__c=:OpportunityLocationId
            ) 
            From Discovery_Product_Definition__c where Active__c = true  
            Order By Name ASC
        ];
        for(Discovery_Product_Definition__c productsDef : productsDefinition)
        {
            allProductIds.add(productsDef.Id);
            solutionsWrapperObject = new ALL_solutionsWrapper();                                       
            List<Product_at_Site__c> discoveryProducts = productsDef.Discovery_Product_Definitions__r;            
            if(discoveryProducts!=null && !discoveryProducts.isEmpty() && discoveryProducts.size()>0)
            {
                existingProductsList.addAll(discoveryProducts);
                if(discoveryProducts.get(0).Notes__c != null){
                    solutionsWrapperObject.notes = discoveryProducts.get(0).Notes__c.replaceAll('(?i)[^a-z0-9 ]', '');
                }
                solutionsWrapperObject.isCurrent = discoveryProducts.get(0).Current__c;
                solutionsWrapperObject.isProposed = discoveryProducts.get(0).Proposed__c;
                solutionsWrapperObject.isSold = discoveryProducts.get(0).Proposed_and_Sold__c;
                solutionsWrapperObject.productId = discoveryProducts.get(0).Id;
                solutionsWrapperObject.otherDepartment = discoveryProducts.get(0).Other_Department__c;
                solutionsWrapperObject.otherWorkflow = discoveryProducts.get(0).Other_Workflow__c;  
                solutionsWrapperObject.isIncludeQuestion = discoveryProducts.get(0).Include_Questions__c;
            }
            if(productsDef.Name != null){
                productsDef.Name = productsDef.Name.replaceAll('(?i)[^a-z0-9 ]', '');
            }
            solutionsWrapperObject.dpdObject = productsDef;
            solutionsWrapperObject.isChecked = false;                  
            solutionsWrapper.add(solutionsWrapperObject);
        }                
        
        List<Product_at_Site__c> products = [
            Select Id,Other_Product_Name__c,Include_Questions__c,Other_Department__c,Other_Workflow__c,Opportunity_Location__c,Notes__c,Proposed_and_Sold__c,Proposed__c,Current__c,Discovery_Product_Definition__c
            From Product_at_Site__c 
            Where Opportunity_Location__c=:OpportunityLocationId AND Discovery_Product_Definition__c NOT IN :allProductIds
            Order By Other_Product_Name__c ASC
        ];
        for(Product_at_Site__c pas : products){
            solutionsWrapperObject = new ALL_solutionsWrapper();                        
            Discovery_Product_Definition__c tempDpd = new Discovery_Product_Definition__c();              
            if(pas.Other_Product_Name__c != null){                               
                tempDpd.Name = pas.Other_Product_Name__c.replaceAll('(?i)[^a-z0-9 ]', '');
            } 
            if(pas.Notes__c != null){                
                solutionsWrapperObject.notes = pas.Notes__c.replaceAll('(?i)[^a-z0-9 ]', '');
            }            
            solutionsWrapperObject.productId = pas.Id;
            solutionsWrapperObject.isCurrent = pas.Current__c;
            solutionsWrapperObject.isProposed = pas.Proposed__c;
            solutionsWrapperObject.isSold = pas.Proposed_and_Sold__c;
            solutionsWrapperObject.isChecked = true;
            solutionsWrapperObject.otherDepartment = pas.Other_Department__c;
            solutionsWrapperObject.otherWorkflow = pas.Other_Workflow__c;                   
            solutionsWrapperObject.dpdObject = tempDpd;  
            solutionsWrapperObject.isIncludeQuestion = pas.Include_Questions__c;
            solutionsWrapper.add(solutionsWrapperObject);
            existingProductsList.add(pas);            
        }
        
        existingProducts =  JSON.serialize(existingProductsList); 
        solutionsWrapper.sort();
        return solutionsWrapper;
    }
    
    @RemoteAction
    public static void deleteProduct(String productId,String opportunityLocationId){
        try{            
            Product_at_Site__c discoveryProduct = [ 
                Select Id,Name,Discovery_Product_Definition__c 
                From Product_at_Site__c
                Where (Discovery_Product_Definition__c=:productId OR Id=:productId)
                And Opportunity_Location__c=:opportunityLocationId
                Limit 1
            ];               
            
            //Need to delete the answers if product is deleted
            //Need to Optimize Queries
            Discovery_Site_Workbook__c discoveryWorkbook = [
                Select Id 
                From Discovery_Site_Workbook__c 
                Where Opportunity_Location__c=:opportunityLocationId
            ];                        
            
            List<Discovery_Product_Question__c> productQuestions = [
                Select Discovery_Question__c 
                From Discovery_Product_Question__c 
                Where Discovery_Product_Definition__c=:discoveryProduct.Discovery_Product_Definition__c
            ];
            
            List<Id> questionIds = new List<Id>();
            for(Discovery_Product_Question__c tempQuestion : productQuestions){
                questionIds.add(tempQuestion.Discovery_Question__c);
            }
            List<Discovery_Answer__c> discoveryAnswers = [
                Select Id 
                From Discovery_Answer__c 
                Where Discovery_Site_Workbook__c=:discoveryWorkbook.Id and Discovery_Question__c=:questionIds
            ];
            delete discoveryAnswers; 
            delete discoveryProduct;
        }
        catch(Exception e){
            system.debug('Exception '+e.getMessage());
        }
    }
    
    @RemoteAction
    public static void saveOtherProduct(String opportunityLocationId,String productName, 
                                        Boolean sold, Boolean current, Boolean proposed, String notes)
    {
        try{
            String currentRecordType;
            productAtSite = new Product_At_Site__c();
            productAtSite.Other_Product_Name__c = productName;            
            productAtSite.Proposed_and_Sold__c = sold;
            productAtSite.Current__c = current;
            productAtSite.Proposed__c = proposed;
            productAtSite.Notes__c = notes;            
            productAtSite.Opportunity_Location__c = opportunityLocationId; 
            
            insert productAtSite;
        }
        catch(Exception e){
            system.debug('Exception '+e.getMessage() +' line -'+e.getLineNumber());
        }
    } 
}