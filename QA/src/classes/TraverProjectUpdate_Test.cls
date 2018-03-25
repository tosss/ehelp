/*
 * Author         Vishal Bandari
 * Created        22 April 2015
 * Description    Test Class for TraverProjectUpdate_Handler
 * Class          TraverProjectUpdate_Handler
 * Code Coverage  100%
 * 
 * History
 * 22 April 2015    Vishal Bandari    Created Trigger
 */
@IsTest
public class TraverProjectUpdate_Test 
{
    @TestSetup
    public static void setData()
    {        
        List<Id> UserIds = new List<Id>();
        List<User> UserList = new List<User>();
        
        Id StandardProfileId = [
            SELECT Id, Name 
            FROM Profile 
            WHERE Name LIKE '%Traver%' 
            LIMIT 1].Id;
        
        for(Integer i=0;i<=1;i++)
        {
            String Random = DS_TestObjects.NextTestUserRandom();
            User NewUser = new User(
                UserName='test-'+Random+'@cdk.com', 
                Email='test-'+Random+'@cdk.com', 
                Alias=Random.length()>8?Random.substring(4, Random.length()):Random,
                EmailEncodingKey='UTF-8', 
                FirstName='Apex' + Random,
                LastName='Test User',
                LanguageLocaleKey='en_US', 
                LocaleSIDKey='en_US', 
                profileid=StandardProfileId, 
                TimeZoneSIDKey='America/Chicago',
                IsActive = true,
                ADID__c='A'+Random,
                FederationIdentifier = 'F'+Random
            );
            UserList.add(NewUser);
        }
        
        insert UserList;
    }
    public static testmethod void validateHandler()
    {
        List< User> UserList = [
            SELECT id, name, firstname, lastname, email 
            FROM user 
            ORDER BY CreatedDate desc
            LIMIT 2
        ];
        
        Account accObj = DS_TestObjects.NewAccount_Inserted();
        
        Traver_Project__c traverObj = new Traver_Project__c(Account__c = accObj.id, EPC__c = UserList[0].id, Process_Coach__c = UserList[1].id);
        insert traverObj;
        
        traverObj.EPC__C = UserList[1].id;
        traverObj.Process_Coach__c = UserList[0].id;
        update traverObj;
        
        traverObj = [
            SELECT EPC__c, Previous_Process_Coach__c, Previous_Process_Coach_Email__c , Previous_EPC_Email__c, Previous_EPC__c
            FROM Traver_Project__c 
            WHERE id=: traverObj.Id
        ];
        
        System.assertEquals(UserList[0].Name, traverObj.Previous_EPC__c,'Previous EPC not set');
        System.assertEquals(UserList[0].Email, traverObj.Previous_EPC_Email__c,'Previous EPC email not set');
        System.assertEquals(UserList[1].Name, traverObj.Previous_Process_Coach__c,'Previous Process Coach not set');
        System.assertEquals(UserList[1].Email, traverObj.Previous_Process_Coach_Email__c,'Previous Process Coach email not set');
        
        TraverProjectUpdate_Handler.updateEPCandProcessCoachField(null,null);
    }
}