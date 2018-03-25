global class ALL_SandboxRefresh_Controller {
   
    global static List<ALL_ChainedJob> jobs = new List<ALL_ChainedJob>();
    global static boolean runAllTasks=false;
    global Static boolean runUpdateEmailIdBatch=false;
    global static boolean runUpdateFieldsBatch=false;
    global static boolean runDeleteHRCases=false;
    
    global static void execute()
    {
        if(runAllTasks)
        {
            updateEmailIdBatch();
            updateFieldsBatch();
            deleteHRCases();
        }
        else if(runUpdateEmailIdBatch)
        {
            updateEmailIdBatch();
        }
        else if(runUpdateFieldsBatch)
        {
            updateFieldsBatch(); 
        }
        else if(runDeleteHRCases)
        {
            deleteHRCases();
        }
        if(jobs.size()!=0)
        {
            ALL_ChainedJob.executeAsChain(jobs);
        }
       
    }
    
    private static void updateEmailIdBatch()
    {
            List<Sandbox_Refresh_Update_Email_ID__c> csList = Sandbox_Refresh_Update_Email_ID__c.getAll().values();
            
            for(Sandbox_Refresh_Update_Email_ID__c csObj : csList)
            {
                String query = 'SELECT ' + csObj.Field_Name__c +' FROM '+csObj.Object_Name__c;
                //Id batchInstanceId =  Database.executeBatch(new ALL_Update_Email_ID_Batch(query,csObj.Field_Name__c, csObj.Object_Name__c),20);
                jobs.add(new ALL_ChainedJob(new ALL_Update_Email_ID_Batch(query,csObj.Field_Name__c, csObj.Object_Name__c),1,'Updating Email ID'));
            }
    }
    private static void updateFieldsBatch()
    {
        List<Sandbox_Refresh_Update_Fields__c> csList = Sandbox_Refresh_Update_Fields__c.getAll().values();
        for(Sandbox_Refresh_Update_Fields__c csObj : csList)
        {
            String query = 'SELECT ' + csObj.Field_Name__c +' FROM '+csObj.Object_Name__c;
            //Id batchInstanceId =  Database.executeBatch(new ALL_Update_Fields_Batch(query,csObj.Field_Name__c, csObj.Object_Name__c,csObj.value__c),20);
            jobs.add(new ALL_ChainedJob(new ALL_Update_Fields_Batch(query,csObj.Field_Name__c, csObj.Object_Name__c,csObj.value__c),1,'Updating Fields'));
        }
    }
    private static void deleteHRCases()
    {
        try
        {
            CustomSettings__c settings = CustomSettings__c.getInstance();
            Id cdkGlobalAccount  =  settings.CDK_Global_Account_Id__c;
            List<Case> casesList = [
                select id 
                from Case 
                where recordType.Name like '%HR%' 
                and recordType.sObjectType='Case' 
                and AccountId=:cdkGlobalAccount 
                limit 10000
            ];
            if(casesList.size()!=0)
            {
                delete casesList;
            }
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
        }
    }
}