// GLOBIT-4983: Process to sync between the Person Account and User
//
// 2017-10-05 marta.malinowska@cdk.com Created
public class ISVC_SyncPersonAccounts_Queueable implements Queueable {
    private String sandboxSuffix;
    private ISVC_NewUserDefaults__mdt companyCommunitiesUserDefaults;
    private Id companyCommunitiesUserProfileId;
    private Map<Id, Account> personAccountsToSync;
    private Map<Id, User> managersToAssign;
    private List<User> usersToUpsert;

    public ISVC_SyncPersonAccounts_Queueable(Map<Id, Account> personAccountsMap){
        personAccountsToSync = personAccountsMap;
    }

    public void execute(QueueableContext context) {
        sandboxSuffix = ALL_Organization_Utility.getSandboxSuffix();
        companyCommunitiesUserDefaults = ALL_CustomSettings_Utility.getCompanyCommunitiesUserDefaults();
        companyCommunitiesUserProfileId = ALL_Profiles_Utility.getCompanyCommunitiesUserProfileId();
        managersToAssign = getManagersToAssign(personAccountsToSync.values());
        usersToUpsert = getUsersToUpsert(personAccountsToSync);
        upsertUsers(usersToUpsert);
    }

    private Map<Id, User> getManagersToAssign(List<Account> accounts){
        Set<Id> managerIds = new Set<Id>();
        for(Account account : accounts){
            if(String.isNotBlank(account.Manager__pc)){
                managerIds.add(account.Manager__pc);
            }
        }
        Map<Id, User> managersMap = new Map<Id, User>();
        for(User user : [SELECT Id, Person_Contact_Id__c FROM User WHERE Person_Contact_Id__c IN :managerIds]){
            managersMap.put(user.Person_Contact_Id__c, user);
        }
        return managersMap;
    }

    private List<User> getUsersToUpsert(Map<Id, Account> personAccountsMap){
        List<Integration_Error__c> integrationErrors = new List<Integration_Error__c>();
        List<User> users = new List<User>();
        Map<String, Id> existingUsersMap = getExistingUsersMap(personAccountsMap.values());
        for(Account account : personAccountsMap.values()){
            if(String.isNotBlank(account.FedId__c)){
                Id userId = existingUsersMap.containsKey(account.FedId__c) ? existingUsersMap.get(account.FedId__c) : null;
                User user = getUserSynchWithPersonAccount(userId, account);
                users.add(user);
            } else {
                Integration_Error__c integrationError = new Integration_Error__c();
                integrationError.Account__c = account.Id;
                integrationError.Error__c = Label.ISVC_UserFederationIdRequired;
                integrationErrors.add(integrationError);
            }
        }
        if(!integrationErrors.isEmpty()){
            Database.insert(integrationErrors, false);
        }
        return users;
    }

    private Map<String, Id> getExistingUsersMap(List<Account> accounts){
        Set<String> federationIds = new Set<String>();
        for(Account account : accounts){
            if(String.isNotBlank(account.FedId__c)){
                federationIds.add(account.FedId__c);
            }
        }
        Map<String, Id> usersByFederationId = new Map<String, Id>();
        for(User user : [SELECT Id, FederationIdentifier FROM User WHERE ProfileId = :companyCommunitiesUserProfileId AND FederationIdentifier IN :federationIds]){
            usersByFederationId.put(user.FederationIdentifier, user.Id);
        }
        return usersByFederationId;
    }

    private User getUserSynchWithPersonAccount(Id userId, Account account){
        User user = new User();
        user.Id = userId;
        user.Person_Account_Id__c = account.Id;
        user.Person_Contact_Id__c = account.PersonContactId;
        user.Username = account.User_Id__pc + companyCommunitiesUserDefaults.Username_Suffix__c;
        if(String.isNotBlank(sandboxSuffix)){
            user.Username += '.' + sandboxSuffix;
        }
        user.ProfileId = companyCommunitiesUserProfileId;
        user.FirstName = account.FirstName;
        user.LastName = account.LastName;
        user.Alias = getUserAlias(account.User_Id__pc);
        user.Email = account.PersonEmail;
        user.EmailEncodingKey = companyCommunitiesUserDefaults.Email_Encoding__c;
        user.LanguageLocaleKey = companyCommunitiesUserDefaults.Language__c;
        user.LocaleSidKey = companyCommunitiesUserDefaults.Locale__c;
        user.TimeZoneSidKey = companyCommunitiesUserDefaults.Time_Zone__c;
        user.FederationIdentifier = account.FedId__c;
        user.EmployeeNumber = account.Employee_Id__pc;
        user.ManagerId = managersToAssign.containsKey(account.Manager__pc) ? managersToAssign.get(account.Manager__pc).Id : null;
        user.Phone = account.Phone;
        user.Extension = account.Phone_Extension__pc;
        user.MobilePhone = account.PersonMobilePhone;
        user.IsActive = account.In_AD__pc;
        return user;
    }

    private void upsertUsers(List<User> users){
        List<Integration_Error__c> integrationErrors = new List<Integration_Error__c>();
        List<Database.UpsertResult> results = Database.upsert(users, false);
        Database.UpsertResult result;
        User user;
        Map<String, String> accountIdToUserId = new Map<String, String>();
        for(Integer i=0; i<results.size(); i++){
            result = results[i];
            user = users[i];
            if(!result.isSuccess()){
                Integration_Error__c integrationError = new Integration_Error__c();
                integrationError.Account__c = user.Person_Account_Id__c;
                integrationError.Error__c = JSON.serialize(result.getErrors());
                integrationErrors.add(integrationError);
            } else {
            		accountIdToUserId.put(user.Person_Account_Id__c, user.Id);
            }
        }
        if(!integrationErrors.isEmpty()){
            Database.insert(integrationErrors, false);
        }
        if (!accountIdToUserId.isEmpty()) {
        		List<Account> accountList = new List<Account>();
        		for (Account a: [SELECT Id, User_Record__pc FROM Account WHERE Id in: accountIdToUserId.keySet() AND User_Record__pc = null ]) {
        			a.User_Record__pc = accountIdToUserId.get(a.Id);
        			accountList.add(a);
        		}
        		update accountList;
        }
    }

    private String getUserAlias(String userId){
        Integer maxAliasLength = Schema.SObjectType.User.fields.Alias.getLength();
        if(String.isNotBlank(userId)){
            return userId.left(maxAliasLength);
        }
        return null;
    }
}