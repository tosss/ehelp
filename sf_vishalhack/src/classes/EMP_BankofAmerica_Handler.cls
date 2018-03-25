public class EMP_BankofAmerica_Handler 
{
    public static void processProcurementRecordTypes(list<Case> procurementCases)
    {
        try
        {
            List<Id> contactIds = new List<Id> ();
            
            for (Case caseObject : procurementCases) 
            {
                if (caseObject.BOA_Manager_Approval__c == 'Manager - Rejected' || caseObject.BOA_Manager_Approval__c == 'Procurement - Rejected') 
                {
                    contactIds.add(caseObject.CreatedById);
                }
            }
            
            List<Contact> contactList = [select Id, BOA_Registered_T_E_Card__c from Contact where User__c = :contactIds];
            
            system.debug('$$ contactList' + contactList);
            
            for (Contact tempContact : contactList) 
            {
                tempContact.BOA_Registered_T_E_Card__c = false;
            }
            
            update contactList;
        }
        Catch(Exception Exp)
        {
            ALL_UtilitiesMiscellaneous.logException(Exp);
        }
    }
}