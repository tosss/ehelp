// GLOBIT-5610: Internal Support - Re-Contact User Workflow
//
// 2017-11-20 marta.malinowska@cdk.com Created
public class ISVC_ChangeCaseStatus {

    private static Map<Id, Case> cases;
    private static Map<Id, User> accountUsers;
    private static Map<Id, User> contactUsers;

    public static void setStatusToReContactUser(List<FeedItem> feedItemsRelatedToCases){
        setCasesMap(feedItemsRelatedToCases);
        setAccountUsersMap(cases.values());
        setContactUsersMap(cases.values());

        List<Case> casesToUpdate = getCasesToUpdate(feedItemsRelatedToCases);
        update casesToUpdate;
    }

    private static void setCasesMap(List<FeedItem> feedItems){
        Set<Id> caseIds = new Set<Id>();
        for(FeedItem item : feedItems){
            caseIds.add(item.ParentId);
        }
        cases = new Map<Id, Case>();
        for(Case cas : [SELECT Id, AccountId, ContactId FROM Case WHERE Id IN :caseIds]) {
            cases.put(cas.Id, cas);
        }
    }

    private static void setAccountUsersMap(List<Case> cases){
        Set<Id> accountIds = new Set<Id>();
        for(Case cas : cases){
            if(String.isNotBlank(cas.AccountId)){
                accountIds.add(cas.AccountId);
            }
        }
        accountUsers = new Map<Id, User>();
        for(User usr : [SELECT Id, Person_Account_Id__c, Person_Contact_Id__c FROM User WHERE Person_Account_Id__c IN :accountIds]){
            if(String.isNotBlank(usr.Person_Account_Id__c)){
                accountUsers.put(usr.Person_Account_Id__c, usr);
            }
        }
    }

    private static void setContactUsersMap(List<Case> cases){
        Set<Id> contactIds = new Set<Id>();
        for(Case cas : cases){
            if(String.isNotBlank(cas.ContactId)){
                contactIds.add(cas.ContactId);
            }
        }
        contactUsers = new Map<Id, User>();
        for(User usr : [SELECT Id, Person_Account_Id__c, Person_Contact_Id__c FROM User WHERE Person_Contact_Id__c IN :contactIds]){
            if(String.isNotBlank(usr.Person_Contact_Id__c)){
                contactUsers.put(usr.Person_Contact_Id__c, usr);
            }
        }
    }

    private static List<Case> getCasesToUpdate(List<FeedItem> feedItemsRelatedToCases){
        List<Case> casesToUpdate = new List<Case>();
        for(FeedItem item : feedItemsRelatedToCases){
            Case relatedCase = cases.get(item.ParentId);
            Boolean isCreatedByCaseRelatedAccount = accountUsers.containsKey(relatedCase.AccountId)
                    && accountUsers.get(relatedCase.AccountId).Id == item.CreatedById;
            Boolean isCreatedByCaseRelatedContact = contactUsers.containsKey(relatedCase.ContactId)
                    && contactUsers.get(relatedCase.ContactId).Id == item.CreatedById;
            if(isCreatedByCaseRelatedAccount || isCreatedByCaseRelatedContact){
                Case caseToUpdate = new Case();
                caseToUpdate.Id = relatedCase.Id;
                caseToUpdate.Status = ALL_Picklists_Utility.STATUS_RECONTACT_USER;
                casesToUpdate.add(caseToUpdate);
            }
        }
        return casesToUpdate;
    }
}