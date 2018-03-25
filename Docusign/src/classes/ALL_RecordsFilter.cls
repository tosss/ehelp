public class ALL_RecordsFilter 
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
        ];
        
        ALL_RecordsFilter_Criteria__c criteriaObj= ALL_RecordsFilter_Criteria__c.getAll().get(CriteriaName); 
        frObj.criteria = criteriaObj.Criteria__c;
        
        String fieldNames =' Id';
        for(ALL_RecordsFilter_Conditions__c condition : conditions)
        {
            if(!condition.Field__c.contains('[]'))
            {
                fieldNames += ','+ condition.Field__c+' ';
            }
            else
            {
                String name = condition.Field__c;
                name = name.substring(0,name.indexOf('['));
                name = name.substring(0,name.lastIndexOf('.'))+'.Id';
                fieldNames += ','+name+' ';
            }
        }
        
        List<sobject> allSobjects = Database.query('SELECT '+fieldNames+' FROM '+ ObjectName+ ' WHERE ID IN: ids');
                
        for(Sobject sobjectObj : allsobjects)
        {     
        	Map<String, Boolean> sobjectRecordConditions = new Map<String, Boolean>();
            
            for(ALL_RecordsFilter_Conditions__c condition : conditions)
            { 
                if(frObj.criteria.contains(condition.Name))
                {
                    String fieldName = condition.Field__c;
                    Sobject sobjectDesc = sobjectObj;
                    if(!fieldName.contains('[]'))
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
                    else
                    {
                        String name = condition.Field__c;
                        name = name.substring(0,name.indexOf('['));
                        name = name.substring(0,name.lastIndexOf('.'));
                        List<sobject> childObjects = CustomSettings.evaluateChildObjects(String.valueOf(sobjectDesc.getSobject(name).get('Id')), condition.Field__c,condition.Value__c,condition.Operator__c,ObjectName);
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