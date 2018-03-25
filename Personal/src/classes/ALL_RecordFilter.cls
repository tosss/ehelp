public class ALL_RecordFilter 
{
    public static FilteredRecords evaluateCriteria(String criteriaName,String objectName,List<Id> Ids)
    {
        FilteredRecords filteredRecordObject = new FilteredRecords();
        All_RecordsFilter_Criteria__c criteriaObject = All_RecordsFilter_Criteria__c.getAll().get(criteriaName);
        criteriaName =  '%'+criteriaName+'%';
        List<ALL_RecordsFilter_Conditions__c> conditions = [
            SELECT Name, Field__c, Filter_Criteria__c, Operator__c, Value__c
            FROM ALL_RecordsFilter_Conditions__c
            WHERE Filter_Criteria__c LIKE :criteriaName
            Order By CreatedDate desc
        ];
        String queryingFields = 'Id';
        Map<String,String> subQueryFieldsMap = new Map<String,String>();
        for(ALL_RecordsFilter_Conditions__c condition : conditions)
        {
            String conditionName = String.valueOf(Integer.valueOf(condition.Name));
            if(criteriaObject.Criteria__c.contains(' '+conditionName+' ')||criteriaObject.Criteria__c.startswith(conditionName)|| criteriaObject.Criteria__c.endswith(conditionName))
            {
                if(!condition.Field__c.contains('[]') && !condition.Field__c.contains('[Top]'))
                {
                    queryingFields += ','+CustomSettings3.getFieldName(condition.Field__c);
                }
                else if(!condition.Field__c.contains('[Top]') || (condition.Field__c.contains('[]') && (condition.Field__c.indexOf('[]') < condition.Field__c.indexOf('[Top]'))))
                {
                    if(condition.Field__c.indexOf('[]') < condition.Field__c.indexOf('.')) 
                    {
                        String relationName = CustomSettings3.getChildRelationName(condition.Field__c);
                        if(!subQueryFieldsMap.keySet().contains(relationName))
                        {
                            subQueryFieldsMap.put(relationName,'Id');
                        }
                        String existingFields = ','+subQueryFieldsMap.get(relationName)+CustomSettings3.getFieldNameForChildRelation(condition.Field__c);
                    }
                    else
                    {
                        queryingFields += ','+CustomSettings3.relationsBeforeChild(condition.Field__c)+'.Id'; 
                    }
                }
                else
                {
                    queryingFields += ','+CustomSettings3.relationsBeforeTop(condition.Field__c)+'.Id';
                }
            }
        }
        queryingFields = CustomSettings3.uniqueFields(queryingFields);
        for(String relationName : subQueryFieldsMap.keySet())
        {
            String subqueryFields = CustomSettings3.uniqueFields(subQueryFieldsMap.get(relationName));
            queryingFields += ', ( select '+subqueryFields+' from '+relationName+' )';
        }
        Map<Id, sobject> queryResult = new Map<Id,Sobject>(Database.query('Select '+queryingFields+' from '+objectName+ ' where id IN: Ids'));
        Map<String,childConditions> childRelationCondition = new Map<String,childConditions>();
        Map<String,topParentCondition> parentTopConditions = new Map<String,topParentCondition>();
        for(ALL_RecordsFilter_Conditions__c condition:conditions)
        {
            String conditionName = String.valueOf(Integer.valueOf(condition.Name));
            if(criteriaObject.Criteria__c.contains(conditionName) && (condition.Field__c.contains('[]') || condition.Field__c.contains('[Top]') ))
            {
                if(condition.Field__c.contains('[]') && ((!condition.Field__c.contains('[Top]') && (condition.Field__c.indexOf('[]') > condition.Field__c.indexOf('.')))
                   ||(condition.Field__c.contains('[Top]') && (condition.Field__c.indexOf('[]') < condition.Field__c.indexOf('[Top]')))))
                {
                    String relationsIncludingChild = condition.Field__c.substringBefore('[]');
                    if(!childRelationCondition.keySet().contains(relationsIncludingChild))
                    {
                        childConditions Cc = new childConditions();
                        cc.relationName = CustomSettings3.getChildRelationName(condition.Field__c);
                        cc.parentObjectName = CustomSettings3.getObjectNameForChildRelation(condition.Field__c, ObjectName);
                        cc.fieldNames = 'Id';
                        cc.parentIds = new Set<Id>();
                        cc.conditionsIncluded = '';
                        childRelationCondition.put(relationsIncludingChild, cc);
                    }
                    childConditions exisitngCC = childRelationCondition.get(relationsIncludingChild);
                    exisitngCC.fieldNames += ','+CustomSettings3.getFieldNameForChildRelation(condition.Field__c);
                    exisitngCC.conditionsIncluded += ','+conditionName;
                    childRelationCondition.put(relationsIncludingChild, exisitngCC);
                }
                if(condition.Field__c.contains('[Top]'))
                {
                    String relationsIncludingChild = condition.Field__c.substringBefore('[Top]');
                    if(!parentTopConditions.keySet().contains(relationsIncludingChild))
                    {
                        topParentCondition tpc = new topParentCondition();
                        tpc.parentObjectName = CustomSettings3.getObjectNameForParentTop(condition.Field__c, ObjectName);
                        tpc.parentIds = new Set<Id>();
                        tpc.relationName = CustomSettings3.getTopParentRelationName(condition.Field__c); 
                        tpc.fieldNames = 'Id';
                        tpc.levels = CustomSettings3.getFieldDepth(condition.Field__c);
                        tpc.conditionsIncluded = '';
                        parentTopConditions.put(relationsIncludingChild,tpc);
                    }
                    topParentCondition exisitngTpc = parentTopConditions.get(relationsIncludingChild);
                    exisitngTpC.fieldNames += ','+CustomSettings3.getFieldNameForTopParentRelation(condition.Field__c);
                    exisitngTpc.conditionsIncluded +=  ','+conditionName;
                    parentTopConditions.put(relationsIncludingChild,exisitngTpC);
                }
            }
        }
        childRelationCondition = CustomSettings3.addParentIds(childRelationCondition,queryResult.values());
        Map<String,Map<Id,sobject>> childConditions = Customsettings3.queryChildRecords(childRelationCondition);
        parentTopConditions = CustomSettings3.addParentIds(parentTopConditions,queryResult.values(),childConditions,ObjectName); 
        CustomSettings3 cs3 = new CustomSettings3();
        Map<String,Map<Id,sobject>> childToTopParentMap = new Map<String,Map<Id,sobject>>();
        for(topParentCondition tpc : parentTopConditions.values())
        {
            if(!childToTopParentMap.keySet().contains(tpc.relationName))
            {
                childToTopParentMap.put(tpc.relationName,cs3.queryTopIds(tpc,''));
            }
            else
            {
                Map<Id,sobject> existingMap = childToTopParentMap.get(tpc.relationName);
                tpc.parentIds.removeAll(existingMap.keySet());
                if(tpc.parentIds.size()>0)
                {
                    existingMap.putAll(cs3.queryTopIds(tpc,''));
                    childToTopParentMap.put(tpc.relationName,existingMap);
                }
            }
        }
        for(ALL_RecordsFilter_Conditions__c condition:conditions)
        {
            String conditionName = String.valueOf(Integer.valueOf(condition.Name));
            if(criteriaObject.Criteria__c.contains(conditionName) && (condition.Field__c.contains('[]') && condition.Field__c.contains('[Top]') ))
            {
                if(condition.Field__c.indexOf('[Top]')<condition.Field__c.indexOf('[]'))
                {
                    
                }
            }
        }
        return filteredRecordObject;
    }
    public class FilteredRecords
    {
        public Map<id,sobject> filteredParentObjects;
        String criteria;
        public Map<Id, Map<String,List<sobject>>> filteredChildObjects;
    }
    public class childConditions
    {
        public string parentObjectName;
        public string relationName;
        public Set<Id> parentIds;
        public String fieldNames;
        public String conditionsIncluded;
    }
    public class topParentCondition
    {
        public String parentObjectName;
        public String relationName;
        public String fieldNames;
        public Integer levels;
        public Set<Id> parentIds;
        public String conditionsIncluded;
    }
}