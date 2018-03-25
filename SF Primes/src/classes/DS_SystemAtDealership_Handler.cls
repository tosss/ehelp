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
        
        list<Systems__c> sysList = [SELECT s.Id, s.SLXSystem_ID__c, s.SLXVendor_ID__c, s.Type__c FROM Systems__c s where Id IN :sysPk ];
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
            if(!sad.System_Type__c.startsWithIgnoreCase('Previous')) {
                setPrevious(sad);
            }
        }
    }
    public static void beforeUpdate(list<System_at_Dealership__c> sad,map<Id,sObject> om) {
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
    public static void afterInsert(list<sObject> NewSADs,map<ID,sObject> NewMap) {
        //nothing to do
    }
    public static void afterUpdate(list<sObject> OldSADs,list<sObject> NewSADs,map<ID,sObject> OldMap,map<ID,sObject> NewMap) {
		//nothing to do
    }
    public static void afterDelete(list<sObject> OldSADs,map<ID,sObject> OldMap) {
        //nothing to do
    }
    public static void afterUndelete(list<sObject> NewSADs,map<ID,sObject> NewMap) {
        //nothing to do
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
            list<Systems__c> uSys = [select Id, SLXSystem_ID__c, SLXVendor_ID__c, Type__c,Vendor_Code__c from Systems__c where Id = :rec.Vendor__c];
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