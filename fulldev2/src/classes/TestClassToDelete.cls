@isTest
public class TestClassToDelete 
{
    @testSetup static void toDelete(){
        User u = [select Id from USer where Name='Cast Iron Integration' limit 1];
        system.runAs(u)
        {
            system.debug(Schema.sObjectType.Project_Task__c.isUpdateable());
            system.debug(Schema.sObjectType.Project_Task__c.isAccessible()); 
            system.debug(Schema.sObjectType.Project_Task__c.isQueryable());
            system.debug(Schema.sObjectType.Project_Task__c.isSearchable());
            system.debug(Schema.sObjectType.Project_Task__c.isUndeletable());
            
            system.debug(Schema.sObjectType.User.fields.Contact_Vendor_ID__c.isUpdateable());
            system.debug(Schema.sObjectType.User.fields.Contact_Vendor_ID__c.isAccessible()); 
            //system.debug(Schema.sObjectType.User.fields.Contact_Vendor_ID__c.isQueryable());
            //system.debug(Schema.sObjectType.User.fields.Contact_Vendor_ID__c.isSearchable());
           // system.debug(Schema.sObjectType.User.fields.Contact_Vendor_ID__c.isUndeletable());
             
        }
    }
}