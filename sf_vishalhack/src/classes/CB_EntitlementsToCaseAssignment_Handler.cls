//2/25/2014 - Venkata Shrivol - Created
//2016-08-02 - siva.pragad@cdk.com - added tryCatch and Exception logging
//2016-09-07 - siva.pragada@cdk.com - added AND Status != 'Closed' to the case query and used logDmlFailedRecords methods to log failed records.
//2017-05-09 - siva.pragada@cdk.com - added code for EliteCare entitlemets
public class CB_EntitlementsToCaseAssignment_Handler 
{
    public static Set<String> getPrioritySlas()
    {
        Set<String> priorityEntitlements = new Set<String>();
        
        for(ALL_CreateEntitlements__c ace: ALL_CreateEntitlements__c.getAll().values())
        {
            priorityEntitlements.add(ace.Entitlement_Value__c);
        }
        
        return priorityEntitlements;
    }
    
    public static void webIdNullCheck(list<Case> EntitlementToCases, map<ID, Case> oldMap)
    {
        list<Case> casesToInsert = new list<Case>();
        
        if(EntitlementToCases != null && !EntitlementToCases.isEmpty()) 
        {
            for(Case c:EntitlementToCases)
            {
                if(c.WebID__c!=null)
                {
                    casesToInsert.add(c);
                }
            }
            if(!casesToInsert.isEmpty())
            {
                CB_EntitlementsToCaseAssignment_Handler.updateEntToCase(casesToInsert, oldMap);    
            }
        } 
    }
    public static void updateEntToCase(list<Case> newCases, map<ID, Case> oldCaseMap)
    {
        try{
                set<Id> recTypeIds = new Set<id>();
                set<Id> webIds = new Set<id>();
                string assignEntTypeCheck = '';
            
                for(Case c: newCases)
                {
                    recTypeIds.add(c.RecordTypeId);
                    webIds.add(c.WebId__c);            
                }
                
                //NOTE Remove below query to use Utilities Describe method to get recordType info siva.pragada@cdk.com 9/14/2015
                Map<Id,RecordType> recTypeMap = new Map<Id,RecordType>([Select Id, Name from RecordType where id In :recTypeIds]);
                
                
                Map<Id, map<String, Entitlement>> webIdEntMap = new Map<Id, map<String, Entitlement>>();
            
                for(Entitlement ent : [
                                       Select Id, Name, Type,webId__c, EndDate 
                                       from Entitlement 
                                       where webId__c in : webIds 
                                       and Status = 'Active' and EndDate=null
                                      ]
                )
                {
                    Map<String, Entitlement>  tempEnt = 
                        webIdEntMap.containsKey(ent.webId__c) ? webIdEntMap.get(ent.webId__c) : new map<String, Entitlement>();
                    tempEnt.put(ent.Name, ent);
                    webIdEntMap.put(ent.webid__c, tempEnt);
                }
                
                boolean oldCaseExists = oldCaseMap != null ? true : false;
                            
                for(Case c : newCases)
                { 
                	Map<String, Entitlement> entMap = webIdEntMap.get(c.WebID__c);
                    String recTypeName = recTypeMap.containsKey(c.recordtypeId) ? recTypeMap.get(c.recordtypeId).Name : '';                    
                    assignEntTypeCheck = checkRecordTypeName(recTypeName);
                    
                    Set<String> priorityEntitlements = getPrioritySlas();
                    Entitlement priorityEntl = null;
                    
                    for(String entlValue: priorityEntitlements)
                    {
                        if(entMap != null)
                        {
                            priorityEntl = entMap.get(entlValue);
                            
                            if(priorityEntl != null)
                            {
                                break; 
                            }
                        }
                    }
                    
                    /*priorityEntl = 
                            entMap.get('EnhancedCare Tech Support') != null ? 
                            entMap.get('EnhancedCare Tech Support') : 
                            entMap.get('ExpressCare Tech Support') != null ? 
                            entMap.get('ExpressCare Tech Support') : 
                            entMap.get('EliteCare Tech Support');*/
                 
                     if(priorityEntl != null)
                     { 
                         c.EntitlementId = priorityEntl.Id;
                         CONTINUE;
                     }
                            
                    if((assignEntTypeCheck!=null && assignEntTypeCheck!='') && 
                       (assignEntTypeCheck.equals('creative') || assignEntTypeCheck.equals('technical')))
                    {  
                        if(entMap != null)
                        {
                            for(String key: entMap.keySet())
                            {
                                Entitlement ent = entMap.get(key);
                                
                                if(ent != null && ent.type != null && 
                                   assignEntTypeCheck.equals('creative') && ent.type.equalsIgnoreCase('Creative Support'))
                                {
                                    c.SlaStartDate_Custom__c = c.CreatedDate;
                                    c.EntitlementId = ent.Id;
                                    
                                    if(c.Status.containsIgnoreCase('On Hold'))
                                    {
                                        c.SlaStartDate_Custom__c = null;
                                        c.EntitlementId = null; 
                                        c.slaStartDate = null;
                                        c.Target_Date_Time__c = null;
                                    }
                                    
                                    if(oldCaseExists && 
                                       oldCaseMap.get(c.ID).Status.containsIgnoreCase('On Hold') && 
                                       !c.Status.containsIgnoreCase('On Hold'))
                                    {
                                        c.SlaStartDate_Custom__c = dateTime.now();
                                    }
                                    
                                    system.debug('---Found---'+c.EntitlementId);
                                    BREAK;
                                }
                                else if(ent.type != null && assignEntTypeCheck.equals('technical') && ent.type.equalsIgnoreCase('Technical Support'))
                                {
                                    c.EntitlementId = ent.Id;
                                    system.debug('---Found---'+c.EntitlementId);
                                    BREAK;
                                }
                            }
                        }
                    }
                }
        }
        catch(Exception exp)
        {
             ALL_UtilitiesMiscellaneous.logException(exp);
        }
    }
	
	
    public static void updateEntToCaseOnWebIdUpdate(Set<id> webIds)
    { 
        try{
              //list<Case> clist = [select Id, WebID__c, RecordTypeId from Case where WebID__c IN :webIds];
                 //updateEntToCase(clist);
                set<Id> recTypeIds = new Set<id>();
            
                list<Case> newCases = [
                    Select Id, RecordTypeId, RecordType.Name, WebId__c, EntitlementId 
                    from Case 
                    where WebId__c in :webIds 
                    AND Status != 'Closed'
                ];
            
                string assignEntTypeCheck='';               
                Map<Id, map<String, Entitlement>> webIdEntMap = new Map<Id, map<String, Entitlement>>();
            
                for(Entitlement ent : [
                                       Select Id, Name, Type,webId__c, EndDate 
                                       from Entitlement 
                                       where webId__c in : webIds 
                                       and Status = 'Active' and EndDate=null
                                      ]
                )
                {
                    Map<String, Entitlement>  tempEnt = 
                        webIdEntMap.containsKey(ent.webId__c) ? webIdEntMap.get(ent.webId__c) : new map<String, Entitlement>();
                    tempEnt.put(ent.Name, ent);
                    webIdEntMap.put(ent.webid__c, tempEnt);
                }
            
                for(Case c : newCases)
                {             
                    map<String, Entitlement> entMap = webIdEntMap.containsKey(c.webId__c) ? webIdEntMap.get(c.webId__c) : new map<String, Entitlement>();
                    String recTypeName = c.recordtype.Name;                    
                    assignEntTypeCheck = checkRecordTypeName(recTypeName);
                    
                    Set<String> priorityEntitlements = getPrioritySlas();
                    Entitlement priorityEntl = null;
                    
                    for(String entlValue: priorityEntitlements)
                    {
                        if(entMap != null)
                        {
                            priorityEntl = entMap.get(entlValue);
                            
                            if(priorityEntl != null)
                            {
                                break; 
                            }
                        }
                    }
                    
                   /*Entitlement priorityEntl = 
                            entMap.get('EnhancedCare Tech Support') != null ? 
                            entMap.get('EnhancedCare Tech Support') : 
                            entMap.get('ExpressCare Tech Support') != null ? 
                            entMap.get('ExpressCare Tech Support') : 
                            entMap.get('EliteCare Tech Support');*/
                    
                    if(priorityEntl != null)
                    { 
                        c.EntitlementId = priorityEntl.Id;
                        CONTINUE;
                    }
                    
                    if((assignEntTypeCheck!=null && assignEntTypeCheck!='') && (assignEntTypeCheck.equals('creative') || assignEntTypeCheck.equals('technical')))
                    {   
                        if(entMap != null)
                        {
                            for(String entName : entMap.keySet())
                            {
                                Entitlement ent = entMap.get(entName);
                                
                                if(ent != null && ent.type != null && 
                                   assignEntTypeCheck.equals('creative') && ent.type.equalsIgnoreCase('Creative Support'))
                                {
                                    c.EntitlementId = ent.Id;
                                    
                                    BREAK;
                                }
                                else if(ent.type != null && assignEntTypeCheck.equals('technical') && ent.type.equalsIgnoreCase('Technical Support'))
                                {
                                    c.EntitlementId = ent.Id;
                                    
                                    BREAK;
                                }
                            }
                        }
                    }
                }
            
               list<Database.SaveResult> saveResults = Database.Update(newCases, false);
               ALL_UtilitiesMiscellaneous.logDmlFailedRecords(saveResults);
                
        }
        catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
        }
    }
    
    public static string checkRecordTypeName(string recordTypeName)
    {
        string validRecordTypeName='';
        string validEntType='';
        string check='';
        try{
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
        }
        Catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
        }
        return  check;	   
    } 
}