public class TopMostParent2 
{
    Set<Id> hasParentSobjects;
    Map<Id,Id> hasSobjectMap;
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
            TopMostParent2 tpm = new TopMostParent2();
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
            TopMostParent2 tpm = new TopMostParent2();
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