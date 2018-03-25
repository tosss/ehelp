//	Created: 2015-06-01 from Request R-960 (combine old triggers into single)
//	Developers:	Addanki, Lakshmi
//				Chava, Maheshwar
//				Cook, Brian 
//				Kalicut, Ram
//				Khan, Mutahhar
//				Li, Guolong 
//				Mishra, Akash 
//				Simhadri, Smitha
//				Thurow, Bill
//	
//	25/10/2016 vishal.bandari@cdk.com -     added method setAccountDSM : RQ-08091 
//20-03-2017 - lalitha.adduru@cdk.com - update NSA Renewal flag on Account whenever Sys at DS of Sys Type DMS is updated - RQ-08786
global with sharing class DS_SystemAtDealership_Handler {
    //
    //
    //
    //*********************************************************************************** 
    //Constants
    private static string systemId = '            ';
    private static string dmsSysId = '            ';
    private static string dateMask = '        ';
    
    //array of SaDs to update
    private static list<System_at_Dealership__c> updSys = new list<System_at_Dealership__c>();
    //array of SaDs to delete
    private static list<System_at_Dealership__c> delSad = new list<System_at_Dealership__c>();    
    
    //
    //
    //
    //***********************************************************************************
    //Main execution function to be called only from trigger
    global static void ExecuteTrigger(){
        //make sure code is being called from the trigger
        if(!Trigger.isExecuting){
            system.debug('Trigger code called from outside of trigger.');
        }
        //before events
        if(Trigger.isbefore) {
            if(Trigger.isInsert) {
                beforeInsert(Trigger.new);
            } else if(Trigger.isUpdate) {
                //beforeUpdate(Trigger.new,Trigger.oldMap);
                beforeUpdate(Trigger.new,Trigger.oldMap);
            } else if(Trigger.isDelete) {
                beforeDelete(Trigger.old,Trigger.oldMap);
            }
            //after events
        } else if(Trigger.isafter) {
            if(Trigger.isInsert) {
                afterInsert(Trigger.new,Trigger.newMap);
            } else if(Trigger.isUpdate) {
                afterUpdate(Trigger.old,Trigger.new,Trigger.oldMap,Trigger.newMap);
            } else if(Trigger.isDelete) {
                afterDelete(Trigger.old,Trigger.oldMap);
            } else if(Trigger.isUndelete) {
                afterUndelete(Trigger.new,Trigger.newMap);
            }
        }
    }
    //
    //
    //
    //***********************************************************************************
    //Before actions
    //
    public static void beforeInsert(list<System_at_Dealership__c> NewSADs) {
        //get array of Vendor__c values for the System_at_Dealership__c records being inserted
        //
        //sysPk = list of Systems__c primary keys
        set<string> sysPk = new set<string>();
        
        //change and make set<Id> instead of list to ensure uniqueness
        for(System_at_Dealership__c sad : NewSADs) {
            sysPk.add(sad.Vendor__c);
        }
        
        list<Systems__c> sysList = [
            SELECT s.Id, s.SLXSystem_ID__c, s.SLXVendor_ID__c, s.Type__c 
            FROM Systems__c s where Id IN :sysPk 
        ];
        
        map<Id,Systems__c> sysMap = new map<Id,Systems__c>();
        
        for(Systems__c sys : sysList){
            Systems__c sc = new Systems__c();
            sc.Id = sys.Id;
            sc.SLXSystem_ID__c = sys.SLXSystem_ID__c;
            sc.SLXVendor_ID__c = sys.SLXVendor_ID__c;
            sc.Type__c = sys.Type__c;
            sysMap.put(sys.id,sc);            
        }
        
        //get the composite external id if it doesn't exist for each record being inserted
        for(System_at_Dealership__c sad : NewSADs) {
            if(sad.CompositeExtID__c == null) {
                Systems__c sys = sysMap.get(sad.Vendor__c);
                
                if(sys.SLXSystem_ID__c != null) {
                    sad.SLX_Sys_ID__c = sys.SLXSystem_ID__c;
                }				
                
                sad.CompositeExtID__c = compileCompId(sad.Account__c,
                                                      getDate(sad.Install_Date__c),
                                                      sys.SLXVendor_ID__c,
                                                      sad.SLX_Sys_ID__c,
                                                      sad.System_Type__c);
            }
            if(sad.System_Type__c != null && !sad.System_Type__c.startsWithIgnoreCase('Previous')) {
                setPrevious(sad);
            }
        }
        
        updateNSARenewalFlagOnAccount(NewSADs, null);
    }
    
    public static void beforeUpdate(list<System_at_Dealership__c> sad,map<Id,sObject> om) {
        updateNSARenewalFlagOnAccount(sad, (Map<Id,System_at_Dealership__c>) om);
        string dms = '';
        string vendid = '';
        string insdt = '';
        set<id> VendList = new set<id>();       
        Map<Id, Systems__c> MapVendorLists = new Map<Id, Systems__c>();
        
        for (System_at_Dealership__c sd1 : sad){
            If (sd1.Vendor__c !=null) {
                VendList.add(sd1.Vendor__c);
            }          
        }
        
        for (Systems__c Systems : [
            SELECT Id, SLXSystem_ID__c, SLXVendor_ID__c, Type__c 
            FROM Systems__c
            WHERE Id IN :VendList                                         
        ]){
            If (!MapVendorLists.containsKey(Systems.id)) {
                MapVendorLists.put(Systems.id,Systems);                             
            }
        }
        
        for (System_at_Dealership__c sd : sad) {
            System_at_Dealership__c oldObj = (System_at_Dealership__c)om.get(sd.id); 
            if (sd.System_Type__c == oldObj.System_Type__c || 
                sd.System_Type__c == 'Previous '+ oldObj.System_Type__c || 
                oldObj.System_Type__c == 'Previous '+ sd.System_Type__c){
                    if (oldObj.System_Type__c == 'Previous '+ sd.System_Type__c){
                        sd.addError('The System Type can not be changed from Previous to Current System Type');
                    }
                    //Check if vendor system, system type or install date was changed. If yes, derive and update composite key   
                                   
                    if (sd.Vendor__c != oldObj.Vendor__c || 
                        sd.System_Type__c != oldObj.System_Type__c || 
                        sd.Install_Date__c != oldObj.Install_Date__c) {
                            
                            insdt = getDate(sd.Install_Date__c);
                            
                            Systems__c sys=MapVendorLists.get(sd.Vendor__c);
                            
                            //limit 1 and outside the loop
                            if (sys != null){                        
                                if (sys.SLXSystem_ID__c == null){ 
                                    //create a constant and use that instead of having it defined here
                                    dms = '            ';
                                } else {
                                    dms = sys.SLXSystem_ID__c;
                                } 
                                
                                //Set SLX Vendor ID
                                if (sd.SLX_Vendor_ID__c == null || sd.SLX_Vendor_ID__c != sys.SLXVendor_ID__c) {
                                    sd.SLX_Vendor_ID__c = sys.SLXVendor_ID__c;
                                }
                                
                                //Set SLX Sys ID
                                if (sd.SLX_Sys_ID__c == null || sd.SLX_Sys_ID__c != dms) {
                                    sd.SLX_Sys_ID__c = dms;
                                }                   
                                //set composite key
                                sd.CompositeExtID__c = compileCompId(
                                    sd.Account__c,
                                    insdt,
                                    sys.SLXVendor_ID__c,
                                    sd.SLX_Sys_ID__c,
                                    sd.System_Type__c);
                            }         
                        }            
                } else { 
                    sd.addError('The System Type can not be changed to another type');
                    throw new applicationException('Cannot change System Type');
                } 
        }
    }
    public static void beforeDelete(list<sObject> OldSADs,map<ID,sObject> OldMap) {
        //nothing to do
    }
    //
    //
    //
    //***********************************************************************************
    //
    //After actions
    //
    public static void afterInsert(list<sobject> NewSADs,map<ID,sobject> NewMap) {
        //25/10/2016 vishal.bandari@cdk.com -     invoked method setAccountDSM()
        setAccountDMS(NewSADs);
    }
    public static void afterUpdate(list<sobject> OldSADs,list<sobject> NewSADs,map<ID,sobject> OldMap,map<ID,sobject> NewMap) {
        //25/10/2016 vishal.bandari@cdk.com -     invoked method setAccountDSM()
		setAccountDMS(NewSADs);
    }
    public static void afterDelete(list<sObject> OldSADs,map<ID,sObject> OldMap) {
        //nothing to do
    }
    public static void afterUndelete(list<sObject> NewSADs,map<ID,sObject> NewMap) {
        //nothing to do
    }
    
    //20-03-2017 - lalitha.adduru@cdk.com - update NSA Renewal flag on Account whenever Sys at DS of Sys Type DMS is updated - RQ-08786
    public static void updateNSARenewalFlagOnAccount(List<System_at_Dealership__c> dealershipList,Map<Id, System_at_Dealership__c> oldMap)
    {
        List<System_at_Dealership__c> relevantDealerships = new List<System_at_Dealership__c>();
        Set<Id> accountIdSet= new Set<Id>();
        for(System_at_Dealership__c systemDealership : dealershipList)
        {
            if(systemDealership.System_Type__c == 'DMS')
            {
                system.debug('system type is DMS');
                relevantDealerships.add(systemDealership);
                accountIdSet.add(systemDealership.Account__c);
                System_at_Dealership__c oldDealership = (oldMap == null || oldMap.get(systemDealership.Id) == null) ? null : 
            										oldMap.get(systemDealership.Id);
                if(oldDealership != null && oldDealership.Account__c != systemDealership.Account__c )
                {
                    accountIdSet.add(oldDealership.Account__c);
                }
            }
        }
        Map<Id, Account> accountMap = new Map<id, Account>([
            SELECT id, NSA_Renewal_Flag__c 
            FROM Account WHERE Id in :accountIdSet
        ]);
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        for(System_at_Dealership__c relevantDealership : relevantDealerships)
        {
            System_at_Dealership__c oldDealership = (oldMap == null || oldMap.get(relevantDealership.Id) == null) ? null : 
            										oldMap.get(relevantDealership.Id);
            Account masterAccount = accountMap.get(relevantDealership.Account__c);
            if(oldDealership == null || (relevantDealership.NSA_Renewal_Flag__c != oldDealership.NSA_Renewal_Flag__c)
               || masterAccount.NSA_Renewal_Flag__c != relevantDealership.NSA_Renewal_Flag__c)
            {
                system.debug('Updating NSA Renewal FLag on Account ------>');
                masterAccount.NSA_Renewal_Flag__c = relevantDealership.NSA_Renewal_Flag__c;
                if(oldDealership != null && oldDealership.Account__c != relevantDealership.Account__c)
                {
                    Account oldMasterAccount = accountMap.get(oldDealership.Account__c);
                    oldMasterAccount.NSA_Renewal_Flag__c = false;
                    accountsToUpdate.put(oldDealership.Account__c, oldMasterAccount);
                }
                accountsToUpdate.put(relevantDealership.Account__c, masterAccount);
            }
        }
        if(!accountsToUpdate.isEmpty())
        {
            update accountsToUpdate.values();
        }
    }
    
    //25/10/2016 vishal.bandari@cdk.com -     added method setAccountDSM() : RQ-08091 
    public static void setAccountDMS(List<Sobject> NewSADs)
    {
        List<Id> vendorSystems = new List<Id>();
        for(Sobject systemDealershipSobject : NewSADs)
        {
            System_at_Dealership__c systemDealershipObject = (System_at_Dealership__c)systemDealershipSobject;
            if(systemDealershipObject.System_Type__c != null && systemDealershipObject.System_Type__c.equalsIgnoreCase('dms'))
            {
                vendorSystems.add(systemDealershipObject.Vendor__c);
            }
        }
        Map<Id,Account> accountMap = new Map<Id,Account>();
        for(Systems__c systemsObj :  [
            SELECT Name,
            (
                SELECT Id,Account__c,Install_Date__c,Contract_Term_Date__c
                FROM System_at_Dealership_Vendors__r
                WHERE Id IN: NewSADs
            )
            FROM Systems__c
            WHERE Id IN: vendorSystems
        ])
        {
            for(System_at_Dealership__c systemADealerObj : systemsObj.System_at_Dealership_Vendors__r)
            {
                Account accountObj = new Account();
                accountObj.Current_DMS__c = systemsObj.Name;
                accountObj.Id = systemADealerObj.Account__c;
                accountObj.Current_DMS_Install_Date__c = systemADealerObj.Install_Date__c;
                accountObj.Current_Term_Expiration_Date__c = systemADealerObj.Contract_Term_Date__c;
                accountMap.put(systemADealerObj.Account__c,accountObj);
            }
        }
        if(accountMap.size() > 0)
        {
            update accountMap.values();
        }
    }
    //
    //
    //
    //***********************************************************************************
    //   
    //class functions
    //
    public static string getDate(Date dt) {
        string mask = '';
        
        if(dt == null) {
            mask = dateMask;	//make a constant
        } else {
            mask = string.valueof(dt.Year());
            if(dt.Month() < 10) {
                mask += '0' + string.valueof(dt.Month());
            } else {
                mask += string.valueof(dt.Month());
            }
            
            if(dt.Day() < 10) {
                mask += '0' + string.valueof(dt.Day());
            } else {
                mask += string.valueof(dt.Day());
            }
        }
        return mask;		
    }
    public static string compileCompId(	string acctId, string insDatestring, string slxVendorId, string slxSystemId, string sysType){
        string compositeId = '';
        
        if(slxSystemId == null || slxSystemId == '') {
            compositeId = acctId + insDatestring + slxVendorId + systemId + sysType;	
        } else {
            compositeId = acctId + insDatestring + slxVendorId + slxSystemId + sysType;
        }
        return compositeId; 
    } 
    public static void setPrevious(System_at_Dealership__c sad) {
        //array to search for SaDs to update
        list<System_at_Dealership__c> uSad = new list<System_at_Dealership__c>();
        //array to search for SaDs to delete
        list<System_at_Dealership__c> dSad = new list<System_at_Dealership__c>();
       
        uSad = [
            select	Id,Account__c,Install_Date__c,System_Type__c,Vendor__c,CompositeExtID__c
            from	System_at_Dealership__c
            where	Account__c = :sad.Account__c and System_Type__c = :sad.System_Type__c
        ];
        //make both arrays the same
        dSad = uSad;
        
        //anything match?
        //if(uSad.size() != 0){
		updateDeleteExistingSaDs(uSad,dSad);
        //}
        //delete any problem children
        database.delete(delSad);
        
        //update whatever's left
        database.update(updSys);
    }	
    
    public static void updateDeleteExistingSaDs(list<System_at_Dealership__c> uSad,list<System_at_Dealership__c> dSad){
        //new composite id
        string comp = '';
        
        //dms string
        string dms = '';
        
        //vendor code string
        string vc = '';        
        //loop through update array
        for(System_at_Dealership__c rec : uSad){
            //find and update the SLXSystemID
            list<Systems__c> uSys = [
                select Id, SLXSystem_ID__c, SLXVendor_ID__c, Type__c,Vendor_Code__c 
                from Systems__c where Id = :rec.Vendor__c
            ];
            
            for(Systems__c aSys : uSys){
                if(aSys.SLXSystem_ID__c == null) {
                    dms = dmsSysId;
                } else {
                    dms = aSys.SLXSystem_ID__c;
                }
                vc = aSys.Vendor_Code__c;
            }
            rec.System_Type__c = 'Previous ' + rec.System_Type__c;
            comp = compileCompId(rec.Account__c,getDate(rec.Install_Date__c),vc,dms,rec.System_Type__c);               
            
            for(System_at_Dealership__c del : dSad){
                if(del.CompositeExtID__c == comp){
                    delSad.add(del);
                } else {
                    rec.CompositeExtID__c = comp;
                    updSys.add(rec);
                }
            }
        }        
    }
    
    public class applicationException extends Exception{}  
}