// Derived From: http://christopheralunlewis.blogspot.com/2011/05/how-to-dynamically-clone-salesforce.html
// Posted by: Christopher Alun Lewis on Wednesday, May 18, 2011 
// Modified by: Matthew Keefe
public class sObjectCloner
{
    // Clone a list of objects to a particular object type 
    // Parameters 
    // - List<sObject> sObjects - the list of objects to be cloned 
    // - Schema.SobjectType objectType - the type of object to be cloned. 
    // The sObjects you pass in must include the ID field, 
    // and the object must exist already in the database, 
    // otherwise the method will not work. 
    public static List<sObject> CloneRecords (List<Id> sObjectIds)
    {
        // A list of fields for the sObject being cloned
        Map<String, Schema.Sobjectfield> sObjectFields = new Map<String, Schema.Sobjectfield>();
        
        // A list of new cloned sObjects
        List<sObject> clonedSObjects = new List<sObject>();
        
        system.debug(sObjectIds);
        
        // If there are no objects sent into the method, 
        // then return an empty list 
        if (sObjectIds != null && !sObjectIds.isEmpty())
        {
            // get the Types of all the supplied sObjects
            // since this method does not support sObjects of varied types, get the first type returned
            Schema.Sobjecttype objectType = IdToType(sObjectIds[0]);
            
            if(objectType == null) {
                return new List<sObject>(); }
            
            // describe the sObject
            Schema.DescribeSObjectResult DescribeResult = objectType.getDescribe();
            
            // Get all the fields from the selected object type using 
            // the get describe method on the object type.
            if (objectType != null)
            {
                sObjectFields = DescribeResult.fields.getMap();
            }
            
            if(!sObjectFields.IsEmpty())
            {
                // Using the list of sObject IDs and the object type, 
                //   we can construct a string based SOQL query 
                //   to retrieve the field values of all the objects.
                
                String allSObjectFieldsQuery = 'SELECT ';
                String allSObjectFields = '';
                
                //for (Integer i=0; i<sObjectFields.size(); i++) {
                for (String s : sObjectFields.keyset()) 
                {
                    // Boolean FieldIsUnique = false; 
                    // try { FieldIsUnique = sObjectFields.get(s).getDescribe().IsUnique(); } catch (Exception e) {}
                    // if(!FieldIsUnique) { allSObjectFields += (allSObjectFields != '' ? ', ' : '') + sObjectFields.get(s); }
                    
                    Schema.DescribeFieldResult FieldDescription = null;
                    try { FieldDescription = sObjectFields.get(s).getDescribe(); } catch (Exception e) {}
                    
                    // remove any unique fields or address fields (address fields are collections of other fields)
                    if(FieldDescription != null 
                    && !FieldDescription.IsUnique() 
                    && FieldDescription.getType() != Schema.DisplayType.ADDRESS) { 
                        allSObjectFields += (allSObjectFields != '' ? ', ' : '') + sObjectFields.get(s); }
                } 
                
                allSObjectFieldsQuery += allSObjectFields + ' FROM ' + DescribeResult.getName() + ' WHERE ID IN (';
                
                for (Integer i=0; i<sObjectIds.size(); i++) {
                    allSObjectFieldsQuery += (i != 0 ? ', \'' : '\'') + sObjectIds.get(i) + '\'';
                } 
                
                allSObjectFieldsQuery += ')';
                
                system.debug(allSObjectFieldsQuery);
                
                try
                {
                    // Execute the query. For every result returned, 
                    // use the clone method on the generic sObject 
                    // and add to the collection of cloned objects
                    for (SObject sObjectFromDatabase : Database.query(allSObjectFieldsQuery)) {
                        clonedSObjects.add(sObjectFromDatabase.clone(false,true));    
                    }
                }
                catch (exception e)
                {
                    system.debug(e);
                    
                    // Write exception capture method 
                    // relevant to your organisation. 
                    // Debug message, Apex page message or 
                    // generated email are all recommended options.
                }
            }
        }        
        
        // return the cloned sObject collection.
        return clonedSObjects;
    }
    
    public static Schema.Sobjecttype IdToType(Id i)
    {
        Map<Id,Schema.Sobjecttype> TypesByIds = sObjectCloner.IdsToTypes(new List<Id>{i});
        if(TypesByIds.size() > 0) { return TypesByIds.values()[0]; }
        else { return null; }
    }
    
    public static Map<Id,Schema.Sobjecttype> IdsToTypes (List<Id> Ids)
    {
        Map<String,List<Id>> IdsByPrefix = new Map<String,List<Id>>();
        
        for(Id i : Ids) 
        {
            String p = null;
            try { p = String.valueOf(i).substring(0,3); } catch (Exception e) { continue; }
            
            List<Id> SortedIds = IdsByPrefix.get(p);
            if(SortedIds == null) { SortedIds = new List<Id>(); }
            SortedIds.add(i);
            
            IdsByPrefix.put(p,SortedIds); 
        }
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<Id,Schema.Sobjecttype> Types = new Map<Id,Schema.Sobjecttype>();
        
        for(Schema.SObjectType stype : gd.values())
        {
            Schema.DescribeSObjectResult r = stype.getDescribe();
            String gp = r.getKeyPrefix();
            
            if(gp != null && IdsByPrefix.keyset().contains(gp)) {
                for(Id i : IdsByPrefix.get(gp)) {
                    Types.put(i,r.getSObjectType()); 
                } 
            }
        }
        
        return Types;
    }
}