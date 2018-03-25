@IsTest
public class ALL_RecordsFilter_Test 
{
    @testSetup
    public static void setupTestData()
    {
        List<Account> accountList  = new List<Account>();
        for(Integer i=0;i<8;i++)
        {
            accountList.add(new Account(Name='Test Account'+i));
        }
        insert accountList;
        for(Integer i=1;i<8;i++)
        {
            accountList[i].ParentId = accountList[i-1].id;
        }
        update accountList;
        List<Contact> contactList = new List<Contact>();
        for(Integer i=0;i<3;i++)
        {
            contactList.add(new Contact(AccountId = accountList[7].id,FirstName = 'FirstContact'+i,LastName = 'LastConatct'+i));
            contactList.add(new Contact(AccountId = accountList[0].id,FirstName = 'FirstContact'+i,LastName = 'LastConatct'+i));
        }
        insert contactList;
        
        String CurrentUserInitials = '';
        
        if(UserInfo.getFirstName() != null && UserInfo.getLastName() != null) {
            CurrentUserInitials = UserInfo.getFirstName().substring(0,1)+UserInfo.getLastName().substring(0,1);
        }
        else {
            CurrentUserInitials = 'IU'; // integration user
        }
        
        insert new Opportunity(AccountId = accountList[7].id,Name=CurrentUserInitials+' - Oppoutunity1',Type='Add-on',ADP_Opportunity_Owner__c=UserInfo.getUserId(),StageName='Plan',CloseDate=Date.today());
        insert new Opportunity(AccountId = accountList[0].id,Name=CurrentUserInitials+' - Oppoutunity1',Type='Add-on',ADP_Opportunity_Owner__c=UserInfo.getUserId(),StageName='Plan',CloseDate=Date.today());
        insert new Opportunity(AccountId = accountList[7].id,Name=CurrentUserInitials+' - Oppoutunity2',Type='Add-on',ADP_Opportunity_Owner__c=UserInfo.getUserId(),StageName='Plan',CloseDate=Date.today());
        insert new Opportunity(AccountId = accountList[0].id,Name=CurrentUserInitials+' - Oppoutunity2',Type='Add-on',ADP_Opportunity_Owner__c=UserInfo.getUserId(),StageName='Plan',CloseDate=Date.today());
        insert new Opportunity(AccountId = accountList[7].id,Name=CurrentUserInitials+' - Oppoutunity3',Type='Add-on',ADP_Opportunity_Owner__c=UserInfo.getUserId(),StageName='Plan',CloseDate=Date.today());
        insert new Opportunity(AccountId = accountList[0].id,Name=CurrentUserInitials+' - Oppoutunity3',Type='Add-on',ADP_Opportunity_Owner__c=UserInfo.getUserId(),StageName='Plan',CloseDate=Date.today());
        
        List<ALL_RecordsFilter_Conditions__c> arfsList = new List<ALL_RecordsFilter_Conditions__c>();
        ALL_RecordsFilter_Conditions__c arfcObj = new ALL_RecordsFilter_Conditions__c(
            Filter_Criteria__c='Sample Filter',		
            Operator__c = '^=',
            Field__c = 'Account.Name',
            Value__c = 'Test',
            Name = '1'
        );
        arfsList.add(arfcObj);
        arfcObj = new ALL_RecordsFilter_Conditions__c(
            Filter_Criteria__c='Sample Filter',
            Operator__c = '*=',
            Field__c = 'StageName',
            Value__c = 'Discover',
            Name = '2'
        );
        arfsList.add(arfcObj);
        arfcObj = new ALL_RecordsFilter_Conditions__c(
            Filter_Criteria__c='Sample Filter',		
            Operator__c = '^=',
            Field__c = 'Account.Contacts[].Name',
            Value__c = 'david',
            Name = '3'
        );
        arfsList.add(arfcObj);
        arfcObj = new ALL_RecordsFilter_Conditions__c(
            Filter_Criteria__c='Sample Filter',
            Operator__c = '^=',			
            Field__c = 'Account.Parent[Top].Name',
            Value__c = 'Top',
            Name = '4'
        );
        arfsList.add(arfcObj);
        arfcObj = new ALL_RecordsFilter_Conditions__c(
            Filter_Criteria__c='Sample Filter',			
            Operator__c = '*=',
            Field__c = 'Account.Parent[Top].Contacts[].Name',
            Value__c = 'Contact',
            Name = '5'
        );
        arfsList.add(arfcObj);
        insert arfsList;  
        insert new ALL_RecordsFilter_Criteria__c(Name='Sample Filter',Criteria__c='( 1 | 2 ) & 3 & 4 | 5');
    }
    static testmethod void test1()
    {
        Map<Id,Opportunity> opportunityList = new Map<Id,Opportunity>([SELECT Id FROM Opportunity]);
        test.startTest();
        ALL_RecordsFilter_Utility.evaluateCriteria('Sample Filter',new List<Id>(opportunityList.keySet()),'Opportunity');    
        test.stopTest();
    }
}