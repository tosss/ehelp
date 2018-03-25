@isTest
public class ALL_ParentChildRecordsGeneric_Test
{
    //Author: Anirudh Singh
    //Date  : 4th June, 2015
    //Description: This is the test class for the class ALL_ParentChildRecords_Controller.
    //This test will ensure that a generic use-case for the ParentChild component will work and its code is covered.
    
    @TestSetup static void setupTestData()
    {
        List<Account> accountList=new List<Account>();
        for(Integer i=0; i<10; i++)
        {
            Account acc=new Account();
            acc.Name='Acc Test '+i;
            accountList.add(acc);
        }
        accountList[0].Signer_Required__c=true;
        accountList[0].Signer_1_2_Signer__c='General Manager';
        accountList[0].Signer_2_2_Signer__c='Any ADP Legal Signer';
        accountList[4].Signer_Required__c=true;
        accountList[4].Signer_1_2_Signer__c='Any ADP Legal Signer';
        accountList[4].Signer_2_2_Signer__c='Client Authorized Signer';
        insert accountList;
        
        List<Contact> contactList=new List<Contact>();
        for(Account acc: accountList)
        {
            for(Integer i=0; i<10; i++)
            {
                Contact con=new Contact();
                con.FirstName='Con ';
                con.LastName='Test '+i;
                con.AccountId=acc.Id;
                contactList.add(con);
            }
        }
        contactList[1].Do_Not_Fax__c=true;
        contactList[6].Do_Not_Fax__c=true;
        insert contactList;
        
        WebID__c web1=new WebID__c();
        web1.Name='Test Web Id 1';
        web1.Account__c=accountList[0].Id;
        insert web1;
        
        Case c1=new Case();
        c1.AccountId=accountList[0].Id;
        c1.WebID__c=web1.Id;
        c1.ContactId=contactList[2].Id;
        c1.Subject='test case';
        c1.Status='Open';
        c1.Product_Category__c='Analytics';
        c1.Origin='Phone';
        c1.Origin_Type__c='Advocacy';
        c1.Priority='Standard';
        //c1.Escalation_Reason__c='Pricing/Inventory Issue';
        insert c1;
    }
    
    static testMethod void validateAccountContactSave()
    {
        system.debug('Start validateAccountContactSave---->');
        List<Account> accountList=[SELECT Id, Name FROM Account];
        List<Contact> contactList=[SELECT Id, FirstName, LastName FROM Contact];
        
        PageReference pRef=Page.ALL_RecordsView;
        Test.setCurrentPage(pRef);
        
        test.startTest();
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        ALL_RecordsViewWrapper attributesCollection=new ALL_RecordsViewWrapper();
        attributesCollection.childAPIName='Contact';
        attributesCollection.childColumnNames='FirstName, LastName, AccountId, Phone, Do_Not_Fax__c, Do_Not_Solicit__c, LastModifiedDate';
        attributesCollection.childColumnWidths='40px, 40px';
        attributesCollection.childFieldSortOrderAPINames='FirstName, LastName, AccountId';
        attributesCollection.childRelationshipName='Contacts';
        attributesCollection.childSearchEnabled=true;
        attributesCollection.createNewChildEnabled=true;
        attributesCollection.createNewParentEnabled=true;
        attributesCollection.deleteEnabled=true;
        attributesCollection.editEnabled=true;
        attributesCollection.filterConditionChild='';
        attributesCollection.filterConditionParent='';
        attributesCollection.massUpdateEnabled=true;
        attributesCollection.mode='view';
        attributesCollection.parentAPIName='Account';
        attributesCollection.parentColumnNames='Name, Account_Advocate__c, AnnualRevenue, Region__c, Accounting_Products_to_be_Sold__c, Key_Rep__c, LastModifiedDate, of_Annual_Visits_Required__c, Signer_Required__c, Customer_Gauge__c, Data_Circuit_EOT_Date__c, Legal_Entity_Last_Updated__c';
        attributesCollection.parentColumnWidths='60px, 60px, 40px, 90px';
        attributesCollection.parentFieldSortOrderAPINames='AnnualRevenue, Region__c';
        attributesCollection.quickSaveEnabled=true;
        attributesCollection.redirectURL='google.com';
        attributesCollection.saveEnabled=true;
        attributesCollection.parentRequiresChildren=true;
        parentChildRef.fetchAllAttributes=attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ColumnAndWidthsWrapper> childColsWidths=parentChildRef.displayChildColumnsAndWidthList;
        List<ALL_ParentChildRecords_Controller.ColumnAndWidthsWrapper> parentColsWidths=parentChildRef.displayParentColumnsAndWidthList;
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        parentChildRef.displayQueryResult=queryResult;
        
        queryResult[0].parentSelected=true;
        queryResult[1].parentSelected=true;
        
        queryResult[0].childRecords[0].childSelected=true;
        queryResult[0].childRecords[1].childSelected=true;
        queryResult[1].childRecords[0].childSelected=true;
        queryResult[1].childRecords[1].childSelected=true;
        
        queryResult[0].parentRecord.put('Account_Advocate__c', UserInfo.getUserId());
        queryResult[0].parentRecord.put('Annual_Revenue__c', 1000000);
        queryResult[0].parentRecord.put('Region__c', 'Enterprise');
        queryResult[1].parentRecord.put('Account_Advocate__c', UserInfo.getUserId());
        queryResult[1].parentRecord.put('Annual_Revenue__c', 9000000);
        queryResult[1].parentRecord.put('Region__c', 'Central North');
        
        queryResult[0].childRecords[0].childRecord.put('Do_Not_Fax__c', true);
        queryResult[0].childRecords[0].childRecord.put('Phone', '9898798789');
        queryResult[0].childRecords[1].childRecord.put('Do_Not_Fax__c', false);
        queryResult[0].childRecords[1].childRecord.put('Phone', '9899999999');
        queryResult[1].childRecords[0].childRecord.put('Do_Not_Fax__c', true);
        queryResult[1].childRecords[0].childRecord.put('Phone', '6666666666');
        queryResult[1].childRecords[1].childRecord.put('Do_Not_Fax__c', false);
        parentChildRef.saveMethod(); //Quick Save Scenario
        
        queryResult[1].parentRecord.put('Signer_Required__c', true);
        queryResult[1].parentRecord.put('Signer_1_2_Signer__c', '');
        queryResult[1].parentRecord.put('Signer_2_2_Signer__c', '');
        queryResult[1].childRecords[1].childRecord.put('FirstName', '');
        pRef.getParameters().put('saveScenario', 'Save'); //Save Scenario
        parentChildRef.saveMethod();
        test.stopTest();
        system.debug('End validateAccountContactSave---->');
    }
    
    static testMethod void validateAccountContactSaveNewRec()
    {
        system.debug('Start validateAccountContactSaveNewRec---->');
        List<Account> accountList=[SELECT Id, Name FROM Account];
        List<Contact> contactList=[SELECT Id, FirstName, LastName FROM Contact];
        
        PageReference pRef=Page.ALL_RecordsView;
        Test.setCurrentPage(pRef);
        
        test.startTest();
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        ALL_RecordsViewWrapper attributesCollection=new ALL_RecordsViewWrapper();
        attributesCollection.childAPIName='Contact';
        attributesCollection.childColumnNames='FirstName, LastName, AccountId, Phone, Do_Not_Fax__c, Do_Not_Solicit__c, LastModifiedDate';
        attributesCollection.childColumnWidths='40px, 40px';
        attributesCollection.childFieldSortOrderAPINames='FirstName, LastName, AccountId';
        attributesCollection.childRelationshipName='Contacts';
        attributesCollection.childSearchEnabled=true;
        attributesCollection.createNewChildEnabled=true;
        attributesCollection.createNewParentEnabled=true;
        attributesCollection.deleteEnabled=true;
        attributesCollection.editEnabled=true;
        attributesCollection.filterConditionChild='';
        attributesCollection.filterConditionParent='';
        attributesCollection.massUpdateEnabled=true;
        attributesCollection.mode='view';
        attributesCollection.parentAPIName='Account';
        attributesCollection.parentColumnNames='Name, Account_Advocate__c, AnnualRevenue, Region__c, Accounting_Products_to_be_Sold__c, Key_Rep__c, LastModifiedDate, of_Annual_Visits_Required__c, Signer_Required__c, Customer_Gauge__c, Data_Circuit_EOT_Date__c, Legal_Entity_Last_Updated__c';
        attributesCollection.parentColumnWidths='60px, 60px, 40px, 90px';
        attributesCollection.parentFieldSortOrderAPINames='AnnualRevenue, Region__c';
        attributesCollection.quickSaveEnabled=true;
        attributesCollection.redirectURL='google.com';
        attributesCollection.saveEnabled=true;
        attributesCollection.parentRequiresChildren=true;
        parentChildRef.fetchAllAttributes=attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ColumnAndWidthsWrapper> childColsWidths=parentChildRef.displayChildColumnsAndWidthList;
        List<ALL_ParentChildRecords_Controller.ColumnAndWidthsWrapper> parentColsWidths=parentChildRef.displayParentColumnsAndWidthList;
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        
        parentChildRef.createNewParent();
        queryResult[0].parentRecord.put('Name', 'Acc Test 11');
        parentChildRef.saveMethod();
        
        parentChildRef.parentId=String.valueOf(queryResult[6].parentRecord.get('Id'));
        parentChildRef.createNewChild();
        
        parentChildRef.parentId=String.valueOf(queryResult[9].parentRecord.get('Id'));
        parentChildRef.createNewChild();
        
        parentChildRef.parentId=String.valueOf(queryResult[9].parentRecord.get('Id'));
        parentChildRef.createNewChild();
        
        queryResult[6].childRecords[0].childRecord.put('FirstName', '');
        queryResult[6].childRecords[0].childRecord.put('LastName', 'Test 1');
        queryResult[9].childRecords[0].childRecord.put('FirstName', 'Con');
        queryResult[9].childRecords[0].childRecord.put('LastName', 'Test 1');
        queryResult[9].childRecords[1].childRecord.put('FirstName', 'Con');
        queryResult[9].childRecords[1].childRecord.put('LastName', 'Test 2');
        pRef.getParameters().put('saveScenario', 'Save');
        parentChildRef.saveMethod(); //Save Scenario
        
        parentChildRef.saveAndCloseMethod();
        
        parentChildRef.cancelMethod();
        
        parentChildRef.reloadMethod();
        test.stopTest();
        system.debug('End validateAccountContactSaveNewRec---->');
    }
    
    static testMethod void validateAccountContactMassUpdate()
    {
        system.debug('Start validateAccountContactMassUpdate---->');
        List<Account> accountList=[SELECT Id, Name FROM Account];
        List<Contact> contactList=[SELECT Id, FirstName, LastName FROM Contact];
        
        PageReference pRef=Page.ALL_RecordsView;
        Test.setCurrentPage(pRef);
        
        test.startTest();
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        ALL_RecordsViewWrapper attributesCollection=new ALL_RecordsViewWrapper();
        attributesCollection.childAPIName='Contact';
        attributesCollection.childColumnNames='FirstName, LastName, AccountId, Phone, Do_Not_Fax__c, Do_Not_Solicit__c, LastModifiedDate';
        attributesCollection.childColumnWidths='40px, 40px';
        attributesCollection.childFieldSortOrderAPINames='FirstName, LastName, AccountId';
        attributesCollection.childRelationshipName='Contacts';
        attributesCollection.childSearchEnabled=true;
        attributesCollection.createNewChildEnabled=true;
        attributesCollection.createNewParentEnabled=true;
        attributesCollection.deleteEnabled=true;
        attributesCollection.editEnabled=true;
        attributesCollection.filterConditionChild='';
        attributesCollection.filterConditionParent='';
        attributesCollection.massUpdateEnabled=true;
        attributesCollection.mode='view';
        attributesCollection.parentAPIName='Account';
        attributesCollection.parentColumnNames='Name, Account_Advocate__c, AnnualRevenue, Region__c, Accounting_Products_to_be_Sold__c, Key_Rep__c, LastModifiedDate, of_Annual_Visits_Required__c, Signer_Required__c, Customer_Gauge__c, Data_Circuit_EOT_Date__c, Legal_Entity_Last_Updated__c';
        attributesCollection.parentColumnWidths='60px, 60px, 40px, 90px';
        attributesCollection.parentFieldSortOrderAPINames='AnnualRevenue, Region__c';
        attributesCollection.quickSaveEnabled=true;
        attributesCollection.redirectURL='google.com';
        attributesCollection.saveEnabled=true;
        attributesCollection.parentRequiresChildren=true;
        attributesCollection.childDisableCheckField='Do_Not_Fax__c';
        attributesCollection.childFieldsToDisableForRow='FirstName, LastName';
        attributesCollection.parentDisableCheckField='Signer_Required__c';
        attributesCollection.parentFieldsToDisableForRow='AnnualRevenue, Region__c, Accounting_Products_to_be_Sold__c';
        parentChildRef.fetchAllAttributes=attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ColumnAndWidthsWrapper> childColsWidths=parentChildRef.displayChildColumnsAndWidthList;
        List<ALL_ParentChildRecords_Controller.ColumnAndWidthsWrapper> parentColsWidths=parentChildRef.displayParentColumnsAndWidthList;
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        
        //Parent Mass Update
        parentChildRef.displayParentSelectionPanel();
        String objectTypeParent='Account';
        List<String> idListParent=new List<Id>();
        idListParent.add(String.valueOf(queryResult[1].parentRecord.get('Id')));
        idListParent.add(String.valueOf(queryResult[3].parentRecord.get('Id')));
        idListParent.add(String.valueOf(queryResult[4].parentRecord.get('Id')));
        idListParent.add(String.valueOf(queryResult[5].parentRecord.get('Id')));
        List<String> fieldNamesListParent=new List<String>();
        fieldNamesListParent.add('Name');
        fieldNamesListParent.add('Region__c');
        fieldNamesListParent.add('of_Annual_Visits_Required__c');
        fieldNamesListParent.add('Signer_Required__c');
        fieldNamesListParent.add('Account_Advocate__c');
        List<String> updatedfieldValuesParent=new List<String>();
        updatedfieldValuesParent.add('Acc Test Mass Update 1');
        updatedfieldValuesParent.add('East Europe');
        updatedfieldValuesParent.add('1');
        updatedfieldValuesParent.add('1');
        updatedfieldValuesParent.add(UserInfo.getUserId());
        
        List<String> parentRecordIdsToBeDisabledList=new List<String>();
        parentRecordIdsToBeDisabledList.add(String.valueOf(queryResult[0].parentRecord.get('Id')));
        parentRecordIdsToBeDisabledList.add(String.valueOf(queryResult[3].parentRecord.get('Id')));
        
        List<String> parentFieldsToDisableForRowList=new List<String>();
        parentFieldsToDisableForRowList.add('Name');
        parentFieldsToDisableForRowList.add('Region');
        
        Map<String, String> massUpdateParent=ALL_ParentChildRecords_Controller.MassUpdate(objectTypeParent, idListParent, fieldNamesListParent, 
                                                                                          updatedfieldValuesParent, parentRecordIdsToBeDisabledList, 
                                                                                          parentFieldsToDisableForRowList);
        pRef.getParameters().put('recordsList', JSON.serialize(massUpdateParent));
        pRef.getParameters().put('typeOfUpdateScenario', 'parentRec');
        parentChildRef.errorOnRecords();
        
        //Child Mass Update
        parentChildRef.displayChildSelectionPanel();
        String objectTypeChild='Contact';
        List<String> idListChild=new List<Id>();
        idListChild.add(String.valueOf(queryResult[1].childRecords[0].childRecord.get('Id')));
        idListChild.add(String.valueOf(queryResult[3].childRecords[0].childRecord.get('Id')));
        idListChild.add(String.valueOf(queryResult[4].childRecords[0].childRecord.get('Id')));
        idListChild.add(String.valueOf(queryResult[5].childRecords[0].childRecord.get('Id')));
        List<String> fieldNamesListChild=new List<String>();
        fieldNamesListChild.add('Phone');
        fieldNamesListChild.add('FirstName');
        fieldNamesListChild.add('Do_Not_Fax__c');
        List<String> updatedfieldValuesChild=new List<String>();
        updatedfieldValuesChild.add('94389583989');
        updatedfieldValuesChild.add('');
        updatedfieldValuesChild.add('0');
        
        List<String> childRecordIdsToBeDisabledList=new List<String>();
        childRecordIdsToBeDisabledList.add(String.valueOf(queryResult[0].childRecords[1].childRecord.get('Id')));
        childRecordIdsToBeDisabledList.add(String.valueOf(queryResult[1].childRecords[0].childRecord.get('Id')));
        
        List<String> childFieldsToDisableForRowList=new List<String>();
        childFieldsToDisableForRowList.add('Phone');
        childFieldsToDisableForRowList.add('LastName');
        
        Map<String, String> massUpdateChild=ALL_ParentChildRecords_Controller.MassUpdate(objectTypeChild, idListChild, fieldNamesListChild, 
                                                                                         updatedfieldValuesChild, childRecordIdsToBeDisabledList, 
                                                                                         childFieldsToDisableForRowList);
        pRef.getParameters().put('recordsList', JSON.serialize(massUpdateChild));
        pRef.getParameters().put('typeOfUpdateScenario', 'childRec');
        parentChildRef.errorOnRecords();
        parentChildRef.massUpdateMethod();
        test.stopTest();
        system.debug('End validateAccountContactMassUpdate---->');
    }
    
    static testMethod void accountContactFieldUpdateViewMode()
    {
        system.debug('Start accountContactFieldUpdateViewMode---->');
        List<Account> accountList=[SELECT Id, Name FROM Account];
        List<Contact> contactList=[SELECT Id, FirstName, LastName FROM Contact];
        
        PageReference pRef=Page.ALL_RecordsView;
        Test.setCurrentPage(pRef);
        
        test.startTest();
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        ALL_RecordsViewWrapper attributesCollection=new ALL_RecordsViewWrapper();
        attributesCollection.childAPIName='Contact';
        attributesCollection.childColumnNames='FirstName, LastName, AccountId, Phone, Do_Not_Fax__c, Do_Not_Solicit__c, LastModifiedDate';
        attributesCollection.childColumnWidths='40px, 40px';
        attributesCollection.childFieldSortOrderAPINames='FirstName, LastName, AccountId';
        attributesCollection.childRelationshipName='Contacts';
        attributesCollection.childSearchEnabled=true;
        attributesCollection.createNewChildEnabled=true;
        attributesCollection.createNewParentEnabled=true;
        attributesCollection.deleteEnabled=true;
        attributesCollection.editEnabled=true;
        attributesCollection.filterConditionChild='';
        attributesCollection.filterConditionParent='';
        attributesCollection.massUpdateEnabled=true;
        attributesCollection.mode='view';
        attributesCollection.parentAPIName='Account';
        attributesCollection.parentColumnNames='Name, Account_Advocate__c, AnnualRevenue, Region__c, Accounting_Products_to_be_Sold__c, Key_Rep__c, LastModifiedDate, of_Annual_Visits_Required__c, Signer_Required__c, Customer_Gauge__c, Data_Circuit_EOT_Date__c, Legal_Entity_Last_Updated__c';
        attributesCollection.parentColumnWidths='60px, 60px, 40px, 90px';
        attributesCollection.parentFieldSortOrderAPINames='AnnualRevenue, Region__c';
        attributesCollection.quickSaveEnabled=true;
        attributesCollection.redirectURL='google.com';
        attributesCollection.saveEnabled=true;
        attributesCollection.parentRequiresChildren=true;
        parentChildRef.fetchAllAttributes=attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ColumnAndWidthsWrapper> childColsWidths=parentChildRef.displayChildColumnsAndWidthList;
        List<ALL_ParentChildRecords_Controller.ColumnAndWidthsWrapper> parentColsWidths=parentChildRef.displayParentColumnsAndWidthList;
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        
        pRef.getParameters().put('fieldName', 'Region');
        pRef.getParameters().put('recordId', String.valueOf(queryResult[7].parentRecord.get('Id')));
        parentChildRef.displayFieldUpdatePanel();
        parentChildRef.objectToUpdateInViewMode.put('Region__c', 'Europe');
        parentChildRef.fieldUpdateInViewMode();
        
        pRef.getParameters().put('fieldName', 'Do Not Fax');
        pRef.getParameters().put('recordId', String.valueOf(queryResult[4].childRecords[0].childRecord.get('Id')));
        parentChildRef.displayFieldUpdatePanel();
        parentChildRef.closeFieldUpdatePanel();
        
        pRef.getParameters().put('fieldName', 'First Name');
        pRef.getParameters().put('recordId', String.valueOf(queryResult[4].childRecords[0].childRecord.get('Id')));
        parentChildRef.displayFieldUpdatePanel();
        parentChildRef.objectToUpdateInViewMode.put('FirstName', '');
        parentChildRef.fieldUpdateInViewMode();
        test.stopTest();
        system.debug('End accountContactFieldUpdateViewMode---->');
    }
    
    static testMethod void validateAccountContactDelete()
    {
        system.debug('Start validateAccountContactDelete---->');
        List<Account> accountList=[SELECT Id, Name FROM Account];
        List<Contact> contactList=[SELECT Id, FirstName, LastName FROM Contact];
        
        PageReference pRef=Page.ALL_RecordsView;
        Test.setCurrentPage(pRef);
        
        test.startTest();
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        ALL_RecordsViewWrapper attributesCollection=new ALL_RecordsViewWrapper();
        attributesCollection.childAPIName='Contact';
        attributesCollection.childColumnNames='FirstName, LastName, AccountId, Phone, Do_Not_Fax__c, Do_Not_Solicit__c, LastModifiedDate';
        attributesCollection.childColumnWidths='40px, 40px';
        attributesCollection.childFieldSortOrderAPINames='FirstName, LastName, AccountId';
        attributesCollection.childRelationshipName='Contacts';
        attributesCollection.childSearchEnabled=true;
        attributesCollection.createNewChildEnabled=true;
        attributesCollection.createNewParentEnabled=true;
        attributesCollection.deleteEnabled=true;
        attributesCollection.editEnabled=true;
        attributesCollection.filterConditionChild='';
        attributesCollection.filterConditionParent='';
        attributesCollection.massUpdateEnabled=true;
        attributesCollection.mode='view';
        attributesCollection.parentAPIName='Account';
        attributesCollection.parentColumnNames='Name, Account_Advocate__c, AnnualRevenue, Region__c, Accounting_Products_to_be_Sold__c, Key_Rep__c, LastModifiedDate, of_Annual_Visits_Required__c, Signer_Required__c, Customer_Gauge__c, Data_Circuit_EOT_Date__c, Legal_Entity_Last_Updated__c';
        attributesCollection.parentColumnWidths='60px, 60px, 40px, 90px';
        attributesCollection.parentFieldSortOrderAPINames='AnnualRevenue, Region__c';
        attributesCollection.quickSaveEnabled=true;
        attributesCollection.redirectURL='google.com';
        attributesCollection.saveEnabled=true;
        attributesCollection.parentRequiresChildren=true;
        parentChildRef.fetchAllAttributes=attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ColumnAndWidthsWrapper> childColsWidths=parentChildRef.displayChildColumnsAndWidthList;
        List<ALL_ParentChildRecords_Controller.ColumnAndWidthsWrapper> parentColsWidths=parentChildRef.displayParentColumnsAndWidthList;
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        
        //Delete Scenario
        List<Id> childRecordsToBeDeleted=new List<Id>();
        childRecordsToBeDeleted.add(String.valueOf(queryResult[5].childRecords[0].childRecord.get('Id')));
        Map<String, String> childRecordsWithErrorMessagesMap=ALL_ParentChildRecords_Controller.deleteRecords(childRecordsToBeDeleted);
        pRef.getParameters().put('recordsList', JSON.serialize(childRecordsWithErrorMessagesMap));
        pRef.getParameters().put('typeOfUpdateScenario', 'childRec');
        parentChildRef.errorOnRecords();
        
        List<Id> parentRecordsToBeDeleted=new List<Id>();
        parentRecordsToBeDeleted.add(String.valueOf(queryResult[6].parentRecord.get('Id')));
        parentRecordsToBeDeleted.add(String.valueOf(queryResult[7].parentRecord.get('Id')));
        parentRecordsToBeDeleted.add(String.valueOf(queryResult[9].parentRecord.get('Id')));
        Map<String, String> parentRecordsWithErrorMessagesMap=ALL_ParentChildRecords_Controller.deleteRecords(parentRecordsToBeDeleted);
        pRef.getParameters().put('recordsList', JSON.serialize(parentRecordsWithErrorMessagesMap));
        pRef.getParameters().put('typeOfUpdateScenario', 'parentRec');
        parentChildRef.errorOnRecords();
        test.stopTest();
        system.debug('End validateAccountContactDelete---->');
    }
    
    static testMethod void miscellaneousValidations()
    {
        system.debug('Start miscellaneousValidations---->');
        List<Account> accountList=[SELECT Id, Name FROM Account];
        List<Contact> contactList=[SELECT Id, FirstName, LastName FROM Contact];
        
        PageReference pRef=Page.ALL_RecordsView;
        Test.setCurrentPage(pRef);
        
        test.startTest();
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        ALL_RecordsViewWrapper attributesCollection=new ALL_RecordsViewWrapper();
        attributesCollection.childAPIName='Contact';
        attributesCollection.childColumnNames='FirstName, LastName, AccountId, Phone, Do_Not_Fax__c, Do_Not_Solicit__c, LastModifiedDate';
        attributesCollection.childColumnWidths='40px, 40px';
        attributesCollection.childFieldSortOrderAPINames='FirstName, LastName, AccountId';
        attributesCollection.childRelationshipName='Contacts';
        attributesCollection.childSearchEnabled=true;
        attributesCollection.createNewChildEnabled=true;
        attributesCollection.createNewParentEnabled=true;
        attributesCollection.deleteEnabled=true;
        attributesCollection.editEnabled=true;
        attributesCollection.filterConditionChild='';
        attributesCollection.filterConditionParent='';
        attributesCollection.massUpdateEnabled=true;
        attributesCollection.mode='view';
        attributesCollection.parentAPIName='Account';
        attributesCollection.parentColumnNames='Name, Account_Advocate__c, AnnualRevenue, Region__c, Accounting_Products_to_be_Sold__c, Key_Rep__c, LastModifiedDate, of_Annual_Visits_Required__c, Signer_Required__c, Customer_Gauge__c, Data_Circuit_EOT_Date__c, Legal_Entity_Last_Updated__c';
        attributesCollection.parentColumnWidths='60px, 60px, 40px, 90px';
        attributesCollection.parentFieldSortOrderAPINames='AnnualRevenue, Region__c';
        attributesCollection.quickSaveEnabled=true;
        attributesCollection.redirectURL='google.com';
        attributesCollection.saveEnabled=true;
        attributesCollection.parentRequiresChildren=true;
        parentChildRef.fetchAllAttributes=attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ColumnAndWidthsWrapper> childColsWidths=parentChildRef.displayChildColumnsAndWidthList;
        List<ALL_ParentChildRecords_Controller.ColumnAndWidthsWrapper> parentColsWidths=parentChildRef.displayParentColumnsAndWidthList;
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        
        parentChildRef.createNewParentWGrandparent();
		List<SelectOption> displayGrandparentOptions=parentChildRef.displayGrandparentOptions;
        parentChildRef.displayGrandparentOptions=displayGrandparentOptions;
        String grandParentLabel=parentChildRef.grandparentLabel;
        Boolean displayGrandParentPanel=parentChildRef.displayGrandParentPanel;
        parentChildRef.closeGrandparentPanel();
        parentChildRef.cancelGrandparentPanel();
        
        String lookupFieldValue=ALL_ParentChildRecords_Controller.fetchUserId('anirudh singh', 'Account', 'Account_Advocate__c');
        
        //dataAvailable=false
        ALL_ParentChildRecords_Controller parentChildRef1=new ALL_ParentChildRecords_Controller();
        attributesCollection=new ALL_RecordsViewWrapper();
        attributesCollection.dataAvailable=false;
        parentChildRef1.fetchAllAttributes=attributesCollection;
        parentChildRef1.pageController=new ALL_PageBase_Controller();
        
        //dataAvailable=true and no attributes passed
        ALL_ParentChildRecords_Controller parentChildRef2=new ALL_ParentChildRecords_Controller();
        attributesCollection=new ALL_RecordsViewWrapper();
        attributesCollection.dataAvailable=true;
        parentChildRef2.fetchAllAttributes=attributesCollection;
        parentChildRef2.pageController=new ALL_PageBase_Controller();
        
        //Only the required attributes are passed
        ALL_ParentChildRecords_Controller parentChildRef3=new ALL_ParentChildRecords_Controller();
        attributesCollection=new ALL_RecordsViewWrapper();
        attributesCollection.childAPIName='Contact';
        attributesCollection.childColumnNames='FirstName, LastName, AccountId, Phone, Do_Not_Fax__c, Do_Not_Solicit__c, LastModifiedDate';
        attributesCollection.childColumnWidths='';
        attributesCollection.childFieldSortOrderAPINames='LastName, AccountId';
        attributesCollection.childRelationshipName='Contacts';
        attributesCollection.filterConditionChild='';
        attributesCollection.filterConditionParent='';
        attributesCollection.mode='';
        attributesCollection.parentAPIName='Account';
        attributesCollection.parentColumnNames='Name, Account_Advocate__c, AnnualRevenue, Region__c, Accounting_Products_to_be_Sold__c, Key_Rep__c, LastModifiedDate, of_Annual_Visits_Required__c, Signer_Required__c, Customer_Gauge__c, Data_Circuit_EOT_Date__c, Legal_Entity_Last_Updated__c';
        attributesCollection.parentColumnWidths='Account_Advocate__c, AnnualRevenue';
        attributesCollection.parentFieldSortOrderAPINames='';
        attributesCollection.redirectURL='';
        parentChildRef3.fetchAllAttributes=attributesCollection;
        parentChildRef3.pageController=new ALL_PageBase_Controller();
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult3=parentChildRef3.displayQueryResult;
        
        ALL_ParentChildRecords_Controller parentChildRef4=new ALL_ParentChildRecords_Controller();
        attributesCollection=new ALL_RecordsViewWrapper();
        attributesCollection.childAPIName='Contact';
        attributesCollection.childColumnNames='FirstName, LastName, AccountId, Phone, Do_Not_Fax__c, Do_Not_Solicit__c, LastModifiedDate';
        attributesCollection.childColumnWidths='40px, 40px';
        attributesCollection.childFieldSortOrderAPINames='FirstName, LastName, AccountId';
        attributesCollection.childRelationshipName='Contacts';
        attributesCollection.childSearchEnabled=true;
        attributesCollection.createNewChildEnabled=true;
        attributesCollection.createNewParentEnabled=true;
        attributesCollection.deleteEnabled=true;
        attributesCollection.editEnabled=true;
        attributesCollection.filterConditionChild='limit 10';
        attributesCollection.filterConditionParent='limit 10';
        attributesCollection.massUpdateEnabled=true;
        attributesCollection.mode='view';
        attributesCollection.parentAPIName='Account';
        attributesCollection.parentColumnNames='Name, Account_Advocate__c, AnnualRevenue, Region__c, Accounting_Products_to_be_Sold__c, Key_Rep__c, LastModifiedDate, of_Annual_Visits_Required__c, Signer_Required__c, Customer_Gauge__c, Data_Circuit_EOT_Date__c, Legal_Entity_Last_Updated__c';
        attributesCollection.parentColumnWidths='60px, 60px, 40px, 90px';
        attributesCollection.parentFieldSortOrderAPINames='AnnualRevenue, Region__c';
        attributesCollection.quickSaveEnabled=true;
        attributesCollection.redirectURL='google.com';
        attributesCollection.saveEnabled=true;
        parentChildRef4.fetchAllAttributes=attributesCollection;
        parentChildRef4.pageController=new ALL_PageBase_Controller();
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult4=parentChildRef4.displayQueryResult;
        
        ALL_ParentChildRecords_Controller parentChildRef5=new ALL_ParentChildRecords_Controller();
        attributesCollection=new ALL_RecordsViewWrapper();
        attributesCollection.childAPIName='Contact';
        attributesCollection.childColumnNames='FirstName, LastName, AccountId, Phone, Do_Not_Fax__c, Do_Not_Solicit__c, LastModifiedDate';
        attributesCollection.childColumnWidths='40px, 40px';
        attributesCollection.childFieldSortOrderAPINames='FirstName, LastName, AccountId';
        attributesCollection.childRelationshipName='Contacts';
        attributesCollection.childSearchEnabled=true;
        attributesCollection.createNewChildEnabled=true;
        attributesCollection.createNewParentEnabled=true;
        attributesCollection.deleteEnabled=true;
        attributesCollection.editEnabled=true;
        attributesCollection.filterConditionChild='where Do_Not_Fax__c=true and Do_Not_Solicit__c=true limit 10';
        attributesCollection.filterConditionParent='where Account_Advocate__c!=Null limit 10';
        attributesCollection.massUpdateEnabled=true;
        attributesCollection.mode='edit';
        attributesCollection.parentAPIName='Account';
        attributesCollection.parentColumnNames='Name, Account_Advocate__c, AnnualRevenue, Region__c, Accounting_Products_to_be_Sold__c, Key_Rep__c, LastModifiedDate, of_Annual_Visits_Required__c, Signer_Required__c, Customer_Gauge__c, Data_Circuit_EOT_Date__c, Legal_Entity_Last_Updated__c';
        attributesCollection.parentColumnWidths='60px, 60px, 40px, 90px';
        attributesCollection.parentFieldSortOrderAPINames='AnnualRevenue, Region__c';
        attributesCollection.quickSaveEnabled=true;
        attributesCollection.redirectURL='google.com';
        attributesCollection.saveEnabled=true;
        parentChildRef5.fetchAllAttributes=attributesCollection;
        parentChildRef5.pageController=new ALL_PageBase_Controller();
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult5=parentChildRef5.displayQueryResult;
        
        ALL_ParentChildRecords_Controller parentChildRef6=new ALL_ParentChildRecords_Controller();
        attributesCollection=new ALL_RecordsViewWrapper();
        attributesCollection.childAPIName='Contact';
        attributesCollection.childColumnNames='FirstName, LastName, AccountId, Phone, Do_Not_Fax__c, Do_Not_Solicit__c, LastModifiedDate';
        attributesCollection.childColumnWidths='40px, 40px';
        attributesCollection.childFieldSortOrderAPINames='FirstName, LastName, AccountId';
        attributesCollection.childRelationshipName='Contacts';
        attributesCollection.childSearchEnabled=true;
        attributesCollection.createNewChildEnabled=true;
        attributesCollection.createNewParentEnabled=true;
        attributesCollection.deleteEnabled=true;
        attributesCollection.editEnabled=true;
        attributesCollection.filterConditionChild='where Do_Not_Fax__c=true and Do_Not_Solicit__c=true';
        attributesCollection.filterConditionParent='where Account_Advocate__c!=Null';
        attributesCollection.massUpdateEnabled=true;
        attributesCollection.mode='view';
        attributesCollection.parentAPIName='Account';
        attributesCollection.parentColumnNames='Name, Account_Advocate__c, AnnualRevenue, Region__c, Accounting_Products_to_be_Sold__c, Key_Rep__c, LastModifiedDate, of_Annual_Visits_Required__c, Signer_Required__c, Customer_Gauge__c, Data_Circuit_EOT_Date__c, Legal_Entity_Last_Updated__c';
        attributesCollection.parentColumnWidths='60px, 60px, 40px, 90px';
        attributesCollection.parentFieldSortOrderAPINames='AnnualRevenue, Region__c';
        attributesCollection.quickSaveEnabled=true;
        attributesCollection.redirectURL='google.com';
        attributesCollection.saveEnabled=true;
        parentChildRef6.fetchAllAttributes=attributesCollection;
        parentChildRef6.pageController=new ALL_PageBase_Controller();
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult6=parentChildRef6.displayQueryResult;
        
        ALL_ParentChildRecords_Controller parentChildRef7=new ALL_ParentChildRecords_Controller();
        attributesCollection=new ALL_RecordsViewWrapper();
        attributesCollection.childAPIName='Contact';
        attributesCollection.childColumnNames='FirstName, LastName, AccountId, Phone, Do_Not_Fax__c, Do_Not_Solicit__c, LastModifiedDate';
        attributesCollection.childRelationshipName='Contacts';
        attributesCollection.parentAPIName='test';
        attributesCollection.parentColumnNames='Name, Account_Advocate__c, AnnualRevenue, Region__c, Accounting_Products_to_be_Sold__c, Key_Rep__c, LastModifiedDate, of_Annual_Visits_Required__c, Signer_Required__c, Customer_Gauge__c, Data_Circuit_EOT_Date__c, Legal_Entity_Last_Updated__c';
        parentChildRef7.fetchAllAttributes=attributesCollection;
        parentChildRef7.pageController=new ALL_PageBase_Controller();
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult7=parentChildRef7.displayQueryResult;
        
        //2015-07-29- anirudh.singh@cdk.com- Added this to cover fetchColumnLabels method.
        String parentColumnAPINames='Name, Account_Advocate__c, AnnualRevenue';
        List<String> parentColumnLabels=new List<String>{'Account Name', 'Account Advocate', 'Annual Revenue'};
        List<String> fetchParentColumnLabels=ALL_ParentChildRecords_Controller.fetchColumnLabels('Account', parentColumnAPINames);
        system.assertEquals(parentColumnLabels, fetchParentColumnLabels);
        test.stopTest();
        system.debug('End miscellaneousValidations---->');
    }
}