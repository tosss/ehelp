@isTest
private class Enghouse_Test 
{
    @TestSetup
    static void setupTestData() {
        Profile StandardProfile = [
            Select Id, Name 
            From Profile 
            Where Name = 'Standard User' 
            Limit 1
        ];
        
        Id StandardProfileId = StandardProfile != null ? StandardProfile.Id :null;
        
        String Random = String.valueOf( Math.round( Math.random() * 1000 ) * DateTime.now().millisecond() );
        
        User TestUser = new User(
            UserName='test-Enghouse-1@mailinator.com', 
            Email='test-Enghouse-1@mailinator.com', 
            Alias='Enghouse',
            EmailEncodingKey='UTF-8', 
            FirstName='Enghouse',
            LastName='Test User', 
            LanguageLocaleKey='en_US', 
            LocaleSIDKey='en_US', 
            profileid=StandardProfileId, 
            TimeZoneSIDKey='America/Chicago',
            ADID__c='A'+Random,
            FederationIdentifier='F'+Random
        );
        
        insert TestUser;
    }
    
    static testMethod void testGetUser() {
        User u = [SELECT Id FROM User where UserName = 'test-Enghouse-1@mailinator.com' limit 1];
        
        System.runAs(u) 
        {
            System.debug('Current User: ' + UserInfo.getUserName());    
            
            String JSONString = Enghouse.getUser();
            
            System.debug('Result: ' + JSONString);
            
            Map<String, String> mapUser = (Map<String, String>)JSON.deserialize(JSONString, Map<String, String>.class);
            
            System.assertEquals(mapUser.get('userId'), UserInfo.getUserId());
            System.assertEquals(mapUser.get('email'), UserInfo.getUserEmail());
            System.assertEquals(mapUser.get('name'), UserInfo.getName());              
        }
    }
    
    static testMethod void testGetActivityFields() {
        User u = [SELECT Id FROM User where UserName = 'test-Enghouse-1@mailinator.com' limit 1];
        
        System.runAs(u) {
            System.debug('Current User: ' + UserInfo.getUserName());    
            
            String JSONString = Enghouse.getActivityFields('3', false);
            
            System.debug('Result: ' + JSONString);
            
            Map<String, Object> mapData = (Map<String, Object>)JSON.deserializeUntyped(JSONString);
            
            System.assertEquals((String)mapData.get('id'), '3');
            System.assertEquals((Boolean)mapData.get('success'), true);
        }
    }
    
    static testMethod void testGetActivityFieldsCustom() {
        User u = [SELECT Id FROM User where UserName = 'test-Enghouse-1@mailinator.com' limit 1];
        
        System.runAs(u) {
            System.debug('Current User: ' + UserInfo.getUserName());    
            
            String JSONString = Enghouse.getActivityFields('7', true);
            System.debug('Result: ' + JSONString);
            
            Map<String, Object> mapData = (Map<String, Object>)JSON.deserializeUntyped(JSONString);
            
            System.assertEquals((String)mapData.get('id'), '7');
            System.assertEquals((Boolean)mapData.get('success'), true);
            
            List<Object> listFields = (List<Object>)mapData.get('result');
            Boolean nonCustom = false;
            
            for (Object f : listFields) {
                Map<String, Object> field = (Map<String, Object>)f;
                if ((Boolean)field.get('custom') == false) {
                    nonCustom = true;
                    break;
                }           
            }
            
            System.assertEquals(nonCustom, false);
        }
    }
    
    static testMethod void testProcessException()
    {
        String JSONErrorMessageString = Enghouse.processException('Error Message', 'ID');
        
        System.assertEquals('{"error":"Exception: Error Message","success":false,"id":"ID"}', JSONErrorMessageString);
    }
    
}