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
10/5/15     Venkata shrivol		re-factored the code
------------------------------------------------------------*/
public class IMP_ProjectLinks_Controller{
    
    public SubProject__c subProject {get;set;}
    
    //map<entityType, list<map<entityNumber, URL>>>
    public map<string, list<map<string, string>>> finalMap {get; set;}
    
    //map<enitityNumber, entityNumberListSize>
    public static map<string, Integer> entityNumberMapSize {get; set;}
    public map<String, String> SolutionDesigns {get;set;}
    public Integer lastIndexOfSolution{get;set;}
     
    public IMP_ProjectLinks_Controller(ApexPages.StandardController subProjectController)
    {
        try
        {
        	//map<entityType, list<map<entityNumber, URL>>>
        	finalMap = new map<string, list<map<string, string>>>();
        	
        	entityNumberMapSize = new map<String, Integer>();
        	
        	set<string> allProjectLinks = new set<string>{'RMS Request','Impact Project','CMF','NIS','Contract'};
            
            //get subproject record from the standard controller
            this.subProject = (SubProject__c )subProjectController.getRecord();
            
            if(subProject!= null)
            {
            	// populate the links for solution designs
            	SolutionDesigns = GetSolutionDesigns(subProject, 'Solution_Design__c');
                lastIndexOfSolution = SolutionDesigns.size();
            	
            	// Retrieve all the entities from a subProject
            	SubProject__c thisSubPrj = [
            		select Id, 
            		(
            			select Entity_Type__c, Entity_Number__c 
			    		from SubProject_External_Related_Entities__r
			    	),
			    	( 
			    		select Mission_ID__c, Record_Type_Name__c  
			    		from SubProject_External_References__r
			    		where RecordType.Name ='NIS'
			    	) 
			    	from SubProject__c where Id =:subProject.Id
			    ]; 
			    	
            	list<SubProject_External_Related_Entity__c> entityListOfSubProject = 
            	
            		thisSubPrj.SubProject_External_Related_Entities__r!=null ? thisSubPrj.SubProject_External_Related_Entities__r: 
            		new list<SubProject_External_Related_Entity__c>();
            		
            	list<SubProject_External_Reference__c> externalReferencesOfSubProject = 
            	
            		thisSubPrj.SubProject_External_References__r!=null ? thisSubPrj.SubProject_External_References__r: 
            		new list<SubProject_External_Reference__c>();
            	
            	
            	// Sort all the retrieved entitites into a map<entityType, list<entityNumbers>>
			    map<string, list<string>> entityTypeToNumberMap = new map<string, list<string>>();
			    
			    for(SubProject_External_Related_Entity__c spere:entityListOfSubProject)
			    {
			    	list<string> tempList = entityTypeToNumberMap.containsKey(spere.Entity_Type__c) ? 
			    							entityTypeToNumberMap.get(spere.Entity_Type__c) : 
			    							new list<String>();
			    	tempList.add(spere.Entity_Number__c);
			    	entityTypeToNumberMap.put(spere.Entity_Type__c, tempList);
			    }
			    
			    for(SubProject_External_Reference__c sper:externalReferencesOfSubProject)
			    {
			    	list<string> tempList = entityTypeToNumberMap.containsKey(sper.Record_Type_Name__c) ? 
			    							entityTypeToNumberMap.get(sper.Record_Type_Name__c) : 
			    							new list<String>();
			    	tempList.add(sper.Mission_ID__c);
			    	entityTypeToNumberMap.put(sper.Record_Type_Name__c, tempList);
			    }
			    
			    for(string entityType:allProjectLinks)
			    {
			    	if(!entityTypeToNumberMap.keySet().contains(entityType))
			    	{
			    		list<string> tempList = new list<string>();
			    		entityTypeToNumberMap.put(entityType, tempList);
			    	}
			    }
			    
			    system.debug('-----entityTypeToNumberMap---'+entityTypeToNumberMap);
			    
			    if(!entityTypeToNumberMap.isEmpty())
			    {
			    	finalMap = GenerateLinks(entityTypeToNumberMap);	
			    }
            }
        }
        catch(Exception e)
        {
            System.debug('Execption '+e.getMessage()+' at  '+e.getLineNumber());
        }
    }
    
    public static map<string, list<map<string, string>>> GenerateLinks(map<string, list<string>> entityTypeToNumberMap)
    {
    	string orgId = UserInfo.getOrganizationId(); // orgId used in populating solution design links
    	map<string, string> numberToURLMap;
    	list<map<string, string>> numberToURLMapList;
    	map<string, list<map<string, string>>> completeURLMap = new map<string, list<map<string, string>>>();
    	
    	//retrieve all the URLS from custom settings
    	Map<String, IMP_ProjectLinksUrls__c> allInitialEntityURLMap = IMP_ProjectLinksUrls__c.getAll();
    	string entityTypeURL = '';
        string resetURLForEntNum ='';
    	boolean rmsWithImpactCheck = false;
    	
    	
    	if(!allInitialEntityURLMap.isEmpty())
    	{
    		for(String entityType: entityTypeToNumberMap.keySet())
	    	{
	    		numberToURLMapList = new list<map<string, string>>();
				
	    		if(entityType!='RMS Request')
	    		{
	    			entityTypeURL = allInitialEntityURLMap.get(entityType)!=null ? allInitialEntityURLMap.get(entityType).URL_Value__c : '';
	    			entityNumberMapSize.put(entityType, entityTypeToNumberMap.get(entityType).size());
	    		}
	    		else
	    		{
	    			// When entityType is RMS and the same subproject contains Impact Project number
	    			if(!entityTypeToNumberMap.get('Impact Project').isEmpty())
	    			{
	    				entityTypeURL = allInitialEntityURLMap.get('RMS Request with Impact')!=null ? allInitialEntityURLMap.get('RMS Request with Impact').URL_Value__c : '';
	    				entityNumberMapSize.put(entityType, 1);
	    				rmsWithImpactCheck = true;	
	    			}
	    			// When entityType is RMS and the same subproject does not contains Impact Project number
	    			else
	    			{
	    				entityTypeURL = allInitialEntityURLMap.get('RMS Request without Impact')!=null ? allInitialEntityURLMap.get('RMS Request without Impact').URL_Value__c : '';
	    				entityNumberMapSize.put(entityType, entityTypeToNumberMap.get(entityType).size());
	    			}
	    			
	    		}
	    		
	    		// From the url retrieved above, modify it according to entityType and add it to the list of maps
	    		for(String entityNumber:entityTypeToNumberMap.get(entityType))
	    		{
	    			numberToURLMap = new map<string, string>();
                    resetURLForEntNum = entityTypeURL;
	    			if(rmsWithImpactCheck)
	    			{
	    				numberToURLMap = generateRMSURL(entityTypeToNumberMap.get('Impact Project').get(0), resetURLForEntNum);
	    				numberToURLMapList.add(numberToURLMap);
	    				rmsWithImpactCheck = false;
	    				break;
	    			}
	    			else
	    			{
	    				resetURLForEntNum +=entityNumber;
	    				if(entityType =='CMF')
	    				{
	    					resetURLForEntNum += '&rs:Command=Render';
	    				}
	    				else if(entityType =='NIS')
	    				{
	    					resetURLForEntNum += '&organizationId=' + orgId;
	    				}
	    				numberToURLMap.put(entityNumber, resetURLForEntNum);
	    				numberToURLMapList.add(numberToURLMap);
	    			}
	    		}
	    		completeURLMap.put(entityType, numberToURLMapList);
	    		
	    	}
	    	
	    	// This below check is for the subproject where it has a impact project number but it doesn't have RMS number
	    	if(!entityTypeToNumberMap.get('Impact Project').isEmpty() && entityTypeToNumberMap.get('RMS Request').isEmpty())
	    	{
	    		map<string, string> tempMap = new map<string, string>();
	    		list<map<string, string>> tempMapList = new list<map<string, string>>();
	    		tempMap = generateRMSURL(entityTypeToNumberMap.get('Impact Project').get(0), allInitialEntityURLMap.get('RMS Request with Impact').URL_Value__c);
	    		tempMapList.add(tempMap);
	    		completeURLMap.put('RMS Request', tempMapList);
	    		entityNumberMapSize.put('RMS Request', 1);
	    	}
    	}
    	return completeURLMap;
    } 
    
    public static map<string, string> generateRMSURL(string impactProjectNumber, string rmsURL)
    {
    	map<string, string> tempMap = new map<string, string>();
    	if(impactProjectNumber!=null && rmsURL!=null)
    	{
    		rmsURL += impactProjectNumber;
			tempMap.put(impactProjectNumber, rmsURL);
    	}
		return tempMap;
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
        set<Id> oppIds = new set<Id>();
        
        //get opportunities from the subprojectopp ; this will be used to determinse solution designs
        for(SubProjectOpp__c subProjOpp : subProjectOppList){
            oppIds.add(subProjOpp.Opportunity__c);
        }
        
        //List<Opportunity> oppList = [Select Id FROM Opportunity WHERE Id IN : oppIds];
        //get solution designs present from the list of opportunities        
        list<Solution_Design__c> SolutionDesigns = [
            Select Id, Name, Solution_Design_Name__c 
            From Solution_Design__c 
            Where Opportunity__c IN :oppIds
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