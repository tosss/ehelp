//2016-10-05- anirudh.singh@cdk.com- Created this Extension for ALL_MassCreateOppSites Visualforce Page.
//2017-04-28- anirudh.singh@cdk.com- Modified this class for RQ-09132 Merge Add Opportunity Sites Pages & Functionality.
public class ALL_MassCreateOppSites_Extension
{
    //This is used to hold the unique Account Ids for which the Site record is present for the Opportunity record.
    public Map<Id, Id> accIdAndSiteIdsMap{get; set;}
    
    //This is used to hold the Opportunity record.
    public Opportunity opportunityRecord{get; set;}
    
    //This is used to hold the accounts list for which Sites are manually added.
    public List<Account> displayManuallyAddedAccsList{get; set;}
    
    //This is the list of ColumnNameLabelWrapper to display the Manually Added accounts.
    //As the list from ALL_AccountHierarchy_Controller is static and it comes as Null on fetching in this class extension.
    public List<ALL_AccountHierarchy_Controller.ColumnNameLabelWrapper> columnNameLabelWrapperList{get; set;}
    
    public Boolean userDiscAccess{get; set;}
    
    //This is the Constructor of the class.
    public ALL_MassCreateOppSites_Extension(ALL_AccountHierarchy_Controller accHierarchyController)
    {
        //This is used to fetch the opportunity Id from the page parameter.
        String opportunityId=ApexPages.currentPage().getParameters().get('oppId');
        
        //Initializing the Manually Added accounts list and ColumnNameLabelWrapper.
        displayManuallyAddedAccsList=new List<Account>();
        columnNameLabelWrapperList=new List<ALL_AccountHierarchy_Controller.ColumnNameLabelWrapper>();
        
        //If opportunity Id passed as the page parameter is not Null.
        if(opportunityId!=Null)
        {
            //Try block to catch any error during fetching the records.
            try
            {
                //Fetch the record type id for Site Record Type.
                Id siteRecordTypeId=fetchSiteRecordTypeId();
                
                //Fetch the Opportunity record and its Child Opportunity Location (Site) records.
                opportunityRecord=[
                    SELECT Id, Name, AccountId, 
                    (
                        SELECT Id, Site__c 
                        FROM Opportunity_Sites__r
                        WHERE RecordTypeId=:siteRecordTypeId
                    ) 
                    FROM Opportunity 
                    WHERE Id=:opportunityId
                ];
                
                //Get the Account Ids from the Opportunity Location (Sites) records.
                accIdAndSiteIdsMap=new Map<Id, Id>();
                if(opportunityRecord.Opportunity_Sites__r!=Null && opportunityRecord.Opportunity_Sites__r.size()>0)
                {
                    for(Opportunity_Location__c oppSite: opportunityRecord.Opportunity_Sites__r)
                    {
                        accIdAndSiteIdsMap.put(oppSite.Site__c, oppSite.Id);
                    }
                }
                
                //Putting AccountId as Null, just to display the Account Name as blank when the Add Site Lookup is displayed in the Modal.
                //This is not saved on the Opportunity record.
                opportunityRecord.AccountId=Null;
                
                //2017-04-28- anirudh.singh@cdk.com- Added the below line for RQ-09132.
                userDiscAccess=fetchUserDiscAccess();
            }
            catch(Exception ex)
            {
                system.debug('Error '+ex.getMessage()+' at Line No. '+ex.getLineNumber());
            }
        }
    }
    
    //This is used to get the Site Record Type Id for Opportunity Location object.
    private static Id fetchSiteRecordTypeId()
    {
        return Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
    }
    
    //2017-04-28- anirudh.singh@cdk.com- Added the below method for RQ-09132.
    //This method checks if the user has discovery access or not.
    private static Boolean fetchUserDiscAccess()
    {
        Boolean discAccess=false;
        
        List<PermissionSetAssignment> permSetAssignmentList=new List<PermissionSetAssignment>([
            SELECT Id 
            FROM PermissionSetAssignment 
            WHERE AssigneeId=:UserInfo.getUserId()
            AND PermissionSetId IN (
                SELECT Id 
                FROM PermissionSet
                WHERE IsOwnedByProfile=false
                AND Label='Discovery App'
            )
        ]);
        
        if(permSetAssignmentList.size()>0)
        {
            discAccess=true;
        }
        
        return discAccess;
    }
    
    //This remote action is invoked from JQuery ALL_MassCreateOppSites_JS.
    @RemoteAction 
    public static Map<Id, String> createOpportunitySites(List<String> accountIdsList, Id opportunityId)
    {
        //Fetch the record type id for Site Record Type.
        Id siteRecordTypeId=fetchSiteRecordTypeId();
        
        //This is used to hold the Opportunity Location (Site) records to be created.
        List<Opportunity_Location__c> oppSitesList=new List<Opportunity_Location__c>();
        
        //Opportunity Location (Site) records are added to the oppSitesList for the selected Accounts.
        for(String accountId: accountIdsList)
        {
            Opportunity_Location__c oppSiteRecord=new Opportunity_Location__c();
            oppSiteRecord.RecordTypeId=siteRecordTypeId;
            oppSiteRecord.Opportunity__c=opportunityId;
            oppSiteRecord.Site__c=accountId;
            oppSitesList.add(oppSiteRecord); 
        }
        
        //Opportunity Location (Site) records are inserted.
        List<Database.SaveResult> oppSitesSaveResult=Database.insert(oppSitesList, false);
        
        //This is used to hold any errors in inserting the Opportunity Location (Site) records.
        //It holds Account Id and Error String Map.
        Map<Id, String> accIdAndErrorsMap=new Map<Id, String>();
        
        //Errors are processed.
        for(Integer i=0; i<oppSitesSaveResult.size(); i++)
        {
            //Errors are processed, if fail.
            if(!oppSitesSaveResult[i].isSuccess())
            {
                //Error message is combined as a String.
                String errorMessage='';
                for(Database.Error err: oppSitesSaveResult[i].getErrors())
                {
                    errorMessage+=(errorMessage=='') ? err.getMessage() : '\n'+err.getMessage();
                }
                accIdAndErrorsMap.put(accountIdsList[i], errorMessage);
            }
        }
        //accIdAndErrorsMap.put(accountIdsList[0], 'hi');
        
        //Account Id and Error String Map is returned.
        return accIdAndErrorsMap;
    }
    
    //This remote action is invoked from JQuery ALL_MassCreateOppSites_JS.
    /*@RemoteAction
    public static Map<Id, String> deleteOppSite(String accountId, Id opportunityId)
    {
        //Fetch the record type id for Site Record Type.
        Id siteRecordTypeId=fetchSiteRecordTypeId();
        
        //Fething the Site record and their building records. This will be made to fetch only Site records, once
        //the Trigger to delete Building records on deletion of Site record is in place.
        List<Opportunity_Location__c> oppSitesAndBuildingsList=[
            SELECT Id, Site__c 
            FROM Opportunity_Location__c 
            WHERE Opportunity__c=:opportunityId 
            AND Site__c=:accountId 
            //AND RecordTypeId=:siteRecordTypeId
        ];
        
        //Opportunity Location records are deleted.
        List<Database.DeleteResult> oppLocationsDeleteResult=Database.delete(oppSitesAndBuildingsList, false);
        
        //This is used to hold any errors in deleting the Opportunity Location (Site) records.
        //It holds Account Id and Error String Map.
        Map<Id, String> accIdAndErrorsMap=new Map<Id, String>();
        
        //Errors are processed.
        for(Integer i=0; i<oppLocationsDeleteResult.size(); i++)
        {
            //Errors are processed, if fail.
            //Also, only for Site Record Type. Since, we are displaying only Sites on the Page.
            if(!oppLocationsDeleteResult[i].isSuccess() && oppSitesAndBuildingsList[i].RecordTypeId==siteRecordTypeId)
            {
                //Error message is combined as a String.
                String errorMessage='';
                for(Database.Error err: oppLocationsDeleteResult[i].getErrors())
                {
                    errorMessage+=(errorMessage=='') ? err.getMessage() : '\n'+err.getMessage();
                }
                accIdAndErrorsMap.put(accountId, errorMessage);
            }
        }
        
        //Account Id and Error String Map is returned.
        return accIdAndErrorsMap;
    }*/
    
    //This is used to fetch the Manually Added Sites.
    //It is invoked from an action function named fetchManuallyAddedSitesFunction.
    public void fetchManuallyAddedSites()
    {
        //The parameters passed from the action function are fetched.
        String accIdsManuallyAdded=ApexPages.currentPage().getParameters().get('accIdsManuallyAdded');
        String accColumnsToBeFetched=ApexPages.currentPage().getParameters().get('accColumnsToBeFetched');
        String colNameLabelMap=ApexPages.currentPage().getParameters().get('colNameLabelMap');
        
        //accIdsManuallyAdded and colNameLabelMap Parameters are deserialized.
        List<String> accIdsManuallyAddedList=(List<String>)system.JSON.deserialize(accIdsManuallyAdded, List<String>.class);
        columnNameLabelWrapperList=
            (List<ALL_AccountHierarchy_Controller.ColumnNameLabelWrapper>)system.JSON.deserialize(colNameLabelMap, List<ALL_AccountHierarchy_Controller.ColumnNameLabelWrapper>.class);
        
        //Query String is built.
        String queryString='SELECT '+accColumnsToBeFetched+' FROM Account WHERE Id IN :accIdsManuallyAddedList';
        
        //This is used to hold any error message while fetching the records.
        String errorMessage='';
        try
        {
            //Initializing the Account list for Manually Added Sites.
            displayManuallyAddedAccsList=new List<Account>();
            
            //Fetching the Account list for Manually Added Sites.
            displayManuallyAddedAccsList=database.query(queryString);
        }
        catch(Exception ex)
        {
            errorMessage=ex.getMessage();
        }
    }
}