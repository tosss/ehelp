//2016-01-21- anirudh.singh@cdk.com- Created this test class for handler DS_KeyRepChange_Handler 
//+ and bringing the Trigger DS_KeyRepChange upto standards it up to the Standards as per Request RQ-06024.
@isTest
public class DS_KeyRepChange_Test
{
    @TestSetup
    private static void setupData()
    {
        Account accountRecord=DS_TestObjects.NewAccount();
        accountRecord.Region__c='National';
        insert accountRecord;
    }
    
    private static testMethod void testPositive()
    {
        Account accountRecord=[SELECT Id FROM Account];
        
        List<User> userList=new List<User>();
        
        User userRecordOne=DS_TestObjects.NewUser();
        userRecordOne.Forecasting_Channel__c='National';
        userList.add(userRecordOne);
        
        User userRecordTwo=DS_TestObjects.NewUser();
        userRecordTwo.Forecasting_Channel__c='National';
        userList.add(userRecordTwo);
        
        insert userList;
        
        List<ADP_Default_Team__c> accountTeamList=new List<ADP_Default_Team__c>();
        
        ADP_Default_Team__c teamOne=new ADP_Default_Team__c();
        teamOne.Name=userRecordOne.Name+'Team';
        teamOne.Key_Rep__c=userRecordOne.Id;
        teamOne.Region__c='National';
        accountTeamList.add(teamOne);
        
        ADP_Default_Team__c teamTwo=new ADP_Default_Team__c();
        teamTwo.Name=userRecordOne.Name+'Team';
        teamTwo.Key_Rep__c=userRecordOne.Id;
        teamTwo.Region__c='National';
        accountTeamList.add(teamTwo);
        
        insert accountTeamList;
        
        test.startTest();
        List<Key_Rep_Changes__c> keyRepChangesList=new List<Key_Rep_Changes__c>();
        
        Key_Rep_Changes__c keyRepChangesRecOne=new Key_Rep_Changes__c();
        keyRepChangesRecOne.New_Key_Rep__c=userRecordOne.Id;
        keyRepChangesRecOne.Account__c=accountRecord.Id;
        keyRepChangesList.add(keyRepChangesRecOne);
        
        Key_Rep_Changes__c keyRepChangesRecTwo=new Key_Rep_Changes__c();
        keyRepChangesRecTwo.New_Key_Rep__c=userRecordOne.Id;
        keyRepChangesRecTwo.Account__c=accountRecord.Id;
        keyRepChangesList.add(keyRepChangesRecTwo);
        
        DS_KeyRepChange_Handler.addErrorToInsertedRecords(keyRepChangesList);
        
        try
        {
            insert keyRepChangesList;
        }
        catch(Exception e)
        {
            system.debug(e);
        }
        
        test.stopTest();
    }
    
    private static testMethod void testNegative()
    {
        Account accountRecord=[SELECT Id FROM Account];
        
        User userRecord=DS_TestObjects.NewUser();
        userRecord.Forecasting_Channel__c='National';
        insert userRecord;
        
        test.startTest();
        List<Key_Rep_Changes__c> keyRepChangesList=new List<Key_Rep_Changes__c>();
        
        Key_Rep_Changes__c keyRepChangesRec=new Key_Rep_Changes__c();
        keyRepChangesRec.New_Key_Rep__c=userRecord.Id;
        keyRepChangesRec.Account__c=accountRecord.Id;
        keyRepChangesList.add(keyRepChangesRec);
        
        DS_KeyRepChange_Handler.addErrorToInsertedRecords(keyRepChangesList);
        
        try
        {
            insert keyRepChangesList;
        }
        catch(Exception e)
        {
            system.debug(e);
        }
        test.stopTest();
    }
}