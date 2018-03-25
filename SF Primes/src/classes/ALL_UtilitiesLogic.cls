public class ALL_UtilitiesLogic 
{  
    //createdby Siva.Pragada@cdk.com
    public static boolean allFieldValuesComparison(string identifier, sobject newRecord, sObject oldRecord)
    {
        map<string, map<string, string>> FieldValuesOrganizedMap = ALL_UtilitiesData.OrganizeFieldValueConditionsInaMap();        
        map<string, string> FieldNamesMap, FieldValuesMap;
        
        FieldNamesMap = FieldValuesOrganizedMap.get('FieldNames');
        FieldValuesMap = FieldValuesOrganizedMap.get('FieldValues');
        
        boolean fieldsChangedAndConditionsMet = false;
        
        List<string> FieldIdentifiers = new list<string>();
        set<string> fieldSet = new set<string>();
        
        if(identifier != null && !string.isEmpty(identifier) && identifier.contains('AND'))
        {
            FieldIdentifiers = identifier.Split('AND');
        }
        else if(identifier != null && !string.isEmpty(identifier) && !identifier.contains('AND'))
        {
            identifier = identifier.normalizeSpace();
            FieldIdentifiers.add(identifier);
        }
        
        system.debug(FieldIdentifiers);
        
        set<boolean> booleanSet = new set<boolean>();
        
        if(FieldIdentifiers != null && !FieldIdentifiers.isEmpty())
        {
            for(string identity: FieldIdentifiers)
            { 
                identity = identity!= null?identity.normalizeSpace():identity;                
                string FieldAPIName = FieldNamesMap.get(identifier);                
                fieldSet.add(FieldAPIName);                
            } 
        }
        
        fieldsChangedAndConditionsMet = compareNewAndOldTriggerValues(fieldSet, newRecord, oldRecord);
        
        return fieldsChangedAndConditionsMet;
    }
    
    //createdby Siva.Pragada@cdk.com
    public static boolean compareField(sObject newRecord, sObject oldRecord, string field)
    {
        boolean valueSame = false;
        
        if(newRecord != null && oldRecord != null && field != null && !string.isEmpty(field))
        {
            if(newRecord.get(field) == oldRecord.get(field))
            {
                valueSame = true;
            }
        }
        return valueSame;
    }
    
    //createdby Siva.Pragada@cdk.com and Matt.Keefe@cdk.com    
    public static map<boolean, list<sObject>> compareNewAndOldTriggerValues(set<string> fieldSet, map<ID, sObject> newMap, map<ID, sObject> oldMap)
    {
        map<boolean, list<sObject>> ChangedRecordsMap = new map<boolean, list<sObject>>();
        
        if(Trigger.isAfter || Trigger.isUpdate)
        {
            if(!fieldSet.isEmpty() && !newMap.isEmpty() && !oldMap.isEmpty())
            {
                boolean fieldValuesChanged;
                
                for(sObject obj: newMap.values())
                {
                    fieldValuesChanged =  compareNewAndOldTriggerValues(fieldSet, obj, oldMap.get(obj.ID));
                    list<sObject> recordList = ChangedRecordsMap.get(fieldValuesChanged);
                    if(recordList == null){ recordList = new list<sObject>();}
                    recordList.add(obj);
                    ChangedRecordsMap.put(fieldValuesChanged, recordList);
                }
            }
        }
        
        return ChangedRecordsMap;
    }
    public static boolean compareNewAndOldTriggerValues(set<string> fieldSet, sObject newRecord, sObject oldRecord)
    {
        boolean fieldValuesChanged = false;
        
        set<boolean> booleanSet = new set<boolean>();
        
        if(fieldSet != null && newRecord != null && oldRecord != null)
        {
            for(string field: fieldSet)
            {
                booleanSet.add(compareField(newRecord, oldRecord, field));
            }
        }
        
        if(booleanSet.contains(false)){ fieldValuesChanged = true; }
        
        return fieldValuesChanged;
    }
    
    //createdby Siva.Pragada@cdk.com
    public static boolean compareTheValues(String IdentifierString, sObject sObj)
    {        
        map<string, map<string, string>> FieldValuesOrganizedMap = ALL_UtilitiesData.OrganizeFieldValueConditionsInaMap(); 
        
        map<string, string> FieldNamesMap = FieldValuesOrganizedMap.get('FieldNames');
        map<string, string> FieldValuesMap = FieldValuesOrganizedMap.get('FieldValues');
        
        boolean ValuesMatch = null;
        
        list<string> Values = new list<string>();
        
        if(IdentifierString != null && IdentifierString.contains('AND'))
        {
            Values = IdentifierString.split('AND');
        }
        else 
        {
            Values.add(IdentifierString);
        }
        set<string> FieldValuesSetFromCustomSettings = new set<string>();
        set<string> FieldValuesOnCurrentRecord = new set<string>();
        
        for(string s: Values)
        {    
            s = s.normalizeSpace();
            string fieldValue, field;
            
            fieldValue = FieldValuesMap.get(s);
            field = FieldNamesMap.get(s);
            
            FieldValuesSetFromCustomSettings.add(fieldValue);
            
            if(field != null)
            {
                if(fieldValue.equalsIgnoreCase('not null') && 
                   sObj.get(field) != null)
                {
                    FieldValuesOnCurrentRecord.add('Not Null');
                }
                else if(fieldValue.equalsIgnoreCase('null') && 
                        string.valueOf(sObj.get(field)) == null)
                {
                    FieldValuesOnCurrentRecord.add('Null');
                }
                else
                {
                    FieldValuesOnCurrentRecord.add(string.ValueOf(sObj.get(field)));
                }
            }
        }  
        
        ValuesMatch = !FieldValuesOnCurrentRecord.isEmpty() && FieldValuesOnCurrentRecord.equals(FieldValuesSetFromCustomSettings);
        
        return ValuesMatch;
    }
}