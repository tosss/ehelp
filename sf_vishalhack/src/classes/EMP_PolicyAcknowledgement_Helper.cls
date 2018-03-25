//Author: Anirudh Singh
//Dated: 24th September, 2015
//Description: This is a helper class is for EMP_PolicyAcknowledgement trigger.
public class EMP_PolicyAcknowledgement_Helper
{
    public static void updateRecords(List<EMP_Policy__c> policyAcknowledgementList)
    {
        system.debug('Start updateRecords---->');
        if(Trigger.isAfter)
        {
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)
            {
                if(ALL_CheckRecursive.runCodeBlockOnce('afterUpdate_ALL')){
                    
                    ALL_GenericRollup_Helper.genericCountRollUp(policyAcknowledgementList, 'Contact', 'Policies__r', 
                                                                'Employee_Contact__c', 'Total_Policies__c', '');
                    
                    ALL_GenericRollup_Helper.genericCountRollUp(policyAcknowledgementList, 'Contact', 'Policies__r', 
                                                                'Employee_Contact__c', 'Total_Policies_To_Approve__c', 'Acknowledgement_Status__c=false');
                }
                
            }
        }
        system.debug('End updateRecords---->');
    }
}