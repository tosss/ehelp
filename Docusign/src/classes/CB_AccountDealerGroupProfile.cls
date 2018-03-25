public with sharing class CB_AccountDealerGroupProfile
{
    public GlobalSettings__c Settings; // for determining which profiles have access
    
    public Dealer_Group_Profile__c DealerGroupProfile {get;set;}
    public Account CurrentAccount {get;set;}
    public Account TopAccount {get;set;}
    
    public Boolean ShowContinue {get;set;}
    
    // constructor
    public CB_AccountDealerGroupProfile() { }
    
    public PageReference Init()
    {
        CurrentAccount = null;
        TopAccount = null;
        
        Settings = GlobalSettings__c.getInstance();
        
        // determines which objects and types are valid and which field to look up the Account from (in the query)
        List<Dealer_Group_Profile_Settings__c> ObjectTypes = Dealer_Group_Profile_Settings__c.getAll().values();
        Map<String,Dealer_Group_Profile_Settings__c> TypesByObjectName = new Map<String,Dealer_Group_Profile_Settings__c>();  
        String ValidTypes = '';
        
        for(Integer i=0; i < ObjectTypes.size(); i++)
        {
            ValidTypes += (i == 0 ? '' : ', ') + ObjectTypes.get(i).sObjectType__c;
            TypesByObjectName.put(ObjectTypes.get(i).sObjectType__c, ObjectTypes.get(i));
        }
        
        String oid = ApexPages.currentPage().getParameters().get('oid');
        String otype = ApexPages.currentPage().getParameters().get('otype'); 
        
        if(oid == null || oid == '' || otype == null || otype == '') { 
            ShowContinue = false; ApexPages.addMessage(new ApexPages.Message(
                ApexPages.severity.ERROR, 'The Object Id and Type parameters are required. ')); return null; }
        
        if(!TypesByObjectName.keyset().contains(otype)) {
            ShowContinue = false; ApexPages.addMessage(new ApexPages.Message(
                ApexPages.severity.ERROR, 'The Type parameter can be only one of these values: ' + ValidTypes + '. ')); return null; }
        
        String af = TypesByObjectName.get(otype).Account_Field__c;
        sObject s = Database.query('Select ' + af + ' From ' + otype + ' Where Id = \'' + oid + '\'');
        
        if(s.get(af) != null)
        {
        	CurrentAccount = [Select Id, Name, Corporation__c, Corporation__r.Name, Group__c, Group__r.Name From Account Where Id = :String.valueOf(s.get(af)) Limit 1];
        }
        else
        {
        	String InvalidAccountMessage = 'Could not find the Account associated with this record. Please make sure the ' + af + ' field is set on this ' + TypesByObjectName.get(otype).Name + '. ';
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, InvalidAccountMessage)); ShowContinue = false; 
        	return null;
        }
        
        List<Dealer_Group_Profile__c> DealerGroupProfiles = [
            Select Id, Name From Dealer_Group_Profile__c Where Dealer_Group__c = :CurrentAccount.Group__c Or Dealer_Group__c = :CurrentAccount.Corporation__c Or Dealer_Group__c = :CurrentAccount.Id];
        
        system.debug(DealerGroupProfiles);
        
        if(DealerGroupProfiles != null) 
        {
            if(!DealerGroupProfiles.IsEmpty()) 
            {
                DealerGroupProfile = DealerGroupProfiles[0];
                
                PageReference p = new PageReference('/' + DealerGroupProfile.Id); p.setRedirect(true);
                return p;
            }
        }
        
        // valid User Profile check
        String ValidProfiles = Settings.Dealer_Group_Profile_Profiles_1__c + ',' + Settings.Dealer_Group_Profile_Profiles_2__c;
        Profile CurrentUserProfile = [Select Name From Profile Where Id = :UserInfo.getProfileId() Limit 1];
        
        String InvalidProfileMessage = 'This profile does not exist. Please contact the CAM, GAM, or DSM-Nat-Ent on the Account.';
        
        if(CurrentUserProfile == null) { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, InvalidProfileMessage)); ShowContinue = false; return null; }
        if(!ValidProfiles.contains(CurrentUserProfile.Name)) { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, InvalidProfileMessage)); ShowContinue = false; return null; }
        
        // Corporation check
        if(CurrentAccount.Corporation__c != null) {
            TopAccount = new Account(Id=CurrentAccount.Corporation__c,Name=CurrentAccount.Corporation__r.Name); }
        else {
            if(CurrentAccount.Group__c != null) {
                TopAccount = new Account(Id=CurrentAccount.Group__c,Name=CurrentAccount.Group__r.Name); }
            else {
                TopAccount = new Account(Id=CurrentAccount.Id,Name=CurrentAccount.Name); 
            } 
        }
        
        Boolean TopAccountHasChildren = [Select Id From Account Where Corporation__c = :TopAccount.Id OR Group__c = :TopAccount.Id].size() > 0;
        
        if(TopAccount != null && TopAccountHasChildren) 
        { 
            ShowContinue = true; 
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.severity.INFO, 'This profile does not exist. Click "continue" to create a new profile for "' + TopAccount.Name + '". ')); 
        }
        else
        {
            ShowContinue = false;
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.severity.INFO, 'A Corporation or Group was not found for Account referenced by the specified record. ')); 
        }
        
        return null;
    }
    
    public PageReference CreateDealerGroupProfile()
    {
        String DealerGroupProfilePrefix = Dealer_Group_Profile__c.sObjectType.getDescribe().getKeyPrefix();
        
        if(TopAccount == null)
        {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.severity.ERROR, 'Could not find the Account specified. ')); 
            
            return ApexPages.currentPage();
        }
        
        DealerGroupProfile = new Dealer_Group_Profile__c(Dealer_Group__c=TopAccount.Id); 
        
        insert DealerGroupProfile;
        PageReference p = new PageReference('/' + DealerGroupProfile.Id + '/e'); 
        p.getParameters().put('retURL', '/' + DealerGroupProfile.Id);
        p.setRedirect(true);
        
        //PageReference p = new PageReference('/' + DealerGroupProfilePrefix + '/e');
        //p.getParameters().put('CF00Ne0000000Oup9', TopAccount.Name);
        //p.getParameters().put('CF00Ne0000000Oup9_lkid', TopAccount.Id);
        //p.getParameters().put('retURL', '/' + CurrentAccount.Id);
        //p.setRedirect(true);
        
        return p;
    }
}