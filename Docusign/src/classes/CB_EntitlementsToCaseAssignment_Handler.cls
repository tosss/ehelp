/*
 2/25/2014 - Venkata Shrivol - Created
*/

public class CB_EntitlementsToCaseAssignment_Handler 
{
    public static void updateEntToCase(list<Case> newCases)
    {
        try{
                set<Id> recTypeIds = new Set<id>();
                set<Id> webIds = new Set<id>();
                string assignEntTypeCheck = '';
                for(Case c: newCases){
                    recTypeIds.add(c.RecordTypeId);
                    webIds.add(c.WebId__c);            
                }
     
                Map<Id,RecordType> recTypeMap = new Map<Id,RecordType>([Select Id, Name from RecordType where id In :recTypeIds]);
                Map<Id,list<Entitlement>> webIdEntMap = new Map<Id,list<Entitlement>>();
                for(Entitlement ent : [Select Id, Name, Type,webId__c from Entitlement where Status = 'Active' and EndDate=null and webId__c in : webIds]){
                    list<Entitlement>  tempEnt = webIdEntMap.containsKey(ent.webId__c) ? webIdEntMap.get(ent.webId__c) : new list<Entitlement>();
                    // Two cases when created with same WebID__c each having 2 entitlements..no duplicates because of above Set pf WebID's
                    tempEnt.add(ent);
                    webIdEntMap.put(ent.webid__c, tempEnt);
                }
                system.debug('----webIdEntMap---'+webIdEntMap);
                for(Case c : newCases)
                {             
                    list<Entitlement> entLst = webIdEntMap.containsKey(c.webId__c) ? webIdEntMap.get(c.webId__c) : new list<Entitlement>();
                    String recTypeName = recTypeMap.containsKey(c.recordtypeId) ? recTypeMap.get(c.recordtypeId).Name : '';
                    system.debug('----entLst---'+entLst);
                    system.debug('----recTypeName---'+recTypeName);
                    assignEntTypeCheck = checkRecordTypeName(recTypeName);
                    if((assignEntTypeCheck!=null && assignEntTypeCheck!='') && (assignEntTypeCheck.equals('creative') || assignEntTypeCheck.equals('technical'))){                
                           for(Entitlement ent : entLst)
                           {
                               if(ent.type != null && assignEntTypeCheck.equals('creative') && ent.type.equalsIgnoreCase('Creative Support'))
                               {
                                   c.EntitlementId = ent.Id;
                                   system.debug('---Found---'+c.EntitlementId);
                                   break;
                               }
                               else if(ent.type != null && assignEntTypeCheck.equals('technical') && ent.type.equalsIgnoreCase('Technical Support'))
                               {
                                   c.EntitlementId = ent.Id;
                                   system.debug('---Found---'+c.EntitlementId);
                                   break;
                               }
                           }
                       }
                }
        }
        catch(Exception ex){
            system.debug('--------Exception-----------'+ex);
        }
    }
	
	
    public static void updateEntToCaseOnWebIdUpdate(Set<id> webIds)
    {
        try{
              //list<Case> clist = [select Id, WebID__c, RecordTypeId from Case where WebID__c IN :webIds];
                 //updateEntToCase(clist);
                set<Id> recTypeIds = new Set<id>();
                list<Case> newCases = [Select Id, RecordTypeId, RecordType.Name, WebId__c, EntitlementId from Case where WebId__c in :webIds ];
                string assignEntTypeCheck='';               
                Map<Id,list<Entitlement>> webIdEntMap = new Map<Id,list<Entitlement>>();
                for(Entitlement ent : [Select Id, Name, Type,webId__c, EndDate from Entitlement where webId__c in : webIds and Status = 'Active' and EndDate=null]){
                    list<Entitlement>  tempEnt = webIdEntMap.containsKey(ent.webId__c) ? webIdEntMap.get(ent.webId__c) : new list<Entitlement>();
                    tempEnt.add(ent);
                    webIdEntMap.put(ent.webid__c, tempEnt);
                }
                system.debug('----webIdEntMap---'+webIdEntMap);
                for(Case c : newCases){             
                    list<Entitlement> entLst = webIdEntMap.containsKey(c.webId__c) ? webIdEntMap.get(c.webId__c) : new list<Entitlement>();
                    String recTypeName = c.recordtype.Name;
                    system.debug('----entLst---'+entLst);
                    system.debug('----recTypeName---'+recTypeName);
                    assignEntTypeCheck = checkRecordTypeName(recTypeName);
                    if((assignEntTypeCheck!=null && assignEntTypeCheck!='') && (assignEntTypeCheck.equals('creative') || assignEntTypeCheck.equals('technical')))
                    {                
                           for(Entitlement ent : entLst)
                           {
                               if(ent.type != null && assignEntTypeCheck.equals('creative') && ent.type.equalsIgnoreCase('Creative Support'))
                               {
                                   c.EntitlementId = ent.Id;
                                   system.debug('---Found---'+c.EntitlementId);
                                   break;
                               }
                               else if(ent.type != null && assignEntTypeCheck.equals('technical') && ent.type.equalsIgnoreCase('Technical Support'))
                               {
                                   c.EntitlementId = ent.Id;
                                   system.debug('---Found---'+c.EntitlementId);
                                   break;
                               }
                           }
                       }
                }
               update newCases;               
                
        }
        catch(Exception ex){
            system.debug('--------Exception-----------'+ex);
        }
    }
    
    public static string checkRecordTypeName(string recordTypeName)
    {
        string validRecordTypeName='';
        string validEntType='';
        string check='';
        if(recordTypeName!=null && recordTypeName!='')
        {
            for(CB_CaseRecordTypes__c cRType: CB_CaseRecordTypes__c.getAll().Values())
            {
                validRecordTypeName = cRtype.Name;
                validEntType = cRType.EntitlementSupport_Type__c;
                if(recordTypeName.equals(validRecordTypeName))
                {
                    if(validEntType == 'Technical Support')
                    {
                        check = 'technical';
                        break;
                    }
                    else if(validEntType == 'Creative Support')
                    {
                        check = 'creative';
                        break;
                    }
                 }
             }   
        }
    	return  check;	   
    } 
}