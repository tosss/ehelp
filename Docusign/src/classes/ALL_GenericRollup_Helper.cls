//Author: Anirudh Singh
//Description: This is a generic class for Rollup the Child to Parent.
//Dated: 2015-08-04
public class ALL_GenericRollup_Helper
{
    //This method will be invoked on after insert and after update of the Child record.
    //Also, it will accept only those Child Records which were successfully inserted or updated.
    //It will then take the Parent Ids in a set, query the Child Records and then update the Parent.
    //The method will update a field on Parent with the SUM of the field values on Child records.
    public static void genericSumRollUp(
        List<sObject> childRecords,  String parentAPIName, String fieldNameLinkedToParent, 
        String parentFieldName, String childFieldName)
    {
        system.debug('Start genericSumRollUp---->');
        
        //Creating a set of Parent Ids for the Childs that need to be updated.
        Set<String> parentIds=new Set<String>();
        for(sObject ref: childRecords)
        {
            parentIds.add(String.valueOf(ref.get(fieldNameLinkedToParent)));
        }
        
        //A Query String is created for fetching the Parent Records.
        String parentQueryString='SELECT '+parentFieldName+' FROM '+parentAPIName;
        parentQueryString+=+' WHERE Id IN (\''+ALL_UtilitiesString.ListToDelimitedString(new List<String>(parentIds), '\',\'')+'\')';
        
        //The query is performed and the Parent Records are fetched.
        List<sObject> parentRecordsList=new List<sObject>();
        parentRecordsList=Database.query(parentQueryString);
        
        //This list contains the list of Parent Records that need to be updated.
        List<sObject> parentRecordsToUpdate=new List<sObject>();
        
        //Fetching the Parent Target Type.
        Schema.SObjectType targetTypeParent=Schema.getGlobalDescribe().get(parentAPIName);
        
        //Iterating the Parent Records List.
        for(sObject parent: parentRecordsList)
        {
            sObject parentRec;
            Integer total=0;
            //Iterating the Child Records.
            for(sObject child: childRecords)
            {
                if(parent.get('Id')==child.get(fieldNameLinkedToParent))
                {
                    parentRec=targetTypeParent.newSObject();
                    parentRec.put('Id', parent.get('Id'));
                    total=total+Integer.valueOf(child.get(childFieldName));
                }
            }
            
            if(parentRec!=Null)
            {
                parentRec.put(parentFieldName, (Integer.valueOf(parent.get(parentFieldName))+total));
                parentRecordsToUpdate.add(parentRec);
            }
        }
        
        //The Parent Records are updated.
        List<Database.SaveResult> parentUpdateResults=Database.update(parentRecordsToUpdate, false);
        system.debug('End genericSumRollUp---->');
    }
    
    //This method will be invoked on after insert and after update of the Child record.
    //Also, it will accept only those Child Records which were successfully inserted or updated.
    //It will then take the Parent Ids in a set, query the Child Records and then update the Parent.
    //The method will update a field on Parent with the Concatenated field values on Child records.
    public static void genericConcatenateRollUp(
        List<sObject> childRecords, String parentAPIName, String fieldNameLinkedToParent, 
        String parentFieldName, String childFieldName, String delimiter)
    {
        system.debug('Start genericConcatenateRollUp---->');
        
        //Global Describe Map.
        Map<String, Schema.SObjectType> globalDescMap=Schema.getGlobalDescribe();
        
        //Fetching the Child Field Map.
        String childSObjName=childRecords[0].Id.getSObjectType().getDescribe().getName();
        Map<String, Schema.SObjectField> resultMapChild=globalDescMap.get(childSObjName).getDescribe().Fields.getMap();
        
        String childFieldType=Null;
        for(String fieldRef: resultMapChild.keySet())
        {
            if(fieldRef==childFieldName)
            {
                childFieldType=String.ValueOf(resultMapChild.get(fieldRef).getDescribe().getType());
                break;
            }
        }
        
        Set<String> parentIds=new Set<String>();
        Set<String> childFieldValues=new Set<String>();
        for(sObject ref: childRecords)
        {
            parentIds.add(String.valueOf(ref.get(fieldNameLinkedToParent)));
            if(childFieldType.toUpperCase()=='REFERENCE')
            {
                childFieldValues.add(String.valueOf(ref.get(childFieldName)));
            }
        }
        
        //A Query String is created for fetching the Parent Records.
        String parentQueryString='SELECT '+parentFieldName+' FROM '+parentAPIName+' WHERE Id IN ';
        parentQueryString+='(\''+ALL_UtilitiesString.ListToDelimitedString(new List<String>(parentIds), '\',\'')+'\')';
        
        //The query is performed and the Parent Records are fetched.
        List<sObject> parentRecordsList=new List<sObject>();
        parentRecordsList=Database.query(parentQueryString);
        
        //This list contains the list of Parent Records that need to be updated.
        List<sObject> parentRecordsToUpdate=new List<sObject>();
        
        //Fetching the Parent Target Type.
        Schema.SObjectType targetTypeParent=globalDescMap.get(parentAPIName);
        
        if(childFieldType.toUpperCase()=='REFERENCE')
        {
            Id referencedFieldValue=String.valueOf(childRecords[0].get(childFieldName));
            String referencedSObjName=referencedFieldValue.getSObjectType().getDescribe().getName();
            
            String referencedObjQueryString='SELECT Name FROM '+referencedSObjName+' WHERE Id IN ';
        	referencedObjQueryString+='(\''+ALL_UtilitiesString.ListToDelimitedString(new List<String>(childFieldValues), '\',\'')+'\')';
            
            List<sObject> referencedObjectRecords=new List<sObject>();
            referencedObjectRecords=Database.query(referencedObjQueryString);
            
            //Iterating the Parent Records List.
            for(sObject parent: parentRecordsList)
            {
                sObject parentRec;
                
                //Populate the current value in the Parent Field into finalValue.
                String finalValue=String.valueOf(parent.get(parentFieldName));
                
                //Iterating the Child Records.
                for(sObject child: childRecords)
                {
                    for(sObject ref: referencedObjectRecords)
                    {
                        String referencedValue=String.valueOf(ref.get('Name'));
                        
                        if(parent.get('Id')==child.get(fieldNameLinkedToParent) 
                           && finalValue==Null 
                           && referencedValue!=Null 
                           && String.valueOf(child.get(childFieldName))==String.valueOf(ref.get('Id')))
                        {
                            finalValue=referencedValue;
                            
                            if(parentRec==Null)
                            {
                                parentRec=targetTypeParent.newSObject();
                                parentRec.put('Id', parent.get('Id'));
                            }
                            break;
                        }
                        else if(parent.get('Id')==child.get(fieldNameLinkedToParent) 
                                && finalValue!=Null 
                                && referencedValue!=Null 
                                && String.valueOf(child.get(childFieldName))==String.valueOf(ref.get('Id'))
                                && !finalValue.toLowerCase().contains(referencedValue.toLowerCase()))
                        {
                            finalValue+=delimiter+' '+referencedValue;
                            break;
                        }
                    }
                }
                
                if(parentRec!=Null)
                {
                    parentRec.put(parentFieldName, finalValue);
                    parentRecordsToUpdate.add(parentRec);
                }
            }
        }
        else if(childFieldType.toUpperCase()=='STRING')
        {
            //Iterating the Parent Records List.
            for(sObject parent: parentRecordsList)
            {
                sObject parentRec;
                String finalValue=String.valueOf(parent.get(parentFieldName));
                
                //Iterating the Child Records.
                for(sObject child: childRecords)
                {
                    if(parent.get('Id')==child.get(fieldNameLinkedToParent) 
                       && finalValue==Null 
                       && child.get(childFieldName)!=Null)
                    {
                        finalValue=String.valueOf(child.get(childFieldName));
                        
                        if(parentRec==Null)
                        {
                            parentRec=targetTypeParent.newSObject();
                            parentRec.put('Id', parent.get('Id'));
                        }
                    }
                    else if(parent.get('Id')==child.get(fieldNameLinkedToParent) 
                            && finalValue!=Null 
                            && child.get(childFieldName)!=Null 
                            && !finalValue.toLowerCase().contains((String.valueOf(child.get(childFieldName))).toLowerCase()))
                    {
                        finalValue+=delimiter+' '+String.valueOf(child.get(childFieldName));
                    }
                }
                
                if(parentRec!=Null)
                {
                    parentRec.put(parentFieldName, finalValue);
                    parentRecordsToUpdate.add(parentRec);
                }
            }
        }
        
        //The Parent Records are updated.
        List<Database.SaveResult> parentUpdateResults=Database.update(parentRecordsToUpdate, false);
        system.debug('End genericConcatenateRollUp---->');
    }
}