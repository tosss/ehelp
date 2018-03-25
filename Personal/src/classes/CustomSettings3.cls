public class CustomSettings3 {
 
    Set<Id> hasParentSobjects;
    Map<Id,Id> hasSobjectMap;
  
    //Example: CustomSettings3.queryChildObjects(new List<Id>{'00154000002HlO0'},'Role__c,Name','Account','Contacts')
    public static Map<Id,List<sobject>> queryChildObjects(List<Id> ParentIds, String fieldNames, String ParentObject,String requiredRelation)
    {
        Map<Id,List<sobject>> fileteredObjects = new Map<Id,List<sobject>>();
              
        List<sobject> allObjects = Database.Query('Select id, (select id, '+fieldNames+' from '+requiredRelation+' ) from '+ParentObject+' Where Id In: ParentIds');
        for(sobject sobjObj : allObjects)
        {
            fileteredObjects.put((Id)sobjObj.get('Id'),sobjObj.getSobjects(requiredRelation));
        }
        return fileteredObjects;
    }
    public static String getChildRelationName(String ConditionName)
    {
        if(ConditionName.contains('.') && (ConditionName.indexOf('.')< ConditionName.indexOf('[]')))
        {
            //Example : Opportunity.Account.Contacts[].Account.Parent[Top].Name;
            return ConditionName.substringBetween('.','[]');
        }
        //Example : Opportunity.Contacts[].Account.Parent[Top].Name;
        return ConditionName.substringBefore('[]');
    }
    public static String getTopParentRelationName(String ConditionName)
    {
        if(ConditionName.indexOf('[]') > ConditionName.indexOf('[Top]'))
        {
            return ConditionName.substringBetween('.','[Top]');
        }
        ConditionName = ConditionName.substringBefore('[Top]');
        ConditionName = ConditionName.reverse();
        ConditionName = ConditionName.substringBefore('.');
        return ConditionName.reverse();
    }
    public static String getTopParentBaseRelationName(String ConditionField)
    {
        String baseRelation = ConditionField.substringBefore('[Top]');
        baseRelation = baseRelation.reverse();
        baseRelation = baseRelation.substringAfter('.');
        if(baseRelation.contains('.'))
        {
            baseRelation = baseRelation.substringBefore('.');
        }
        return baseRelation.reverse();
    }
    public static String getChildBaseRelationName(String ConditionField)
    {
        String baseRelation = ConditionField.substringBefore('[]');
        baseRelation = baseRelation.reverse();
        baseRelation = baseRelation.substringAfter('.');
        if(baseRelation.contains('.'))
        {
            baseRelation = baseRelation.substringBefore('.');
        }
        return baseRelation.reverse();
    }
    public static String relationsBeforeChild(String ConditionField)
    {
        String baseRelation = ConditionField.substringBefore('[]');
        baseRelation = baseRelation.reverse();
        baseRelation = baseRelation.substringAfter('.');
        return baseRelation.reverse();
    }
    public static String relationsBeforeTop(String ConditionField)
    {
        String baseRelation = ConditionField.substringBefore('[Top]');
        baseRelation = baseRelation.reverse();
        baseRelation = baseRelation.substringAfter('.');
        return baseRelation.reverse();
    }
    public static String getFieldNameForTopParentRelation(String ConditionField)
    {
        if(ConditionField.contains('[]') && (ConditionField.indexOf('[Top]') < ConditionField.indexOf('[]')))
        {
            String parentField = ConditionField.substring(ConditionField.indexof('[Top]')+6,ConditionField.indexof('[]'));
            if(parentField.contains('.'))
            {
                //Example : Opportunity.Account.Parent[Top].Account.Contacts[].Name;
                return parentField.substring(0,parentField.lastIndexOf('.'))+'.Id';
            }
            //Example : Opportunity.Account.Parent[Top].Contacts[].Name;
            return ConditionField.substringBetween('.','[Top]')+'.Id';
        }
        //Example : Opportunity.Account.Parent[Top].CreatedBy.Name;
        return ConditionField.substring(ConditionField.lastIndexof(']')+2,ConditionField.length());
    }
    
    public static String getFieldNameForChildRelation(String ConditionField)
    {
        if(ConditionField.contains('[Top]') && (ConditionField.indexOf('[]') < ConditionField.indexOf('[Top]')))
        {
            String parentField = ConditionField.substring(ConditionField.indexof(']')+2,ConditionField.indexof('[Top]'));
            if(parentField.contains('.'))
            {
                //Example : Opportunity.Account.Contacts[].Account.Parent[Top].Name;
                return parentField.substring(0,parentField.lastIndexOf('.'))+'.Id';
            }
            //Example : Opportunity.Account.Contacts[].Parent[Top].Name;
            return parentField+'.Id';
        }
        //Example : Opportunity.Account.Contacts[].CreatedBy.Name;
        return ConditionField.substring(ConditionField.lastIndexof(']')+2,ConditionField.length());
    }
    
    public static string getFieldName(String ConditionField)
    {
        if(ConditionField.contains(']'))
        {
            return ConditionField.substring(ConditionField.lastIndexof(']')+2,ConditionField.length());
        }
        return ConditionField;
    }
    public static string getObjectNameForParentTop(String ConditionName, String ParentObject)
    {
        if(ConditionName.contains('[]') && (ConditionName.indexOf('[]')<ConditionName.indexOf('[Top]')))
        {
            String conditionFieldForChild = ConditionName.substringBefore('[]')+'[].'+ConditionName.substringBetween('].','.');
            String ChildObjectParentType = getObjectNameForChildRelation(conditionFieldForChild,ParentObject);
            String ChildRelation=getChildRelationName(ConditionName);
            String childObjectType = '';
            for(Schema.ChildRelationship cr:Schema.getGlobalDescribe().get(ChildObjectParentType).getDescribe().getChildRelationships())
            {
                if(cr.getRelationshipName() == ChildRelation)
                {
                   
                    childObjectType = String.valueOf(cr.getChildSobject());
                    break;
                }
            }
            return getObjectNameForParentTop(ConditionName.substringAfter('[]'),childObjectType);
            return conditionFieldForChild; 
        }
        
        String relationNameToFind = ConditionName.substringAfter('[Top]');
        relationNameToFind = '[Top]'+relationNameToFind;
        String   temp = ConditionName.substringBefore('[Top]');
        return getObjectNameAnyDepth(relationNameToFind,temp,ConditionName,ParentObject);
    }
    public static string getObjectNameForChildRelation(String ConditionName, String ParentObject)
    {
        if(ConditionName.contains('[Top]') && (ConditionName.indexOf('[]') > ConditionName.indexOf('[Top]')))
        {
            String temp = ConditionName.substringBefore('[Top]');
            temp = temp.substring(0, temp.lastIndexOf('.'));
            ConditionName = temp + ConditionName.substringAfter('[Top]');
        }
        if((ConditionName.indexOf('[]') > ConditionName.indexOf('.')))
        {
            String relationNameToFind = ConditionName.substringAfter('[]');
            relationNameToFind = '[]'+relationNameToFind;
            String  temp = ConditionName.substringBefore('[]');
            return getObjectNameAnyDepth(relationNameToFind,temp,ConditionName,ParentObject);
        }
        return ParentObject;
    }
     public static String getObjectNameAnyDepth(String relationNameToFind, String temp,String ConditionName,String ParentObject)
    {
        List<String> tempSplit = temp.split('\\.');
        relationNameToFind = tempSplit[tempSplit.size()-2]+'.'+tempSplit[tempSplit.size()-1]+relationNameToFind;
        while(true)
        {
             
            List<Schema.DescribeSObjectResult> res = Schema.describeSObjects(new List<String>{ParentObject});
            string relationName = ConditionName.substringBefore('.');
            for(Schema.DescribeSobjectResult r : res )
            {
                Map<string,Schema.SObjectField> fieldMap = r.fields.getMap();
                for(string s  : fieldMap.keySet()) {
                    if(fieldMap.get(s).getDescribe().getType() == Schema.DisplayType.REFERENCE) {
                        if(fieldMap.get(s).getDescribe().getRelationShipName() == relationName)
                        {
                            if(relationNameToFind == ConditionName)
                            {
                                return String.valueof(fieldMap.get(s).getDescribe().getReferenceTo()).remove('(').remove(')');
                            }
                            else
                            {
                                ParentObject = String.valueof(fieldMap.get(s).getDescribe().getReferenceTo()).remove('(').remove(')');
                            }
                           
                        }    
                    }
                   
                }
            }
           
            ConditionName = ConditionName.substring(ConditionName.indexOf('.')+1);
        }
        return '';
    }
    public static Object getValue(Sobject sobj,String Field)
    {
        while(Field.contains('.'))
        {
            if(sobj == null)
            {
                return null;
            }
            sobj = sobj.getSobject(Field.substringBefore('.'));
            Field = Field.substringAfter('.');
        }
        return sobj.get(Field);
    } 
    public static Map<String, ALL_RecordFilter.childConditions> addParentIds(Map<String, ALL_RecordFilter.childConditions> childRelationCondition, List<sobject> sobjects)
    {
        for(String BaseRelation : childRelationCondition.keySet())
        {
            ALL_RecordFilter.childConditions cc = childRelationCondition.get(BaseRelation);
            BaseRelation = BaseRelation.substringBeforeLast('.')+'.Id';
            for(Sobject sobj : sobjects)
            {
                Object obj = getValue(sobj,BaseRelation);
                if(obj!= null)
                {
                    cc.parentIds.add((Id)obj);
                }
            }
        }
        Map<String, ALL_RecordFilter.childConditions> childRelationConditionNew = new Map<String, ALL_RecordFilter.childConditions>();
        for(ALL_RecordFilter.childConditions cc  : childRelationCondition.values())
        {
            String parentRelationCombinationKey = cc.parentObjectName+'[]'+cc.relationName;
            if(!childRelationConditionNew.keySet().contains(parentRelationCombinationKey))
            {
                childRelationConditionNew.put(parentRelationCombinationKey,cc);
                continue;
            }
            ALL_RecordFilter.childConditions existingCC = childRelationConditionNew.get(parentRelationCombinationKey);
            existingCC.fieldNames += cc.fieldNames;
            existingCC.parentIds.addAll(cc.parentIds);
            existingCC.conditionsIncluded += cc.conditionsIncluded;
            childRelationConditionNew.put(parentRelationCombinationKey,existingCC);
        }
        for(String parentRelationCombinationKey  : childRelationConditionNew.keySet())
        {
            ALL_RecordFilter.childConditions cc = childRelationConditionNew.get(parentRelationCombinationKey);
            cc.fieldNames= uniqueFields(cc.fieldNames);
            cc.conditionsIncluded = uniqueFields(cc.conditionsIncluded);
            childRelationConditionNew.put(parentRelationCombinationKey, cc);
            
        }
        return childRelationConditionNew;
    }
    public static Map<String, ALL_RecordFilter.topParentCondition> addParentIds(Map<String, ALL_RecordFilter.topParentCondition> parentTopConditions, List<sobject> sobjects,Map<String,Map<Id,sobject>> childConditions,String parentObject)
    {
        for(String BaseRelation : parentTopConditions.keySet())
        {
            if(!BaseRelation.contains('[]'))
            {
                ALL_RecordFilter.topParentCondition tpc = parentTopConditions.get(BaseRelation);
                if(BaseRelation.contains('[]'))
                {
                    BaseRelation = BaseRelation.substringBeforeLast('[]');
                }
                BaseRelation = BaseRelation.substringBeforeLast('.')+'.Id';
                for(Sobject sobj : sobjects)
                {
                    Object obj = getValue(sobj,BaseRelation);
                    if(obj!= null)
                    {
                        tpc.parentIds.add((Id)obj);
                    }
                }
            }
            else
            {
                ALL_RecordFilter.topParentCondition tpc = parentTopConditions.get(BaseRelation);
                String relationParentObject = CustomSettings3.getObjectNameForChildRelation(BaseRelation, ParentObject);
                string relationName = CustomSettings3.getChildRelationName(BaseRelation);
                String fieldName = CustomSettings3.getFieldNameForChildRelation(BaseRelation+'[Top]');
                String childRelationKey = relationParentObject+'[]'+relationName;
                Map<Id,Sobject> childMap = childConditions.get(childRelationKey);
                for(Id parentId : childMap.keySet())
                {
                    List<Sobject> childObjects = childMap.get(parentId).getSobjects(relationName);
                    for(sobject child : childObjects)
                    {
                        tpc.parentIds.add((Id)getValue(child,fieldName));
                    }
                }
                parentTopConditions.put(BaseRelation,tpc);
            }
        }
        Map<String, ALL_RecordFilter.topParentCondition> parentTopConditionsNew = new Map<String, ALL_RecordFilter.topParentCondition>();
        for(ALL_RecordFilter.topParentCondition tpc  : parentTopConditions.values())
        {
            String parentRelationCombinationKey = tpc.parentObjectName+'[Top]'+tpc.relationName;
            if(!parentTopConditionsNew.keySet().contains(parentRelationCombinationKey))
            {
                parentTopConditionsNew.put(parentRelationCombinationKey,tpc);
                continue;
            }
            ALL_RecordFilter.topParentCondition existingTPC = parentTopConditionsNew.get(parentRelationCombinationKey);
            existingTPC.fieldNames += ','+tpc.fieldNames;
            existingTPC.parentIds.addAll(tpc.parentIds);
            existingTPC.conditionsIncluded += ','+tpc.conditionsIncluded;
            parentTopConditionsNew.put(parentRelationCombinationKey,existingTPC);
        }
        return parentTopConditionsNew;
    }
    public Static Integer getFieldDepth(String field)
    {
        if(field.contains('[]') && field.indexOf('[Top]') < field.indexof('[]'))
        {
            field = field.substringBetween('[Top].','[]');
        }
        else
        {
            field = field.substringAfter('[Top].');
        }
        return field.countMatches('.');
    }
    public static String uniqueFields(String fields)
    {
        return String.join(new List<String>(new Set<String>(fields.split(','))),', ');
    }
    public static Map<String,Map<Id,sobject>> queryChildRecords(Map<String, ALL_RecordFilter.childConditions> childRelationCondtions)
    {
        Map<String,Map<Id,sobject>> childrelationPerCondition = new Map<String,Map<Id,sobject>>();
        for( String baseRelationIncludingChild: childRelationCondtions.keySet())
        {
            ALL_RecordFilter.childConditions cc = childRelationCondtions.get(baseRelationIncludingChild);
            Set<Id> ids = cc.parentIds;
            Map<Id,sobject> sobjects = new Map<Id,sobject>(Database.query('select id, ( select '+cc.fieldNames+' from '+ cc.relationName+' ) from '+cc.parentObjectName+' Where Id IN :Ids'));
            childrelationPerCondition.put(baseRelationIncludingChild, sobjects);
        }
        return childrelationPerCondition;
    }
    
    public Map<Id,sobject> queryTopIds(ALL_RecordFilter.topParentCondition topParentCondition,String query)
    {
        hasParentSobjects = new Set<Id>();
        hasSobjectMap = new Map<Id,Id>();
        Map<Id,sobject> idToParentObject = new Map<Id,sobject>();
        String relationName = topParentCondition.relationName;
        String parentName = topParentCondition.parentObjectName;
        String fieldName = topParentCondition.fieldNames;
        Set<Id> idslist = topParentCondition.parentIds;
        List<sobject> sList;
        Integer levels = fieldName.countMatches('.');
        if(fieldName.trim().toLowerCase() == 'id')
        {
            query = 'Select id,'
                +relationName+'.Id, '
                +relationName+'.'+relationName+'.Id,'
                +relationName+'.'+relationName+'.'+relationName+'.Id,'
                +relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.Id,'
                +relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.Id'
                +' from '+parentName+ ' where id in :idsList';
        }
        else if(query=='')
        {
             query = getQuery(topParentCondition.fieldNames,topParentCondition.relationName,topParentCondition.levels,topParentCondition.parentObjectName)+ ' where id in :idsList';             
        }
        sList = Database.query(query); 
        
        for(sobject sobj : slist)
        {
            if(!idToParentObject.keySet().contains((Id)sobj.get('Id')))
            {
                Integer level = 5-levels;
                Object currentLevelValue = getValue(sobj,relationName,'Id',level);
                if(currentLevelValue!=null)
                {
                    hasParentSobjects.add((Id)currentLevelValue);
                    hasSobjectMap.put((Id)sobj.get('Id'),(Id)currentLevelValue);
                }
               else
                {
                    while(level>=0)
                    {
                        Object value = getValue(sobj,relationName,'Id',level);
                       
                        if(value != null)
                        {
                            while(level >= 0)
                            {
                                idToParentObject.put((Id)getValue(sobj,relationName,'Id',level),sobj);
                                level--;
                            }
                        }
                        level--;
                    }
                }
            }
        }
        if(hasParentSobjects.size()>0)
        {
            CustomSettings3 tpm = new CustomSettings3();
            topParentCondition.parentIds = new Set<Id>(hasParentSobjects);
            Map<Id,sobject> updatedValues = tpm.queryTopIds(topParentCondition,query);
            for(Id sobjId : hasSobjectMap.keyset())
            {
                idToParentObject.put(sobjId,updatedValues.get(hasSobjectMap.get(sobjId)));
            }
        }
        return idToParentObject;
    }
    public object getValue(Sobject sobj,String relationName, String fieldName, Integer level)
    {
        for(Integer i=0;i<level;i++)
        {
            if(sobj == null)
            {
                return null;
            }
            sobj = sobj.getSobject(relationName);
        }
        while(fieldName.contains('.'))
        {
            if(sobj!=null)
            {
                sobj = sobj.getSobject(fieldName.substringBefore('.'));
            }
            else
            {
                return null;
            }
            fieldName = fieldName.substringAfter('.');
        }
        if(sobj != null)
        {
            return sobj.get(fieldName);
        }
       
        return null;
    }
    public static String getQuery(String fields,String relationName, Integer levels,String parentName)
    {
        fields = uniqueFields(fields);
        List<String> fieldNames = fields.split(',');
        string query = fields+',';
        for(String fieldName:fieldNames)
        {
            fieldName = fieldName.remove(' ');
            levels = CustomSettings3.getFieldDepth('[Top].'+fieldName);
            query +=  (levels<1? relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.Id,'
                       +relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.'+fieldName+',':'');
            query +=  (levels<2? relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.Id,'
                       +relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.'+fieldName+',':'');
            query +=  (levels<3? relationName+'.'+relationName+'.'+relationName+'.Id,'
                       +relationName+'.'+relationName+'.'+relationName+'.'+fieldName+',':'');
            query +=  (levels<4? relationName+'.'+relationName+'.Id,'
                       +relationName+'.'+relationName+'.'+fieldName+',':'');
            query +=  (levels<5? +relationName+'.Id,'
                       +relationName+'.'+fieldName+',':'');
        }
        query = query.remove(' ');
        query = uniqueFields(query);
        query = 'Select '+query.removeEnd(',')+' ';
        query += ' from '+parentName;
        return query;
    }
 /*    public static Boolean Compare(Object actualValue,String Operator,String expectedValue)
    {
        if(actualValue == null)
        {
            if(expectedValue == null && Operator == '=')
            {
                return true;
            }
            return false;
        }
        if(expectedValue == null)
        {
            if(expectedValue == null && Operator == '!=')
            {
                return true;
            }
            return false;
        }
        Operator = Operator.replace(' ','');
        String valueDataType = getType(actualValue);
        if(valueDataType == 'Id')
        {
            actualValue = (Object)(String.valueOf(actualValue).substring(0,15));
            expectedValue = expectedValue.substring(0,15);
        }
       
        String stringActualValue = String.valueOf(actualValue);                           
        String exactStringValue = stringActualValue;
        String exactStringExpected = expectedValue;
        stringActualValue = stringActualValue.toLowerCase();
        expectedValue = expectedValue.toLowerCase();
       
        if(Operator == '=')
        {
            return stringActualValue.equals(expectedValue);
        }
        else if(Operator == '()=')
        {
            set<String> expectedValues = new Set<String>(expectedValue.split(';'));
            set<String> actualValues = new Set<String>(stringActualValue.split(';'));
            for(String value:expectedValues)
            {
                value = value.trim();
            }
            for(String value:actualValues)
            {
                if(expectedValues.contains(value))
                {
                    return true;
                }
            }
            return false;
        }
        else if(Operator == '!=')
        {
            return !(stringActualValue.equals(expectedValue));
        }
        else if(Operator == '^=')
        {
            return stringActualValue.startswith(expectedValue);
        }
        else if(Operator == '$=')
        {
            return stringActualValue.endswith(expectedValue);
        }
        else if(Operator == '*=')
        {
            return stringActualValue.contains(expectedValue);
        }
       
        stringActualValue = exactStringValue;
        expectedValue = exactStringExpected;
       
        if(valueDataType == 'Integer')
        {
            return IntegerCompare(Integer.valueof(stringActualValue.replace(' ','')),Operator,Integer.valueof(expectedValue.replace(' ','')));
        }
        else if(valueDataType == 'Long')
        {
            return LongCompare(Long.valueof(stringActualValue.replace(' ','')),Operator,Long.valueof(expectedValue.replace(' ','')));
        }
        else if(valueDataType == 'Decimal')
        {
            return DecimalCompare(Decimal.valueof(stringActualValue.replace(' ','')),Operator,Decimal.valueof(expectedValue.replace(' ','')));
        }
        else if(valueDataType == 'Date')
        {
            return DateCompare(Date.valueof(stringActualValue.replace(' ','')),Operator,Date.valueof(expectedValue.replace(' ','')));
        }
        else if(valueDataType == 'DateTime')
        {
            return DateTimeCompare(DateTime.valueof(stringActualValue.replace(' ','')),Operator,DateTime.valueof(expectedValue.replace(' ','')));
        }
        else if(valueDataType == 'Double')
        {
            return DoubleCompare(Double.valueof(stringActualValue.replace(' ','')),Operator,Double.valueof(expectedValue.replace(' ','')));
        }
        else
        {
            return StringCompare(stringActualValue.trim(),Operator,expectedValue.trim());
        }
        return false;
    }
    private static Boolean StringCompare(String Operand1, String Operator, String Operand2)
    {      
        if(Operator == '<')
        {
            return Operand1< Operand2;
        }
        else if(Operator == '>')
        {
            return Operand1 > Operand2;
        }
        else if(Operator == '<=')
        {
            return Operand1 <= Operand2;
        }
        else if(Operator == '>=')
        {
            return Operand1 >= Operand2;
        }
        return false;
    }
    private static Boolean DoubleCompare(Double Operand1, String Operator, Double Operand2)
    {      
        if(Operator == '<')
        {
            return Operand1< Operand2;
        }
        else if(Operator == '>')
        {
            return Operand1 > Operand2;
        }
        else if(Operator == '<=')
        {
            return Operand1 <= Operand2;
        }
        else if(Operator == '>=')
        {
            return Operand1 >= Operand2;
        }
        return false;
    }
    private static Boolean DateTimeCompare(DateTime Operand1, String Operator, DateTime Operand2)
    {       
        if(Operator == '<')
        {
            return Operand1< Operand2;
        }
        else if(Operator == '>')
        {
            return Operand1 > Operand2;
        }
        else if(Operator == '<=')
        {
            return Operand1 <= Operand2;
        }
        else if(Operator == '>=')
        {
            return Operand1 >= Operand2;
        }
        return false;
    }
   
    private static Boolean IntegerCompare(Integer Operand1, String Operator, Integer Operand2)
    {       
        if(Operator == '<')
        {
            return Operand1< Operand2;
        }
        else if(Operator == '>')
        {
            return Operand1 > Operand2;
        }
        else if(Operator == '<=')
        {
            return Operand1 <= Operand2;
        }
        else if(Operator == '>=')
        {
            return Operand1 >= Operand2;
        }
        return false;
    }
    private static Boolean DecimalCompare(Decimal Operand1, String Operator, Decimal Operand2)
    {       
        if(Operator == '<')
        {
            return Operand1< Operand2;
        }
        else if(Operator == '>')
        {
            return Operand1 > Operand2;
        }
        else if(Operator == '<=')
        {
            return Operand1 <= Operand2;
        }
        else if(Operator == '>=')
        {
            return Operand1 >= Operand2;
        }
        return false;
    }
    private static Boolean LongCompare(Long Operand1, String Operator, Long Operand2)
    {       
        if(Operator == '<')
        {
            return Operand1< Operand2;
        }
        else if(Operator == '>')
        {
            return Operand1 > Operand2;
        }
        else if(Operator == '<=')
        {
            return Operand1 <= Operand2;
        }
        else if(Operator == '>=')
        {
            return Operand1 >= Operand2;
        }
        return false;
    }
    private static Boolean DateCompare(Date Operand1, String Operator, Date Operand2)
    {       
        if(Operator == '<')
        {
            return Operand1< Operand2;
        }
        else if(Operator == '>')
        {
            return Operand1 > Operand2;
        }
        else if(Operator == '<=')
        {
            return Operand1 <= Operand2;
        }
        else if(Operator == '>=')
        {
            return Operand1 >= Operand2;
        }
        return false;
    }
   
    private static string getType(Object objectValue)
    {
        if(objectValue==null)
        {
            return '';              
        }
        else if(objectValue instanceof SObject)
        {
            return ((SObject)objectValue).getSObjectType().getDescribe().getName()+'';
        }
        if(objectValue instanceof Boolean)
        {
            return 'Boolean';
        }          
        if(objectValue instanceof Id)
        {
            return 'Id';
        }                
        if(objectValue instanceof String) 
        {
            return 'String';
        }          
        if(objectValue instanceof Blob)
        {
            return 'Blob';
        }             
        if(objectValue instanceof Date) 
        {
            return 'Date';
        }            
        if(objectValue instanceof Datetime)  
        {
            return 'Datetime';
        }       
        if(objectValue instanceof Time)   
        {
            return 'Time';
        }          
        if(objectValue instanceof String)
        {
            return 'String';
        }           
        if(objectValue instanceof Integer)  
        {
            return 'Integer';
        }        
        if(objectValue instanceof Long)  
        {
            return 'Long';
        }           
        if(objectValue instanceof Decimal) 
        {
            return 'Decimal';
        }         
        if(objectValue instanceof Double) 
        {
            return 'Double';
        }      
        return 'Object';                  
    }
   
    public static Boolean EvaluateCriteria(String filterCriteria, Map<String,Boolean> conditionValues)
    {
        for(String conditionName : conditionValues.keySet())
        {           
            if(conditionValues.get(conditionName))
            {
                filterCriteria = filterCriteria.replace(conditionName,'T');
            }
            else
            {
                filterCriteria = filterCriteria.replace(conditionName,'F');
            }
        }
       
        filterCriteria = filterCriteria.replace(' ','');
       
        return EvaluateBooleanExpression3.evaluateInfixExpression(filterCriteria);
    }
   
    
    
    public static List<sobject> evaluateChildObjects(List<sobject> allObjects,String fieldName,String expectedValue,String Operator,String ParentObject )
    {
        List<sobject> fileteredObjects = new List<sobject>();
        String requiredField = fieldName.substring(fieldName.lastindexOf('.')+1);
        String requiredParentObject;
        if(fieldName.indexOf('.')<fieldName.indexOf('['))
        {
            requiredParentObject = getObjectName(fieldName,ParentObject);
        }
        else
        {
            requiredParentObject = ParentObject;
        }
        String requiredRelation=fieldName.substringBetween('.','[');
        for(sobject sobjObj : allObjects)
        {
            if(CustomSettings.Compare(sobjObj.get(requiredField), Operator, expectedValue))
            {
                fileteredObjects.add(sobjObj);
            }
        }
       
        return fileteredObjects;
    }
   
    public static String getObjectName(String ConditionName, String ParentObject)
    {
        String relationNameToFind;
        String temp;
        if(ConditionName.contains('[Top]'))
        {
            relationNameToFind = ConditionName.substringAfter('[Top]');
            relationNameToFind = '[Top]'+relationNameToFind;
            temp = ConditionName.substringBefore('[Top]');
        }
        else
        {
            relationNameToFind = ConditionName.substringAfter('[]');
            relationNameToFind = '[]'+relationNameToFind;
            temp = ConditionName.substringBefore('[]');
        }
        List<String> tempSplit = temp.split('\\.');
        relationNameToFind = tempSplit[tempSplit.size()-2]+'.'+tempSplit[tempSplit.size()-1]+relationNameToFind;
        while(true)
        {
            List<Schema.DescribeSObjectResult> res = Schema.describeSObjects(new List<String>{ParentObject});
            string relationName = ConditionName.substringBefore('.');
            for(Schema.DescribeSobjectResult r : res )
            {
                Map<string,Schema.SObjectField> fieldMap = r.fields.getMap();
                for(string s  : fieldMap.keySet()) {
                    if(fieldMap.get(s).getDescribe().getType() == Schema.DisplayType.REFERENCE) {
                        if(fieldMap.get(s).getDescribe().getRelationShipName() == relationName)
                        {
                            if(relationNameToFind == ConditionName)
                            {
                                return String.valueof(fieldMap.get(s).getDescribe().getReferenceTo()).remove('(').remove(')');
                            }
                            else
                            {
                                ParentObject = String.valueof(fieldMap.get(s).getDescribe().getReferenceTo()).remove('(').remove(')');
                            }
                           
                        }    
                    }
                   
                }
            }
           
            ConditionName = ConditionName.substring(ConditionName.indexOf('.')+1);
        }
       
        
        return '';
    }
    public Map<Id,Object> getTopParentFields(List<Id> idsList, String condition,String ObjectName, Boolean forChild)
    {
        hasParentSobjects = new Set<Id>();
        hasSobjectMap = new Map<Id,Id>();
        Map<Id,Object> idToParent = new Map<Id,Object>();
        String relationName = condition.substringBetween('.','[Top]');
        String parentName = condition.substringBetween('.',relationName);
        if(parentName == '')
        {
            parentName = CustomSettings3.getObjectName(condition,ObjectName);
        }
        String fieldName = condition.substring(condition.indexOf('[Top].')+6);
        List<sobject> sList;
        Integer levels = fieldName.countMatches('.');
        if(fieldName.trim().toLowerCase() == 'id' || forChild)
        {
            sList = Database.query('Select id,'
                                   +relationName+'.Id, '
                                   +relationName+'.'+relationName+'.Id,'
                                   +relationName+'.'+relationName+'.'+relationName+'.Id,'
                                   +relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.Id,'
                                   +relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.Id'
                                   +' from '+parentName+ ' where id in :idsList'
                                  );
        }
        else
        {
            string query = 'Select id,'+fieldName+',';
            query +=  (levels<1? relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.Id,'
                       +relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.'+fieldName+',':'');
            query +=  (levels<2? relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.Id,'
                       +relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.'+fieldName+',':'');
            query +=  (levels<3? relationName+'.'+relationName+'.'+relationName+'.Id,'
                       +relationName+'.'+relationName+'.'+relationName+'.'+fieldName+',':'');
            query +=  (levels<4? relationName+'.'+relationName+'.Id,'
                       +relationName+'.'+relationName+'.'+fieldName+',':'');
            query +=  (levels<5? +relationName+'.Id, '
                       +relationName+'.'+fieldName:'');
            query = query.removeEnd(',')+' ';
            query += ' from '+parentName+ ' where id in :idsList';
           
            sList = Database.query(query);               
        }
        for(sobject sobj : slist)
        {
            if(!idToParent.keySet().contains((Id)sobj.get('Id')))
            {
                Integer level = 5-levels;
                Object currentLevelValue = getValue(sobj,relationName,'Id',level);
                if(currentLevelValue!=null)
                {
                    hasParentSobjects.add((Id)currentLevelValue);
                    hasSobjectMap.put((Id)sobj.get('Id'),(Id)currentLevelValue);
                }
               else
                {
                    while(level>=0)
                    {
                        Object value;
                        if(forChild)
                        {
                            value = getValue(sobj,relationName,'Id',level);
                        }
                        else
                        {
                            value = getValue(sobj,relationName,fieldName,level);
                        }
                       
                        if(value != null)
                        {
                            while(level >= 0)
                            {
                                idToParent.put((Id)getValue(sobj,relationName,'Id',level),value);
                                level--;
                            }
                        }
                        level--;
                    }
                }
            }
        }
        if(hasParentSobjects.size()>0)
        {
            CustomSettings3 tpm = new CustomSettings3();
            Map<Id,object> updatedValues = tpm.getTopParentFields(new List<Id>(hasParentSobjects),condition,objectName,forChild);
            for(Id sobjId : hasSobjectMap.keyset())
            {
                idToParent.put(sobjId,updatedValues.get(hasSobjectMap.get(sobjId)));
            }
        }
        return idToParent;
    }
    public Map<Id,List<sObject>> getTopParentChildFields(List<Id> idsList, String condition,String ObjectName)
    {
        hasParentSobjects = new Set<Id>();
        hasSobjectMap = new Map<Id,Id>();
        Map<Id,Object> idToParent = new Map<Id,Object>();
        String relationName = condition.substringBetween('.','[Top]');
        String parentName = condition.substringBetween('.',relationName);
        if(parentName == '')
        {
            parentName = CustomSettings3.getObjectName(condition,ObjectName);
        }
        String fieldName = condition.substring(condition.indexOf('[Top].')+6);
        List<sobject> sList;
        Integer levels = fieldName.countMatches('.');
        sList = Database.query('Select id,'
                               +relationName+'.Id, '
                               +relationName+'.'+relationName+'.Id,'
                               +relationName+'.'+relationName+'.'+relationName+'.Id,'
                               +relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.Id,'
                               +relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.'+relationName+'.Id'
                               +' from '+parentName+ ' where id in :idsList'
                              );
        for(sobject sobj : slist)
        {
            if(!idToParent.keySet().contains((Id)sobj.get('Id')))
            {
                Integer level = 5-levels;
                Object currentLevelValue = getValue(sobj,relationName,'Id',level);
                if(currentLevelValue!=null)
                {
                    hasParentSobjects.add((Id)currentLevelValue);
                    hasSobjectMap.put((Id)sobj.get('Id'),(Id)currentLevelValue);
                }
                else
                {
                    while(level>=0)
                    {
                        Object value = getValue(sobj,relationName,'Id',level);
                        if(value != null)
                        {
                            while(level >= 0)
                            {
                                idToParent.put((Id)getValue(sobj,relationName,'Id',level),value);
                                level--;
                            }
                        }
                        level--;
                    }
                }
            }
       }
        if(hasParentSobjects.size()>0)
        {
            CustomSettings3 tpm = new CustomSettings3();
            Map<Id,Object> updatedValues = tpm.getTopParentFields(new List<Id>(hasParentSobjects),condition,objectName,true);
            for(Id sobjId : hasSobjectMap.keyset())
            {
                idToParent.put(sobjId,updatedValues.get(hasSobjectMap.get(sobjId)));
            }
        }
        Set<Id> IdsSend = new Set<Id>();
        for(Object idObj: idToParent.values())
        {
            if(idObj!=null)
            {
                IdsSend.add((Id)idObj);
            }
           
        }
        Map<Id,List<sobject>> sobjList = CustomSettings3.queryChildObjects(new List<Id>(IdsSend),Condition.substringAfter('[Top].'),CustomSettings3.getObjectName(Condition, ObjectName));
        Map<Id,List<sobject>> returnList = new Map<Id,List<sobject>>();
        for(Id idObj : idToParent.keySet())
        {
            returnList.put(idObj, sobjList.get((Id)idToParent.get(idObj)));
        }
        return returnList;
    }
    public object getValue(Sobject sobj,String relationName, String fieldName, Integer level)
    {
        for(Integer i=0;i<level;i++)
        {
            if(sobj == null)
            {
                return null;
            }
            sobj = sobj.getSobject(relationName);
        }
        while(fieldName.contains('.'))
        {
            if(sobj!=null)
            {
                sobj = sobj.getSobject(fieldName.substringBefore('.'));
            }
            else
            {
                return null;
            }
            fieldName = fieldName.substringAfter('.');
        }
        if(sobj != null)
        {
            return sobj.get(fieldName);
        }
       
        return null;
    }
*/
}