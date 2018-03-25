//Used in Sandbox Refresh v2.0 -  ALL_SandboxRefresh_Controller
global class ALL_Update_Email_ID_Batch implements Database.Batchable<sObject>  {
    
    global String Query;
    global String fieldName;
    global String objectName;
    global ALL_Update_Email_ID_Batch(String query,String fieldName, String objectName)
    {
        this.Query=query; 
        this.fieldName = fieldName;
        this.objectName = objectName;
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
            String sandboxAppend = '.'+ALL_UtilitiesMiscellaneous.GetCurrentInstanceName();
            for(sObject updateObj : objects)
            {
                
                Schema.sObjectType objectDef = Schema.getGlobalDescribe().get(objectName).getDescribe().getSObjectType();
                Map<String, Schema.SobjectField> ObjectFieldsMap = objectDef.getDescribe().fields.getMap();
                String emailId  = (String)updateObj.get(fieldName);
                updateObj = objectDef.newSobject(updateObj.Id);
                if(emailId!=null && !emailId.endswithIgnoreCase(sandboxAppend) )
                {
                    updateObj.put(fieldName,emailId+sandboxAppend);
                    updateList.add(updateObj);
                }
                
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