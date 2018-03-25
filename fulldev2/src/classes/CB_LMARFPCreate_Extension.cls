//Request - 04926: RFP to USIM contacts via VF Page and route to LMA Strategist
//08/31/15 smitha.simhadri@cdk.com Created
public class CB_LMARFPCreate_Extension {
    public LMA_RFP__C rfp{get; set;}         
    public String selectedRecType {get; set;}        
    public String selectedLMA {get; set;}        
    public String selectedModelOne {get; set;}        
    public String selectedModelTwo {get; set;}        
    public String selectedModelThree {get; set;}        
    public String selectedModelFour {get; set;}        
    public List<selectOption> LMAAccts {get; set;}        
    public List<selectOption> LMAModels{get; set;}
    public account agencyAcct;
    
    
    public CB_LMARFPCreate_Extension (ApexPages.StandardController stdCtrl)
    {  
        rfp = (LMA_RFP__C) stdCtrl.getRecord();        
    }
    
    public Set<String> rfpRecTypes
    {
        get{
            
            System.debug(UserInfo.getUserId());            
            System.debug(UserInfo.getUserName());
            
            id userId = UserInfo.getUserId();
            
            List<contact> agencyContacts = [
                select id, name, account.id, account.name 
                from contact 
                where user__r.id = :userId
            ];      
            
            rfpRecTypes  = new Set<String>();
            
            IF(agencyContacts != null && !agencyContacts.isEmpty())
            {
                
                for (Contact agencyContact: agencyContacts) {	                
                    
                    agencyAcct = [
                        select id, name
                        from account 
                        where id = :agencyContact.account.id
                    ];
                    
                    if(agencyAcct!=null)
                    {
                        System.debug('Agency Account is: ' + agencyContact.account.id);
                        System.debug('Agency Account name is: ' + agencyContact.account.name);
                        
                        List<Manufacturer_at_Dealership__C> mfgDlr = [
                            select id, name, account__r.name, account__r.id, manufacturer__r.id, manufacturer__r.name
                            from manufacturer_at_dealership__c 
                            where account__r.id = :agencyAcct.id
                        ];                
                        
                        if(mfgDlr != null && !mfgDlr.isEmpty())
                        {
                            for (Manufacturer_at_Dealership__C mfgDlrOne: mfgDlr) 
                            {
                                System.debug('Manufacturer at Dealership Id is: ' + mfgDlrOne.id); 
                                System.debug('Manufacturer Name is: ' + mfgDlrOne.manufacturer__r.name);
                                
                                String mfgName = mfgDlrOne.manufacturer__r.name;
                                CB_LMA_MFgr_record_types__C recTypeCS = CB_LMA_MFgr_record_types__C.getInstance(mfgName);
                                
                                String recTypeVal =  recTypeCS.record_type__c;
                                rfpRecTypes.add(recTypeVal);
                                
                                System.debug('Rec Type Name: ' + recTypeVal);                
                            }   
                        }                         
                        
                    }                  
                    
                }                
                
            }
            else 
            {
                rfpRecTypes = null;
            }
            return rfpRecTypes;            
        }
        set;
    }
    
    public List<SelectOption> getRFPrecTypeOptions()
    {
        List<SelectOption> RFPrecTypeOptions = new List<SelectOption>();
        RFPrecTypeOptions.add(new SelectOption('', '---Select One---'));
        
        if(rfpRecTypes != null && !rfpRecTypes.isEmpty())
        {
            for (String rfpRecTypesOne: rfpRecTypes)
            {
                RFPrecTypeOptions.add(new SelectOption(rfpRecTypesOne, rfpRecTypesOne));                        
            }
        }
        return RFPrecTypeOptions;
    }    
    
    public List<account> lmas{
        get{         
            
            System.debug('SelectedRecType is : ' + selectedRecType);            
            
            List<CB_LMA_MFgr_record_types__C> mfgRecTypesCS = [
                select name, franchise__c, Record_Type__c 
                from CB_LMA_MFgr_record_types__C 
                where record_type__c = :selectedRecType
            ];                
            
            String mfgrNameCS;
            String franchise;
            
            if(mfgRecTypesCS!=null && !mfgRecTypesCS.isEmpty())
            {
                for (CB_LMA_MFgr_record_types__C mfgRecTypesCSOne: mfgRecTypesCS)
                {                
                    System.debug('Mfg Custom Setting Name is:'+ mfgRecTypesCSOne.name);
                    System.debug('Mfg Custom Setting Franchise__C is:'+ mfgRecTypesCSOne.Franchise__c); 
                    System.debug('Mfg Custom Setting Record_Type__C is:'+ mfgRecTypesCSOne.Record_Type__c); 
                    
                    mfgrNameCS = mfgRecTypesCSOne.name;
                    franchise = mfgRecTypesCSOne.franchise__c;
                }
                
                System.debug('Final Manufacturer Name is ' + mfgrNameCS);
                System.debug('Final Franchise is ' + franchise);
                
                manufacturer_at_dealership__c mfgrParent = [
                    select id, name, account__r.id 
                    from manufacturer_at_dealership__c 
                    where manufacturer__r.name = :mfgrNameCS
                ];
                
                System.debug('Parent Acct Id is ' + mfgrParent.account__r.id );
                
                if(mfgrParent!=null) 
                {
                    lmas = 	[
                        select id, name
                        from account
                        where id IN (
                            select account__c 
                            from business_site__c 
                            where franchise__c = :franchise 
                            and status__c = 'A' 
                            and account__r.parent.id = :mfgrParent.account__r.id 
                            and account__r.site_type__r.name = 'Local Marketing'
                        )
                    ];                   
                    
                }  
                else 
                {
                   lmas = null; 
                }
                
            }
            else 
            {
                lmas=null;	    
            }       
            
            return lmas;  
            
        }
        set;
    }
    
    public void getlmaoptions() 
    { //Fetch all LMA Accounts of OEM/Record Type Selected
        
        String currLMAAcct;
        LMAAccts = new List<SelectOption>();
        LMAAccts.add(new SelectOption('', '---Select One---')); 
        
        if (selectedRecType!= 'null')
        {
            for (account lmaOne:lmas)
            {
                LMAAccts.add(new SelectOption(lmaOne.name, lmaOne.name));              
            }            
        }  
        
        //Fetch all models of OEM/Record Type selected
        LMAModels = new List<selectOption>();
        LMAModels.add(new selectOption('', '--Select One--'));        
        
        System.debug('Selected Record Type is : ' + selectedRecType);
        Set<String>  modelNames = new Set<String>();
        
        for (CB_LMA_RFP_Models__c model: CB_LMA_RFP_Models__c.getAll().values()) 
        {
            if (selectedRecType == model.manufacturer__c)
            {
                modelNames.add(model.name); 
                System.debug('Model from Custom Setting CB_LMA_RFP_Models__c is : ' + model.name);
            }
            
        }
        
        for (String modelNamesOne: modelNames) 
        {
            System.debug('Model from set modelNames is : ' + modelNamesOne);
            LMAModels.add(new selectOption(modelNamesOne, modelNamesOne)); 
        }
        
    }  
    
    public PageReference Save()    
    {       
        if (selectedRecType != null)
        {
            ID RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('LMA_RFP__c', selectedRecType);
            
            rfp.RecordTypeId = RecordTypeId;
            
            id selLMAAcct = [
                select id
                from account
                where name = :selectedLMA].id;
            
            if(selLMAAcct!=null)            
            {
                rfp.LMA__c = selLMAAcct;
                
                rfp.Model_1__c = selectedModelOne;
                rfp.Model_2__c = selectedModelTwo;
                rfp.Model_3__c = selectedModelThree;
                rfp.Model_4__c = selectedModelFour;
                
                rfp.status__c = 'Created';
                
                try { 
                    insert rfp;                
                } Catch(Exception e) {
                    //e.setMessage('LMA RFP: Exception occured:');
                    //ApexPages.addMessages(e.getMessage()); 
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage())) ;
                    return null;
                    
                }
                return new PageReference('/' + rfp.id); 
            }
            else 
            {
                return null;
            }            
            
        }
        else 
        {
            return null;
        }
    } 
}