//2016-05-19 vishal.bandari@cdk.com - updated trigger as per the request RQ-07014
//2017-02-27 ragashalini.koka@cdk.com - Added the method to inactivate CRs if the Accounts are marked as duplicate for RQ-08685
trigger ALL_Contact_Relationship on Contact_Relationship__c (before insert,after insert, before update, after update, before delete, after delete) 
{
    GlobalSettings__c gs = GlobalSettings__c.getOrgDefaults();
    
    if(UserInfo.getUserName() != gs.Admin_Integration_Username__c)
    {
        if(Trigger.isBefore) 
        {
            // 2016-07-29 matt.keefe@cdk.com - added or condition for Trigger.isUpdate
            if(Trigger.isInsert || Trigger.isUpdate)
            {
                for(Contact_Relationship__c crt:Trigger.New)
                {
                    // 2016-07-29 matt.keefe@cdk.com - added condition for null and blank check
                    if(crt.Account_Contact_Id__c == null || crt.Account_Contact_Id__c == '') 
                    {
                        crt.Account_Contact_Id__c = (String)crt.Account__c + (String)crt.Contact__c; 
                    }
                }
                 //2017-02-27 ragashalini.koka@cdk.com - Added the method to inactivate CRs if the Accounts are marked as duplicate for RQ-08685
                ALL_Contact_Relationship_Handler.updateCRStatusOfDuplicateAccounts(Trigger.oldMap, Trigger.new);
            }
            
            if(Trigger.isUpdate)
            {
                ALL_Contact_Relationship_Handler.beforeUpdate(Trigger.New, Trigger.oldMap);   
            }
            
            if(Trigger.isDelete)
            {
                ALL_Contact_Relationship_Handler.beforeDelete(Trigger.old);    
            }
        }
        else if(Trigger.isAfter) 
        {
            //2016-05-19 vishal.bandari@cdk.com - added below code as per the request RQ-07014
            if(Trigger.isInsert)
            {
                ALL_Contact_Relationship_Handler.afterInsert(Trigger.New);
            }
            
            //2016-05-19 vishal.bandari@cdk.com - added below code as per the request RQ-07014
            else if(Trigger.isUpdate) 
            {
                ALL_Contact_Relationship_Handler.afterUpdate(Trigger.new, Trigger.oldMap);
            }
            
            else if(Trigger.isDelete) {
                ALL_Contact_Relationship_Handler.afterDelete(Trigger.old);
            }
            
           
        }
    }
}