global class ALL_Update_Fields_Batch implements Database.Batchable<sObject> {

    global String Query;
    global String fieldName;
    global String objectName;
    global String value;
    global ALL_Update_Fields_Batch(String query,String fieldName, String objectName,String value)
    {
        this.Query=query; 
        this.fieldName = fieldName;
        this.objectName = objectName;
        this.value = value;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(Query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> objects)
    {
        try
        {
            List<sObject> updateList = new List<sObject>();
            
            for(sObject updateObj : objects)
            {
                Schema.sObjectType objectDef = Schema.getGlobalDescribe().get(objectName).getDescribe().getSObjectType();
                Map<String, Schema.SobjectField> ObjectFieldsMap = objectDef.getDescribe().fields.getMap();
                updateObj = objectDef.newSobject(updateObj.Id);
                updateObj.put(fieldName,value);
                updateList.add(updateObj);
            }
            update updateList;
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
    }
}