@isTest
public class ALL_InstalledBase_Test 
{
    @testSetUp static void setUpData()
    {
        List<sObject> settings = new List<sObject>();
        
        settings.add(new Field_Value_Conditions__c(Name='001', Identifier__c='001', sObject__c='Installed_Base__c',
                                                  Field_Name__c='Product_Code__c', EqualsTo__c=true, Field_Value__c='14.660.00'));
        settings.add(new Field_Value_Conditions__c(Name='002', Identifier__c='002', sObject__c='Installed_Base__c',
                                                  Field_Name__c='Product_Status__c', EqualsTo__c=true, Field_Value__c='Active'));
        settings.add(new Field_Value_Conditions__c(Name='003', Identifier__c='003', sObject__c='Installed_Base__c',
                                                  Field_Name__c='Product_Status__c', EqualsTo__c=true, Field_Value__c='Inactive'));
        
        settings.add(new Field_Value_Conditions__c(Name='004', Identifier__c='004', sObject__c='Installed_Base_Item__c',
                                                  Field_Name__c='Product_Code__c', EqualsTo__c=true, Field_Value__c='14.662.00'));
        settings.add(new Field_Value_Conditions__c(Name='005', Identifier__c='005', sObject__c='Installed_Base_Item__c',
                                                  Field_Name__c='Product_Status__c', EqualsTo__c=true, Field_Value__c='Active'));
        settings.add(new Field_Value_Conditions__c(Name='006', Identifier__c='006', sObject__c='Installed_Base_Item__c',
                                                  Field_Name__c='Product_Status__c', EqualsTo__c=true, Field_Value__c='Inactive'));
        
        settings.add(new ALL_CreateEntitlements__c(Name='001',sObject__c='Installed_Base__c',Entitlement_Value__c='ExpressCare Tech Support',Do_This__c='Create',Condition_Check__c='(001 AND 002)'));
        settings.add(new ALL_CreateEntitlements__c(Name='002',sObject__c='Installed_Base__c',Entitlement_Value__c='ExpressCare Tech Support',Do_This__c='Close',Condition_Check__c='(001 AND 003)'));
        settings.add(new ALL_CreateEntitlements__c(Name='003',sObject__c='Installed_Base_Item__c',Entitlement_Value__c='ExpressCare Tech Support',Do_This__c='Create',Condition_Check__c='(004 AND 005)'));
        settings.add(new ALL_CreateEntitlements__c(Name='004',sObject__c='Installed_Base_Item__c',Entitlement_Value__c='ExpressCare Tech Support',Do_This__c='Close',Condition_Check__c='(004 AND 006)'));
        
        Account newAccount = DS_TestObjects.NewAccount_Inserted();
        WebId__c newWebID = DS_TestObjects.NewWebID_Inserted();
        
        Insert settings;
        
        //test creating Entitlements
        Installed_Base__c Ib = new Installed_Base__c();
        Ib.Name = '1234567';
        Ib.Account__c = newAccount.ID;
        Ib.WebID__c = newWebID.ID;
        Ib.Product_Code__c = '14.660.00';
        Ib.Product_Status__c = 'Active';
        
        Insert Ib;
        
        Installed_Base_Item__c Ibi = new Installed_Base_Item__c();
        Ibi.Name = '1234567';
        Ibi.Installed_Base__c = Ib.ID;
        Ibi.Product_Code__c = '14.662.00';
        Ibi.Product_Status__c = 'Active';    
        
        Insert Ibi;
        
    }
    
    static testMethod void testClosingEntitlements()
    {
        Installed_Base__c Ib = [
            Select ID, Name, Product_Status__c 
            From Installed_Base__c
            Where Name='1234567' Limit 1
        ];
        
        Installed_Base_Item__c Ibi = [
            Select ID, Name, Product_Status__c 
            From Installed_Base_Item__c 
            Where Name='1234567' Limit 1
        ];
        
        Update new List<sObject> { new Installed_Base__c(Id=Ib.ID,Product_Status__c='Inactive'), 
            new Installed_Base_Item__c(Id=Ibi.ID, Product_Status__c='Inactive')};
    }

}