/*------------------------------------------------------------
Author:      Alexander Daria
Company:     Cloud Sherpas
Description: IMP_CheckList_Controller test class
History
09/01/14     Alexander Daria        Created
11/18/14     Samuel Oberes          Implemented IMP_TestFactory_Helper methods
------------------------------------------------------------*/
@isTest
public class IMP_CheckList_Controller_Test {
    static testMethod void ValidateCheckList() 
    {
        
        List<Project__c> ListPrj = new List<Project__c>{};
        List<Project_Checklist__c> ListPrjCheckList = new list<Project_Checklist__c>();
        List<Checklist_Category__c> ListPrjCategory = new list<Checklist_Category__c>();
        List<Checklist_Item__c> ListChklistItem = new List<Checklist_Item__c>{};
        List<Checklist_Answer__c> ListChklistAnswer = new List<Checklist_Answer__c>{};
                
                
        test.startTest();
        
        
        
        //insert Checklist Category
        Integer cnt = 1;
        for (cnt = 1; cnt< 7;cnt++) {
            Checklist_Category__c testchkCategory = IMP_TestFactory_Helper.buildChecklistCategory();
            testchkCategory.Name = 'CAT' + cnt;
            ListPrjCategory.add(testchkCategory);  
        }
        insert ListPrjCategory;

        //insert New Project
        Project__c testPrj = IMP_TestFactory_Helper.buildProject(1);
        testPrj.Name = 'Test Project';
        ListPrj.add(testPrj);
        insert ListPrj;
        
        //Select Project Checklist 
        List<Project_Checklist__c> testPrjCheckList = [Select Project__c,Item_Category__c from Project_Checklist__c];  
        
        //insert Checklist Item   
        for (Checklist_Category__c  testchkCategory:ListPrjCategory) {
            Checklist_Item__c testChkListItem = IMP_TestFactory_Helper.buildChecklistItem(testchkCategory.Id);
            testChkListItem.Active__c = true;
            ListChklistItem.add(testChkListItem);
        }
        insert ListChklistItem; 
        
        //insert Checklist Answer   
        for (Project_Checklist__c prjCheck : testPrjCheckList) {
            Checklist_Answer__c testChkAnswer = IMP_TestFactory_Helper.buildChecklistAnswer(prjCheck.Id);
            testChkAnswer.Response__c = 'testing';
            testChkAnswer.URL_Location__c = 'www.gmail.com';
            ListChklistAnswer.add(testChkAnswer);
            
            Checklist_Answer__c testChkAnswer2 = IMP_TestFactory_Helper.buildChecklistAnswer(prjCheck.Id);
            testChkAnswer2.Response__c = 'testing';
            testChkAnswer2.URL_Location__c = 'www.gmail.com';
            ListChklistAnswer.add(testChkAnswer2);
        }
        insert ListChklistAnswer;
        
        //set page to Standard Controller Project__C
        ApexPages.StandardController sc = new ApexPages.StandardController(testPrj);
        IMP_CheckList_Controller controller = new IMP_CheckList_Controller(sc);
        
        //set Page
        PageReference pageRef = Page.IMP_ChecklistPage;
        PageRef.getParameters().put('id', testPrj.Id);
        Test.setCurrentPage(pageRef);
        
        controller.saveRecords();
        controller.Close();
        controller.Cancel();
        controller.editRecords();
        test.stopTest();
        
        //check the data from the objects
        ListPrj = [select name from Project__c where name=:'Test Project'];
        ListChklistAnswer = [select Response__c,URl_Location__c from Checklist_Answer__c where Project_Checklist__c in:testPrjCheckList];     
        ListPrjCategory = [select name from Checklist_Category__c where name =:'CAT1'];
        
        System.assertEquals('Test Project',   ListPrj[0].Name);
        System.assertEquals('Yes',   ListChklistAnswer[0].Response__c);
        System.assertEquals('www.gmail.com', ListChklistAnswer[0].URL_Location__c);              
        System.assertEquals('CAT1', ListPrjCategory[0].name);
        System.assert(controller.isEditMode);
        
    }
}