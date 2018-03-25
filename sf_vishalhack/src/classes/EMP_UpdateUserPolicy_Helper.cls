public class EMP_UpdateUserPolicy_Helper {
    public static void executeUpdateUserPolicy(List<ContentVersion> contentVersionsObj )
    { 
        //get all the content in the policy library
        EMP_HR_Components__c comp = EMP_HR_Components__c.getOrgDefaults();
        List<ContentDocument> objContentDocument = EMP_PolicyUtility.getPolicyContentDocument(comp.Policy__c);
        
        if (!objContentDocument.isEmpty())
        {
            //convert list to map for easy access
            Map<Id,ContentDocument> contentDocuments = EMP_PolicyUtility.mapContentDocument(objContentDocument);
            
            List<EMP_Policy__c> insertPolicy = new List<EMP_Policy__c>();
            List<ContentVersion> lstContentVersion = new List<ContentVersion>();
            
            //get all id in the policy log to check if the content was already added to the user acknowledgement
            Map<Id,Id> existingContentId = EMP_PolicyUtility.getPolicyReference();
            
            for (ContentVersion contentVer : contentVersionsObj)
            {
                //check if the current policy does not exist in the log
                if (!existingContentId.containsKey(contentVer.ContentDocumentId))
                {
                    //check if the policy is valid for acknowledgement
                    if (date.valueOf(contentVer.Expiration_Date__c) > date.today() && contentVer.Acknowledgement_Required__c == true 
                        && contentDocuments.containsKey(contentVer.ContentDocumentId) && 'Global'.equals(contentVer.Policy_Geographic_Applicability__c))
                    {
                        lstContentVersion.add(contentVer);
                    }
                }
                
            }
            
            if (!lstContentVersion.isEmpty())
            {
                //get all user that can acknowledge a policy
                List<User> validEmployee = EMP_PolicyUtility.getUserForAcknowledgement();
                
                //creates policy acknowledgement records, given supplied parameters of valid employees and qualified policy content
                //determined in the prior FOR loop
                EMP_PolicyUtility.generatePolicyAcknowledgement(validEmployee,lstContentVersion);
                
                //update the policy reference log with entries for all policies for which acknowledge records have been created
                EMP_PolicyUtility.updatePolicyReference(lstContentVersion);
            }
        }
    }
}