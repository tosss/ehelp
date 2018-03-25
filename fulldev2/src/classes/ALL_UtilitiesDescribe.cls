global class ALL_UtilitiesDescribe 
{
    //createdby Siva.Pragada@cdk.com
    global static Schema.DescribeSObjectResult getDescribeInfoForsObject(string sObjectName)
    {
        if(sObjectName != null && !String.isEmpty(sObjectName))
        {
            return Schema.getGlobalDescribe().get(sObjectName).getDescribe();
        }
        
        return null;        
    }
    
    //createdby Siva.Pragada@cdk.com
    global static ID getRecordTypeIdOfAnySObject( string sObjectName, string RecordTypeName )
    {
        map<string, Schema.RecordTypeInfo> rtMapByName;
        
        if(sObjectName != null && !String.isEmpty(sObjectName))
        {
            rtMapByName = ALL_UtilitiesDescribe.getDescribeInfoForsObject(sObjectName).getRecordTypeInfosByName();
            
            if(RecordTypeName != null && !String.isEmpty(RecordTypeName) && rtMapByName != null && !rtMapByName.isEmpty())
            {
                return rtMapByName.get( RecordTypeName ).getRecordTypeId();                
            }
        }
        return null;       
    }
    
    //createdby Siva.Pragada@cdk.com
    global static string getRecordTypeNameOfAnySObject( string sObjectName, ID RecordTypeId )
    { 
        map<ID, Schema.RecordTypeInfo> rtMapById;
        
        if(sObjectName != null && !String.isEmpty(sObjectName))
        {
            rtMapById = ALL_UtilitiesDescribe.getDescribeInfoForsObject(sObjectName).getRecordTypeInfosById();
            
            if(RecordTypeId != null && rtMapById != null && !rtMapById.isEmpty())
            {
                return rtMapById.get( RecordTypeId ).getName();
            }
        }        
        return null;       
    }
    
    //createdby Siva.Pragada@cdk.com
    global static string sObjectTypeFinder( sobject sObjectRecord )
    {
        return sObjectRecord.getSObjectType().getDescribe().getName();
    }
    
    //createdby Siva.Pragada@cdk.com
    global static Map<String,Schema.RecordTypeInfo> getRecordTypeInfosByName( string sObjectType )
    {
        if(sObjectType != null)
        {
            return ALL_UtilitiesDescribe.getDescribeInfoForsObject(sObjectType).getRecordTypeInfosByName();
        }
        else{ return null; }
    }
    
    //createdby Siva.Pragada@cdk.com
    global static Map<ID, Schema.RecordTypeInfo> getRecordTypeInfosByID( string sObjectType )
    {
        if(sObjectType != null)
        {
            return ALL_UtilitiesDescribe.getDescribeInfoForsObject(sObjectType).getRecordTypeInfosByID();
        }
        else{ return null; }
    }
    
    //createdby Siva.Pragada@cdk.com
    global static map<string, list<soBject>> RecordTypeTosObjects( List<sObject> NewList ) 
    {
        string sObjectType = ALL_UtilitiesDescribe.sObjectTypeFinder(NewList[0]);
        
        Boolean RecordTypeMaster = ALL_UtilitiesDescribe.getRecordTypeInfosByName(sObjectType).get('Master').isDefaultRecordTypeMapping(); 
        
        map<string, list<sObject>> RecordTypeTosObjects = new map<string, list<sObject>>();
        
        if( RecordTypeMaster )
        {
          RecordTypeTosObjects.put('Master', NewList);  
        }
        else
        {
            for(sobject o: NewList)
            {
                Id RecordTypeId = (ID)o.get('RecordTypeId');
                string RecordTypeName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject( sObjectType, RecordTypeId );
                list<sObject> sObjectsRecordTypeWise = RecordTypeTosObjects.get( RecordTypeName );
                
                if(sObjectsRecordTypeWise == null)
                { 
                    sObjectsRecordTypeWise = new list<sObject>();                    
                }
                
                sObjectsRecordTypeWise.add(o);                
                RecordTypeTosObjects.put(RecordTypeName, sObjectsRecordTypeWise);
            }
        }
        
        return RecordTypeTosObjects;
    } 
}