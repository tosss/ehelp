public class ALL_RecordsFilter_Utility2
{
    
    public static FilteredRecords evaluateCriteria(String CriteriaName, List<Id> ids, String ObjectName)
    {
        FilteredRecords frObj = new FilteredRecords();
        frObj.criteria = '';
        frObj.filteredParentObjects = new Map<Id,Sobject>();
        frObj.filteredChildObjects = new Map<Id, Map<String,List<sobject>>>();
        List<ALL_RecordsFilter_Conditions__c> conditions = [
            SELECT Name, Field__c, Filter_Criteria__c, Operator__c, Value__c 
            FROM ALL_RecordsFilter_Conditions__c 
            WHERE Filter_Criteria__c =: CriteriaName
            Order By CreatedDate desc
        ];
        
        ALL_RecordsFilter_Criteria__c criteriaObj= ALL_RecordsFilter_Criteria__c.getAll().get(CriteriaName); 
        frObj.criteria = criteriaObj.Criteria__c;
        
        String fieldNames =' Id';
        for(ALL_RecordsFilter_Conditions__c condition : conditions)
        {
            if(!condition.Field__c.contains('[]') && !condition.Field__c.contains('[Top]'))
            { 
                String name = condition.Field__c;
                if(!fieldNames.contains(','+name+' ,') && !fieldNames.contains(','+name+' '))
                {
                    fieldNames += ','+name+' ';
                }
            }
            else
            {
                String name = condition.Field__c;
                name = name.substring(0,name.indexOf('['));
                name = name.substring(0,name.lastIndexOf('.'))+'.Id';
                if(!fieldNames.contains(','+name+' ,') && !fieldNames.contains(','+name+' '))
                {
                    fieldNames += ','+name+' ';
                }
            }
        }
        Map<Id, Map<String,List<sobject>>> allChildForAllConditions = new Map<Id, Map<String,List<sobject>>>();
        Map<Id, Map<String,object>> allChildForAllTopConditions = new Map<Id, Map<String,object>>();
        List<sobject> allSobjects = Database.query('SELECT '+fieldNames+' FROM '+ ObjectName+ ' WHERE ID IN: ids');
        for(ALL_RecordsFilter_Conditions__c condition : conditions)
        {
            if(frObj.criteria.contains(condition.Name))
            {
                system.debug(condition.Field__c);
                if(condition.Field__c.contains('[Top]') && !condition.Field__c.contains('[]') )
                {
                    List<Id> allIdsOfParent = new List<Id>();
                    Map<Id,Id> idtoParentId = new Map<Id,Id>();
                    
                    for(sobject sobjectObj : allsobjects)
                    {
                        String fieldName = condition.Field__c;
                        fieldName = fieldName.substring(0,fieldName.indexof('['));
                        fieldName = fieldName.substring(0,fieldName.lastIndexOf('.'));
                        Sobject sobjectDesc = sobjectObj;
                        if(fieldName.contains('.'))
                        {
                            sobjectDesc = sobjectObj.getSobject(fieldName.split('\\.',2)[0]);
                            fieldName= fieldName.split('\\.',2)[1];
                            while(fieldName.contains('.'))
                            {
                                sobjectDesc = sobjectDesc.getSobject(fieldName.split('\\.',2)[0]);
                                fieldName = fieldName.split('\\.',2)[1];
                            }
                        }
                        allIdsOfParent.add((Id)sobjectDesc.getSobject(fieldName).get('Id'));
                        idtoParentId.put((Id)sobjectObj.get('Id'),(Id)sobjectDesc.getSobject(fieldName).get('Id'));
                    }
                    CustomSettings tpm2 = new CustomSettings();
                    Map<Id,Object> result = tpm2.getTopParentFields(allIdsOfParent, condition.Field__c, ObjectName,false);
                    for(Id idOfParent : idtoParentId.keySet())
                    {
                        if(!allChildForAllTopConditions.keySet().contains(idOfParent))
                        {
                            allChildForAllTopConditions.put(idOfParent,new  Map<String,Object>());
                        }
                        Map<String,Object> existing =  allChildForAllTopConditions.get(idOfParent);
                        existing.put(condition.Field__c, result.get(idtoParentId.get(idOfParent)));
                        allChildForAllTopConditions.put(idOfParent,existing);
                    }
                    
                    
                }
                if(condition.Field__c.contains('[]'))
                {
                    List<Id> allIdsOfParent = new List<Id>();
                    Map<Id,Id> idtoParentId = new Map<Id,Id>();
                    for(sobject sobjectObj : allsobjects)
                    {
                        String fieldName = condition.Field__c;
                        fieldName = fieldName.substring(0,fieldName.indexof('['));
                        fieldName = fieldName.substring(0,fieldName.lastIndexOf('.'));
                        Sobject sobjectDesc = sobjectObj;
                        if(fieldName.contains('.'))
                        {
                            sobjectDesc = sobjectObj.getSobject(fieldName.split('\\.',2)[0]);
                            fieldName= fieldName.split('\\.',2)[1];
                            while(fieldName.contains('.'))
                            {
                                sobjectDesc = sobjectDesc.getSobject(fieldName.split('\\.',2)[0]);
                                fieldName = fieldName.split('\\.',2)[1];
                            }
                        }
                        allIdsOfParent.add((Id)sobjectDesc.getSobject(fieldName).get('Id'));
                        idtoParentId.put((Id)sobjectObj.get('Id'),(Id)sobjectDesc.getSobject(fieldName).get('Id'));
                    }
                    Map<Id,List<Sobject>> childObjectsforCurrentCondtion;
                    if(!condition.Field__c.contains('[Top]'))
                    {
                        childObjectsforCurrentCondtion = CustomSettings.queryChildObjects(allIdsOfParent, condition.Field__c, ObjectName);
                    }
                    else
                    {
                        CustomSettings tpm2 = new CustomSettings();
                        childObjectsforCurrentCondtion =  tpm2.getTopParentChildFields(allIdsOfParent,condition.Field__c,ObjectName);
                    }
                    for(Id idOfParent : idtoParentId.keySet())
                    {
                        if(!allChildForAllConditions.keySet().contains(idOfParent))
                        {
                            allChildForAllConditions.put(idOfParent,new  Map<String,List<sobject>>());
                        }
                        Map<String,List<sobject>> existing =  allChildForAllConditions.get(idOfParent);
                        existing.put(condition.Field__c, childObjectsforCurrentCondtion.get(idtoParentId.get(idOfParent)));
                        allChildForAllConditions.put(idOfParent,existing);
                    }
                }
            }
        }
        for(Sobject sobjectObj : allsobjects)
        {     
            Map<String, Boolean> sobjectRecordConditions = new Map<String, Boolean>();
            
            for(ALL_RecordsFilter_Conditions__c condition : conditions)
            { 
                if(frObj.criteria.contains(condition.Name))
                {
                    String fieldName = condition.Field__c;
                    Sobject sobjectDesc = sobjectObj;
                    if(fieldName.contains('[Top]') && !fieldName.contains('[]'))
                    {
                        sobjectRecordConditions.put(condition.Name,CustomSettings.Compare(allChildForAllTopConditions.get((Id)sobjectObj.get('Id')).get(fieldName), condition.Operator__c,condition.Value__c));
                    }
                    else if(!fieldName.contains('[]'))
                    {
                        if(fieldName.contains('.'))
                        {
                            sobjectDesc = sobjectObj.getSobject(fieldName.split('\\.',2)[0]);
                            fieldName= fieldName.split('\\.',2)[1];
                            while(fieldName.contains('.'))
                            {
                                sobjectDesc = sobjectDesc.getSobject(fieldName.split('\\.',2)[0]);
                                fieldName = fieldName.split('\\.',2)[1];
                            }
                        }
                        sobjectRecordConditions.put(condition.Name,CustomSettings.Compare(sobjectDesc.get(fieldName), condition.Operator__c,condition.Value__c));
                    }
                    if(fieldName.contains('[]'))
                    {
                        String name = condition.Field__c;
                        name = name.substring(0,name.indexOf('['));
                        name = name.substring(0,name.lastIndexOf('.'));
                        Map<String,List<sobject>> allChildForcurrentCondtion  =  allChildForAllConditions.get((Id)sobjectObj.get('Id'));
                        List<sobject> childObjects = new List<sobject>();
                        if(allChildForcurrentCondtion != null)
                        {
                            if(allChildForcurrentCondtion.keySet().contains(condition.Field__c))
                            {
                                childObjects = CustomSettings.evaluateChildObjects(allChildForcurrentCondtion.get(condition.Field__c), condition.Field__c,condition.Value__c,condition.Operator__c,ObjectName);    
                            }
                        }
                        
                        if(!frObj.filteredChildObjects.keySet().contains((Id)sobjectObj.get('Id')))
                        {
                            frObj.filteredChildObjects.put((Id)sobjectObj.get('Id'), new Map<String,List<sobject>>());
                        }
                        Map<String,List<sobject>> existing = frObj.filteredChildObjects.get((Id)sobjectObj.get('Id'));
                        existing.put(condition.Field__c,childObjects);
                        frObj.filteredChildObjects.put((Id)sobjectObj.get('Id'), existing);
                        if(childObjects.size()>0)
                        {
                            sobjectRecordConditions.put(condition.Name,true);
                        }
                        else
                        {
                            sobjectRecordConditions.put(condition.Name,false);
                        }
                    }
                }
            }
            if(CustomSettings.EvaluateCriteria(frObj.criteria,sobjectRecordConditions))
            {
                frObj.filteredParentObjects.put((Id)sobjectObj.get('Id'),sobjectObj);
            }
        }
        
        return frObj;
    }
    public class FilteredRecords
    {
        public Map<id,sobject> filteredParentObjects;
        String criteria;
        public Map<Id, Map<String,List<sobject>>> filteredChildObjects; 
    }

}