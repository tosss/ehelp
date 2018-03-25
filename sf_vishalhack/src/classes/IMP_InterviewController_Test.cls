/*------------------------------------------------------------
Author: Hemanth Kesapragada
Description: This class is to test IMP_Interview_Controller
History:
2015-06-01 Hemanth.kesapragada@cdk.com  Created
2015-06-09 Hemanth.kesapragada@cdk.com  Added all the methods to test the component
2016-13-06 -venkata.shrivol@cdk.com -commented few methods
2016-12-05 - venkata.shrivol@cdk.com - commented the code as we no longer require it. 
------------------------------------------------------------*/
@isTest
public class IMP_InterviewController_Test 
{
    /*private static  Question_Category__c qCategory;
    private static  Discovery_Workbook_Category__c wCategory;
    private Static  SubProject__c subProjectObj;
    private Static  Account acc;
    private Static Contact contactObj1;
    private Static Contact contactObj2;
    private Static Contact contactObj3;
    private static IMP_Interview_Controller controllerObj;
    private static SubProject_Client_Contact__c clientContactObj1; 
    private static SubProject_Client_Contact__c clientContactObj2;
    private static SubProject_Client_Contact__c clientContactObj3;
    private static Discovery_Workbook_Interviewer__c interviewers;
    private static Discovery_Workbook_Interviewee__c interviewees;
    private static string customerContactRecordTypeId;
    //Initialize the variables and use the data in all methods
    static
    {
        Project__c proj = generate_Project();
        subProjectObj = generate_subProject(proj.Id);
        acc = generate_Account();
        Site_Workbook__c siteWorkbook = generate_SiteWorkbook(proj.Id,acc.Id,subProjectObj.Id);    
        qCategory = createQuestionCategory();
        wCategory = GenerateTestData_Project(siteWorkbook.Id,qCategory.Id);
        List<Question__c> question = createQuestion(wCategory.Id,qCategory.Id);
        Solution__c sol_c = createSolution(qCategory.Id);
        createProduct(sol_c.Id);
        interviewers = createInteviewer(wCategory.Id);
        interviewees = createInterviewee(wCategory.Id);
        createCustomSettings();
        customerContactRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        
        contactObj1 = IMP_TestFactory_Helper.buildContact(null);
        contactObj2 = IMP_TestFactory_Helper.buildContact(null);
        contactObj3 = IMP_TestFactory_Helper.buildContact(null);
        
        if(customerContactRecordTypeId!=null && customerContactRecordTypeId!='')
        {
        	contactObj1.RecordTypeId = customerContactRecordTypeId;  
            contactObj2.RecordTypeId = customerContactRecordTypeId;
        	contactObj3.RecordTypeId = customerContactRecordTypeId;    
        }
        
        Insert contactObj1;
        Insert contactObj2;
        Insert contactObj3;
        
        clientContactObj1 = generate_subProjectClientContact(subProjectObj.Id,contactObj1.Id);
        clientContactObj2 =  generate_subProjectClientContact(subProjectObj.Id,contactObj2.Id);
        clientContactObj3 = generate_subProjectClientContact(subProjectObj.Id,contactObj3.Id);
        
        controllerObj = new IMP_Interview_Controller();
        controllerObj.siteWorkbookCategoryId = wCategory.Id;
        controllerObj.questionCategoryId = qCategory.Id;
        controllerObj.subProjectId = subProjectObj.Id;
        controllerObj.isEditMode = true;

    }
    testmethod static void testLoad()
    {
        User testUser = IMP_TestFactory_Helper.buildUserAdmin();
        insert testUser;
        System.runAs(testUser)
        {
            controllerObj.setChosenInterviewee('');
            controllerObj.getChosenInterviewee();
            controllerObj.selectedTypeOfContact='';
            controllerObj.clientContactsOptions = null;
            controllerObj.selectedClientContacts=null;
            controllerObj.setAddChosenInterviewee('');
            controllerObj.getAddChosenInterviewee();
            controllerObj.ContactObj = null;
            Contact newContact = controllerObj.ContactObj;
            controllerObj.fetchIntervieweeMap = controllerObj.intervieweeMap;
            controllerObj.intervieweeMap = null;
            controllerObj.fetchInterviewerList = controllerObj.interviewerList;
            controllerObj.interviewerList = null;
            Discovery_Workbook_Category__c discCatObj = controllerObj.discWrkSiteCategory;
        }
    }
    testMethod static void testAddFromContacts()
    {
        //To test add interviewee method - User selected 'Add from Contacts'
        PageReference pref = Page.IMP_SiteWorkbookCategory;
        pref.getParameters().put('message','');
        controllerObj.selectedTypeOfContact = 'contacts';
        controllerObj.newContactFlag = false;
        controllerObj.captureInterviewee.Interviewee__c = contactObj1.Id;
        controllerObj.addInterviewee();
    }
    testMethod static void testAddFromContactsForErrors()
    {
        //To test addInterviewee method - errors
        controllerObj.selectedTypeOfContact = null;
        controllerObj.newContactFlag = false;
        controllerObj.captureInterviewee.Interviewee__c = contactObj1.Id;
        controllerObj.addInterviewee();
    }
    testMethod static void testFetchClientContacts()
    {
        
        //To test fetchClientContacts method
        controllerObj.fetchClientContacts();
        List<SubProject_Client_Contact__c> clientContactList =  [select Client_Contact__c,Client_Contact__r.Name ,Client_Contact__r.FirstName
                                                                 from SubProject_Client_Contact__c 
                                                                 where SubProject__c =:subProjectObj.Id];
        System.assertEquals(clientContactList.size(), controllerObj.clientContactsOptions.size());
    }
    testMethod static void testAddFromClientContacts()
    {
        
        //To test add interviewee method - User selected 'Add from SubprojectClientContacts'
        controllerObj.selectedTypeOfContact = 'clientContacts';
        controllerObj.newContactFlag = false;
        controllerObj.selectedClientContacts =  new List<String>();
        controllerObj.selectedClientContacts.add(clientContactObj1.Client_Contact__r.Id);
        controllerObj.selectedClientContacts.add(clientContactObj2.Client_Contact__r.Id);
        controllerObj.addInterviewee();
        
        
        controllerObj.selectedClientContacts =  new List<String>();
        controllerObj.selectedClientContacts.add(clientContactObj3.Client_Contact__r.Id);
        controllerObj.addInterviewee();
        
    }
    testMethod static void removeInterviewee()
    {
        //To test add interviewee method - User selected 'Add from Contacts'
        PageReference pref = Page.IMP_SiteWorkbookCategory;
        pref.getParameters().put('message','');
        controllerObj.selectedTypeOfContact = 'contacts';
        controllerObj.newContactFlag = false;
        controllerObj.captureInterviewee.Interviewee__c = contactObj1.Id;
        controllerObj.addInterviewee();
        
        //To test removeInterviewee method 
        List<Discovery_Workbook_Interviewee__c> intervieweeList = [SELECT Id FROM Discovery_Workbook_Interviewee__c limit 1];
        controllerObj.setChosenInterviewee(intervieweeList.get(0).Id);
        controllerObj.removeInterviewee();
        List<Discovery_Workbook_Interviewee__c> newIntervieweeList = [SELECT Id FROM Discovery_Workbook_Interviewee__c where id in :intervieweeList];
        System.assertEquals(newIntervieweeList.size(), 0);
        
        //To test removeInterviewee Method - errors
        controllerObj.setChosenInterviewee(null);
        controllerObj.removeInterviewee();
    }
    testMethod static void testRenderAction()
    {
        //To test renderAction method 
        controllerObj.selectedTypeOfContact = 'clientContacts';
        controllerObj.renderAction();
        
    }
    //2016-06-13 -venkata.shrivol@cdk.com -commented this method 
    /*testMethod static void testSaveNewContact()
    {
        //To test saveNewContact method
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.FirstName = 'Test';
        con.LastName = 'Demo '+acc.Id;
        con.Role__c = 'Accountant';
        if(customerContactRecordTypeId!=null && customerContactRecordTypeId!='')
        {
        	con.RecordTypeId = customerContactRecordTypeId;    
        }
        controllerObj.contactObj = con;
        PageReference actualPageRef =  controllerObj.saveNewContact();
        String actualURL = actualPageRef.getUrl();
        PageReference expectedPageRef = new PageReference('/apex/imp_siteworkbookcategory?id='+wCategory.Id+'&subProject='+subProjectObj.id);
        expectedPageRef.getParameters().put('message','New contact created successfully');
        String expectedURL = expectedPageRef.getUrl();
        System.assertEquals(actualURL, expectedURL);
        
        Discovery_Workbook_Category__c wrkCategory = [select id,Contact_Being_Interviewed__r.Id from Discovery_Workbook_Category__c where id=:wCategory.Id] ;
        System.assertEquals(wrkCategory.Contact_Being_Interviewed__r.Id, con.Id);
        
        //To test saveNewContact method errors
        con = new Contact();
        con.AccountId = null;
        con.FirstName = 'Test';
        con.LastName = null;
        con.Role__c = 'Accountant';
        if(customerContactRecordTypeId!=null && customerContactRecordTypeId!='')
        {
        	con.RecordTypeId = customerContactRecordTypeId;
        }
        controllerObj.contactObj = con;
        actualPageRef =  controllerObj.saveNewContact();
    }*/
 
    /*private static SubProject__c generate_subProject(Id projectId)
    {
        SubProject__c subObj = IMP_TestFactory_Helper.buildSubProject(projectId);
        Insert subObj;
        return subObj;
    }
    
    private static SubProject_Client_Contact__c generate_subProjectClientContact(Id subProjectId,Id ContactId)
    {
        SubProject_Client_Contact__c clientContactObj = new SubProject_Client_Contact__c();
        clientContactObj.Client_Contact__c = ContactId;
        clientContactObj.SubProject__c = subProjectId;
        clientContactObj.Role__c = 'IT Manager';
        insert clientContactObj;
        return clientContactObj;
    }
    
     private static Project__c generate_Project()
    {
        Project__c proj = IMP_TestFactory_Helper.buildProject(0);
        Insert proj;
        
        return proj;
    }
    
    private static Account generate_Account()
    {
        List<Account> insertAccount = new List<Account>();
        Account actSource = IMP_TestFactory_Helper.buildAccount();
        insertAccount.add(actSource);            
        
        
        return actSource;
    }
    
    private static Site_Workbook__c generate_SiteWorkbook(Id projectId, Id AccountId, Id subProjectId)
    {
        Site_Workbook__c siteWorkbook = IMP_TestFactoryTemporary_Helper.buildSiteWorkbook(projectId, subProjectId);
        siteWorkbook.Site__c = AccountId;
        Insert siteWorkbook;  
        
        return siteWorkbook;
    }
    
    private static Question_Category__c createQuestionCategory() 
    {
        Question_Category__c qCat = IMP_TestFactoryTemporary_Helper.buildDealershipNeed();
        insert qCat;
        
        return qCat;
    }
    
    private static Discovery_Workbook_Category__c GenerateTestData_Project(Id siteWorkBookId,Id qCategoryId)
    {       
        
        Discovery_Workbook_Category__c wCat = IMP_TestFactoryTemporary_Helper.buildDiscoveryWorkbookCategory(qCategoryId);
        wCat.Site_Workbook__c = siteWorkBookId;
        Insert wCat;        
        
        
        return wCat;
    }
    
    private static List<Question__c> createQuestion(Id wCategoryId, Id qCategoryId)
    {
        List<Question__c> insertQuestion = new List<Question__c>();
        for (Integer ctr = 0; ctr < 2; ctr++) 
        {
            Question__c quest = new Question__c();
            quest.Active__c = true;
            quest.Question_Text__c = 'This is a test question for item ' + String.valueOf(ctr);
            //quest.Question_Category__c = qCategoryId;
            quest.Answer_Type__c = 'Text';
            if (math.mod(ctr, 3) == 0)
            {               
                quest.Cloneable__c = false;
                quest.Project_Type__c = 'Upgrade';
                quest.Market__c = 'Dash - Small Auto';
            }else
            {                
                quest.Cloneable__c = true;
                quest.Project_Type__c = 'Upgrade';
                quest.Market__c = 'DMS Agnostic APP - Shared';
            }
            
            insertQuestion.add(quest);
        }
        
        insert insertQuestion;
        
        List<Answer__c> insertAnswer =  new List<Answer__c>();
        Integer ctr2 = 0;
        for (Question__c questions : insertQuestion) 
        {
            Answer__c ans = new Answer__c();
            //ans.Discovery_Workbook_Category__c = wCategoryId;
            ans.Question__c = questions.Id;
            if (math.mod(ctr2, 2) == 0)
            {               
                ans.Text_Answer__c = 'Source Answer' + questions.Id;
                ans.Any_Answer__c = true;
            }else 
            {
                ans.YesNo_Answer__c = null;
                ans.Number_Answer__c = null;                
                ans.Currency_Answer__c = null;
                ans.Text_Answer__c = null;
            }
            
            ctr2++;
            insertAnswer.add(ans);
        }
        System.debug('$$ '+insertAnswer.size()+' insertAnswer '+insertAnswer+' qCategoryId '+qCategoryId);
        
        Insert insertAnswer;

        return insertQuestion;
    }
    
    
    private static Solution__c createSolution(Id qCategoryId)
    {
        Solution__c sol = IMP_TestFactoryTemporary_Helper.buildSolution(qCategoryId);
        Insert sol;
        
        return sol;
    }
    
    private static List<Product__c> createProduct(Id solutionId)
    {
        List<Product__c> prods = new List<Product__c>();
        Product__c prod = IMP_TestFactoryTemporary_Helper.buildProduct(solutionId);
        prod.Name = 'Baseline Payroll US/Canada';
        prods.add(prod);
        
        prod = IMP_TestFactoryTemporary_Helper.buildProduct(solutionId);
        prod.Name = 'Payroll Plus Premier';
        prods.add(prod);
        
        Insert prods;
        
        return prods;        
    }
    
    private static void generateDQuestionProduct(List<Question__c> questions, List<Product__c> products)
    {        
        List<Discovery_Question_Product__c> dest = new List<Discovery_Question_Product__c>();
        Integer ctr = 0;
        for(Product__c prod : products)
        {
            Integer ctr2 = 0;
            for (Question__c quest : questions)
            {
                if (math.mod(ctr2, 2) == ctr)
                {
                    Discovery_Question_Product__c qProd = IMP_TestFactoryTemporary_Helper.buildDiscoveryQuestionProduct(prod.Id, quest.Id);
                    dest.add(qProd);
                }
                ctr2++;
            }
            ctr++;
        }
        
        insert dest;
    }
    private static User createUser()
    {
        List<User> users = new List<User>();
        User user = IMP_TestFactory_Helper.buildUser();
        user.IsActive = true;
        
        users.add(user);
        insert user;
        
        return user;
    }
    
    private static Discovery_Workbook_Interviewer__c createInteviewer(Id wCategoryId)
    {   
        User mike = IMP_TestFactory_Helper.buildUser();
        
        Discovery_Workbook_Interviewer__c interviewer = new Discovery_Workbook_Interviewer__c();
        interviewer.Interviewer__c = mike.Id;
        interviewer.Discovery_Workbook_Category__c = wCategoryId;
        insert interviewer;
        
        
        return interviewer;
    }
    
    private static Discovery_Workbook_Interviewee__c createInterviewee(Id wCategoryId)
    {
        Contact contacts = IMP_TestFactory_Helper.buildContact(null);
        Insert contacts;
        
        Discovery_Workbook_Interviewee__c interviewee = new Discovery_Workbook_Interviewee__c();
        interviewee.Interviewee__c = contacts.Id;
        
        interviewee.Discovery_Workbook_Category__c = wCategoryId;
        insert interviewee;
        
        return interviewee;
    }
     //2016-06-13 -venkata.shrivol@cdk.com -commented this method
    /*private static Contact createNewContact()
    {
        Contact contacts = IMP_TestFactory_Helper.buildContact(null);
        if(customerContactRecordTypeId!='' && customerContactRecordTypeId!=null)
        {
        	contacts.RecordTypeId = customerContactRecordTypeId;    
        }
        Insert contacts;
        
        return contacts;
    }*/
    
    /*private static void createCustomSettings()
    {
        IMP_MarketList__c market = IMP_TestFactoryTemporary_Helper.buildMarketListItem(IMP_TestFactoryTemporary_Helper.Enum_MarketList.DASH_SMALL_AUTO);
        insert market;
        
        IMP_ProjectTypeList__c product = IMP_TestFactoryTemporary_Helper.buildProjectTypeItem(IMP_TestFactoryTemporary_Helper.Enum_ProjectTypeList.UPGRADE);
        insert product;
        
        IMP_AutoSaveTimers__c  timer = IMP_TestFactoryTemporary_Helper.buildAutoSaveTimerItem(IMP_TestFactoryTemporary_Helper.Enum_AutoSaveTimers.AUTO_SAVE);
        insert timer;
    }*/
}