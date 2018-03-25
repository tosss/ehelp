/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Controller for IMP_ProjectLinks that displays on the subproject all RMS, Impact Project, Contract,
CMF from the related external entities, Opportunity Solution designs from SubProjectOpp,
and the Mission Links from subproject externel reference
Test Class:
History
09/15/14    Kimiko Roberto      Created
11/25/14    Kimiko Roberto      Updated link generation links that derive to the specific RMS Request, if no overarching Impact
number for the set of requests exist for the given Subproject.
01/23/15    Hemanth				Added logic to set the size of the links
02/23/15    Sanjay				Horizontal links and a bug in RMS 
------------------------------------------------------------*/
public class IMP_ProjectLinks_Controller{
    
    public SubProject__c subProject {get;set;}
    //set maps for values and urls by getting from the custom setting IMP_ProjectLinksUrls;this is what will reflect to the page
    public Map<String, String> RMSLinks {get;set;}    
    public Map<String, String> ImpactProjectLinks {get;set;}
    public Map<String, String> ContractLinks {get;set;}
    public Map<String, String> CMFLinks {get;set;}
    public Map<String, String> SolutionDesigns {get;set;}
    public Map<String, String> MissionLinks {get;set;}
    //01/23/15 Hemanth Added variable to hold the size of the list
    public Integer lastIndexOfRMS{get;set;}
    public Integer lastIndexOfImpact{get;set;}
    public Integer lastIndexOfContract{get;set;}
    public Integer lastIndexOfMission{get;set;}
    public Integer lastIndexOfSolution{get;set;}
    public Integer lastIndexOfCMFLinks{get;set;}
    
    public IMP_ProjectLinks_Controller(ApexPages.StandardController subProjectController){
        
        try
        {
            //get subproject record from the standard controller
            this.subProject = (SubProject__c )subProjectController.getRecord();
            
            if(subProject!= null)
            {
                //generate urls by passing subproject and entity type to get properly mapped values from the custom setting
                RMSLinks = GenerateLinks(subProject, 'RMS Request');
                lastIndexOfRMS = RMSLinks.size();
                ImpactProjectLinks = GenerateLinks(subProject, 'Impact Project'); system.debug(ImpactProjectLinks);
                lastIndexOfImpact = ImpactProjectLinks.size();
                ContractLinks = GenerateLinks(subProject, 'Contract');
                lastIndexOfContract = ContractLinks.size();
                MissionLinks = GenerateLinks(subproject, 'NIS');
                lastIndexOfMission = MissionLinks.size();
                SolutionDesigns = GetSolutionDesigns(subProject, 'Solution_Design__c');
                lastIndexOfSolution = SolutionDesigns.size();
                CMFLinks = GenerateLinks(subProject, 'CMF');
                lastIndexOfCMFLinks = CMFLinks.size();
                List<string> ImpactProjectNumbers = new List<string>(ImpactProjectLinks.keySet());               
            }
        }
        catch(Exception e)
        {
            System.debug('Execption '+e.getMessage()+' at  '+e.getLineNumber());
        }
    }
    
    //create the Urls based on the entity type passed; entity type values and the urls from the custom setting will be concatinated to complete the full url
    public static MAP<string, string> GenerateLinks(SubProject__c p, String entityType)
    {
        try
        {
            
        //get URL value from custom setting IMP_ProjectLinksUrls
        Map<String, IMP_ProjectLinksUrls__c> urlValues = IMP_ProjectLinksUrls__c.getAll();
        //create a map for the final url output; it will be the final output retruned containing the complete url
        Map<string, string> completeURL = new Map<string, string>();
        String newURL = '';
        String URL = '';
        List<SubProject_External_Related_Entity__c> entityList = new List<SubProject_External_Related_Entity__c>();
        Map<Id, String> RMStoImpactIds = new Map<Id, String>(); // 2015-03-31 Matt Keefe - added map for generating links
        List<SubProject_External_Reference__c> externalReferenceList = new List<SubProject_External_Reference__c>();
        List<Organization> orgList = [SELECT Id FROM Organization LIMIT 1];
        String orgId = '';
        
        for(Organization org : orgList){
            orgId = org.Id;
        }
        
        //get values from SubProject External Related Entity Object from the passed subproject object; the entity number will be concatinated to the url to create the full url
        //for rms request numbers, we also get the values of the Impact Numbers to redirect the user within the RMS system to the overall Impact Project # (which can have have multiple RMS #s)
        //except if there is no present Impact Number
        
        if(entityType == 'Impact Project')
        {
            entityList = IMP_Project_Utility.retrieveExternalRelatedEntity(p.Id, 'Impact Project');
            //entityList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE SubProject__c = :p.Id AND Entity_Type__c = 'Impact Project'];
        }
        else if(entityType == 'RMS Request')
        {
            // default to no Impact Numbers
            entityType = 'RMS Request without Impact';
            
            List<SubProject_External_Related_Entity__c> ImpactEntityList = IMP_Project_Utility.retrieveExternalRelatedEntity(p.Id, 'Impact Project');
            //entityList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE SubProject__c = :p.Id AND Entity_Type__c = 'Impact Project'];
            
            // 2015-03-31 Matt Keefe - added ImpactEntity variable for compiling a list of RMS and Impact Ids
            SubProject_External_Related_Entity__c ImpactEntity = null;
            if(ImpactEntityList != null && !ImpactEntityList.isEmpty()) { ImpactEntity = ImpactEntityList.get(0); }
            
            //if the following if statement resolves to 'TRUE', it means that we have an Impact Project #
            //so, we'll use the retreive the RMS Request(s), and generate links with their unique values
            if(!ImpactEntityList.isEmpty()) {
                entityType = 'RMS Request with Impact';
            }
            
            // pull all RMS Request entities (do not pass entityType, as the value has changed)
            entityList = IMP_Project_Utility.retrieveExternalRelatedEntity(p.Id, 'RMS Request');
            
            // 2015-03-31 Matt Keefe - added RMS to Impact Map
            for(SubProject_External_Related_Entity__c entity : entityList) 
            { 
                if(entityType.equals('RMS Request with Impact'))
                {
                    RMStoImpactIds.put(entity.Id, ImpactEntity.Entity_Number__c); 
                }
                else
                {
                    RMStoImpactIds.put(entity.Id, entity.Entity_Number__c); 
                }
            }
        }
        else if(entityType == 'Contract'){
            entityList = IMP_Project_Utility.retrieveExternalRelatedEntity(p.Id, 'Contract');
            //entityList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE SubProject__c = :p.Id AND Entity_Type__c = 'Contract'];
        }
        //get values from SubProject External Reference Object from the passed subproject object; the Mission Id will be concatinated to the url to create the full url
        else if(entityType == 'NIS'){
            externalReferenceList = IMP_Project_Utility.retrieveExternalReference(p.Id, 'NIS');
            //externalReferenceList = [SELECT Mission_ID__c FROM SubProject_External_Reference__c WHERE SubProject__c = :p.Id AND Record_Type_Name__c = 'NIS'];
        }
        //get values from SubProject External Related Entity Object from the passed subproject object; the entity number will be concatinated to the url to create the full url
        else if(entityType == 'CMF'){
            entityList = IMP_Project_Utility.retrieveExternalRelatedEntity(p.Id, 'CMF');  
        }
        
        //get url values from the custom setting and map them with the proper entity type; this will then be concatinated to the acquired Entity numbers and Mission Ids
        URL = urlValues.get(entityType).URL_Value__c;
        
        for(SubProject_External_Related_Entity__c val : entityList)
        {
            // 2015-03-31 Matt Keefe - modified to add ImpactNumber 
            //   instead of RMS number for RMS entitys
            if(entityType != null && entityType.contains('RMS')) {
                String ImpactNumber = RMStoImpactIds.get(val.Id);
                newURL = URL + ImpactNumber;
            }
            else {
                newURL = URL + val.Entity_Number__c;
            }
            
            //add additional suffix if entity type is = CMF
            if(entityType == 'CMF'){
                newURL = newURL + '&rs:Command=Render';
            }
            
            completeURL.put(val.Entity_Number__c, newURL);
        }
        
        for(SubProject_External_Reference__c val : externalReferenceList)
        {
            newURL = URL + val.Mission_ID__c + '&organizationId=' + orgId;
            completeURL.put(val.Mission_ID__c, newURL);
            
        }
            return completeURL;
        }
        catch(Exception e)
        {
            System.debug('Execption '+e.getMessage()+' at  '+e.getLineNumber());
            return null;
        }
    }
    
    
    //get solution design from related opportunities of SubProject from SubprojectOpp from the passed subproject object
    public static Map<string, string> GetSolutionDesigns(SubProject__c p, string fieldApiName)
    {    //get URL value from custom setting IMP_ProjectLinksUrls ; this will be used to create the full URL shown in the page
        Map<String, IMP_ProjectLinksUrls__c> urlValues = IMP_ProjectLinksUrls__c.getAll();
        String newURL = '';
        String URL = '';
        CustomSettings__c CS = CustomSettings__c.getOrgDefaults();
        //create map for the final url output
        Map<string, string> completeURL = new Map<string, string>();
        List<SubProjectOpp__c> subProjectOppList = IMP_Project_Utility.retrieveSubProjectOpps(p.Id);
        
        URL = urlValues.get(fieldApiName).URL_Value__c;
        List<Id> oppIds = new List<Id>();
        
        //get opportunities from the subprojectopp ; this will be used to determinse solution designs
        for(SubProjectOpp__c subProjOpp : subProjectOppList){
            oppIds.add(subProjOpp.Opportunity__c);
        }
        
        List<Opportunity> oppList = [Select Id FROM Opportunity WHERE Id IN : oppIds];
        //get solution designs present from the list of opportunities        
        list<Solution_Design__c> SolutionDesigns = [
            Select Id, Name, Solution_Design_Name__c 
            From Solution_Design__c 
            Where Opportunity__c IN :oppList
        ];
        
        //construct complete url for the solution design by concatinating the opportunity name, solution design and the url from the custom setting
        for(Solution_Design__c solDes : SolutionDesigns){
            //newURL = URL + '?SID='+ solDes.Name + '&UID=' + Userinfo.getUserId();
            newURL = 'http://' + CS.SAWebServer__c + '/' + CS.SAPortal__c + URL + solDes.Name + '&UID=' + Userinfo.getUserId();
            completeURL.put(solDes.Name + '-' + solDes.Solution_Design_Name__c, newURL);
        }
        
        return completeURL;
    }
    
}