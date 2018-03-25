//Author: Anirudh Singh
//Description: This is a generic class for Rollup the Child to Parent.
//Dated: 2015-08-04
public class ALL_GenericRollup_Helper
{
    //This method will be invoked from Child record trigger.
    //Also, it will accept only those Child Records which were successfully inserted or updated.
    //It will then take the Parent Ids in a set, query the Child Records and then update the Parent.
    //The method will update a field on Parent with the SUM of the field values on Child records.
    public static void genericSumRollUp(
        List<sObject> childRecords, String parentAPIName, String childRelationshipName, 
        String fieldNameLinkedToParent, String parentFieldName, String childFieldName, 
        String whereConditionChild)
    {
        system.debug('Start genericSumRollUp---->');
        
        //Creating a set of Parent Ids for the Childs that need to be updated.
        Set<String> parentIds=new Set<String>();
        for(sObject ref: childRecords)
        {
            if(String.valueOf(ref.get(fieldNameLinkedToParent))!=Null 
               && String.valueOf(ref.get(fieldNameLinkedToParent))!='')
            {
                parentIds.add(String.valueOf(ref.get(fieldNameLinkedToParent)));
            }
        }
        
        //A Query String is created for fetching the Parent Records.
        String parentQueryString='SELECT '+parentFieldName;
        parentQueryString+=', (SELECT '+childFieldName+' FROM '+childRelationshipName;
        if(whereConditionChild!=Null && whereConditionChild!='' && !whereConditionChild.containsIgnoreCase('where '))
        {
            parentQueryString+=' WHERE '+whereConditionChild;
        }
        else if(whereConditionChild!=Null && whereConditionChild!='' && whereConditionChild.containsIgnoreCase('where '))
        {
            parentQueryString+=' '+whereConditionChild;
        }
        parentQueryString+=')';
        parentQueryString+=' FROM '+parentAPIName;
        parentQueryString+=' WHERE Id IN (\''+ALL_UtilitiesString.ListToDelimitedString(new List<String>(parentIds), '\',\'')+'\')';
        
        //This list contains the list of Parent Records that need to be updated.
        List<sObject> parentRecordsToUpdate=new List<sObject>();
        
        //Fetching the Parent Target Type.
        Schema.SObjectType targetTypeParent=Schema.getGlobalDescribe().get(parentAPIName);
        
        //The query is performed and the Parent Records are fetched and iterated.
        for(sObject parent: Database.query(parentQueryString))
        {
            sObject parentRec;
            Integer total=0;
            
            if(parent.getSObjects(childRelationshipName)!=Null && parent.getSObjects(childRelationshipName).size()>0)
            {
                //Iterating the Child Records.
                for(sObject child: parent.getSObjects(childRelationshipName))
                {
                    if(Integer.valueOf(child.get(childFieldName))!=Null)
                    {
                        total+=Integer.valueOf(child.get(childFieldName));
                    }
                }
            }
            
            parentRec=targetTypeParent.newSObject();
            parentRec.put('Id', parent.get('Id'));
            parentRec.put(parentFieldName, total);
            parentRecordsToUpdate.add(parentRec);
        }
        
        //The Parent Records are updated.
        List<Database.SaveResult> parentUpdateResults=Database.update(parentRecordsToUpdate, false);
        system.debug('End genericSumRollUp---->');
    }
    
    //This method will be invoked from Child record trigger.
    //Also, it will accept only those Child Records which were successfully inserted or updated.
    //It will then take the Parent Ids in a set, query the Child Records and then update the Parent.
    //The method will update a field on Parent with the Concatenated field values on Child records.
    public static void genericConcatenateRollUp(
        List<sObject> childRecords, String parentAPIName, String childRelationshipName, 
        String fieldNameLinkedToParent, String parentFieldName, String childFieldName, 
        String referencedSObjFieldName, String delimiter, String whereConditionChild)
    {
        system.debug('Start genericConcatenateRollUp---->');
        
        //Fetching the Child Field Map.
        String childSObjName=childRecords[0].Id.getSObjectType().getDescribe().getName();
        Map<String, Schema.SObjectField> resultMapChild=Schema.getGlobalDescribe().get(childSObjName).getDescribe().Fields.getMap();
        
        String childFieldType=Null;
        for(String fieldRef: resultMapChild.keySet())
        {
            if(childFieldName==fieldRef)
            {
                childFieldType=String.valueOf(resultMapChild.get(fieldRef).getDescribe().getType());
                break;
            }
        }
        
        Set<String> parentIds=new Set<String>();
        
        for(sObject ref: childRecords)
        {
            if(String.valueOf(ref.get(fieldNameLinkedToParent))!=Null 
               && String.valueOf(ref.get(fieldNameLinkedToParent))!='')
            {
                parentIds.add(String.valueOf(ref.get(fieldNameLinkedToParent)));
            }
        }
        
        //A Query String is created for fetching the Parent Records.
        String parentQueryString='SELECT '+parentFieldName;
        parentQueryString+=', (SELECT '+childFieldName+' FROM '+childRelationshipName;
        if(whereConditionChild!=Null && whereConditionChild!='' && !whereConditionChild.containsIgnoreCase('where '))
        {
            parentQueryString+=' WHERE '+whereConditionChild;
        }
        else if(whereConditionChild!=Null && whereConditionChild!='' && whereConditionChild.containsIgnoreCase('where '))
        {
            parentQueryString+=' '+whereConditionChild;
        }
        parentQueryString+=')';
        parentQueryString+=' FROM '+parentAPIName+' WHERE Id IN ';
        parentQueryString+='(\''+ALL_UtilitiesString.ListToDelimitedString(new List<String>(parentIds), '\',\'')+'\')';
        
        //This list contains the list of Parent Records that need to be updated.
        List<sObject> parentRecordsToUpdate=new List<sObject>();
        
        //Fetching the Parent Target Type.
        Schema.SObjectType targetTypeParent=Schema.getGlobalDescribe().get(parentAPIName);
        
        if(childFieldType.toUpperCase()=='REFERENCE')
        {
            //The query is performed and the Parent Records are fetched.
            List<sObject> parentRecordsList=new List<sObject>();
            parentRecordsList=Database.query(parentQueryString);
            
            Set<String> childFieldValues=new Set<String>();
            //Iterating the Parent Records List.
            for(sObject parent: parentRecordsList)
            {
                if(parent.getSObjects(childRelationshipName)!=Null && parent.getSObjects(childRelationshipName).size()>0)
                {
                    //Iterating the Child Records.
                    for(sObject child: parent.getSObjects(childRelationshipName))
                    {
                        if(String.valueOf(child.get(childFieldName))!=Null 
                           && String.valueOf(child.get(childFieldName))!='')
                        {
                            childFieldValues.add(String.valueOf(child.get(childFieldName)));
                        }
                    }
                }
            }
            
            Id referencedFieldValue=String.valueOf(childRecords[0].get(childFieldName));
            String referencedSObjName=referencedFieldValue.getSObjectType().getDescribe().getName();
            
            String referencedObjQueryString='SELECT '+referencedSObjFieldName+' FROM '+referencedSObjName;
            if(childFieldValues.size()>0)
            {
                referencedObjQueryString+=' WHERE Id IN ';
                referencedObjQueryString+='(\''+ALL_UtilitiesString.ListToDelimitedString(new List<String>(childFieldValues), '\',\'')+'\')';
            }
            
            List<sObject> referencedObjectRecords=new List<sObject>();
            referencedObjectRecords=Database.query(referencedObjQueryString);
            
            //Iterating the Parent Records List.
            for(sObject parent: parentRecordsList)
            {
                sObject parentRec;
                String finalConcatenatedValue;
                
                if(parent.getSObjects(childRelationshipName)!=Null && parent.getSObjects(childRelationshipName).size()>0)
                {
                    //Iterating the Child Records.
                    for(sObject child: parent.getSObjects(childRelationshipName))
                    {
                        for(sObject ref: referencedObjectRecords)
                        {
                            String referencedValue=String.valueOf(ref.get(referencedSObjFieldName));
                            
                            if(referencedValue!=Null && referencedValue!='' 
                               && finalConcatenatedValue==Null 
                               && String.valueOf(child.get(childFieldName))==String.valueOf(ref.get('Id')))
                            {
                                finalConcatenatedValue=referencedValue;
                            }
                            else if(referencedValue!=Null && referencedValue!='' 
                                    && finalConcatenatedValue!=Null 
                                    && !finalConcatenatedValue.containsIgnoreCase(referencedValue) 
                                    && String.valueOf(child.get(childFieldName))==String.valueOf(ref.get('Id')))
                            {
                                finalConcatenatedValue+=delimiter+' '+referencedValue;
                            }
                        }
                    }
                }
                
                parentRec=targetTypeParent.newSObject();
                parentRec.put('Id', parent.get('Id'));
                parentRec.put(parentFieldName, finalConcatenatedValue);
                parentRecordsToUpdate.add(parentRec);
            }
        }
        else if(childFieldType.toUpperCase()=='STRING')
        {
            //Iterating the Parent Records List.
            for(sObject parent: Database.query(parentQueryString))
            {
                sObject parentRec;
                String finalConcatenatedValue;
                
                if(parent.getSObjects(childRelationshipName)!=Null && parent.getSObjects(childRelationshipName).size()>0)
                {
                    //Iterating the Child Records.
                    for(sObject child: parent.getSObjects(childRelationshipName))
                    {
                        String referencedValue=String.valueOf(child.get(childFieldName));
                        
                        if(referencedValue!=Null && referencedValue!='' && finalConcatenatedValue==Null)
                        {
                            finalConcatenatedValue=referencedValue;
                        }
                        else if(referencedValue!=Null && referencedValue!='' && finalConcatenatedValue!=Null 
                                && !finalConcatenatedValue.containsIgnoreCase(referencedValue))
                        {
                            finalConcatenatedValue+=delimiter+' '+referencedValue;
                        }
                    }
                }
                
                parentRec=targetTypeParent.newSObject();
                parentRec.put('Id', parent.get('Id'));
                parentRec.put(parentFieldName, finalConcatenatedValue);
                parentRecordsToUpdate.add(parentRec);
            }
        }
        
        //The Parent Records are updated.
        List<Database.SaveResult> parentUpdateResults=Database.update(parentRecordsToUpdate, false);
        system.debug('End genericConcatenateRollUp---->');
    }
    
    //This method will be invoked from Child record trigger.
    //Also, it will accept only those Child Records which were successfully inserted or updated.
    //It will then take the Parent Ids in a set, query the Child Records and then update the Parent.
    //The method will update a field on Parent with the COUNT of Child records.
    public static void genericCountRollUp(
        List<sObject> childRecords, String parentAPIName, String childRelationshipName, 
        String fieldNameLinkedToParent, String parentFieldName, String whereConditionChild)
    {
        system.debug('Start genericCountRollUp---->');
        
        //Creating a set of Parent Ids for the Childs that need to be updated.
        Set<String> parentIds=new Set<String>();
        for(sObject ref: childRecords)
        {
            if(String.valueOf(ref.get(fieldNameLinkedToParent))!=Null 
               && String.valueOf(ref.get(fieldNameLinkedToParent))!='')
            {
                parentIds.add(String.valueOf(ref.get(fieldNameLinkedToParent)));
            }
        }
        
        //A Query String is created for fetching the Parent Records.
        String parentQueryString='SELECT '+parentFieldName;
        parentQueryString+=', (SELECT Id FROM '+childRelationshipName;
        if(whereConditionChild!=Null && whereConditionChild!='' && !whereConditionChild.containsIgnoreCase('where '))
        {
            parentQueryString+=' WHERE '+whereConditionChild;
        }
        else if(whereConditionChild!=Null && whereConditionChild!='' && whereConditionChild.containsIgnoreCase('where '))
        {
            parentQueryString+=' '+whereConditionChild;
        }
        parentQueryString+=')';
        parentQueryString+=' FROM '+parentAPIName;
        parentQueryString+=' WHERE Id IN (\''+ALL_UtilitiesString.ListToDelimitedString(new List<String>(parentIds), '\',\'')+'\')';
        
        //This list contains the list of Parent Records that need to be updated.
        List<sObject> parentRecordsToUpdate=new List<sObject>();
        
        //Fetching the Parent Target Type.
        Schema.SObjectType targetTypeParent=Schema.getGlobalDescribe().get(parentAPIName);
        
        //The query is performed and the Parent Records are fetched and iterated.
        for(sObject parent: Database.query(parentQueryString))
        {
            sObject parentRec=targetTypeParent.newSObject();
            parentRec.put('Id', parent.get('Id'));
            
            if(parent.getSObjects(childRelationshipName)!=Null && parent.getSObjects(childRelationshipName).size()>0)
            {
                parentRec.put(parentFieldName, parent.getSObjects(childRelationshipName).size());
            }
            else
            {
                parentRec.put(parentFieldName, 0);
            }
            
            parentRecordsToUpdate.add(parentRec);
        }
        
        //The Parent Records are updated.
        List<Database.SaveResult> parentUpdateResults=Database.update(parentRecordsToUpdate, false);
        system.debug('End genericCountRollUp---->');
    }
}