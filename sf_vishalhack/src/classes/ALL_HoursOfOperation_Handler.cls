//2016-09-29 -venkata.shrivol@cdk.com - updated class
public class ALL_HoursOfOperation_Handler 
{
    public static  map<string, list<String>> oppLocToRecTypesMap = new map<string, list<string>>();
    
    public static map<string, Hours_Of_Operation__c> oppLocToHoursMap = new map<string, Hours_Of_Operation__c>();
    
    public static void beforeInsertAndBeforeUpdate(list<Hours_Of_Operation__c> newRecords)
    {
        for(Hours_Of_Operation__c newRecord: newRecords)
        {
            list<string> differentDepts = new list<string>();
            
            system.debug('----->'+newRecord.Common_End_Time__c);
            system.debug('----->'+newRecord.Common_Start_Time__c);
            system.debug('----->'+newRecord.Days_to_Select__c);
            
            if(newRecord.Common_End_Time__c!='' && newRecord.Common_Start_Time__c!='' && newRecord.Days_to_Select__c!=null)
            {
                list<string> days = newRecord.Days_to_Select__c.split(';');
                if(days!=null)
                {
                    for(string str:days)
                    {
                        string startTimeField = str+'_Start_Time__c';
                        string endTimeField = str +'_End_Time__c';
                        newRecord.put(startTimeField, newRecord.Common_Start_Time__c);
                        newRecord.put(endTimeField, newRecord.Common_End_Time__c); 
                    }
                }
            }
            if(newRecord.Department__c != null && newRecord.Department__c!='')
            {
                differentDepts = newRecord.Department__c.split(';');
                if(differentDepts.size() > 1)
                {
                    newRecord.Department__c = differentDepts.get(0);
                    differentDepts.remove(0);
                    oppLocToRecTypesMap.put(newRecord.Opportunity_Location__c+UserInfo.getUserId(), differentDepts);
                    oppLocToHoursMap.put(newRecord.Opportunity_Location__c+UserInfo.getUserId(), newRecord);
                }
            }  
        }
       
    }
    
    public static void afterInsert(map<Id,Hours_Of_Operation__c> newMap)
    {
        list<Hours_Of_Operation__c> recordsToInsert = new list<Hours_Of_Operation__c>();
        //system.debug('-----recordToRecTypesMap-----'+oppLocToRecTypesMap); 
        
        for(string uniqueString : oppLocToRecTypesMap.keySet())
        {
            // 2016-10-28 matt.keefe@cdk.com - added null check to fix test class error
            if(oppLocToRecTypesMap.get(uniqueString) != null)
            {
                for(string str : oppLocToRecTypesMap.get(uniqueString))
                {
                    
                    Hours_Of_Operation__c RecordToClone =  oppLocToHoursMap.get(uniqueString);
                    if(RecordToClone != null)
                    {
                        Hours_Of_Operation__c newRec = RecordToClone.clone();
                        newRec.Department__c = str;
                    	recordsToInsert.add(newRec);
                    }
                    
                }
            }
        }
        insert recordsToInsert;
    }
    
    public static void checkDuplicates(list<Hours_Of_Operation__c> newList, map<Id,Hours_Of_Operation__c> oldMap )
    {
        set<Id> siteIds = new set<ID>();
        map<Id, list<String>> checkMap = new map<ID, list<String>>();
        map<Id, string> oppLocIDtoNameMap = new map<Id, string>();
        for(Hours_Of_Operation__c ho:newList)
        {
            siteIDs.add(ho.Opportunity_Location__c);	    
        }
        
        for(Hours_of_operation__c ho:[select Department__c, Id, Opportunity_Location__c, Opportunity_Location__r.Name 
                                      from Hours_Of_Operation__c 
                                      where Opportunity_Location__c IN : siteIds])
        {
            if(ho.Department__c!=null && ho.Department__c!='')
            {
                
                if(checkMap.containsKey(ho.Opportunity_Location__c))
                {
                    list<String> existingList = checkMap.get(ho.Opportunity_Location__c); 
                    existingList.addALL(ho.Department__c.split(';'));
                    checkMap.put(ho.Opportunity_Location__c, existingList);
                }
                else
                {
                    checkMap.put(ho.Opportunity_Location__c, ho.Department__c.split(';'));   
                }
                if(oldMap!=null)
                {
                    if(oldMap.get(ho.Id)!=null)
                    {
                        string existingDepartment = oldMap.get(ho.Id).Department__c;
                        set<string> departmentSet = new set<String>(checkMap.get(ho.Opportunity_Location__c));
                        if(departmentSet.contains(existingDepartment))
                        {
                            system.debug('----existingDepartment-------'+existingDepartment);
                            departmentSet.remove(existingDepartment);
                        }
                        checkmap.put(ho.Opportunity_Location__c, new list<string>(departmentSet));
                    }  
                }
                
            }
            oppLocIDtoNameMap.put(ho.Opportunity_Location__c, ho.Opportunity_Location__r.Name);
        }
        for(Hours_Of_Operation__c ho:newList)
        {
            if(ho.Department__c != null)
            {
                if(checkMap.containsKey(ho.Opportunity_Location__c))
                {
                    set<String> insertingDepartments = new set<String>(ho.Department__c.split(';'));
                    set<String> existingDepartments = new set<String>(checkMap.get(ho.Opportunity_Location__c));
                    
                    for(string str:insertingDepartments)
                    {
                        if(existingDepartments.contains(str))
                        {
                            string oppLocId = (string)ho.Opportunity_Location__c;
                            string oppLocName = oppLocIDtoNameMap.get(ho.Opportunity_Location__c);
                            string error_message = 'Oops! There is already a record for '+str+' deparment on this Site ' +' <a href=\'/'+oppLocId+'\' target=\'_blank\'>'+oppLocName+'</a>';
                            ho.addError(error_message, false);
                            break;
                        }
                    }
                    
                }
            } 
        }
    }
}