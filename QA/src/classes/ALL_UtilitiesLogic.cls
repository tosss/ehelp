public class ALL_UtilitiesLogic 
{
    //2016-03-07 - COMMENT: PLEASE DO NOT REMOVE COMMENTED OUT METHODS - siva.pragada@cdk.com - these will be used for expanding automation
    //2015-12-14 - Siva.Pragada@cdk.com Expanded Field Value Conditions custom settings and made changes to CompareTheValues() method.
    //2015-09-18 - class createdby Siva.Pragada@cdk.com 
   
    public static map<string, boolean> evaluatedExpressionsMap = new map<string, boolean>();
    public static map<string, object> identifierToFieldValueMap = new map<string, object>();
    public static integer getCustomSettings = 0;
    public static map<string, Field_Value_Conditions__c> staticFieldValuesOrganizedMap 
        = new map<string, Field_Value_Conditions__c>();
    public static map<string, boolean> fieldValueChangedMap = new map<string, boolean>();
    public static list<string> driversList = new list<string>();
    public static map<string, boolean> allIdentifierTobooleanMap = new map<string, boolean>();
    public static map<string, ALL_Query_Conditions__c> queryConditionsMap;
   
    /*public static void triggerOrderOfExecution(string triggerName)
    {
        Account_Hierarchy_Fields__c ahf = new Account_Hierarchy_Fields__c();
        ahf.Name = string.valueOf(crypto.getRandomInteger());
        
        if(trigger.isBefore && trigger.isUpdate)
        {
            ahf.Field_Name__c = triggerName + ' - isBefore';
        }
        
        if(trigger.isAfter && trigger.isUpdate)
        {
            ahf.Field_Name__c = triggerName + ' - isAfter';
        }
        insert ahf;
    }*/
    
    //01-26-2016 - created - siva.pragada@cdk.com - keep it simple version
    public static boolean fieldValueChangeAndCompareToCustomSetting(Field_Value_Conditions__c fvc, sObject newRecord)
    { 
        string currentField = fvc.Field_Name__c;        
        string customSettingValue = fvc.Field_Value__c;
        boolean newfieldValueEqualsToCustomSettings = false;
        object newFieldValue;
        
        if(currentField != null)
        { 
            if(currentField.contains('.'))
            {
                newFieldValue = ALL_UtilitiesData.GetDataFromNestedFields(currentField, newRecord);
            }
            else
            {
                newFieldValue = newRecord.get(currentField);
            }
            
            if(fvc.EqualsTo__c)
            {
                if(newFieldValue == customSettingValue)
                {
                    newfieldValueEqualsToCustomSettings = true;
                }
            }
            
            if(fvc.Not_EqualsTo__c)
            {
                if(newFieldValue != customSettingValue)
                { 
                    newfieldValueEqualsToCustomSettings = true;
                }
            }
            
            if(fvc.Contains__c)
            {  
                boolean newFieldValueIsNotNull = (newFieldValue != null);
                boolean newFieldValueContainsCustomSettingValue 
                    = newFieldValueIsNotNull && string.valueOf(newFieldValue).containsIgnoreCase(customSettingValue);
                
                if(newFieldValueContainsCustomSettingValue)
                {
                    newfieldValueEqualsToCustomSettings = true;
                }
            }
            
            if(fvc.Not_Contains__c)
            {  
                boolean newFieldValueIsNotNull = (newFieldValue != null);
                boolean newFieldValueContainsCustomSettingValue 
                    = newFieldValueIsNotNull && string.valueOf(newFieldValue).containsIgnoreCase(customSettingValue);
                
                if(!newFieldValueContainsCustomSettingValue || !newFieldValueIsNotNull)
                {
                    newfieldValueEqualsToCustomSettings = true;
                }
            }
            
            if(fvc.isBoolean__c)
            {
                system.debug(fvc.isTrue__c);
                system.debug(newFieldValue);
                if(fvc.isTrue__c == newFieldValue)
                {
                    newfieldValueEqualsToCustomSettings = true;
                }
            }
        }
        else
        {
            if(fvc.isInsert__c && Trigger.isInsert)
            {
                newfieldValueEqualsToCustomSettings = true;
            }
            
            if(fvc.isUpdate__c && Trigger.isUpdate)
            {
                newfieldValueEqualsToCustomSettings = true;
            }
        }
        
        return newfieldValueEqualsToCustomSettings;     
    }
    
    
    //2015-09 - createdby Siva.Pragada@cdk.com
    public static boolean compareField(sObject newRecord, sObject oldRecord, string field)
    {
        boolean valueSame = false;
        
        if(newRecord != null && oldRecord != null && field != null)
        {
            if(newRecord.get(field) == oldRecord.get(field))
            {
                valueSame = true;
            }
        }
        return valueSame;
    }

    // 2015-09 - createdby siva.pragada@cdk.com 
    public static boolean compareNewAndOldTriggerValues(set<string> fieldSet, sObject newRecord, sObject oldRecord)
    {
        boolean fieldValuesChanged = false;
        
        set<boolean> booleanSet = new set<boolean>();
        system.debug(fieldSet);
        if(fieldSet != null && newRecord != null && oldRecord != null)
        {
            for(string field: fieldSet)
            {                
                booleanSet.add(compareField(newRecord, oldRecord, field));
            }
        }
        
        if(booleanSet.contains(false)){ fieldValuesChanged = true; }
        system.debug(booleanSet);
        return fieldValuesChanged;
    }
    
    //createdby Siva.Pragada@cdk.com and modified on 01/08/2016
    public static map<string, Field_Value_Conditions__c> OrganizeFieldValueConditionsInaMap(sObject record)
    {
        List<Field_Value_Conditions__c> FVC = Field_Value_Conditions__c.getAll().Values();
        map<string, Field_Value_Conditions__c> FieldValuesOrganizedMap = new map<string, Field_Value_Conditions__c>();
        string sObjectType = ALL_UtilitiesDescribe.sObjectTypeFinder(record);
        
        for(Field_Value_Conditions__c fv: FVC) 
        {
            if(sObjectType == fv.sObject__c || fv.sObject__c == null)
            {
                FieldValuesOrganizedMap.put(fv.Identifier__c, fv);
            }
        }
        
        return FieldValuesOrganizedMap;
    }
    
    //created 12-28-2015 - siva.pragada@cdk.com
    public static map<string, ALL_Field_Value_Assignment_Settings__c> getFieldValueAssignmentSettings()
    {
        map<string, ALL_Field_Value_Assignment_Settings__c> fieldValueAssignmentSettings 
            = new map<string, ALL_Field_Value_Assignment_Settings__c>();
        
        list<ALL_Field_Value_Assignment_Settings__c> fieldValueAssignmentSettingsList 
            = ALL_Field_Value_Assignment_Settings__c.getAll().Values();
        
        for(ALL_Field_Value_Assignment_Settings__c fva: fieldValueAssignmentSettingsList)
        {
            fieldValueAssignmentSettings.put(fva.Identifier__c, fva);
        }
        
        return fieldValueAssignmentSettings;
    }
   
    //created 12-28-2015 - siva.pragada@cdk.com
    public static map<string, ALL_Query_Conditions__c> getAllQueryConditions()
    {
        queryConditionsMap = new map<string, ALL_Query_Conditions__c>();
        
        list<ALL_Query_Conditions__c> queryConditionsList = ALL_Query_Conditions__c.getAll().Values();
        
        for(ALL_Query_Conditions__c qcs: queryConditionsList)
        {
            queryConditionsMap.put(qcs.Identifier__c, qcs);
        }
        
        return queryConditionsMap;
    }
    
    //created 12-28-2015 - siva.pragada@cdk.com
    public static map<ID, ALL_Field_Value_Assignment_Settings__c> getFieldValueAssignmentsForCurrentCondition(
        string valueAssignmentString)
    {
        system.debug(valueAssignmentString);
        map<ID, ALL_Field_Value_Assignment_Settings__c> fieldValueAssignmentSettingsMap 
            = new map<ID, ALL_Field_Value_Assignment_Settings__c>();
        
        map<string, ALL_Field_Value_Assignment_Settings__c> fieldValueAssignmentSettings 
            = getFieldValueAssignmentSettings();
        
        list<string> Identifiers = valueAssignmentString.split('AND');
        
        if(Identifiers != null && !Identifiers.isEmpty())
        {
            for(string s: Identifiers)
            {
                s = s.normalizeSpace();
                ALL_Field_Value_Assignment_Settings__c fva = fieldValueAssignmentSettings.get(s);
                
                if(fva != null)
                {
                    fieldValueAssignmentSettingsMap.put(fva.ID, fva);
                }
                
            }
        }
        
        return fieldValueAssignmentSettingsMap;
    }
   
    //created 12-28-2015 - siva.pragada@cdk.com
    public static sObject createRecords(string valueAssignmentString, 
                                        string receivingSobjectType, sObject lendingSobject)
    {
        map<ID, ALL_Field_Value_Assignment_Settings__c> fieldValueAssignmentSettingsMap = 
            getFieldValueAssignmentsForCurrentCondition(valueAssignmentString);
        
        sObjectType receivingObjToken = Schema.getGlobalDescribe().get(receivingSobjectType);
        identifierToFieldValueMap = identifierToFieldValueMap(fieldValueAssignmentSettingsMap, lendingSobject);
        
        sObject obj = receivingObjToken.newsObject();
        
        if(fieldValueAssignmentSettingsMap != null && !fieldValueAssignmentSettingsMap.isEmpty())
        {
            for(ALL_Field_Value_Assignment_Settings__c fva: fieldValueAssignmentSettingsMap.values())
            {
                if(fva.Receiving_sObject__c == receivingSobjectType)
                {
                    string receivingField = fva.Receiving_Field_Name__c; 
                    object receivingFieldValue = identifierToFieldValueMap.get(fva.Identifier__c);                
                    obj.put(receivingField, receivingFieldValue);
                }
            }
        }
       
        return obj;
    }    
    
    public static map<string, object> identifierToFieldValueMap(
        map<ID, ALL_Field_Value_Assignment_Settings__c> fieldValueAssignmentSettingsMap, sObject lendingSobject)
    {        
        if(fieldValueAssignmentSettingsMap != null && !fieldValueAssignmentSettingsMap.isEmpty())
        {
            for(ALL_Field_Value_Assignment_Settings__c fva: fieldValueAssignmentSettingsMap.values())
            {  
                if(fva != null)
                {
                    
                    boolean valueAlreadyIntheMap = false;
                    
                    if(identifierToFieldValueMap != null && 
                       identifierToFieldValueMap.keySet().contains(fva.Identifier__c))
                    { 
                        valueAlreadyIntheMap = true;
                    }
                    
                    if(!valueAlreadyIntheMap)
                    {
                        string receivingField = fva.Receiving_Field_Name__c;
                        string lendingField = fva.Lending_Field_Name__c;
                        object receivingFieldValue;
                        
                        if(fva.Lending_sObject__c != null && lendingField != null)
                        { 
                            if(lendingField.contains('.'))
                            {
                                receivingFieldValue = ALL_UtilitiesData.GetDataFromNestedFields(lendingField, lendingSobject);
                            }
                            else
                            {
                                receivingFieldValue = lendingSobject.get(lendingField); 
                            }
                        }
                        else if(fva.String_Field_Value__c != null)
                        { 
                            receivingFieldValue = fva.String_Field_Value__c; 
                        }
                        else if(fva.Query_Conditions_Identifier__c != null)
                        {
                            receivingFieldValue = obtainFieldValue(fva);
                        }
                        
                        identifierToFieldValueMap.put(fva.Identifier__c, receivingFieldValue);
                    }
                }
            }
        } 
        
        return identifierToFieldValueMap;
    }
    
    //created 2-26-2015 - siva.pragada@cdk.com
    public static string getSoqlCondition(string queryConditionString, ALL_Field_Value_Assignment_Settings__c fva)
    {
        string soqlConditionString = '';
        
        ALL_Query_Conditions__c currentQueryCondition = new ALL_Query_Conditions__c();
        
        list<string> conditionsList = new list<string>();
        
        if(queryConditionString.contains('AND') || queryConditionString.contains('OR'))
        {
            conditionsList = queryConditionString.splitByCharacterType();
        }
        else
        {
            if(queryConditionString != null)
            {
                string stringIdentifier = queryConditionString.normalizeSpace();
                currentQueryCondition = queryConditionsMap.get(stringIdentifier);
                conditionsList.add(stringIdentifier);                
            }
           
        }
        
        if(conditionsList != null && !conditionsList.isEmpty())
        {
            for(string s: conditionsList)
            {
                if(s.isNumeric())
                {
                    s = s.normalizeSpace();
                    ALL_Query_Conditions__c currentAllQueryCondition = queryConditionsMap.get(s);
                    
                    if(currentAllQueryCondition != null)
                    {
                        string value = currentAllQueryCondition.Value__c;
                        
                        if(value == null)
                        {
                            if(currentAllQueryCondition.Class_Name__c != null && currentAllQueryCondition.Method_Name__c != null)
                            {
                                value = (string)DynamicSOQL_Helper.routeToSpecificMethod(currentAllQueryCondition, fva);
                            } 
                        }
                        soqlConditionString += currentAllQueryCondition.Key__c + ' ' + currentAllQueryCondition.Operator__c + ' ' + 
                            + '\'' + value + '\'';
                    }
                }
                else
                {
                    soqlConditionString += s;
                }
                
            }
        }
        
        return soqlConditionString;
    }  
    //created 12-28-2015 - siva.pragada@cdk.com
    public static object obtainFieldValue(ALL_Field_Value_Assignment_Settings__c fva)
    {
        string queryConditionString = fva.Query_Conditions_Identifier__c;
        object receivingFieldValue;
        string soqlConditionString = '';
        
        if(queryConditionsMap == null)
        {        
            queryConditionsMap = ALL_UtilitiesLogic.getAllQueryConditions();
        }
        
        if(fva.Query_Field_s__c == null && fva.Query_sObject__c == null)
        {
            queryConditionString = queryConditionString.normalizeSpace();
            ALL_Query_Conditions__c currentAllQueryCondition = queryConditionsMap.get(queryConditionString);
            
            if(currentAllQueryCondition != null && currentAllQueryCondition.Describe_Call__c)
            {
                receivingFieldValue = DynamicSOQL_Helper.routeToSpecificMethod(currentAllQueryCondition, fva);
                return receivingFieldValue;
            }
        }
        else
        {
            soqlConditionString = ALL_UtilitiesLogic.getSoqlCondition(queryConditionString, fva);
        }
        
        string queryString = 'SELECT ' + fva.Query_Field_s__c + ' FROM ' + fva.Query_sObject__c + ' WHERE ' 
            + soqlConditionString + ' LIMIT 1';
        
        system.debug(queryString);
        
        list<sObject> queryResults = dataBase.query(queryString);
        
        if(queryResults.isEmpty())
        {
            return null;
        }
        else
        {
            
            sObject queryResultObject = queryResults.get(0);            
            receivingFieldValue = queryResultObject.get(fva.Query_Field_s__c);
        }
        
        return receivingFieldValue;
    }
   
    public static boolean evaluateExpression(string entireExpression)
    {
        system.debug(entireExpression);
        
        boolean bool = false;
        set<boolean> booleanList = new set<boolean>();
        
        if(entireExpression.contains('AND'))
        {
            for(string s: entireExpression.split('AND'))
            {
                system.debug(s);
                booleanList.add(boolean.valueOf(s.normalizeSpace()));
            } 
            
            if(booleanList.contains(false)){ bool = false;}
            else{ bool = true;}
        }
        else if(entireExpression.contains('OR'))
        {
            for(string s: entireExpression.split('OR'))
            {
                system.debug(s);
                booleanList.add(boolean.valueOf(s.normalizeSpace()));
            } 
            if(booleanList.contains(true)){ bool = true;}
            else{ bool = false;}
        }
        
        system.debug(booleanList);
        system.debug(bool);
        
        return bool;
    }
    
     //Created - 01-29-2016 - siva.pragada@cdk.com
    public static boolean getcompositeExpressionsEvaluatedValue(
        string compositeExpression, sObject newRecord)
    {
        map<string, Field_Value_Conditions__c> FieldValuesOrganizedMap = ALL_UtilitiesLogic.OrganizeFieldValueConditionsInaMap(newRecord);
        string testExpression = compositeExpression;
        
        set<string> driversSet = new set<string>();
        
        if(ALL_UtilitiesLogic.driversList != null && !ALL_UtilitiesLogic.driversList.isEmpty())
        {
            for(string s: ALL_UtilitiesLogic.driversList)
            {
                s = s.normalizeSpace();
                driversSet.add(s);
            }
        }
        system.debug(compositeExpression);
        
        list<string> splitList = compositeExpression.splitByCharacterType();
        
        if(splitList != null && !splitList.isEmpty())
        {
            for(string s: splitList)
            {
                s = s.normalizeSpace();
                
                if(s.isNumeric())
                {
                    boolean currentBool = allIdentifierTobooleanMap.get(s);
                    
                    if(currentBool == null)
                    {
                        system.debug(FieldValuesOrganizedMap);
                        Field_Value_Conditions__c fvc = FieldValuesOrganizedMap.get(s); system.debug(s);
                        currentBool = ALL_UtilitiesLogic.fieldValueChangeAndCompareToCustomSetting(fvc, newRecord);
                        allIdentifierTobooleanMap.put(fvc.Identifier__c, currentBool);
                    }
                    compositeExpression = compositeExpression.replace(s, string.valueOf(currentBool));
                    //testExpression = testExpression.replace(s, string.valueOf(driversSet.contains(s)? false :currentBool));
                }
            }
        }
        
        system.debug(compositeExpression);
        
        compositeExpression = ALL_UtilitiesLogic.recursiveExpressionEvaluate(compositeExpression);
        boolean compositeBool = boolean.valueOf(compositeExpression.normalizeSpace());
        system.debug(compositeBool);
        boolean finalBool = compositeBool;
        
        /*if(compositeBool && oldRecord != null)
        {
            testExpression = ALL_UtilitiesLogic.recursiveExpressionEvaluate(testExpression);
            boolean testBool = boolean.valueOf(testExpression.normalizeSpace());
            
            if(compositeBool ==  testBool)
            {
                finalBool = false;
            }
        }*/
        
        return compositeBool ;
    }
    
    public static string recursiveExpressionEvaluate(string compositeExpression)
    {
        list<string> splitList = new list<string>();
        
        while(!compositeExpression.equals('true') && !compositeExpression.equals('false') )
        {
            if(compositeExpression.contains('(') && compositeExpression.contains(')'))
            {
                
                list<integer> openIndexList = new list<integer>();
                
                string originalExpression = compositeExpression;
                splitList = compositeExpression.split('');
                //openIndexList.clear();
                
                for(integer i=0; i<splitList.size(); i++)
                {
                    string splitString = splitList[i].normalizeSpace();
                    
                    if(splitString == '(')
                    {
                        openIndexList.add(i);
                    }
                    if(splitString == ')')
                    {
                        system.debug(openIndexList);
                        system.debug(openIndexList.size());
                        system.debug(i);
                        integer lastElement = openIndexList.size() - 1;
                        system.debug(lastElement);
                        integer openIndex;
                        
                        if(lastElement>=0)
                        {
                            openIndex = openIndexList.get(lastElement);
                            system.debug(openIndex);
                            string substring = compositeExpression.substring(openIndex, i+1); 
                            system.debug(compositeExpression);
                            system.debug(substring);
                            string expressionLet = substring;
                            
                            if(substring.startsWith('(') && substring.endsWith(')'))
                            {
                                substring = substring.removeStart('(');
                                substring = substring.removeEnd(')');
                            }
                            if(!substring.contains('(') && !substring.contains(')'))
                            {
                                substring = substring.normalizeSpace();
                                boolean substringBool = ALL_UtilitiesLogic.evaluateExpression(substring);
                                
                                system.debug(substring);
                                system.debug(substringBool);
                                
                                compositeExpression = compositeExpression.replace(
                                    expressionLet, string.valueOf(substringBool));
                                system.debug(compositeExpression);
                            }
                            break;
                        }      
                    }
                }
                system.debug(openIndexList);
            }
            else
            {
                compositeExpression = string.valueOf(ALL_UtilitiesLogic.evaluateExpression(compositeExpression));
            }
        }
        return compositeExpression;
    }
    
        // 2015-09 - createdby siva.pragada@cdk.com and Matt.Keefe@cdk.com   
    /*public static map<boolean, list<sObject>> compareNewAndOldTriggerValues(
        set<string> fieldSet, map<ID, sObject> newMap, map<ID, sObject> oldMap)
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
    }*/
    
      
    //created 2015-09 - siva.pragada@cdk.com
   /* public static boolean compareTheValues(string completeExpression, sObject record)
    {
        boolean decodedBoolValue = false;
        list<string> separateANDexpressions = expressionParser(completeExpression);
        set<boolean> boolSet = new set<boolean>();
        
        
        if(separateANDexpressions != null && !separateANDexpressions.isEmpty())
        {
            for(string expression: separateANDexpressions)
            {               
                boolean expressionCheck = ALL_UtilitiesLogic.decodeIdentityExpression(expression, record);
                boolSet.add(expressionCheck);
                evaluatedExpressionsMap.put(expression, expressionCheck);
            }
        }
        
        if(boolSet.contains(true)){ decodedBoolValue = true;}
        
        system.debug(evaluatedExpressionsMap);
        
        return decodedBoolValue;
    }*/
    
    //01-08-2015 - created - siva.pragada@cdk.com
   /* public static list<string> expressionParser(string completeExpression)
    {
        list<string> separateANDexpressions = new list<string>();
        
        if(completeExpression != null && 
           !string.isEmpty(completeExpression) && 
           completeExpression.containsIgnoreCase('OR'))
        {
            separateANDexpressions = completeExpression.split('OR');
        }
        else if(completeExpression != null && 
                !string.isEmpty(completeExpression) &&
                !completeExpression.containsIgnoreCase('OR'))
        {
            separateANDexpressions.add(completeExpression);
        }
        
        if(separateANDexpressions != null && !separateANDexpressions.isEmpty())
        {
            for(integer i=0; i < separateANDexpressions.size(); i++)
            {
                if(separateANDexpressions[i].contains('(') && separateANDexpressions[i].contains(')'))
                {
                    //separateANDexpressions[i] = separateANDexpressions[i].remove('(').remove(')');
                    separateANDexpressions[i] = separateANDexpressions[i].removeStart('(').removeEnd(')');                    
                }
            }
        }
        
        return separateANDexpressions;
    }*/
    
    //Created - 01-18-2016 - siva.pragada@cdk.com
    /*public static boolean parseAndEvaluateCompositeExpression(
        string compositeExpression, sObject newRecord, sObject oldRecord)
    {
        boolean compositeBool;
        string finalCompositeExpression = compositeExpression;
        list<integer> openIndexList = new list<integer>();
        list<string> splitList = compositeExpression.split('');
        list<string> expressions = new list<string>();
        
        if(splitList != null && !splitList.isEmpty())
        {
            for(integer i=0; i<splitList.size(); i++)
            {
                if(splitList[i] == '(')
                {
                    openIndexList.add(i);
                }
                
                if(splitList[i] == ')')
                {
                    integer lastElement = openIndexList.size() - 1;
                    integer openIndex;
                    
                    if(lastElement >= 0)
                    {
                        openIndex = openIndexList.get(lastElement);
                        expressions.add(compositeExpression.substring(openIndex, i+1));                    
                        openIndexList.remove(openIndexList.size() - 1);
                    }      
                }
            }
        }
        
        system.debug(expressions);
        
        boolean expressionBool;
        
        if(expressions != null && !expressions.isEmpty())
        {
            for(string s: expressions)
            {
                system.debug(s);
                string expressionLet = s;
                if(s.startsWith('(') && s.endsWith(')'))
                {
                    s = s.removeStart('(');
                    s = s.removeEnd(')');
                }
                if(!s.contains('(') && !s.contains(')'))
                {
                    expressionBool = ALL_UtilitiesLogic.compareNewAndOldTriggerValuesForConditionalExpression(
                        s, newRecord, oldRecord);
                    system.debug(string.valueOf(expressionBool));
                    compositeExpression = compositeExpression.replace(expressionLet, string.valueOf(expressionBool));
                }
            }
        }
        system.debug(compositeExpression);
        
        if(compositeExpression != null)
        {
            for(string s: compositeExpression.splitByCharacterType())
            {
                if(s.isNumeric())
                {
                    expressionBool = ALL_UtilitiesLogic.compareNewAndOldTriggerValuesForConditionalExpression(
                        s, newRecord, oldRecord);
                    compositeExpression = compositeExpression.replace(s, string.valueOf(expressionBool));
                }
            }
        }
        system.debug(compositeExpression);
        
        if(compositeExpression != null)
        {
            while(!compositeExpression.equals('true') && !compositeExpression.equals('false') )
            {
                if(compositeExpression.contains('(') && compositeExpression.contains(')'))
                {
                    string originalExpression = compositeExpression;
                    splitList = compositeExpression.split('');
                    openIndexList.clear();
                    
                    for(integer i=0; i<splitList.size(); i++)
                    {
                        splitList[i] = splitList[i].normalizeSpace();
                        
                        if(splitList[i] == '(')
                        {
                            openIndexList.add(i);
                        }
                        if(splitList[i] == ')')
                        {
                            integer lastElement = openIndexList.size() - 1;
                            integer openIndex;
                            
                            if(lastElement>=0)
                            {
                                openIndex = openIndexList.get(lastElement);                    
                                string substring = originalExpression.substring(openIndex, i+1);                           
                                system.debug(substring);
                                string expressionLet = substring;
                                
                                if(substring.startsWith('(') && substring.endsWith(')'))
                                {
                                    substring = substring.removeStart('(');
                                    substring = substring.removeEnd(')');
                                }
                                if(!substring.contains('(') && !substring.contains(')'))
                                {
                                    boolean substringBool = ALL_UtilitiesLogic.evaluateExpression(substring);
                                    
                                    system.debug(substring);
                                    system.debug(substringBool);
                                    
                                    compositeExpression = compositeExpression.replace(
                                        expressionLet, string.valueOf(substringBool));
                                    system.debug(compositeExpression);
                                }
                            }      
                        }
                    }
                }
                else
                {
                    compositeExpression = string.valueOf(ALL_UtilitiesLogic.evaluateExpression(compositeExpression));
                }
                compositeExpression = compositeExpression.normalizeSpace();
            }
        }
        
        compositeBool = boolean.valueOf(compositeExpression);
        
        evaluatedExpressionsMap.put(finalCompositeExpression, compositeBool);
        
        return compositeBool;
    }*/
    
    
    //2015-12-14 - createdby Siva.Pragada@cdk.com
   /* public static boolean decodeIdentityExpression(String IdentifierString, sObject sObj)
    {  
        map<string, Field_Value_Conditions__c> fieldValueConditionsMap 
            = ALL_UtilitiesLogic.OrganizeFieldValueConditionsInaMap(sObj);
        
        boolean ValuesMatch = false;
        
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
            string fieldValueInCustomSetting, field;
            Field_Value_Conditions__c fvc = fieldValueConditionsMap.get(s);
            system.debug(s); system.debug(fieldValueConditionsMap); 
            fieldValueInCustomSetting = fvc.Field_Value__c;
            field = fvc.Field_Name__c;
            string fieldValueOnRecord = string.ValueOf(sObj.get(field));
            system.debug(fieldValueOnRecord);
            system.debug(field);
            
            if(field != null)
            {
                if(fvc.EqualsTo__c)
                {
                    if(fieldValueInCustomSetting.equalsIgnoreCase('not null') && 
                       sObj.get(field) != null)
                    {
                        FieldValuesOnCurrentRecord.add('Not Null');
                    }
                    else if(fieldValueInCustomSetting.equalsIgnoreCase('null') && 
                            string.valueOf(sObj.get(field)) == null)
                    {
                        FieldValuesOnCurrentRecord.add('Null');
                    }
                    else
                    {
                        FieldValuesOnCurrentRecord.add(fieldValueOnRecord);
                    }
                    
                    FieldValuesSetFromCustomSettings.add(fieldValueInCustomSetting);
                }
                
                if(fvc.Contains__c)
                {
                    if(fieldValueOnRecord != null && fieldValueOnRecord.containsIgnoreCase(fieldValueInCustomSetting))
                    {
                        FieldValuesOnCurrentRecord.add(fieldValueInCustomSetting);
                    }
                    else
                    {
                        FieldValuesOnCurrentRecord.add(fieldValueOnRecord);
                    }
                    
                    FieldValuesSetFromCustomSettings.add(fieldValueInCustomSetting);
                }
                
                if(fvc.Not_EqualsTo__c)
                {
                    if((fieldValueOnRecord == null) || 
                       (fieldValueOnRecord != null && !fieldValueOnRecord.equalsIgnoreCase(fieldValueInCustomSetting)))
                    {
                        FieldValuesOnCurrentRecord.add(fieldValueInCustomSetting);                       
                    }
                    else 
                    {
                        // do not add to any set, need to have sets unequal for this condition
                    }
                    
                    FieldValuesSetFromCustomSettings.add(fieldValueInCustomSetting);
                    
                }
            }
        }  
        system.debug(FieldValuesSetFromCustomSettings);
        system.debug(FieldValuesOnCurrentRecord);
        
        ValuesMatch = !FieldValuesOnCurrentRecord.isEmpty() && 
            FieldValuesOnCurrentRecord.equals(FieldValuesSetFromCustomSettings);
        
        return ValuesMatch;
    }*/
    
    
    //01-08-2015 - created - siva.pragada@cdk.com 
    /*public static boolean compareNewAndOldTriggerValuesForConditionalExpression(
        string entireExpression, sObject newRecord, sObject oldRecord)
    {
        boolean ValuesChangedAndEqualsSettingsValues = false;
        
        //break expressions by OR
        list<string> expressionSplitByOR = expressionParser(entireExpression);
        system.debug(expressionSplitByOR);
        map<string, list<string>> expressionToSplitList = new map<string, list<string>>();
        map<string, boolean> expressionToBoolean = new map<string, boolean>();
        map<string, Field_Value_Conditions__c> FieldValuesOrganizedMap 
            = ALL_UtilitiesLogic.OrganizeFieldValueConditionsInaMap(newRecord);
        
        
        if(expressionSplitByOR != null && !expressionSplitByOR.isEmpty())
        {
            for(string eachExpression: expressionSplitByOR)
            {
                list<string> identityValuesList = new list<string>();
                
                system.debug(eachExpression);
                
                if(eachExpression != null && eachExpression.contains('AND'))
                {
                    identityValuesList = eachExpression.split('AND');
                }
                else 
                {
                    identityValuesList.add(eachExpression);
                }
                
                expressionToSplitList.put(eachExpression, identityValuesList);
            }
        }
        
        system.debug(expressionToSplitList);
        system.debug(FieldValuesOrganizedMap);
        system.debug(FieldValuesOrganizedMap.keySet());
        
        if(expressionToSplitList != null && !expressionToSplitList.isEmpty())
        {
            for(string aNDexpression: expressionToSplitList.keySet())
            {
                list<string> valuesSplitByAND = expressionToSplitList.get(aNDexpression);
                
                if(valuesSplitByAND != null && !valuesSplitByAND.isEmpty())
                {
                    list<Field_Value_Conditions__c> expressionFVCsList = new list<Field_Value_Conditions__c>();
                    boolean singleORexpressionbool = false;
                    
                    system.debug(valuesSplitByAND);
                    
                    for(string identityNumber: valuesSplitByAND)
                    {
                        identityNumber = identityNumber != null ? identityNumber.normalizeSpace() : null;
                        
                        if(identityNumber != null)
                        {
                            system.debug(identityNumber);
                            Field_Value_Conditions__c fvc = FieldValuesOrganizedMap.get(identityNumber);
                            system.debug(fvc);
                            if(fvc != null)
                            {
                                expressionFVCsList.add(fvc);
                            }
                        }
                        
                    } 
                    system.debug(expressionFVCsList);
                    singleORexpressionbool = compareNewAndOldTriggerValuesForGivenFVCs(
                        expressionFVCsList, newRecord, oldRecord);
                    expressionToBoolean.put(aNDexpression, singleORexpressionbool);
                    ALL_UtilitiesLogic.evaluatedExpressionsMap.put(aNDexpression, singleORexpressionbool);
                }
            }
        }
        system.debug(expressionToBoolean);
        set<boolean> boolSet = new set<boolean>();
        
        if(expressionToBoolean != null && !expressionToBoolean.isEmpty())
        {
            boolSet.addAll(expressionToBoolean.values());
        }
        
        if(boolSet.contains(true)){ ValuesChangedAndEqualsSettingsValues = true; }
        
        ALL_UtilitiesLogic.evaluatedExpressionsMap.put(entireExpression, ValuesChangedAndEqualsSettingsValues);
        
        system.debug(ALL_UtilitiesLogic.evaluatedExpressionsMap);
        
        return ValuesChangedAndEqualsSettingsValues;
    }*/
    
    //01-08-2015 - created - siva.pragada@cdk.com
   /* public static boolean compareNewAndOldTriggerValuesForGivenFVCs(
        list<Field_Value_Conditions__c> FVCsToCheck, sObject newRecord, sObject oldRecord)
    {
        boolean expressionFieldValuesChanged = null;
        set<boolean> boolSet = new set<boolean>();
        
        if(FVCsToCheck != null && !FVCsToCheck.isEmpty())
        {
            expressionFieldValuesChanged = true;
            
            for(Field_Value_Conditions__c fvc: FVCsToCheck)
            {
                boolean fieldValueChangedAndEqualsToCustomSettings = fieldValueChangeAndCompareToCustomSetting2(fvc, newRecord, oldRecord);                                
                boolSet.add(fieldValueChangedAndEqualsToCustomSettings);
            }
        }
        
        if(boolSet.contains(false)){ expressionFieldValuesChanged = false;}
        
        return expressionFieldValuesChanged;
    }*/
    
    
    //01-26-2016 - created - siva.pragada@cdk.com - go crazy version
    /*public static boolean fieldValueChangeAndCompareToCustomSetting2(Field_Value_Conditions__c fvc, sObject newRecord, sObject oldRecord)
    {
        
        string currentField = fvc.Field_Name__c;
        object newFieldValue = newRecord.get(currentField);
        object oldFieldValue = oldRecord != null ? oldRecord.get(currentField) : null;
        string customSettingValue = fvc.Field_Value__c;
        boolean newfieldValueEqualsToCustomSettings = false;
        boolean fieldValueChanged = (newFieldValue != oldFieldValue);
        
        
        string identifier = fvc.Identifier__c;
        identifier = identifier != null ? identifier.normalizeSpace() : null;
        
        
        if(currentField != null)
        { 
            if(fvc.EqualsTo__c)
            {
                if(newFieldValue == customSettingValue)
                {
                    if(oldRecord != null){ fieldValueChangedMap.put(identifier, fieldValueChanged); }                    
                    if(oldRecord != null && fieldValueChanged)
                    { driversList.add(identifier);  newfieldValueEqualsToCustomSettings = true; } 
                    if(oldRecord == null){ newfieldValueEqualsToCustomSettings = true; }
                }
            }
            
            if(fvc.Not_EqualsTo__c)
            {
                if(newFieldValue != customSettingValue)
                { 
                    if(oldRecord != null && fieldValueChanged)
                    { 
                        fieldValueChangedMap.put(identifier, true); 
                        driversList.add(identifier); 
                        newfieldValueEqualsToCustomSettings = true;
                    }
                    
                    if(oldRecord != null && !fieldValueChanged){ fieldValueChangedMap.put(identifier, false); }
                    if(oldRecord == null){ newfieldValueEqualsToCustomSettings = true; }
                }
                
                if(newFieldValue == customSettingValue && oldRecord != null && oldFieldValue != customSettingValue)
                { fieldValueChangedMap.put(identifier, true); }
                
            }
            
            if(fvc.Contains__c)
            {  
                boolean oldFieldValueDoesNotContainCustomSettingValue 
                    = (oldFieldValue != null && 
                       !string.valueOf(oldFieldValue).containsIgnoreCase(customSettingValue));
                boolean newFieldValueIsNotNull = (newFieldValue != null);
                boolean newFieldValueContainsCustomSettingValue 
                    = newFieldValueIsNotNull && string.valueOf(newFieldValue).containsIgnoreCase(customSettingValue);
                
                if((oldFieldValueDoesNotContainCustomSettingValue || oldRecord == null) && 
                   newFieldValueContainsCustomSettingValue)
                {
                    newfieldValueEqualsToCustomSettings = true;
                    if(oldRecord != null)
                    { fieldValueChangedMap.put(identifier, true); driversList.add(identifier);}
                }
                else if((oldFieldValue == null || oldRecord == null) && 
                        newFieldValueContainsCustomSettingValue)
                {
                    newfieldValueEqualsToCustomSettings = true;
                    fieldValueChangedMap.put(identifier, true);
                    if(oldRecord != null) { driversList.add(identifier); }
                }
                
                if(newFieldValue != oldFieldValue)
                {
                    fieldValueChangedMap.put(identifier, true);
                }
            }
        }
        
        return newfieldValueEqualsToCustomSettings;        
    }*/
    
    
        //2015-09 - createdby Siva.Pragada@cdk.com
   /* public static boolean allFieldValuesComparison(string expression, sobject newRecord, sObject oldRecord)
    {
        if(getCustomSettings != 1)
        { 
            staticFieldValuesOrganizedMap = ALL_UtilitiesLogic.OrganizeFieldValueConditionsInaMap(newRecord);
            getCustomSettings = 1;
        }      
       
        boolean fieldsChangedAndConditionsMet = false;
        
        List<string> FieldIdentifiers = new list<string>();
        set<string> fieldSet = new set<string>();
        list<Field_Value_Conditions__c> FVCsToCheck = new list<Field_Value_Conditions__c>();
        
        if(expression != null && !string.isEmpty(expression) && expression.contains('AND'))
        {
            FieldIdentifiers = expression.Split('AND');
        }
        else if(expression != null && !string.isEmpty(expression) && !expression.contains('AND'))
        {
            expression = expression.normalizeSpace();
            FieldIdentifiers.add(expression);
        }
        
        system.debug(FieldIdentifiers);
        
        set<boolean> booleanSet = new set<boolean>();
        
        if(FieldIdentifiers != null && !FieldIdentifiers.isEmpty())
        {
            for(string identity: FieldIdentifiers)
            { 
                if(identity != null)
                {
                    system.debug(identity);
                    identity = identity.normalizeSpace();
                    system.debug(identity);
                    Field_Value_Conditions__c currentFieldValueSetting = staticFieldValuesOrganizedMap.get(identity);
                    if(currentFieldValueSetting != null){ FVCsToCheck.add(currentFieldValueSetting);}
                    string FieldAPIName = currentFieldValueSetting != null ? currentFieldValueSetting.Field_Name__c : null;                    
                    system.debug(FieldAPIName);
                    
                    if(FieldAPIName != null)
                    {                
                        fieldSet.add(FieldAPIName); 
                    } 
                }
            } 
        }
       
        fieldsChangedAndConditionsMet = compareNewAndOldTriggerValues(fieldSet, newRecord, oldRecord);
        
        return fieldsChangedAndConditionsMet;
    }*/
    
    
    //this method is not needed at this time. may be needed to genericize the functionality like this
    /*public static string concatenatedValue(ALL_Field_Value_Assignment_Settings__c fva)
    {
        string concatenatedValue, stringConcate;
        
        map<string, ALL_Field_Value_Assignment_Settings__c> fieldValueAssignmentSettings = getFieldValueAssignmentSettings();
        Schema.DescribeSObjectResult sObjectDescribeResult = ALL_UtilitiesDescribe.getDescribeInfoForsObject(fva.Lending_sObject__c);        
        Map<String,Schema.SObjectField> fieldsMap = sObjectDescribeResult != null ? sObjectDescribeResult.fields.getMap() : null;
                
        if(fva != null)
        {
            stringConcate = fva.Concatenate__c;
            list<string> fieldIdentifiers = stringConcate.split('\\+');
            
            if(fieldIdentifiers != null && !fieldIdentifiers.isEmpty())
            {
                for(string identity: fieldIdentifiers)
                {
                    identity = identity.normalizeSpace();
                    object fieldValue;
                    string fieldLabel;
                    
                    if(identity.isNumeric())
                    { 
                        fieldValue = identifierToFieldValueMap.get(identity); 
                        ALL_Field_Value_Assignment_Settings__c fv = fieldValueAssignmentSettings.get(identity);
                        fieldLabel = fieldsMap != null ? fieldsMap.get(fv.Lending_Field_Name__c).getDescribe().getLabel() : '';
                    }
                    else{ concatenatedValue += identity; }
                    
                    
                    
                    if(fieldValue != null)
                    {
                        concatenatedValue +=  fieldLabel + ': ' + fieldValue + ' ';
                    }
                }
            }            
            
        }
        
        return concatenatedValue;
    }*/
}