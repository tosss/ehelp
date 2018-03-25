public class CustomSettings 
{
    Set<Id> hasParentSobjects;
    Map<Id,Id> hasSobjectMap;
    public static Boolean Compare(Object actualValue,String Operator,String expectedValue)
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
        
        return EvaluateBooleanExpression.evaluateInfixExpression(filterCriteria);
    }
    
    public static Map<Id,List<sobject>> queryChildObjects(List<Id> ParentIds, String fieldName,String ParentObject)
    {
        Map<Id,List<sobject>> fileteredObjects = new Map<Id,List<sobject>>();
        String requiredField = fieldName.substring(fieldName.lastindexOf('.')+1);
        String requiredParentObject;
        String requiredRelation;
        if(fieldName.indexOf('[')<fieldName.indexOf('.'))
        {
            requiredParentObject = ParentObject;
            requiredRelation = fieldName.substringBefore('[');
        }
        else
        {
            requiredParentObject = getObjectName(fieldName,ParentObject);
            requiredRelation = fieldName.substringBetween('.','[');
        }
        
        
        List<sobject> allObjects = Database.Query('Select id, (select id, '+requiredField+' from '+requiredRelation+' ) from '+requiredParentObject+' Where Id In: ParentIds');
        for(sobject sobjObj : allObjects)
        {
            fileteredObjects.put((Id)sobjObj.get('Id'),sobjObj.getSobjects(requiredRelation));
        }
        return fileteredObjects;
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
            parentName = CustomSettings.getObjectName(condition,ObjectName);
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
            CustomSettings tpm = new CustomSettings();
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
            parentName = CustomSettings.getObjectName(condition,ObjectName);
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
            CustomSettings tpm = new CustomSettings();
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
        Map<Id,List<sobject>> sobjList = CustomSettings.queryChildObjects(new List<Id>(IdsSend),Condition.substringAfter('[Top].'),CustomSettings.getObjectName(Condition, ObjectName));
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
}