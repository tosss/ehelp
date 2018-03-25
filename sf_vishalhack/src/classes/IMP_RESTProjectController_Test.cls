/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Test class for IMP_RESTProject_Controller
Test Class:
History
10/07/14    Kimiko Roberto      Created
11/26/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
01/03/15    Karl Simon          Commented out the assignment of a value to the Subproject__c.Dealer_Group__c field, which will be decomissioned in Phase 1 R3.
02/06/15    Kimiko Roberto      Added test scenarios for new logic to associate CMFs to the SubProjectSite created.
08/03/15    Samuel Oberes       Added creation of IMP_EntityTypeHelper__c in createNewProject_Test
12/02/16    Venkata Shrivol		-Commented the project object reference RQ-08305
------------------------------------------------------------*/
@isTest
private class IMP_RESTProjectController_Test{
    
    static testMethod void createNewProject_Test(){
        User integrationUser = IMP_TestFactory_Helper.buildUserAdminIntegrator();
        
        User testUser = IMP_TestFactory_Helper.buildUserAdmin();
        insert testUser;
        
        createCustomSettings();

        system.runAs(integrationUser){

            // populate custom setting IMP_EntityTypeHelper__c. This is needed in the creation of a SPERE.
            IMP_EntityTypeHelper__c eh1 = new IMP_EntityTypeHelper__c(Name = 'CMF', Entity_Field_Name__c = 'CMF_Numbers__c');
            IMP_EntityTypeHelper__c eh2 = new IMP_EntityTypeHelper__c(Name = 'RMS Request', Entity_Field_Name__c = 'RMS_Request_Ids__c');
            insert new List<IMP_EntityTypeHelper__c>{ eh1, eh2 };

            //create test data that will be passed for the integration
            String projectName = 'Test Project 1';
            String projectNumber = '123';
            String dealerCMF = '321';
            List<String> cmfNumbersList = new List<String>{'456', '789'};
            List<String> contractNumbersList = new List<String>{ '01089601', '05204305', '05237478', '05237837', '05237860', '05400168', '05720008', '08330017', '08330018', '08330045', '09700168', '09700175', '09700181', '09700211', '09700212', '09700214', '17314720', '71037290', '71037293', '71037422', '71037924', '71037926', '71039261', '71039325', '71039326', '71039327', '71039328', '71039330', '71040624', '71044800', '71044826', '71048005', '71048106', '71048122', '71049096', '71049098', '71049918', '71052602', '71052835', '71055633', '71059325', '71059820', '71061011', '76001684', '76020349', '76021499', '76022391', '76023039', '76023040', '76023041', '76023057', '76023058', '76023064', '76023065', '76023069', '76023070', '76023072', '76023073', '76023074', '76023075', '76023076', '76023135', '76025906', '76025907', '76026665', '76027137', '76027139', '76027167', '76027783', '76028118', '76028119', '76028397', '76028402', '76028658', '76029492', '76030615', '76030616', '76030621', '76030623', '76031661', '76031887', '76031940', '76031941', '76034295', '76035103', '76035662', '76035977', '76036281', '76036488', '76036491', '76036569', '76037055', '76037068', '76037812', '76038193', '76038610', '76039567', '76039568', '76044596', '76047997', '76063103', '76063104', '76074277', '76074643', '76074644', '76074654', '76074761', '76074763', '76137248', '76137525', '76137684', '76155013', '76155556', '76155986', '76156726', '76158806', '76158807', '76158808', '76158809', '76163585', '76166765', '76167483', '76167485', '76167500', '76167501', '76167502', '76170434', '76170691', '76171329', '76171752', '76172568', '76173307', '76173443'};
            List<String> rmsRequestNumbersList = new List<String>{ '01089601', '05204305', '05237478', '05237837', '05237860', '05400168', '05720008', '08330017', '08330018', '08330045', '09700168', '09700175', '09700181', '09700211', '09700212', '09700214', '17314720', '71037290', '71037293', '71037422', '71037924', '71037926', '71039261', '71039325', '71039326', '71039327', '71039328', '71039330', '71040624', '71044800', '71044826', '71048005', '71048106', '71048122', '71049096', '71049098', '71049918', '71052602', '71052835', '71055633', '71059325', '71059820', '71061011', '76001684', '76020349', '76021499', '76022391', '76023039', '76023040', '76023041', '76023057', '76023058', '76023064', '76023065', '76023069', '76023070', '76023072', '76023073', '76023074', '76023075', '76023076', '76023135', '76025906', '76025907', '76026665', '76027137', '76027139', '76027167', '76027783', '76028118', '76028119', '76028397', '76028402', '76028658', '76029492', '76030615', '76030616', '76030621', '76030623', '76031661', '76031887', '76031940', '76031941', '76034295', '76035103', '76035662', '76035977', '76036281', '76036488', '76036491', '76036569', '76037055', '76037068', '76037812', '76038193', '76038610', '76039567', '76039568', '76044596', '76047997', '76063103', '76063104', '76074277', '76074643', '76074644', '76074654', '76074761', '76074763', '76137248', '76137525', '76137684', '76155013', '76155556', '76155986', '76156726', '76158806', '76158807', '76158808', '76158809', '76163585', '76166765', '76167483', '76167485', '76167500', '76167501', '76167502', '76170434', '76170691', '76171329', '76171752', '76172568', '76173307', '76173443'};
            List<String> dealIdList = new List<String>{'555', '666'};
            String contractRollCalledDate = '2014-10-1';
            String BusinessUnit = 'National Admin';
                            
            Account testAccount = IMP_TestFactory_Helper.buildAccount();
            insert testAccount;
            
            CMF_Info__c testCMF = IMP_TestFactory_Helper.buildCMFInfo(testAccount.Id);
            insert testCMF;
            
            Opportunity testOpportunity = IMP_TestFactory_Helper.buildOpportunity();
            testOpportunity.ADP_Opportunity_Owner__c = testUser.Id;
            testOpportunity.CloseDate = date.Today();
            testOpportunity.AccountId = testAccount.Id;
            insert testOpportunity;
            
            Opportunity_Quotes__c testOppQuote = IMP_TestFactory_Helper.buildOpportunityQuotes(testAccount.Id, testOpportunity.Id);
            insert testOppQuote;

            //insert the test data to the request wrapper
            IMP_RESTProject_Controller.ProjectObject requestWrapper = new IMP_RESTProject_Controller.ProjectObject();
            requestWrapper.projectName = projectName;
            requestWrapper.projectNumber = projectNumber;
            requestWrapper.dealerCMF = dealerCMF;
            requestWrapper.cmfNumbersList = cmfNumbersList;
            requestWrapper.contractNumbersList = contractNumbersList;
            requestWrapper.rmsRequestNumbersList = rmsRequestNumbersList;
            requestWrapper.dealIdList = dealIdList;
            requestWrapper.contractRollCalledDate = contractRollCalledDate;
            requestWrapper.BusinessUnit = BusinessUnit;
            IMP_RESTProject_Controller.Request_POST_Project reqs = new IMP_RESTProject_Controller.Request_POST_Project();
            reqs.project = requestWrapper;
            
            String JsonMsg=JSON.serialize(requestWrapper);
            
            Test.startTest();
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            //call the url for the integration so it will create the response
            req.requestURI = '/services/apexrest/v1/projects/*';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(JsonMsg);
            RestContext.request = req;
            RestContext.response= res;

            //create the response using the request created
            IMP_RESTProject_Controller.Response_POST_Project response = new IMP_RESTProject_Controller.Response_POST_Project();
            response = IMP_RESTProject_Controller.createNewProject(requestWrapper);
            Test.stopTest();
            //get Project, SubProject, Related Entities and response
            //Project__c createdProject = [SELECT Id, Name, Project_Status__c, Project_Region__c FROM Project__c WHERE Name =:projectName]; 
            SubProject__c createdSubProject = [SELECT Id, SubProject_Name__c, SubProject_Status__c, SubProject_Region__c FROM SubProject__c WHERE SubProject_Name__c = 'Test Project 1'];
            List<SubProject_External_Related_Entity__c> contractNumberList = [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'Contract' AND Entity_Number__c IN: contractNumbersList];
            List<SubProject_External_Related_Entity__c> rmsList = [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND Entity_Number__c IN: rmsRequestNumbersList];
            SubProjectOpp__c createdSubProjectOpp = [SELECT Id FROM SubProjectOpp__c WHERE SubProject__c =:createdSubProject.Id];
            SubProject_External_Related_Entity__c cmf = [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Number__c =: testCMF.Ship_CMF__c];
            SubProjectSite__c sps = [SELECT Id FROM SubProjectSite__c WHERE Ship_CMF__c = :testCMF.Ship_CMF__c];
            //assert the Project, SubProject, related entities, and response to confirm that the correct data were created according to the values we set.
            System.assert(response != null);
            //System.assert(createdProject != null);
            System.assert(createdSubProject != null);
            //System.assert(createdProject.Project_Status__c == 'Open');
            //System.assert(createdProject.Project_Region__c == 'National Admin');
            System.assert(createdSubProject.SubProject_Status__c == 'Open');
            System.assert(createdSubProject.SubProject_Region__c == 'National Admin');
            //System.assertEquals(projectName, createdProject.Name);
            System.assertEquals(projectName, createdSubProject.SubProject_Name__c);
            System.assert(createdSubProjectOpp != null);
            System.assertEquals(contractNumberList.size(), 133);
            System.assertEquals(rmsList.size(), 133);
            System.assert(response.isSuccess == true);
            System.assert(response.message == 'SubProject '+ createdSubProject.SubProject_Name__c +' Created.');
            System.assert(response.isSuccess == true);
            System.assert(response.impactProjectNum == projectNumber);
            //System.assert(response.salesforceProjectNum == createdProject.Id);
            System.assert(cmf != null);
            System.assert(sps != null);
            
            
            
        }
        
        
    }
    
    static testMethod void createExistingProject_Test(){
        //create test data that will be passed for the integration
        //this time the requested project is already existing
        /*Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        testProject.Name = 'Test Project 1';
        insert testProject;*/
        
        SubProject__c sub = new Subproject__c();
        sub.Impact_Project_Numbers__c = '123';
        insert sub;
        
        String projectName = 'Test Project 1';
        String projectNumber = '123';
        String dealerCMF = '321';
        List<String> cmfNumbersList = new List<String>{'456', '789'};
        List<String> contractNumbersList = new List<String>{'111', '222'};
        List<String> rmsRequestNumbersList = new List<String>{'333', '444'};
        List<String> dealIdList = new List<String>{'555', '666'};
                        
        Account testAccount = IMP_TestFactory_Helper.buildAccount();
        insert testAccount;
        
        CMF_Info__c testCMF = IMP_TestFactory_Helper.buildCMFInfo(testAccount.Id);
        insert testCMF;
        
        User testUser = IMP_TestFactory_Helper.buildUserAdmin();
        insert testUser;
        
        Opportunity testOpportunity = IMP_TestFactory_Helper.buildOpportunity();
        testOpportunity.ADP_Opportunity_Owner__c = testUser.Id;
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.CloseDate = date.Today();
        insert testOpportunity;
        
        Opportunity_Quotes__c testOppQuote = IMP_TestFactory_Helper.buildOpportunityQuotes(testAccount.id, testOpportunity.id);
        insert testOppQuote;

        //insert the test data to the request wrapper
        IMP_RESTProject_Controller.ProjectObject requestWrapper = new IMP_RESTProject_Controller.ProjectObject();
        requestWrapper.projectName = projectName;
        requestWrapper.projectNumber = projectNumber;
        requestWrapper.dealerCMF = dealerCMF;
        requestWrapper.cmfNumbersList = cmfNumbersList;
        requestWrapper.contractNumbersList = contractNumbersList;
        requestWrapper.rmsRequestNumbersList = rmsRequestNumbersList;
        requestWrapper.dealIdList = dealIdList;
        
        
        
        String JsonMsg=JSON.serialize(requestWrapper);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        //call the url for the integration so it will create the response
        req.requestURI = '/services/apexrest/v1/projects/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        //create the response using the request created
        //a failure response will be generated since the project is already existing
        IMP_RESTProject_Controller.Response_POST_Project response = new IMP_RESTProject_Controller.Response_POST_Project();
        response = IMP_RESTProject_Controller.createNewProject(requestWrapper);
        Test.stopTest();
        //check the response message
        System.assert(response != null);
        System.assert(response.isSuccess == false);
        System.assert(response.message == 'Project Number '+ projectNumber +' already exists.' + ';');
        
        
    }
    //this method is deprecated due to not preventing creation based upon missing SPERE related inputs
    /*static testMethod void createException_Test(){
        //create test data that will be passed for the integration
        //we intentionally miss one of the parameters to cause and test the exception
        String projectName = 'Test Project 1';
        String projectNumber = '123';
        String dealerCMF = '321';
        //List<String> cmfNumbersList = new List<String>{'456', '789'};
        List<String> contractNumbersList = new List<String>{'111', '222'};
        List<String> rmsRequestNumbersList = new List<String>{'333', '444'};
        List<String> dealIdList = new List<String>{'555', '666'};
                    
        Account testAccount = IMP_TestFactory_Helper.buildAccount();
        insert testAccount;
        
        User testUser = IMP_TestFactory_Helper.buildUserAdmin();
        insert testUser;
        
        Opportunity testOpportunity = IMP_TestFactory_Helper.buildOpportunity();
        testOpportunity.ADP_Opportunity_Owner__c = testUser.Id;
        testOpportunity.Account = testAccount;
        testOpportunity.CloseDate = date.Today();
        insert testOpportunity;
        
        Opportunity_Quotes__c testOppQuote = IMP_TestFactory_Helper.buildOpportunityQuotes(testAccount.Id, testOpportunity.Id);
        insert testOppQuote;

        //insert the test data to the request wrapper
        IMP_RESTProject_Controller.ProjectObject requestWrapper = new IMP_RESTProject_Controller.ProjectObject();
        requestWrapper.projectName = projectName;
        requestWrapper.projectNumber = '';
        requestWrapper.dealerCMF = dealerCMF;
        //requestWrapper.cmfNumbersList = cmfNumbersList;
        requestWrapper.contractNumbersList = contractNumbersList;
        requestWrapper.rmsRequestNumbersList = rmsRequestNumbersList;
        requestWrapper.dealIdList = dealIdList;
        
        
        
        String JsonMsg=JSON.serialize(requestWrapper);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        //call the url for the integration so it will create the response
        req.requestURI = '/services/apexrest/v1/projects/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        //create the response using the request created
        //a failure response will be generated since the parameters passed were incomplete
        IMP_RESTProject_Controller.Response_POST_Project response = new IMP_RESTProject_Controller.Response_POST_Project();
        response = IMP_RESTProject_Controller.createNewProject(requestWrapper);
        
        //get external entities
        List<SubProject_External_Related_Entity__c> cmfList = [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Number__c IN: null];
        List<SubProject_External_Related_Entity__c> contractNumberList = [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Number__c IN: contractNumbersList];
        List<SubProject_External_Related_Entity__c> rmsList = [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Number__c IN: rmsRequestNumbersList];
        Test.stopTest();
        //check the values of the entities to confirm the created values
        System.assert(response != null);
        System.assert(cmfList.size() == 0);
        System.assert(contractNumberList.size() == 0);
        System.assert(rmsList.size() == 0);
        
        
    }*/
    
    static testMethod void createNewProjectWithExceedingName_Test(){
        //create test data that will be passed for the integration
        //Project name exceeds text size limit
        String projectName = 'Sample Project00000000000000000000000000000000000000000000000000000000000000000066';
        String projectNumber = null;
        String dealerCMF = null;
        List<String> cmfNumbersList = null;
        List<String> contractNumbersList = null;
        List<String> rmsRequestNumbersList = null;
        List<String> dealIdList = null;
        String contractRollCalledDate = null;
                        
        Account testAccount = IMP_TestFactory_Helper.buildAccount();
        insert testAccount;
        
        CMF_Info__c testCMF = IMP_TestFactory_Helper.buildCMFInfo(testAccount.Id);
        testCMF.Main_CMF__c = dealerCMF;
        testCMF.Ship_CMF__c = dealerCMF;
        insert testCMF;
        
        User testUser = IMP_TestFactory_Helper.buildUserAdmin();
        insert testUser;
        
        Opportunity testOpportunity = IMP_TestFactory_Helper.buildOpportunity();
        testOpportunity.ADP_Opportunity_Owner__c = testUser.Id;
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.CloseDate = date.Today();
        insert testOpportunity;
        
        Opportunity_Quotes__c testOppQuote = IMP_TestFactory_Helper.buildOpportunityQuotes(testAccount.Id, testOpportunity.Id);
        insert testOppQuote;

        //insert the test data to the request wrapper
        IMP_RESTProject_Controller.ProjectObject requestWrapper = new IMP_RESTProject_Controller.ProjectObject();
        requestWrapper.projectName = projectName;
        requestWrapper.projectNumber = '7032123';
        requestWrapper.dealerCMF = null;
        requestWrapper.cmfNumbersList = null;
        requestWrapper.contractNumbersList = null;
        requestWrapper.rmsRequestNumbersList = null;
        requestWrapper.dealIdList = dealIdList;
        
        IMP_RESTProject_Controller.Request_POST_Project reqs = new IMP_RESTProject_Controller.Request_POST_Project();
        reqs.project = requestWrapper;
        
        String JsonMsg=JSON.serialize(requestWrapper);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        //call the url for the integration so it will create the response
        req.requestURI = '/services/apexrest/v1/projects/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        //create the response using the request created
        IMP_RESTProject_Controller.Response_POST_Project response = new IMP_RESTProject_Controller.Response_POST_Project();
        response = IMP_RESTProject_Controller.createNewProject(requestWrapper);
        Test.stopTest();
        //check that the created project's name is truncated having only a maximum length of 80
        //Project__c createdProject = [SELECT Id, Name, Project_Status__c FROM Project__c WHERE Name ='Sample Project000000000000000000000000000000000000000000000000000000000000000000'];
        SubProject__c createdSubProject = [
            SELECT Id, SubProject_Name__c, SubProject_Status__c 
            FROM SubProject__c 
            WHERE SubProject_Name__c =:projectName
        ];
        
        System.assert(response != null);
        //System.assert(createdProject.Name == 'Sample Project000000000000000000000000000000000000000000000000000000000000000000');
        //System.assert(createdProject.Name.length() == 80);
        System.assert(createdSubProject.SubProject_Name__c == projectName);
        
        
    }
    
    static testMethod void createNewProjectWithNulls_Test(){
        //create test data that will be passed for the integration
        //create test data for null checkers, only setting the project name.
        String projectName = 'Sample Project';
        String projectNumber = '1234567';
        String dealerCMF = null;
        List<String> cmfNumbersList = null;
        List<String> contractNumbersList = null;
        List<String> rmsRequestNumbersList = null;
        List<String> dealIdList = null;
        String contractRollCalledDate = null;
        String BusinessUnit = null;
                        
        Account testAccount = IMP_TestFactory_Helper.buildAccount();
        insert testAccount;
        
        CMF_Info__c testCMF = IMP_TestFactory_Helper.buildCMFInfo(testAccount.Id);
        testCMF.Main_CMF__c = dealerCMF;
        testCMF.Ship_CMF__c = dealerCMF;
        insert testCMF;
        
        User testUser = IMP_TestFactory_Helper.buildUserAdmin();
        insert testUser;
        
        Opportunity testOpportunity = IMP_TestFactory_Helper.buildOpportunity();
        testOpportunity.ADP_Opportunity_Owner__c = testUser.Id;
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.CloseDate = date.Today();
        insert testOpportunity;
        
        Opportunity_Quotes__c testOppQuote = IMP_TestFactory_Helper.buildOpportunityQuotes(testAccount.Id, testOpportunity.Id);
        insert testOppQuote;

        //insert the test data to the request wrapper
        IMP_RESTProject_Controller.ProjectObject requestWrapper = new IMP_RESTProject_Controller.ProjectObject();
        requestWrapper.projectName = projectName;
        requestWrapper.projectNumber = projectNumber;
        requestWrapper.dealerCMF = dealerCMF;
        requestWrapper.cmfNumbersList = cmfNumbersList;
        requestWrapper.contractNumbersList = contractNumbersList;
        requestWrapper.rmsRequestNumbersList = rmsRequestNumbersList;
        requestWrapper.dealIdList = dealIdList;
        requestWrapper.contractRollCalledDate = '11';
        requestWrapper.BusinessUnit = BusinessUnit;
        IMP_RESTProject_Controller.Request_POST_Project reqs = new IMP_RESTProject_Controller.Request_POST_Project();
        reqs.project = requestWrapper;
        
        String JsonMsg=JSON.serialize(requestWrapper);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        //call the url for the integration so it will create the response
        req.requestURI = '/services/apexrest/v1/projects/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        //create the response using the request created
        IMP_RESTProject_Controller.Response_POST_Project response = new IMP_RESTProject_Controller.Response_POST_Project();
        response = IMP_RESTProject_Controller.createNewProject(requestWrapper);
        Test.stopTest();
        //check response message knowing the fields were null
        System.assert(response != null);
        system.Debug('**response.message: '+response.message);
        System.assert(response.message == 'cmfNumbersList is null or empty;dealerCMF is null or empty;contractNumbersList is null or empty;MainContractID is null or empty;rmsRequestNumbersList is null or empty;BusinessUnit is null or empty;Invalid date: 11;');
        
        
    }
    
    static testMethod void createNewProjectWithAllNullFields_Test(){
        //create test data that will be passed for the integration
        //do null checks in all fields
        String projectName = 'Sample Project';
        String projectNumber = null;
        String dealerCMF = null;
        List<String> cmfNumbersList = null;
        List<String> contractNumbersList = null;
        List<String> rmsRequestNumbersList = null;
        List<String> dealIdList = null;
        String contractRollCalledDate = null;
                        
        Account testAccount = IMP_TestFactory_Helper.buildAccount();
        insert testAccount;
        
        CMF_Info__c testCMF = IMP_TestFactory_Helper.buildCMFInfo(testAccount.Id);
        testCMF.Main_CMF__c = dealerCMF;
        testCMF.Ship_CMF__c = dealerCMF;
        insert testCMF;
        
        User testUser = IMP_TestFactory_Helper.buildUserAdmin();
        insert testUser;
        
        Opportunity testOpportunity = IMP_TestFactory_Helper.buildOpportunity();
        testOpportunity.ADP_Opportunity_Owner__c = testUser.Id;
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.CloseDate = date.Today();
        insert testOpportunity;
        
        Opportunity_Quotes__c testOppQuote = IMP_TestFactory_Helper.buildOpportunityQuotes(testAccount.Id, testOpportunity.Id);
        insert testOppQuote;

        //insert the test data to the request wrapper
        IMP_RESTProject_Controller.ProjectObject requestWrapper = new IMP_RESTProject_Controller.ProjectObject();
        requestWrapper.projectName = null;
        requestWrapper.projectNumber = null;
        requestWrapper.dealerCMF = null;
        requestWrapper.cmfNumbersList = null;
        requestWrapper.contractNumbersList = null;
        requestWrapper.rmsRequestNumbersList = null;
        requestWrapper.dealIdList = dealIdList;
        requestWrapper.contractRollCalledDate = '11';
        IMP_RESTProject_Controller.Request_POST_Project reqs = new IMP_RESTProject_Controller.Request_POST_Project();
        reqs.project = requestWrapper;
        
        String JsonMsg=JSON.serialize(requestWrapper);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        //call the url for the integration so it will create the response
        req.requestURI = '/services/apexrest/v1/projects/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        //create the response using the request created
        IMP_RESTProject_Controller.Response_POST_Project response = new IMP_RESTProject_Controller.Response_POST_Project();
        response = IMP_RESTProject_Controller.createNewProject(requestWrapper);
        Test.stopTest();
        //check response message knowing that the project name was null
        System.assert(response != null);
        System.assert(response.isSuccess == false);
        System.assert(response.message == 'Project Number is null or empty;');
        
        
    }
    
    private static void createCustomSettings()
    {
        IMP_ProfilesToByPass__c profile = IMP_TestFactory_Helper.buildProfilesToByPass();
        insert profile;
    }
    
}