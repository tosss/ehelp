//2016-05-04- anirudh.singh@cdk.com- Created this class for RQ-06978 as EMP_PolicyAcknowledgementPageController was not following naming standard.
public class EMP_AcknowledgementPage_Controller
{
    private Map <Id, EMP_Policy__c> policyMap{get; set;}
    private List<EMP_Policy__c> policyList{get; set;}
    private Contact currentUserContactRecord{get; set;}
    
    public List<EMP_Policy__c> policiesWithStatusTrueList{get; set;}
    public List<EMP_Policy__c> policiesWithStatusFalseList{get; set;}
    public Id policyId{get; set;}
    public Boolean showTable{get; set;}
    
    public EMP_AcknowledgementPage_Controller()
    {
        system.debug('Start EMP_AcknowledgementPage_Controller---->');
        policyMap=new Map<Id, EMP_Policy__c>();
        policiesWithStatusTrueList=new List<EMP_Policy__c>();
        policiesWithStatusFalseList=new List<EMP_Policy__c>();
        activeUserContact();
        fetchPoliciesList();
        system.debug('End EMP_AcknowledgementPage_Controller---->');
    }
    
    private void activeUserContact()
    {
        system.debug('Start activeUserContact---->');
        currentUserContactRecord=new Contact();
        try
        {
            currentUserContactRecord=[
                SELECT Id
                FROM Contact
                WHERE User__c=:UserInfo.getUserId()
                AND Status__c='Active'
                LIMIT 1
            ];
        }
        catch(Exception ex)
        {
            currentUserContactRecord=Null;
        }
        system.debug('End activeUserContact---->');
    }
    
    private void fetchPoliciesList()
    {
        system.debug('Start fetchPoliciesList---->');
        try
        {
            if(currentUserContactRecord!=Null)
            {
                policyList=[
                    SELECT Acknowledgement_Status__c, Content_Version_ID__c, Date_of_Acknowledgement__c, Policy_Addition_Date__c,
                    Name, VersionNumber__c
                    FROM EMP_Policy__c
                    WHERE Employee_Contact__c=:currentUserContactRecord.Id
                    ORDER BY Policy_Addition_Date__c DESC
                ];
            }
            
            for(EMP_Policy__c policyRecord: policyList)
            {
                if(policyRecord.Acknowledgement_Status__c==true)
                {
                    policiesWithStatusTrueList.add(policyRecord);
                    showTable=true;
                }
                else
                {
                    policiesWithStatusFalseList.add(policyRecord);
                }
            }
        }
        catch(exception ex)
        {
        }
        system.debug('End fetchPoliciesList---->');
    }
    
    //This method will set the selected record as acknowledge.
    public void acknowledgePolicy()
    {
        system.debug('Start acknowledgePolicy---->');
        List<EMP_Policy__c> updatePoliciesList=new List<EMP_Policy__c>();
        
        if(currentUserContactRecord!=Null)
        {
            for(EMP_Policy__c policyRecord : [
                SELECT Acknowledgement_Status__c, Content_Version_ID__c, Date_of_Acknowledgement__c, Policy_Addition_Date__c,
                Name, VersionNumber__c
                FROM EMP_Policy__c
                WHERE Employee_Contact__c=:currentUserContactRecord.Id
                AND Id=:policyId])
            { 
                if(policyRecord.Acknowledgement_Status__c==false)
                {
                    policyRecord.Acknowledgement_Status__c=true;
                    policyRecord.Date_of_Acknowledgement__c=dateTime.now();
                    updatePoliciesList.add(policyRecord);
                }
            }
        }
        
        if(!updatePoliciesList.isEmpty() || updatePoliciesList.size()>0)
        {       
            update updatePoliciesList;       
        }
        system.debug('End acknowledgePolicy---->');
    }
}