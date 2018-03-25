// GLOBIT-5239: Create termination case based on the employee termination record in SuccessFactor
//
// 2017-1-20 stephen.li@cdk.com Created
public with sharing class ISVC_CreateTermCase {
    
    public static List<Case> createCases(List<Deactivation__c> deactivations) {
            List<Case> caseList = new List<Case>();
            Map<Id, Account> accountsMap = getAccountsMap(deactivations);
            
            for (Deactivation__c d : deactivations) {
                // Construct the case description
                Account a = accountsMap.get(d.Employee__c);
                String description = 'Termination - ' + ((a != null) ? a.LastName + ', ' + a.FirstName + ', ' + d.Event_Date__c : '');
                // Create the case
                Case c = new Case(
                        AccountId = d.Employee__c,
                        ContactId = d.Manager__c,
                        RecordTypeId = ALL_RecordTypes_Utility.getTerminationRecordTypeId(),
                        Subject = description,
                        Description = description, 
                        Effective_Date__c = d.Event_Date__c,
                        Impact__c = 'A Single Person',
                        Severity__c = 'Severity5',
                        Origin = 'Web',
                        Deactivation__c = d.Id
                    );
                caseList.add(c);
            }
            return caseList;
    }
    
    public static Map<Id, Account> getAccountsMap(List<Deactivation__c> deactivations){
        Set<Id> accountIds = new Set<Id>();
        for(Deactivation__c d : deactivations){
            if(String.isNotBlank(d.Employee__c)){
                accountIds.add(d.Employee__c);
            }
        }
        Map<Id, Account> accounts = new Map<Id, Account>([
                SELECT Id, LastName, FirstName
                FROM Account WHERE Id IN :accountIds]);
        return accounts;
    }
    
}