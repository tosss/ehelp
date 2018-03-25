@isTest(SeeAllData=true)
private class CB_CaseClosedEmailRecResponse_Test 
{
    static testMethod void myUnitTest() 
    {
        // try to create a case
        try 
        {
            String typeName = 'Tier_1';
            RecordType recType = [SELECT rt.Id from RecordType rt WHERE rt.DeveloperName =: typeName];
            
            Test.startTest(); // START
            
            Case testCase = [SELECT c.Id FROM Case c WHERE c.RecordTypeId = :recType.Id AND c.Status='Closed' LIMIT 1];
            
            EmailMessage[] newEmail = new EmailMessage[0];
            newEmail.add(new EmailMessage(FromAddress = 'jim.whitmoyer@bakertilly.com', Incoming = True, 
            ToAddress= 'ds.email2case@adp.com', Subject = 'Test email', TextBody = 'this is a test ', ParentId = testCase.Id)); 
             
            insert newEmail;
            
            Test.stopTest(); // STOP
        } 
        catch (Exception ex)
        {
            System.debug(ex);
        }
    }
}