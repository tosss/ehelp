/*......................................................................                  
. Description	:	Test class for DS_RequestSendEmail         
. Last Modified	:	By Lalitha Adduru in July 2015 to send list of email
.					addresses as one of the arguments to the method
. Code Coverage	:	100%
......................................................................*/

@IsTest
public class DS_RequestSendEmail_Test
{
    public static testmethod void testSendEmailRequestMethod()
    {
        String Random = ALL_UtilitiesRandom.TrueRandomUpToAMillion();
        String RandomUserName = ALL_UtilitiesRandom.RandomUserName('RequestEmailToDevTest');
        
        list<Profile> AdminProfiles = [
            Select Id, Name 
            From Profile 
            Where PermissionsModifyAllData = true 
            And PermissionsApiEnabled = true 
            And Name like '%System Administrator%'
            limit 1
        ];
        
        if(AdminProfiles != null && !AdminProfiles.isEmpty())
        {
            Profile AdminProfile = AdminProfiles.get(0);
            
            User NewUser = new User(
                UserName=RandomUserName, 
                Email=RandomUserName, 
                Alias=Random.length()>8?Random.substring(4, Random.length()):Random,
                EmailEncodingKey='UTF-8', 
                FirstName='Apex',
                LastName='Test User', 
                LanguageLocaleKey='en_US', 
                LocaleSIDKey='en_US', 
                profileId=AdminProfile.Id, 
                TimeZoneSIDKey='America/Chicago',
                ADID__c='A'+Random,
                FederationIdentifier = 'F'+Random
            ); 
            
            NewUser.putSObject('Profile', AdminProfile);
            insert NewUser;
            
            system.debug(NewUser.Profile);
            
            Request__c req = new Request__c(
                Name = 'TestDescription',
                Details__c='TestDetails',
                Business_Justification__c = 'TestJustification',
                Deployment_Strategy__c='In PROD Only',
                Status__c='Open',
                Internal_Priority__c='2 High', 
                Initial_Estimate__C= 12345,
                User_Groups_Impacted__c='CB - Finance'
            ); insert req;  
            
            Attachment p = new Attachment(Name = 'TestAttachment', Body=Blob.valueof('Test Body'),parentID = req.Id);
            database.insert(p);
            
            Note n = new Note(title='SampleNote', Body='Test Body',parentid = req.id);
            database.insert(n);
            
            //sending a sample string in place of url
            List<String> emails = new List<String>();
            emails.add('lalitha.adduru@cdk.com');
            DS_RequestSendEmail.sendEmailRequest(req.Id,'sample',emails,'SampleMessage'); 
        }
    }
}