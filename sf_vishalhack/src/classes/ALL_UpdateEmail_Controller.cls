/******************************************************************************************
*  2016-08-12 ragashalini.koka@cdk.com - RQ-07383 Created this class 
*  Description : This class chains the batch jobs to update Email ids on the given objects
*  Test Class : ALL_UpdateEmail_Test
*  History
*  2016-08-31 ragashalini.koka@cdk.com  - added extra parameter in ALL_Update_Email_Batch
* *****************************************************************************************/

global class ALL_UpdateEmail_Controller {
    global static List<ALL_ChainedJob> jobsList = new List<ALL_ChainedJob>();
   	//global static Map<String,List<String>> objectToFieldsMap;
    static String queryTemplate = 'SELECT {0} FROM {1} {2}';
   
    public ALL_UpdateEmail_Controller() {
        
        List<Update_Email_Fields__c> updateEmailFieldsList = Update_Email_Fields__c.getall().values();
       	
        //objectToFieldsMap = new Map<String,List<String>>();
        for(Update_Email_Fields__c updateFieldRef : updateEmailFieldsList) {

            if(updateFieldRef.Run_Batch__c) {
             String query = buildQuery(updateFieldRef.Object_API_Name__c,updateFieldRef.FieldSet_API__c, updateFieldRef.Condition__c, null); 
                if(query.length() > 0) {
                    jobsList.add(new ALL_ChainedJob(new ALL_Update_Email_Batch(query, updateFieldRef.Name, updateFieldRef.Log_Exception__c), 100, 'Email Field Updates'));
                    updateFieldRef.Last_Run_Batch_Id__c = null;
                }
            }
        }
       // System.debug('objectToFieldsMap' + objectToFieldsMap); 
        update updateEmailFieldsList;
        if(jobsList.size() > 0) {
           
             ALL_ChainedJob.executeAsChain(jobsList);
        }
    }
    
    public static String buildQuery(String objectName, String fieldsetName, String condition,List<String> fieldsList) {
        
        String query = '';
        
        try {
            Schema.DescribeSObjectResult sObjectResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
            List<String> columnsList = new List<String>();
            if(fieldsetName != null) {
                List<Schema.FieldSetMember> fieldSetMemberList = sObjectResult.fieldSets.getMap().get(fieldsetName).getFields();
                for(Schema.FieldSetMember field : fieldSetMemberList ) {
                   
                    columnsList.add(field.getFieldPath());
                    
                }
            }
            else if(fieldsList != null) {
                columnsList.addAll(fieldsList);
            }
            else {
                columnsList.addAll(sObjectResult.fields.getMap().keySet());
            }
            //objectToFieldsMap.put(objectName.toLowerCase(), columnsList);
            String columns = String.join(columnsList, ',');
            
            String queryCondition = '';
            if(condition != null && condition.length() > 0) {
                queryCondition = 'WHERE ' + condition;
            }
            
            query = String.format(queryTemplate, new List<String>{columns, objectName, queryCondition});
            
            return query;
        }
        catch(Exception exp) {
            System.debug('exp ' + exp.getLineNumber() + exp.getCause());
            return '';
        }
      
     
    }
    
  

}