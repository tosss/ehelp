//2016-06-13- anirudh.singh@cdk.com- Commented Role field referenced from Contact as it is nowhere used, as this field has been moved to Contact Relationship for Shared Contacts Project.
@isTest
private class contactSearchOverrideControllerTest
{
    public static testMethod void testController()
    {
        List<Contact> cc=new List<Contact>();
        
        Account a=new Account(Name='test account');
        insert a;
        
        //2016-06-13- anirudh.singh@cdk.com- Removed Role field as it is no where used in this test class or the contactSearchOverrideController.
        Contact c1=new Contact(FirstName='test', LastName='last', Email='test1@test.com', AccountId=a.Id); // 9/30
        cc.add(c1);
        
        //2016-06-13- anirudh.singh@cdk.com- Removed Role field as it is no where used in this test class or the contactSearchOverrideController.
        Contact c2=new Contact(FirstName='test', LastName='first', Email='test2@test.com', AccountId=a.Id);// 9/29
        cc.add(c2);
        
        //2016-06-13- anirudh.singh@cdk.com- Commented the below line and added a new line for using ALL_SharedContact_Helper.
        //insert cc;
        ALL_SharedContact_Helper.insertDuplicateCheck(cc);
        
        PageReference pageRef=Page.contactSearchOverride;
        Test.setCurrentPage(pageRef);
        List<Id> tempIds=new List<Id>();
        tempIds.add(c1.Id);
        test.setFixedSearchResults(tempIds);
        
        test.startTest();
        contactSearchOverrideController csoc=new contactSearchOverrideController(new ApexPages.StandardController(c1));
        csoc.contactResultsList=new List<Contact>();
        csoc.fName='';
        csoc.lName='';
        csoc.email='';
        
        csoc.searchExisting();
        csoc.newContact();
        
        csoc.email='test2@test.com';
        csoc.searchExisting();
        
        csoc.fName='a';
        csoc.lName='b';
        csoc.email='c';
        csoc.searchExisting();
        
        test.stopTest();
        
        system.assertEquals(1, csoc.contactResultsList.size());
    }
}