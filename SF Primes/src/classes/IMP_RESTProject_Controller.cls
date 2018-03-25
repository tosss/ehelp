/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Web Service integration for creating Projects for Impact
Test Class:
History
09/08/14    Kimiko Roberto      Created
01/15/15    Kimiko Roberto      -Added Business Unit to both Project and Subproject
-Updated to create a SubprojectSite for each of the incoming cmfs
-Removed logic to update Account and CMF fields in both Project and Subproject
-Removed logic to directly create Subproject External Related Entities for CMFs
02/06/15    Kimiko Roberto      -Added new logic to associate CMFs to the SubProjectSite created.
03/04/15    Matt Keefe          -When debugging, fixed formatting issues; brought into compliance with standards
04/02/15    Venkata Shrivol     -Added MainContractID as an extra attribute in ProjectObject and sorted the 
                                 "finalContractNumberSet" to "finalContractNumberList" with MainContractID infront.
04/22/15   Venkata Shrivol      -Added SubProject-Id, SubProjectName to be sent back as Response. 
------------------------------------------------------------*/
@RestResource(urlMapping='/v1/projects/*')
global with sharing class IMP_RESTProject_Controller 
{
    //Create a response and Project based on the data caught
    // (Project Name, Project Number, Impact Number, CMF, RMS number, Contract, list of deal Ids and dealerCMF)
    // together with this response is the creation of the Project
    @HttpPost   
    global static Response_POST_Project createNewProject(ProjectObject project) 
    {
        Response_POST_Project response = new Response_POST_Project();
        
        //query the passed project name to check if it is existing.         
        List<Project__c> checkProject = [
        Select Id,Name,
        (select Id,Name from SubProjects__r order by createdDate) 
        FROM Project__c 
        WHERE Name = :project.projectName];
        
        //Instantiate a log for the Integration's result; 
        //this is a log for the integration's result wether the project is created or not.                                                                                                         
        PM_Interface_Audit_Log__c auditlog = new PM_Interface_Audit_Log__c(
            Interface_Name__c = 'Impact to Salesforce',
            Executed_By__c = userinfo.getuserid(),
            External_Unique_Id_XREF__c = project.projectNumber,
            JSON_Message__c = JSON.serializePretty(project));
        
        //Check if Project is existing through the passed Project Name; 
        //this will determine if the project is already existing or not and create a failure response
        if(checkProject.isEmpty() && (project.projectName != null && project.projectName != ''))
        {
            try
            {
                //List<CMF_Info__c> matchCMF = new List<CMF_Info__c>();
                //CMF_Info__c dealCMF = new CMF_Info__c();
                List<String> cmfNumbersList = new List<String>();
                List<CMF_Info__c> finalCMFList = new List<CMF_Info__c>();
                Date convertedContractRollCalledDate;
                Map<Id, List<CMF_Info__c>> accountIdtoCMFInfoMap = new Map<Id, List<CMF_Info__c>>();
                
                /*
                if(project.dealerCMF != null && project.dealerCMF != '')
                {
                    //find matching dealerCMF from the passed dealerCMF; if there is a match dealer CMF, 
                    //it's Account will be set as the Project and the Subproject's Dealer group
                    matchCMF = IMP_Project_Utility.retrieveCMFInfo(project.dealerCMF, 'Ship_CMF__c');
                    
                    List<CMF_Info__c> matchCMF = [
                        SELECT Id, Account__c, Main_CMF__c, Ship_CMF__c, Status__c
                        FROM CMF_Info__c
                        WHERE Ship_CMF__c = :project.dealerCMF
                        AND Status__c ='A'
                    ];
                    
                    if(!matchCMF.isEmpty()){
                        dealCMF = matchCMF.get(0);
                    }
                    else{        
                        //failure to match a dealerCMF will be logged together with the actual dealerCMF value 
                        if(auditlog.Failure_Reason_Code__c == null || auditlog.Failure_Reason_Code__c == ''){
                            auditlog.Failure_Reason_Code__c = 'No match to Dealer CMF: '+ project.dealerCMF + ';';
                        }
                        else{
                            auditlog.Failure_Reason_Code__c = auditlog.Failure_Reason_Code__c + 'No match to Dealer CMF: '+ project.dealerCMF + ';';
                        }                                                        
                        
                    }
                }
                else{
                    //add a failure reason code due to a null or empty value on dealerCMF
                    if(auditlog.Failure_Reason_Code__c == null || auditlog.Failure_Reason_Code__c == ''){
                        auditlog.Failure_Reason_Code__c = 'dealerCMF is null or empty;';
                    }
                    else{
                        auditlog.Failure_Reason_Code__c = auditlog.Failure_Reason_Code__c + 'dealerCMF is null or empty;';
                    }
                    
                }
                */

                // do null check on all params nad log it on failure reason code; to be sent as response to impact team
                if(project.cmfNumbersList == null || project.cmfNumbersList.isEmpty())
                {
                    
                    if(auditlog.Failure_Reason_Code__c == null || auditlog.Failure_Reason_Code__c == '')
                    {
                        auditlog.Failure_Reason_Code__c = 'cmfNumbersList is null or empty;';
                    }
                    else
                    {
                        auditlog.Failure_Reason_Code__c = auditlog.Failure_Reason_Code__c + 'cmfNumbersList is null or empty;';
                    }
                }
                else
                {
                    cmfNumbersList = project.cmfNumbersList;
                }
                
                if(project.dealerCMF == null || project.dealerCMF == '')
                {
                    if(auditlog.Failure_Reason_Code__c == null || auditlog.Failure_Reason_Code__c == '')
                    {
                        auditlog.Failure_Reason_Code__c = 'dealerCMF is null or empty;';
                    }
                    else
                    {
                        auditlog.Failure_Reason_Code__c = auditlog.Failure_Reason_Code__c + 'dealerCMF is null or empty;';
                    }
                }
                else
                {   
                    
                    if(project.cmfNumbersList != null && !project.cmfNumbersList.isEmpty())
                    {
                        
                        cmfNumbersList.add(0, project.dealerCMF);
                    }
                    else
                    {
                        cmfNumbersList.add(project.dealerCMF);
                    }
                    
                }
                
                //remove duplicates and remove nulls from cmf list and create final cmf list
                if(cmfNumbersList != null && !cmfNumbersList.isEmpty())
                {
                    cmfNumbersList = IMP_Project_Utility.removeDuplicatesFromList(cmfNumbersList);
                    cmfNumbersList = IMP_Project_Utility.removeNullElements(cmfNumbersList);
                    system.Debug('**cmfNumbersList: '+ cmfNumbersList);
                    finalCMFList = IMP_Project_Utility.retrieveCMFInfo(cmfNumbersList, 'Ship_CMF__c');
                    
                    if(!finalCMFList.isEmpty())
                    {
                        //add each matching account to our accountIdtoCMFInfoMap map together with their associated cmf infos
                        //this map will be used later to build a subprojectsite
                        
                        for(CMF_Info__c cmf : finalCMFList)
                        {
                            if(!accountIdtoCMFInfoMap.containsKey(cmf.Account__c))
                            {
                                List<CMF_Info__c> associatedCMFstoAccountList = new List<CMF_Info__c>(); 
                                associatedCMFstoAccountList.add(cmf);
                                accountIdtoCMFInfoMap.put(cmf.Account__c,associatedCMFstoAccountList);  
                            }
                            else
                            {
                                accountIdtoCMFInfoMap.get(cmf.Account__c).add(cmf);
                            }      
                        }
                    }
                    system.Debug('**accountIdtoCMFInfoMap.size(): '+accountIdtoCMFInfoMap.size());
                }
                
                if(project.contractNumbersList == null || project.contractNumbersList.isEmpty())
                {
                    if(auditlog.Failure_Reason_Code__c == null || auditlog.Failure_Reason_Code__c == '')
                    {
                        auditlog.Failure_Reason_Code__c = 'contractNumbersList is null or empty;';
                    }
                    else
                    {
                        auditlog.Failure_Reason_Code__c = auditlog.Failure_Reason_Code__c + 'contractNumbersList is null or empty;';
                    }
                }
                
                if(project.MainContractID == null || project.MainContractID == '')
                {
                    if(auditlog.Failure_Reason_Code__c == null || auditlog.Failure_Reason_Code__c == '')
                    {
                        auditlog.Failure_Reason_Code__c = 'MainContractID is null or empty;';
                    }
                    else
                    {
                        auditlog.Failure_Reason_Code__c = auditlog.Failure_Reason_Code__c + 'MainContractID is null or empty;';
                    }
                }
                
                if(project.rmsRequestNumbersList == null || project.rmsRequestNumbersList.isEmpty())
                {
                    if(auditlog.Failure_Reason_Code__c == null || auditlog.Failure_Reason_Code__c == '')
                    {
                        auditlog.Failure_Reason_Code__c = 'rmsRequestNumbersList is null or empty;';
                    }
                    else
                    {
                        auditlog.Failure_Reason_Code__c = auditlog.Failure_Reason_Code__c + 'rmsRequestNumbersList is null or empty;';
                    }
                }
                
                if(project.projectNumber == null || project.projectNumber == '')
                {
                    if(auditlog.Failure_Reason_Code__c == null || auditlog.Failure_Reason_Code__c == '')
                    {
                        auditlog.Failure_Reason_Code__c = 'projectNumber is null or empty;';
                    }
                    else 
                    {
                        auditlog.Failure_Reason_Code__c = auditlog.Failure_Reason_Code__c + 'projectNumber is null or empty;';
                    }
                }
                
                if(project.BusinessUnit == null || project.BusinessUnit == '')
                {
                    if(auditlog.Failure_Reason_Code__c == null || auditlog.Failure_Reason_Code__c == '')
                    {
                        auditlog.Failure_Reason_Code__c = 'BusinessUnit is null or empty;';
                    }
                    else
                    {
                        auditlog.Failure_Reason_Code__c = auditlog.Failure_Reason_Code__c + 'BusinessUnit is null or empty;';
                    }
                }
                
                if(project.contractRollCalledDate == null || project.contractRollCalledDate == '')
                {
                    if(auditlog.Failure_Reason_Code__c == null || auditlog.Failure_Reason_Code__c == '')
                    {
                        auditlog.Failure_Reason_Code__c = 'contractRollCalledDate is null or empty;';
                    }
                    else
                    {
                        auditlog.Failure_Reason_Code__c = auditlog.Failure_Reason_Code__c + 'contractRollCalledDate is null or empty;';
                    }
                }
                else
                {
                    convertedContractRollCalledDate = date.valueOf(project.contractRollCalledDate);
                }
                
                //truncate project name with project length greater than 80, though subproject will get its original value
                String truncatedPrjName = '';
                String truePrjName = project.projectName;
                
                if(project.projectName.length() > 80)
                {
                    truncatedPrjName = project.projectName.substring(0,80);
                    project.projectName = truncatedPrjName;
                } 
                
                //create Project and Subproject from the passed Project Name and set their status to open; Subproject will also get the Project's name as default                                                                                                                        
                Project__c createdProject = new Project__c(
                    Name = project.projectName,
                    Project_Status__c = 'Open',
                    Project_Region__c = project.BusinessUnit);
                insert createdProject;
                
                SubProject__c createdSubproject = new SubProject__c(
                    Project__c = createdProject.Id,
                    SubProject_Name__c = truePrjName,
                    SubProject_Status__c = 'Open',
                    Contract_Roll_Called__c = convertedContractRollCalledDate,
                    SubProject_Region__c = project.BusinessUnit);
                
                if(project.dealIdList != null && !project.dealIdList.isEmpty())
                {
                    for(String dealId : project.dealIdList)
                    {
                        if(createdSubproject.Deal_Id__c != null && createdSubproject.Deal_Id__c != '')
                        {
                            createdSubproject.Deal_Id__c = createdSubproject.Deal_Id__c + dealId + ';';
                        }
                        else
                        {
                            createdSubproject.Deal_Id__c = dealId + ';';
                        }
                    }
                }
                
                insert createdSubproject;
                
                SubProject__c createdSubprojectRecord = new SubProject__c();
                
                if(createdSubproject.Id!=null)
                {
                	try 
                	{ 
                		 createdSubprojectRecord = [select Id, Name from SubProject__c where Id =:createdSubproject.Id limit 1]; 
                	}
                	catch(Exception ex) 
                	{ 
                		system.debug('------Exception--------'+ex);
                	}
                }
                
                //create SubProjectSites from the matching CMFs
                List<SubProjectSite__c> newSubProjectSiteList = new List<SubProjectSite__c>();
                
                system.Debug('**finalCMFList: '+finalCMFList);
                system.Debug('**accountIdtoCMFInfoMap: '+accountIdtoCMFInfoMap);
                
                
                if(!accountIdtoCMFInfoMap.isEmpty())
                {
                    //iterate thorugh each account in the map
                    for(Id key : accountIdtoCMFInfoMap.keySet())
                    {
                        //create a container for the cmfs that will be associated in the subproject site
                        List<String> shipCMFsList = new List<String>();
                        SubProjectSite__c newSubProjectSite = new SubProjectSite__c(
                            Account__c = key,
                            SubProject__c = createdSubproject.Id
                        );
                        
                        //get the values of all cmfs associated to the account key
                        for(CMF_Info__c cmfinfo : accountIdtoCMFInfoMap.get(key))
                        {
                            //identify the dealer cmf that will define the subproject sites CMF Name
                            if((project.dealerCMF != null && project.dealerCMF != '') && cmfinfo.Ship_CMF__c == project.dealerCMF){
                                newSubProjectSite.CMF_Name__c = cmfInfo.Id;
                            }
                            else if(newSubProjectSite.CMF_Name__c == null){
                                newSubProjectSite.CMF_Name__c = cmfInfo.Id;
                            }
                            
                            //we get all the associated cmfs 
                            shipCMFsList.add(cmfinfo.Ship_CMF__c);
                        }
                        
                        //concatenate all cmfs gathered and stamp it to the CMF_Numbers__c field of the subproject site
                        system.Debug('**shipCMFsList: '+shipCMFsList);
                        newSubProjectSite.CMF_Numbers__c = string.Join(shipCMFsList,',');
                        
                        system.Debug('**newSubProjectSite.CMF_Numbers__c: '+newSubProjectSite.CMF_Numbers__c);
                        newSubProjectSiteList.add(newSubProjectSite);
                    }
                    
                    if(!newSubProjectSiteList.isEmpty()){
                        system.Debug('**newSubProjectSiteList: '+newSubProjectSiteList);
                        insert newSubProjectSiteList;
                    }
                    
                }
                
                //create SubProject related External Entities from the passed list of 
                //contractNumbersList, rmsRequestNumbersList, projectNumber and also using 
                //the recently created Project and SubProject
                
                createExternalEntities(
                    project.contractNumbersList,
                    project.MainContractID, 
                    project.rmsRequestNumbersList,
                    project.projectNumber,
                    createdSubproject.Id,
                    createdProject.Id);
                
                if(project.dealIdList != null && !project.dealIdList.isEmpty())
                {
                    //fetch deal ids from the passed deal id list and match to opportunity quote; this will be used to create SubprojectOpp records
                    List<Opportunity_Quotes__c> matchingOpportunityList = IMP_Project_Utility.retrieveOppQuotesBySet(project.dealIdList);
                    //List<Opportunity_Quotes__c> matchingOpportunityList = [SELECT Id, Name, Deal_ID__c, Opportunity__c FROM Opportunity_Quotes__c        
                    //WHERE Deal_ID__c IN : project.dealIdList];
                    
                    if(!matchingOpportunityList.isEmpty()){
                        List<SubProjectOpp__c> subProjectOppList = new List<SubProjectOpp__c>();
                        
                        for(Opportunity_Quotes__c opporunityQuotes : matchingOpportunityList)
                        {
                            SubProjectOpp__c subProjectOpp = new SubProjectOpp__c(
                                SubProject__c = createdSubproject.Id, Opportunity__c = opporunityQuotes.Opportunity__c,
                                Project__c = createdProject.Id);
                            
                            subProjectOppList.add(subProjectOpp);
                        }
                        
                        //create SubProjectOpp if there are matching Opportunities
                        if(!subProjectOppList.isEmpty()){            
                            insert subProjectOppList;
                        }
                    }
                }
                else
                {
                    if(auditlog.Failure_Reason_Code__c == null || auditlog.Failure_Reason_Code__c == ''){
                        auditlog.Failure_Reason_Code__c = 'dealIdList is null or empty;';
                    }
                    else{
                        auditlog.Failure_Reason_Code__c = auditlog.Failure_Reason_Code__c + 'dealIdList is null or empty;';
                    } 
                }
                
                //set log result to success after successful project creation; this record will 
                //acquire the impact project number sfdc id of the project created and msgs of the result
                auditlog.Result__c = 'Success';
                auditlog.Unique_Id_XREF__c = createdProject.Id;
                auditlog.Unique_SubProject_Id_XREF__c = createdSubproject.Id;
                auditlog.Unique_SubProject_Name_XREF__c = createdSubprojectRecord.Name;
                insert auditlog;
                
                //set response as successful added with the Project created Name, Salesforce Id, 
                //Impact Number and Log Id; this will be sent as a response to the impact system
                response.isSuccess = true;
                response.message = 'Project '+ createdProject.Name +' Created.';
                response.auditlogId = auditlog.Id;                                        
                response.impactProjectNum = auditlog.External_Unique_Id_XREF__c;
                response.salesforceProjectNum = auditlog.Unique_Id_XREF__c;
                response.salesforceSubProjectNum = auditlog.Unique_SubProject_Id_XREF__c;
                response.salesforceSubProjectName = auditlog.Unique_SubProject_Name_XREF__c;
            }
            catch(Exception e)
            {
                //set response as failed with the error msg, Failure msg, Impact Number and Log Id 
                //if an error occurs; this will be sent to impact system notifying them 
                //that a failure occured during creation
                auditlog.Result__c = 'Failure';
                if(auditlog.Failure_Reason_Code__c == null || auditlog.Failure_Reason_Code__c == '')
                {
                    auditlog.Failure_Reason_Code__c = e.getMessage() + ';';
                }
                else
                {
                    auditlog.Failure_Reason_Code__c = auditlog.Failure_Reason_Code__c + e.getMessage() + ';';
                } 
                
                insert auditlog;
                
                response.isSuccess = false;                
                response.message = auditlog.Failure_Reason_Code__c;
                response.auditlogId = auditlog.Id;
                response.impactProjectNum = auditlog.External_Unique_Id_XREF__c;
                response.salesforceProjectNum = auditlog.Unique_Id_XREF__c;
                response.salesforceSubProjectNum = auditlog.Unique_SubProject_Id_XREF__c;
                response.salesforceSubProjectName = auditlog.Unique_SubProject_Name_XREF__c;
            }
        }
        else
        {
            //set response as failed with the Existing project name, error msg, Failure msg, 
            //Impact Number and Log Id; this will be sent to the impact system notifying 
            //them that the project is already existing
            auditlog.Result__c = 'Failure';
            
            if(project.projectName == null || project.projectName == '')
            {
                if(auditlog.Failure_Reason_Code__c == null || auditlog.Failure_Reason_Code__c == ''){
                    auditlog.Failure_Reason_Code__c =  'Project Name is null or empty;';
                }
                else{
                    auditlog.Failure_Reason_Code__c = auditlog.Failure_Reason_Code__c + 'Project Name is null or empty;';
                } 
            }
            else{
                if(auditlog.Failure_Reason_Code__c == null || auditlog.Failure_Reason_Code__c == ''){
                    auditlog.Failure_Reason_Code__c =  'Project '+ project.projectName +' already exists.' + ';';
                }
                else{
                    auditlog.Failure_Reason_Code__c = auditlog.Failure_Reason_Code__c + 'Project '+ project.projectName +' already exists.' + ';';
                }
                
                Project__c existingProject = checkProject.size()>0 ? checkProject.get(0) : new Project__c();
                SubProject__c existingSubProject = existingProject.SubProjects__r.size() > 0 ? existingProject.SubProjects__r.get(0) : new SubProject__c();
                
                response.salesforceProjectNum=existingProject.Id;
                response.salesforceSubProjectNum=existingSubProject.Id;
                response.salesforceSubProjectName=existingSubProject.Name;
                
            }
            
            insert auditlog;
            
            response.isSuccess = false;
            response.message = auditlog.Failure_Reason_Code__c;
            response.auditlogId = auditlog.Id;
            response.impactProjectNum = auditlog.External_Unique_Id_XREF__c;
            if(response.salesforceProjectNum ==null){
            response.salesforceProjectNum = auditlog.Unique_Id_XREF__c;
            }
            if(response.salesforceSubProjectNum ==null){
            response.salesforceSubProjectNum = auditlog.Unique_SubProject_Id_XREF__c;
            }
            if(response.salesforceSubProjectName ==null){
            response.salesforceSubProjectName = auditlog.Unique_SubProject_Name_XREF__c;
            }
        }
        system.debug('----Response-----'+response);
        return response;
    }
    
    //method for creating SubProject External Entities that gets the passed list of contractNumbersList, rmsRequestNumbersList, impactProjectNumber
    //this values will be used for creation of URLs for the Impact system
    public static void createExternalEntities(
        List<String> contractNumbersList, String MainContractID, List<String> rmsRequestNumbersList, String impactProjectNumber, Id subProject, Id project)
    {
    	
        Set<String> existingContractSPERESet = IMP_Project_Utility.checkDuplicateExternalEntity('Contract', subProject);
        Set<String> existingRmsSPERESet = IMP_Project_Utility.checkDuplicateExternalEntity('RMS Request', subProject);
        Set<String> existingImpactNumSPERESet = IMP_Project_Utility.checkDuplicateExternalEntity('Impact Project', subProject);
        
        
        List<SubProject_External_Related_Entity__c> newExternalRefEntityList = new List<SubProject_External_Related_Entity__c>();
        
        if(contractNumbersList != null && !contractNumbersList.isEmpty())
        {
            Set<String> contractNumbersSet = new Set<String>();
            //convert list to Set
            
            contractNumbersSet.addAll(contractNumbersList);
            
            Set<String> finalContractNumberSet = IMP_Project_Utility.getUniqueElementsOfSetOne(contractNumbersSet, existingContractSPERESet);
            
            //converting finalSet to finalList
            list<String> finalContractNumberList = new list<String>();
            if((MainContractID!=null && MainContractID!= '') && finalContractNumberSet.contains(MainContractID))
            {
            	finalContractNumberSet.remove(MainContractID);
            	finalContractNumberList.addAll(finalContractNumberSet);
            	finalContractNumberList.sort();
            	if(finalContractNumberList == null || finalContractNumberList.isEmpty() ){
            		finalContractNumberList.add(MainContractID);
            	}
            	else{
            		finalContractNumberList.add(0,MainContractID);
            	}
            }
            else{
            	finalContractNumberList.addAll(finalContractNumberSet);
            	finalContractNumberList.sort();
            }
            system.debug('----finalContractNumberList-----'+finalContractNumberList);
            //add fetched contractNumbers and create an entity with type Contract
            if(finalContractNumberList != null && !finalContractNumberList.isEmpty())
            {
                for(String contract : finalContractNumberList)
                {   
                    
                    SubProject_External_Related_Entity__c contractNumber = new SubProject_External_Related_Entity__c(
                        SubProject__c = subProject,
                        Project__c = project,
                        Entity_Type__c = 'Contract',
                        Entity_Number__c = contract
                    );
                                                                                                                  
                    newExternalRefEntityList.add(contractNumber);
                    
                }
            }
            
        }
        
        if(rmsRequestNumbersList != null && !rmsRequestNumbersList.isEmpty())
        {
            Set<String> rmsNumbersSet = new Set<String>();
            //convert list to Set
            
            rmsNumbersSet.addAll(rmsRequestNumbersList);
            
            
            Set<String> finalRmsNumberSet = IMP_Project_Utility.getUniqueElementsOfSetOne(rmsNumbersSet, existingRmsSPERESet);
            //add fetched rmsRequestNumbers and create an entity with type CMF
            if(finalRmsNumberSet != null && !finalRmsNumberSet.isEmpty())
            {
                for(String rms : finalRmsNumberSet)
                {            
                    SubProject_External_Related_Entity__c rmsNumber = new SubProject_External_Related_Entity__c(
                        SubProject__c = subProject,
                        Project__c = project,
                        Entity_Type__c = 'RMS Request',
                        Entity_Number__c = rms
                    );                                                                                            
                    
                    
                    newExternalRefEntityList.add(rmsNumber);
                    
                    
                }
            }
            
        }
        
        if(impactProjectNumber != null && impactProjectNumber != '')
        {   
            Set<String> impactNumbersSet = new Set<String>();           
            impactNumbersSet.add(impactProjectNumber);
            
            Set<String> finalImpactNumberSet = IMP_Project_Utility.getUniqueElementsOfSetOne(impactNumbersSet, existingImpactNumSPERESet);
            //add fetched impactProjectNumber and create an entity with type Impact Project
            if(finalImpactNumberSet != null && !finalImpactNumberSet.isEmpty())
            {
                SubProject_External_Related_Entity__c impactNumber = new SubProject_External_Related_Entity__c(
                    SubProject__c = subProject,
                    Project__c = project,
                    Entity_Type__c = 'Impact Project',
                    Entity_Number__c = impactProjectNumber
                );
                
                newExternalRefEntityList.add(impactNumber);
            }   
            
            
        }
        
        if(!newExternalRefEntityList.isEmpty() && newExternalRefEntityList != null)
        {
            //create the entities; these entities will be related to the created subproject      
            insert newExternalRefEntityList;
        }
    }
    
    /* OBJECTS */
    
    global class ProjectObject {
        //Request parameters
        global String projectName {get;set;}
        global String projectNumber {get;set;}
        global List<String> cmfNumbersList {get;set;}
        global List<String> contractNumbersList {get;set;}
        global List<String> rmsRequestNumbersList {get;set;}
        global List<String> dealIdList {get;set;}
        global String dealerCMF {get;set;}
        global String MainContractID {get;set;}
        global String contractRollCalledDate {get;set;}
        global String BusinessUnit {get;set;}
    }
    
    /* REQUESTs */
    
    global class Request_POST_Project {
        global ProjectObject project {get;set;}
    }
    
    /* RESPONSEs */
    
    global class Response_POST_Project {
        //response parameters
        global boolean isSuccess {get;set;}
        global String message {get;set;}
        global String auditlogId {get;set;}
        global String impactProjectNum {get;set;}
        global String salesforceProjectNum {get;set;}
        global String salesforceSubProjectNum {get;set;}
        global String salesforceSubProjectName {get;set;}
        
    }
}