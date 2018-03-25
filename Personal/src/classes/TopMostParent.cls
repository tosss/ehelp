public class TopMostParent 
{
    Map<Id,Id> objectToParentMap;
    Map<Id,object> objectToParentMap2;
    Map<Id,list<object>> objectToParentMap3;
    Map<Id,sobject> objectToParentMap4;
    public Map<Id,Id> getTopParent(List<Id> accId)
    {
        objectToParentMap = new Map<Id,Id>();
        List<Id> yetRequiredAccount = new List<Id>();
        List<Id> didntFindAccount = new List<Id>();
        List<Account> accList = [
            SELECT id, 
            Parent.Id, 
            Parent.Parent.Id,
            Parent.Parent.Parent.Id, 
            Parent.Parent.Parent.Parent.Id,
            Parent.Parent.Parent.Parent.Parent.Id 
            FROM Account
            WHERE Id In: accId
        ];
        for(Account acc : accList)
        {
            if(acc.Parent.Parent.Parent.Parent.Parent.Id != null)
            {
                objectToParentMap.put(acc.Id,acc.Parent.Parent.Parent.Parent.Parent.Id);
                yetRequiredAccount.add(acc.Parent.Parent.Parent.Parent.Parent.Id);
            }
            else if(acc.Parent.Parent.Parent.Parent.Id != null)
            {
                objectToParentMap.put(acc.Id,acc.Parent.Parent.Parent.Parent.Id);
            }
            else if(acc.Parent.Parent.Parent.Id != null)
            {
                objectToParentMap.put(acc.Id,acc.Parent.Parent.Parent.Id);
            }
            else if(acc.Parent.Parent.Parent.Id != null)
            {
                objectToParentMap.put(acc.Id,acc.Parent.Parent.Parent.Id);
            }
            else if(acc.Parent.Parent.Id != null)
            {
                objectToParentMap.put(acc.Id,acc.Parent.Parent.Id);
            }
            else if(acc.Parent.Id != null)
            {
                objectToParentMap.put(acc.Id,acc.Parent.Id);
            }
            else
            {
                objectToParentMap.put(acc.Id,acc.Id);
            }
        }
        if(yetRequiredAccount.size()>0)
        {
            TopMostParent tpm = new TopMostParent();
            Map<Id,Id> newMap = tpm.getTopParent(yetRequiredAccount);
            for(Id lastId : objectToParentMap.keyset())
            {
                objectToParentMap.put(lastId,newMap.get(objectToParentMap.get(lastId)));                
            }
        }
        return objectToParentMap;
        
    }
    public Map<Id,Id> getTopParent2(List<Id> accId)
    {
        objectToParentMap = new Map<Id,Id>();
        List<Id> yetRequiredAccount = new List<Id>();
        List<Id> didntFindAccount = new List<Id>();
        List<Account> accList = [
            SELECT id, 
            Parent.Id, 
            Parent.Parent.Id,
            Parent.Parent.Parent.Id, 
            Parent.Parent.Parent.Parent.Id,
            Parent.Parent.Parent.Parent.Parent.Id 
            FROM Account
            WHERE Id In: accId
        ];
        for(Account acc : accList)
        {
            if(!objectToParentMap.keySet().contains(acc.Id))
            {
                if(acc.Parent.Parent.Parent.Parent.Parent.Id != null)
                {
                    objectToParentMap.put(acc.Id,acc.Parent.Parent.Parent.Parent.Parent.Id);
                    yetRequiredAccount.add(acc.Parent.Parent.Parent.Parent.Parent.Id);
                }
                else if(acc.Parent.Parent.Parent.Parent.Id != null)
                {
                    objectToParentMap.put(acc.Id,acc.Parent.Parent.Parent.Parent.Id);
                    objectToParentMap.put(acc.Parent.Id,acc.Parent.Parent.Parent.Parent.Id );
                    objectToParentMap.put(acc.Parent.Parent.Id,acc.Parent.Parent.Parent.Parent.Id );
                    objectToParentMap.put(acc.Parent.Parent.Parent.Id,acc.Parent.Parent.Parent.Parent.Id );
                    objectToParentMap.put(acc.Parent.Parent.Parent.Parent.Id,acc.Parent.Parent.Parent.Parent.Id );
                }
                else if(acc.Parent.Parent.Parent.Id != null)
                {
                    objectToParentMap.put(acc.Id,acc.Parent.Parent.Parent.Id);
                    objectToParentMap.put(acc.Parent.Id,acc.Parent.Parent.Parent.Id );
                    objectToParentMap.put(acc.Parent.Parent.Id,acc.Parent.Parent.Parent.Id );
                    objectToParentMap.put(acc.Parent.Parent.Parent.Id,acc.Parent.Parent.Parent.Id );
                }
                else if(acc.Parent.Parent.Id != null)
                {
                    objectToParentMap.put(acc.Id,acc.Parent.Parent.Id);
                    objectToParentMap.put(acc.Parent.Id,acc.Parent.Parent.Id );
                    objectToParentMap.put(acc.Parent.Parent.Id,acc.Parent.Parent.Id );
                }
                else if(acc.Parent.Id != null)
                {
                    objectToParentMap.put(acc.Id,acc.Parent.Id);
                    objectToParentMap.put(acc.Parent.Id,acc.Parent.Id );
                }
                else
                {
                    objectToParentMap.put(acc.Id,acc.Id);
                }
            }
        }
        if(yetRequiredAccount.size()>0)
        {
            TopMostParent tpm = new TopMostParent();
            Map<Id,Id> newMap = tpm.getTopParent2(yetRequiredAccount);
            for(Id lastId : objectToParentMap.keyset())
            {
                objectToParentMap.put(lastId,newMap.get(objectToParentMap.get(lastId)));                
            }
        }
        return objectToParentMap;
        
    }
    public Map<Id,Object> getTopParent3(List<Id> accId,string objectName, String FieldName,String RelationName)
    {
        objectToParentMap2 = new Map<Id,Object>();
        List<Id> yetRequiredAccount = new List<Id>();
        List<Id> didntFindAccount = new List<Id>();
        List<Sobject> accList;
        if(FieldName == 'Id')
        {
            accList = Database.query(
                'SELECT id, '
                +RelationName+'.Id, '
                +RelationName+'.'+RelationName+'.Id, '
                +RelationName+'.'+RelationName+'.'+RelationName+'.Id, '
                +RelationName+'.'+RelationName+'.'+RelationName+'.'+RelationName+'.Id, '
                +RelationName+'.'+RelationName+'.'+RelationName+'.'+RelationName+'.'+RelationName+'.Id '
                +' FROM '+objectName
                +' WHERE Id In: accId Order by CreatedDate asc'
            );
        }
        else
        {
            accList = Database.query(
                'SELECT id, '+FieldName+','
                +RelationName+'.Id, '
                +RelationName+'.'+FieldName+','
                +RelationName+'.'+RelationName+'.Id, '
                +RelationName+'.'+RelationName+'.'+FieldName+','
                +RelationName+'.'+RelationName+'.'+RelationName+'.Id, '
                +RelationName+'.'+RelationName+'.'+RelationName+'.'+FieldName+','
                +RelationName+'.'+RelationName+'.'+RelationName+'.'+RelationName+'.Id, '
                +RelationName+'.'+RelationName+'.'+RelationName+'.'+RelationName+'.'+FieldName+','
                +RelationName+'.'+RelationName+'.'+RelationName+'.'+RelationName+'.'+RelationName+'.Id, '
                +RelationName+'.'+RelationName+'.'+RelationName+'.'+RelationName+'.'+RelationName+'.'+FieldName+' '
                +' FROM '+objectName
                +' WHERE Id In: accId Order by CreatedDate asc'
            );
        }
        
        
        for(Sobject acc : accList)
        {
            if(!objectToParentMap2.keySet().contains((Id)acc.get('Id')))
            {
                if(getFieldValue(acc,RelationName,'Id',5) != null)
                {
                    Object levelFiveIdValue = getFieldValue(acc,RelationName,'Id',5);
                    objectToParentMap2.put((Id)acc.get('Id'),levelFiveIdValue);
                    yetRequiredAccount.add((Id)levelFiveIdValue);
                }
                else if(getFieldValue(acc,RelationName,'Id',4) != null)
                {
                    Object levelFourFieldValue = getFieldValue(acc,RelationName,FieldName,4);
                    objectToParentMap2.put((Id)acc.get('Id'),levelFourFieldValue);
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',1),levelFourFieldValue );
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',2) ,levelFourFieldValue);
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',3) ,levelFourFieldValue  );
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',4) ,levelFourFieldValue );
                }
                else if(getFieldValue(acc,RelationName,'Id',3) != null)
                {
                    Object levelThreeFieldValue = getFieldValue(acc,RelationName,FieldName,3);
                    objectToParentMap2.put((Id)acc.get('Id'),levelThreeFieldValue);
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',1),levelThreeFieldValue);
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',2) ,levelThreeFieldValue );
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',3) ,levelThreeFieldValue );
                }
                else if(getFieldValue(acc,RelationName,'Id',2)  != null)
                {
                    Object levelTwoFieldValue = getFieldValue(acc,RelationName,FieldName,2);
                    objectToParentMap2.put((Id)acc.get('Id'),levelTwoFieldValue);
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',1),levelTwoFieldValue);
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',2) ,levelTwoFieldValue );
                }
                else if(getFieldValue(acc,RelationName,'Id',1)  != null)
                {
                    Object levelOneFieldValue = getFieldValue(acc,RelationName,FieldName,1);
                    objectToParentMap2.put((Id)acc.get('Id'),levelOneFieldValue);
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',1),levelOneFieldValue);
                }
                else
                {
                    objectToParentMap2.put((Id)acc.get('Id'),acc.get(FieldName));
                }
            }
        }
        if(yetRequiredAccount.size()>0)
        {
            TopMostParent tpm = new TopMostParent();
            Map<Id,Object> newMap = tpm.getTopParent3(yetRequiredAccount,objectName, FieldName,RelationName);
            for(Id lastId : objectToParentMap2.keyset())
            {
                if((objectToParentMap2.get(lastId) instanceOf Id ) && newMap.keySet().contains((Id)objectToParentMap2.get(lastId)))
                {
                    objectToParentMap2.put(lastId,newMap.get((Id)objectToParentMap2.get(lastId))); 
                }             
            }
        }
        return objectToParentMap2;
        
    }
    public Map<Id,List<Object>> getTopParent4(List<Id> accId,string objectName, String FieldName,String RelationChild, String RelationName)
    {
        objectToParentMap2 = new Map<Id,Object>();
        List<Id> yetRequiredAccount = new List<Id>();
        List<Id> didntFindAccount = new List<Id>();
        List<Sobject> accList = Database.query(
            'SELECT id, '+FieldName+','
            +RelationName+'.Id, '
            +RelationName+'.'+RelationName+'.Id, '
            +RelationName+'.'+RelationName+'.'+RelationName+'.Id, '
            +RelationName+'.'+RelationName+'.'+RelationName+'.'+RelationName+'.Id, '
            +RelationName+'.'+RelationName+'.'+RelationName+'.'+RelationName+'.'+RelationName+'.Id '
            +' FROM '+objectName
            +' WHERE Id In: accId Order by CreatedDate asc'
        );
        for(Sobject acc : accList)
        {
            if(!objectToParentMap2.keySet().contains((Id)acc.get('Id')))
            {
                if(getFieldValue(acc,RelationName,'Id',5) != null)
                {
                    Object levelFiveIdValue = getFieldValue(acc,RelationName,'Id',5);
                    objectToParentMap2.put((Id)acc.get('Id'),levelFiveIdValue);
                    yetRequiredAccount.add((Id)levelFiveIdValue);
                }
                else if(getFieldValue(acc,RelationName,'Id',4) != null)
                {
                    Object levelFourFieldValue = getFieldValue(acc,RelationName,'Id',4);
                    objectToParentMap2.put((Id)acc.get('Id'),levelFourFieldValue);
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',1),levelFourFieldValue );
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',2) ,levelFourFieldValue);
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',3) ,levelFourFieldValue  );
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',4) ,levelFourFieldValue );
                }
                else if(getFieldValue(acc,RelationName,'Id',3) != null)
                {
                    Object levelThreeFieldValue = getFieldValue(acc,RelationName,'Id',3);
                    objectToParentMap2.put((Id)acc.get('Id'),levelThreeFieldValue);
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',1),levelThreeFieldValue);
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',2) ,levelThreeFieldValue );
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',3) ,levelThreeFieldValue );
                }
                else if(getFieldValue(acc,RelationName,'Id',2)  != null)
                {
                    Object levelTwoFieldValue = getFieldValue(acc,RelationName,'Id',2);
                    objectToParentMap2.put((Id)acc.get('Id'),levelTwoFieldValue);
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',1),levelTwoFieldValue);
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',2) ,levelTwoFieldValue );
                }
                else if(getFieldValue(acc,RelationName,'Id',1)  != null)
                {
                    Object levelOneFieldValue = getFieldValue(acc,RelationName,'Id',1);
                    objectToParentMap2.put((Id)acc.get('Id'),levelOneFieldValue);
                    objectToParentMap2.put((Id)getFieldValue(acc,RelationName,'Id',1),levelOneFieldValue);
                }
                else
                {
                    objectToParentMap2.put((Id)acc.get('Id'),acc.get('Id'));
                }
            }
        }
        if(yetRequiredAccount.size()>0)
        {
            TopMostParent tpm = new TopMostParent();
            Map<Id,Object> newMap = tpm.getTopParent3(yetRequiredAccount,objectName, 'Id',RelationName);
            for(Id lastId : objectToParentMap2.keyset())
            {
                objectToParentMap2.put(lastId,newMap.get((Id)objectToParentMap2.get(lastId))); 
                
            }
        }
        if(RelationChild!=null)
        {
            objectToParentMap3 = new Map<Id,List<sobject>>();
            List<Id> ids = new List<Id>();
            for(Object idObj :objectToParentMap2.values())
            {
                ids.add((Id)idObj);
            }
            Map<id,sobject> getChildren= new Map<Id,sobject>(Database.Query('select id, (select id, '+fieldName+' from '+RelationChild+') from '+objectName+' where id in: ids')); 
            for(Id s : objectToParentMap2.keySet())
            {
                objectToParentMap3.put(s,getChildren.get((Id)objectToParentMap2.get(s)).getSobjects(RelationChild));
            }
        }
        return objectToParentMap3;
    }
    public Map<Id,sobject> getTopParent(List<Id> accId,string objectName, String RelationChild, String RelationName)
    {
        objectToParentMap4 = new Map<Id,sobject>();
        List<Id> yetRequiredAccount = new List<Id>();
        Map<Id,Id> didntFindAccount = new Map<Id,Id>();
        List<Sobject> accList = Database.query(
            'SELECT id, '
            +RelationName+'.Id, '
            +RelationName+'.'+RelationName+'.Id, '
            +RelationName+'.'+RelationName+'.'+RelationName+'.Id, '
            +RelationName+'.'+RelationName+'.'+RelationName+'.'+RelationName+'.Id, '
            +RelationName+'.'+RelationName+'.'+RelationName+'.'+RelationName+'.'+RelationName+'.Id '
            +' FROM '+objectName
            +' WHERE Id In: accId Order by CreatedDate asc'
        );
        for(Sobject acc : accList)
        {
            if(!objectToParentMap4.keySet().contains((Id)acc.get('Id')))
            {
                if(getFieldValue(acc,RelationName,'Id',5) != null)
                {
                    Object levelFiveIdValue = getFieldValue(acc,RelationName,'Id',5);
                    didntFindAccount.put((Id)acc.get('Id'),(Id)levelFiveIdValue);
                    yetRequiredAccount.add((Id)levelFiveIdValue);
                }
                else if(getFieldValue(acc,RelationName,'Id',4) != null)
                {
                    SObject levelFourFieldValue = getSobject(acc,RelationName,4);
                    objectToParentMap4.put((Id)acc.get('Id'),levelFourFieldValue);
                    objectToParentMap4.put((Id)getFieldValue(acc,RelationName,'Id',1),levelFourFieldValue );
                    objectToParentMap4.put((Id)getFieldValue(acc,RelationName,'Id',2) ,levelFourFieldValue);
                    objectToParentMap4.put((Id)getFieldValue(acc,RelationName,'Id',3) ,levelFourFieldValue  );
                    objectToParentMap4.put((Id)getFieldValue(acc,RelationName,'Id',4) ,levelFourFieldValue );
                }
                else if(getFieldValue(acc,RelationName,'Id',3) != null)
                {
                    SObject levelThreeFieldValue = getSobject(acc,RelationName,3);
                    objectToParentMap4.put((Id)acc.get('Id'),levelThreeFieldValue);
                    objectToParentMap4.put((Id)getFieldValue(acc,RelationName,'Id',1),levelThreeFieldValue);
                    objectToParentMap4.put((Id)getFieldValue(acc,RelationName,'Id',2) ,levelThreeFieldValue );
                    objectToParentMap4.put((Id)getFieldValue(acc,RelationName,'Id',3) ,levelThreeFieldValue );
                }
                else if(getFieldValue(acc,RelationName,'Id',2)  != null)
                {
                    SObject levelTwoFieldValue = getSobject(acc,RelationName,2);
                    objectToParentMap4.put((Id)acc.get('Id'),levelTwoFieldValue);
                    objectToParentMap4.put((Id)getFieldValue(acc,RelationName,'Id',1),levelTwoFieldValue);
                    objectToParentMap4.put((Id)getFieldValue(acc,RelationName,'Id',2) ,levelTwoFieldValue );
                }
                else if(getFieldValue(acc,RelationName,'Id',1)  != null)
                {
                    SObject levelOneFieldValue = getSobject(acc,RelationName,1);
                    objectToParentMap4.put((Id)acc.get('Id'),levelOneFieldValue);
                    objectToParentMap4.put((Id)getFieldValue(acc,RelationName,'Id',1),levelOneFieldValue);
                }
                else
                {
                    objectToParentMap4.put((Id)acc.get('Id'),acc);
                }
            }
        }
        if(yetRequiredAccount.size()>0)
        {
            TopMostParent tpm = new TopMostParent();
            Map<Id,SObject> newMap = tpm.getTopParent(yetRequiredAccount,objectName, 'Id',RelationName);
            for(Id lastId : objectToParentMap2.keyset())
            {
                objectToParentMap4.put(lastId,newMap.get(didntFindAccount.get(lastId))); 
                
            }
        }
        return objectToParentMap4;
    }
    public Object getFieldValue(Sobject sobj,String relName,String fieldName,Integer levels)
    {
        if(levels<=5)
        {
            for(Integer i=0;i<levels;i++)
            {
                
                if(sobj == null)
                {
                    return null;
                }
                sobj = sobj.getSobject(relName);
                
                if(i==levels-1 && sobj != null)
                {
                    return sobj.get(fieldName);
                }
                else if(i==levels-1 )
                {
                    return null;
                }
            }
            return sobj.get(fieldName);
        }
        return null;
    }
    public sobject getSobject(Sobject sobj,String relName,Integer levels)
    {
        if(levels<=5)
        {
            for(Integer i=0;i<levels;i++)
            {
                
                if(sobj == null)
                {
                    return null;
                }
                sobj = sobj.getSobject(relName);
                
                if(i==levels-1 && sobj != null)
                {
                    return sobj;
                }
                else if(i==levels-1 )
                {
                    return null;
                }
            }
            return sobj;
        }
        return null;
    }
    
}