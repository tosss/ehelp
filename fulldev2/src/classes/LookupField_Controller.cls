public class LookupField_Controller
{
    //Loads the initial value of the given SObject type with ID "value".
    @AuraEnabled
    public static String getCurrentValue(String type, String value)
    {
        system.debug('Start getCurrentValue---->');
        if(String.isBlank(type))
        {
            return Null;
        }
        
        ID lookupId=Null;
        try
        {   
            lookupId=(ID)value;
        }
        catch(Exception ex)
        {
            return Null;
        }
        
        if(String.isBlank(lookupId))
        {
            return Null;
        }
        
        SObjectType objType=Schema.getGlobalDescribe().get(type);
        if(objType==Null)
        {
            return Null;
        }
        
        String nameField=getSobjectNameField(objType);
        String query='Select Id, '+nameField+' From '+type+' Where Id=\''+lookupId+'\'';
        System.debug('query---->'+query);
        
        List<SObject> sObjectList=Database.query(query);
        
        if(sObjectList.size()==0)
        {
            return Null;
        }
        
        system.debug('End getCurrentValue---->');
        return (String)sObjectList[0].get(nameField);
    }
    
    //Returns the "Name" field for a given SObject (e.g. Case has CaseNumber, Account has Name).
    private static String getSobjectNameField(SobjectType sobjType)
    {
        system.debug('Start getSobjectNameField---->');
        
        //Describes lookup obj and gets its name field
        String nameField='Name';
        Schema.DescribeSObjectResult describeSObjectResultRef=sobjType.getDescribe();
        
        for(Schema.SObjectField sObjectFieldRef: describeSObjectResultRef.fields.getMap().values())
        {
            Schema.DescribeFieldResult fieldDescObj=sObjectFieldRef.getDescribe();
            if(fieldDescObj.isNameField())
            {
                nameField=fieldDescObj.getName();
                break;
            }
        }
        
        system.debug('End getSobjectNameField---->');
        return nameField;
    }
    
    //Searchs (using SOSL) for a given Sobject type.
    @AuraEnabled
    public static String searchSObject(String type, String searchString)
    {
        system.debug('Start searchSObject---->');
        
        if(String.isBlank(type) || String.isBlank(searchString))
        {
            return Null;
        }
        
        SObjectType objType=Schema.getGlobalDescribe().get(type);
        if(objType==Null)
        {
            return Null;
        }
        
        String nameField=getSobjectNameField(objType);
        searchString='\'*'+searchString+'*\'';
        
        String soslQuery='FIND :searchString IN NAME FIELDS RETURNING '+type+'(Id, '+nameField+' ORDER BY '+nameField+') LIMIT 20';
        system.debug('soslQuery---->'+soslQuery);
        
        List<List<SObject>> results=Search.query(soslQuery);
        
        List<SearchResult> output=new List<SearchResult>();
        if(results.size()>0)
        {
            for(SObject sobj : results[0])
            {
                SearchResult searchRes=new SearchResult();
                searchRes.id=(String)sobj.get('Id');
                searchRes.value=(String)sobj.get(nameField);
                output.add(searchRes);
            }
        }
        
        system.debug('End searchSObject---->');
        return JSON.serialize(output);
    }
    
    //Utility class for search results.
    public class SearchResult
    {
        public String value{get; set;}
        public String id{get; set;}
    }
}