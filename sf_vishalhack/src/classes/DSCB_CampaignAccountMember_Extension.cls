public class DSCB_CampaignAccountMember_Extension 
{
    //Instance variables
    public Campaign_Account_Members__c campaignAccountMemberObject {get;set;}
    public String selectedItem{get;set;} 
    public Id recordId ;
    public String returnURL;
    public Static final String CAMPAIGN_ACCOUNT_MEMBERS = 'Campaign_Account_Members__c';
    public Static final String ACCOUNT_OBJECT_NAME = 'Account';
    public Static final String CAMPAIGN_OBJECT_NAME = 'Campaign';
    public Static final String ID_PATTERN = '^[a-zA-Z0-9]*$';
    private  boolean isEditMode=false;
    private  boolean isCreateMode=false;
    
    //Getters and Setters
    public boolean getIsEditMode()
    {
        return this.isEditMode;
    }
    public boolean getIsCreateMode()
    {
        return this.isCreateMode;
    }
    
    //constructor to get the values as soon as the page is loaded
    public DSCB_CampaignAccountMember_Extension(ApexPages.StandardController controller)
    {       
        //captures id and return url form the current page url
        recordId=ApexPages.CurrentPage().getparameters().get('id');
        returnURL= ApexPages.CurrentPage().getparameters().get('retURL');
        
        //check edit or create mode
        if(recordId!=null && returnURL!=null)
        {
            isEditMode=true;
            campaignAccountMemberObject = [
                select id,name,Account__r.Name,Campaign__r.Name,Composite_ID__c, Campaign_Member_Status__c 
                from Campaign_Account_Members__c where id=:recordId
            ];
            
            selectedItem = campaignAccountMemberObject.Campaign_Member_Status__c;
        }
        else
        {
            campaignAccountMemberObject =  new Campaign_Account_Members__c();
            isCreateMode=true;
            
            ID parentRecordId;
            if(returnURL!=null && Pattern.matches(ID_PATTERN, returnURL.substring(1)))
            {       
                parentRecordId=returnURL.substring(1);
                String sObjName = parentRecordId.getSObjectType().getDescribe().getName();
                if(sObjName.equalsIgnoreCase(ACCOUNT_OBJECT_NAME))
                {
                    campaignAccountMemberObject.account__c=parentRecordId;
                }
                else if(sObjName.equalsIgnoreCase(CAMPAIGN_OBJECT_NAME))
                {
                    campaignAccountMemberObject.campaign__c=parentRecordId;
                }
            }
        }
    }
    
    
    //get account member status related lists corresponding to the account
    public List<SelectOption> getRelatedCampaignMemberStatus()
    {
        List<SelectOption> memberStatusList = new List<SelectOption>();
        List<Campaign_Member_Status__c> campaignMemberStatusList= [select id,name,Default_Status__c from Campaign_Member_Status__c where Campaign__c =:campaignAccountMemberObject.Campaign__c order by name];
        if(campaignMemberStatusList.size()!=0)
        {
            for(Campaign_Member_Status__c campaignMemberStatusObject: campaignMemberStatusList)
            {
                memberStatusList.add(new SelectOption(campaignMemberStatusObject.name,campaignMemberStatusObject.name));
                if(isCreateMode)
                {
                    if(campaignMemberStatusObject.Default_Status__c )
                    {
                        selectedItem = campaignMemberStatusObject.name;
                    }
                }
            }
        }
        else
        {       
            //Add none if no status present for selected campaign
            memberStatusList.add(new SelectOption('--None--','--None--'));
        }
        return memberStatusList;
    }
    
    //Overriding standard save method
    public PageReference save()
    {
        boolean isError = false;  
        try
        {
            campaignAccountMemberObject.Campaign_Member_Status__c = selectedItem;
            upsert campaignAccountMemberObject;
        }
        catch (DmlException de) {
            isError = true;
            Integer numErrors = de.getNumDml();
            for(Integer i=0;i<numErrors;i++) { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, de.getDmlMessage(i)));
            }
        }
        catch(Exception e)   {
            isError =  true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        if(isError)
        {
            return ApexPages.currentPage();
        }
        else if(returnURL!=null & !isError)
        {
            return new PageReference('/'+returnURL);
        }
        else
        {
            return new PageReference('/'+campaignAccountMemberObject.Campaign__c);
        }
    }
    
    //Overriding standard saveAndNew method
    public PageReference saveAndNew()
    {
        boolean isError = false;
        try
        {       campaignAccountMemberObject.Campaign_Member_Status__c = selectedItem;
         upsert campaignAccountMemberObject;
        }
        catch (DmlException de) {
            isError = true;
            Integer numErrors = de.getNumDml();
            for(Integer i=0;i<numErrors;i++) { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, de.getDmlMessage(i)));
            }
        }
        catch(Exception e)   {
            isError =  true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        if(!isError)
        {
            return new PageReference('/'+Schema.getGlobalDescribe().get(CAMPAIGN_ACCOUNT_MEMBERS).getDescribe().getKeyPrefix()+'/e');
        }
        else
        {       
            return ApexPages.currentPage();
        }
    }
}