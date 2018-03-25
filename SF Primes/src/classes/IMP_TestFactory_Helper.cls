/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: For creating fixtures to be used in testing.
History
10/09/14     Samuel Oberes      Created
10/22/14     Samuel Oberes      Renamed class from "IMP_TestFactory" to "IMP_TestFactory_Helper"
11/18/14     Samuel Oberes      Added buildSiteType, buildChecklistCategory, buildChecklistItem, buildChecklistAnswer, buildSiteWorkbook, buildDiscoveryWorkbookCategory, buildDiscoveryQuestionProduct, buildMarketListItem, buildProjectTypeItem, buildAutoSaveTimerItem, buildQuestion, buildAnswer, buildOpportunity, buildSubProjectOpportunity, buildSubProjectExternalRelatedEntity, buildUserAdmin, buildProfileAdmin, buildRolesToFieldsItem
                                Removed mandatory parameter projectManagerId on buildSubProject because not all use cases need a project manager
12/05/14     Karl Simon         Added buildProfilesToByPass to support test data creation for the IMP_ProfilestoByPass__c custom setting.
01/03/14     Karl Simon         Updated the buildSubProjectSite method to assign a future date to the Estimated_Install_Date_EID__c field.
                                Updated the buildSubProjectSite method to accept a new 3rd parameter, cmfInfoId, and assign it to subProjectSite.CMF_Name__c.
03/23/15     Samuel Oberes      Added buildUserImplementationVIC
07/06/15     Venkata Shrivol    Added buildSiteProducts and modified buildSiteWorkboook, buildQuestion, buildAnswer
07/21/15     Samuel Oberes      In buildTaskDefinition, changed Expected_Duration__c to Expected_Time_Spent__c
07/29/15     Samuel Oberes      Added buildCmfToSubProjectSiteRecord
08/27/15	 Rey Austral		Add LITERAL_ROLE_3PA
09/17/15     Venkata Shrivol	Changed the references of a string value 'LAO' to 'FO'.
10/07/15	 Rey Austral		Update buildCustomSettings
11/03/15     Venkata Shrivol	deleted the methods which use inactive discovery objects
------------------------------------------------------------*/
@isTest
public class IMP_TestFactory_Helper {
    public static final String LITERAL_DASH_SMALL_AUTO = 'Dash - Small Auto';
    public static final String LITERAL_DMS_AGNOSTIC_APP_SHARED = 'DMS Agnostic APP - Shared';
    public static final String LITERAL_DRIVE_BASELINE = 'Drive - Baseline';
    public static final String LITERAL_LIGHTSPEED_POWERSPORTS = 'Lightspeed - Powersports';
    public static final String LITERAL_PFW_HEAVY_EQUIPMENT = 'PFW - Heavy Equipment';
    public static final String LITERAL_ADD_ON = 'Add-on';
    public static final String LITERAL_BUY_SELL = 'Buy/Sell';
    public static final String LITERAL_UNHOOK = 'Unhook';
    public static final String LITERAL_UPGRADE = 'Upgrade';
    public static final String LITERAL_0_UNDISCOVERED = '0. Undiscovered';
    public static final String LITERAL_1_DISCOVER_HURT = '1. Discover the Hurt';
    public static final String LITERAL_2_QUALIFY_HURT = '2. Qualify the Hurt';
    public static final String LITERAL_3_AMPLIFY_HURT = '3. Amplify the Hurt';
    public static final String LITERAL_4_PROPOSE_SOLUTION = '4. Propose a Solution';
    public static final String LITERAL_5_BUY_IN = '5. Buy In';
    public static final String LITERAL_6_SOLUTION_DETAILS = '6. Solution Details';
    public static final String LITERAL_7_TAILOR_SOLUTION = '7. Tailor the Solution';
    public static final String LITERAL_8_CONFIRM_COMMITMENT = '8. Confirm Commitment';
    public static final String LITERAL_9_FORMAL_CONTRACTING = '9. Formal Contracting';
    public static final String LITERAL_10_CLOSED_WON = '10. Closed / Won';
    // public static final String LITERAL_SUBPROJECTSITE__C = 'SubProjectSite__c';
    public static final String FIELD_HWSPECIALIST = 'H_W_Specialist_PFW__c';
    public static final String FIELD_PROJECT_MANAGER = 'Project_Manager__c';
    public static final String FIELD_TRAINING_MANAGER = 'Training_Implementation_Client_Mgr__c';
    public static final String LITERAL_ROLE_3PA = '3PA';

    public enum Enum_MarketList { 
        DASH_SMALL_AUTO, 
        DMS_AGNOSTIC_APP_SHARED, 
        DRIVE_BASELINE, 
        LIGHTSPEED_POWERSPORTS, 
        PFW_HEAVY_EQUIPMENT, 
        MANUAL_INPUT_OF_DEFAULT_VALS 
    }

    public enum Enum_ProjectTypeList {
        ADD_ON,
        BUY_SELL,
        UNHOOK,
        UPGRADE,
        MANUAL_INPUT_OF_DEFAULT_VALS
    }

    public enum Enum_AutoSaveTimers {
        AUTO_SAVE,
        MANUAL_INPUT_OF_DEFAULT_VALS
    }
    
    /* public enum Enum_ProfilesToByPass {
        SUBPROJECTSITE__C,
        MANUAL_INPUT_OF_DEFAULT_VALS
    } */

    public enum Enum_RolesToFields {
        HWSPECIALIST,
        PROJECT_MANAGER,
        TRAINING_MANAGER,
        MANUAL_INPUT_OF_DEFAULT_VALS
    }

    public enum Enum_ExternalReferenceRecordTypes {
        FO
    }

    public static Project__c buildProject(Integer uniqueIdentifier) {
        Project__c p = new Project__c ();
        p.Name = 'Test Project ' + uniqueIdentifier;
        return p;
    }
    
    public static SubProject__c buildSubProject(Id projectId) {
        SubProject__c sp = new SubProject__c();
        sp.SubProject_Name__c = 'Test SubProject Name';
        sp.Project__c = projectId;
        sp.Number_of_Rooftops__c = 2;
        sp.Project_Type__c = LITERAL_UPGRADE;
        sp.Market__c = LITERAL_DRIVE_BASELINE;
        sp.Number_of_User_Connections__c = 2;
        sp.Comments__c = 'Subproject Sample Comments';
        sp.Estimated_Install_Date_EID__c = System.today()+2;
        return sp; 
    }
    
    public static Project_Milestone__c buildMilestoneStandard(Id subProjectId) {
        Project_Milestone__c m = new Project_Milestone__c();
        m.Standard__c = true;
        m.SubProject__c = subProjectId;
        m.Description__c = 'Hardware / Network installed';
        //m.Site__c = 'Test';
        return m;
    }
    
    public static Project_Milestone__c buildMilestoneNonStandard(Id subProjectId, String description) {
        Project_Milestone__c m = new Project_Milestone__c();
        m.Standard__c = false;
        m.SubProject__c = subProjectId;
        m.Description__c = description;
        return m;
    }
    
    public static Project_Activity__c buildProjectActivity(Id milestoneId) {
        Project_Activity__c pa = new Project_Activity__c();
        pa.Milestone__c = milestoneId;
        pa.Planned_Start_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
        pa.Planned_End_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() + 1);
        pa.Description__c = 'TEST DESCRIPTION';
        return pa;
    }
    
    public static User buildUser() {
        return DS_TestObjects.NewUser();
    }
    
    public static Profile buildProfileStandard() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        return p;
    }
    
    public static Laser_Artwork_Order__c buildLaserArtworkOrder(id contactId) {
        Laser_Artwork_Order__c laserArtworkOrder = new Laser_Artwork_Order__c();
        laserArtworkOrder.Contact__c = contactId;
        laserArtworkOrder.Order_Type__c = 'Add/Change - DASH';
        laserArtworkOrder.Order_Status__c = 'Sold';
        laserArtworkOrder.LAS_Name__c = userInfo.getUserId();
        laserArtworkOrder.Order_Priority__c = 'Standard';
        laserArtworkOrder.Prev_SO__c = '12345';
        laserArtworkOrder.Stock_Order__c = '12345';
        laserArtworkOrder.Contract_PO__c = '12345';
        laserArtworkOrder.Change_Notes__c = 'Test';
        laserArtworkOrder.Quote_Type__c = 'Contracted';
        return laserArtworkOrder;
    }
    
    public static Milestone_Definition__c buildMilestoneDefinition() {
        Milestone_Definition__c milestoneDefinition = new Milestone_Definition__c();
        milestoneDefinition.Description__c = 'Test Milestone Definition';
        milestoneDefinition.Project_Type__c = LITERAL_UNHOOK + ';' + LITERAL_UPGRADE + ';';
        milestoneDefinition.Market__c = LITERAL_DRIVE_BASELINE + ';' + LITERAL_DASH_SMALL_AUTO + ';';
        milestoneDefinition.Active__c = false;
        return milestoneDefinition;
    }
    
    public static Activity_Definition__c buildActivityDefinition(Id milestoneDefinitionId) {
        Activity_Definition__c activityDefinition = new Activity_Definition__c();
        activityDefinition.Milestone_Definition__c = milestoneDefinitionId;
        activityDefinition.Active__c = false;
        //activityDefinition.Terminal_Activity__c = true;
        activityDefinition.Offset_Criteria__c = IMP_Project_Utility.OFFSET_CRITERIA_ROLL_CALL;
        activityDefinition.Planned_Start_Date_Offset__c = 1;
        activityDefinition.Planned_End_Date_Offset__c = 2;
        activityDefinition.Description__c = 'Test'; 
        return activityDefinition;
    }
    
    public static Task_Definition__c buildTaskDefinition(Id activityDefinitionId) 
    {
        Task_Definition__c taskDefinition = new Task_Definition__c();
        taskDefinition.Activity_Definition__c = activityDefinitionId;
        taskDefinition.Active__c = false;
        //taskDefinition.Terminal_Task__c = true;        
        taskDefinition.Description__c = 'Test';
        taskDefinition.Sequence__c = 1;     
        taskDefinition.Expected_Time_Spent__c = 1;
        return taskDefinition;
    }
    
    public static Project_Task__c buildProjectTask(Id activityId) 
    {
        Project_Task__c pt = new Project_Task__c();
        pt.Project_Activity__c = activityId;
        pt.Planned_Start_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
        pt.Planned_End_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() + 1);
        pt.Description__c = 'TEST DESCRIPTION';
        pt.Expected_Time_Spent__c = 1;
        return pt;
    }
    
    public static Account buildAccount() {
        Account acc= new Account();
        acc.Name = 'Test Account';
        return acc;
    }
    
    public static Contact buildContact(Id accountId) {
        Contact con = new Contact();
        con.AccountId = accountId;
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Role__c = 'Accountant';
        return con;
    } 
    
    public static Question_Category__c buildDealershipNeed() {
        Question_Category__c dealershipNeeded = new Question_Category__c();
        dealershipNeeded.Name = 'Test Dealership';
        dealershipNeeded.Active__c = true;
        return dealershipNeeded;
    }
    
    public static Solution__c buildSolution(Id dealershipNeededId) {
        Solution__c solution = new Solution__c();
        solution.Name = 'Test Solution';
        solution.Question_Category__c = dealershipNeededId;
        solution.Active__c = true;
        return solution;
    }
    
    public static Product__c buildProduct(Id solutionId) {
        Product__c product = new Product__c();
        product.Name = 'Test Product';
        product.Solution__c = solutionId;
        return product;
    }
    
    // public static Site_Product__c buildSiteProduct(Id subProjectSiteId, Id productId, Id subProjectId)
    // {
    //     Site_Product__c siteProduct = new Site_Product__c();
    //     siteProduct.SubProjectSite__c = subProjectSiteId;
    //     siteProduct.Product__c = productId;
    //     siteProduct.SubProject__c = subProjectId;
    //     return siteProduct;
    // }
    
    //public static SubProject_Product__c buildSubProjectProduct(Id subprojectId, Id productId) {   
    //    SubProject_Product__c subProjectProduct = new SubProject_Product__c();
    //    subProjectProduct.SubProject__c = subprojectId;
    //    subProjectProduct.Product__c = productId; 
    //    return subProjectProduct;
    //}
    
    public static SubProjectSite__c buildSubProjectSite(Id accountId, Id subProjectId, Id cmfInfoId) {
        SubProjectSite__c subProjectSite = new SubProjectSite__c();
        subProjectSite.Account__c = accountId;
        subProjectSite.SubProject__c = subProjectId;
        subProjectSite.CMF_Name__c = cmfInfoId;
        return subProjectSite;
    }
    
    public static IMP_ExternalReferenceRecordTypes__c buildExternalReferenceRecordType() {
        IMP_ExternalReferenceRecordTypes__c setting = new IMP_ExternalReferenceRecordTypes__c();
        setting.Name = 'FO';
        setting.Partner_Id__c = 'LAO_ID__c';
        return setting;
    }
    
    public static SubProject_External_Reference__c buildSubProjectExternalReference(Id laoId , Id subProjectId, Id projectId) {
        SubProject_External_Reference__c externalReference = new SubProject_External_Reference__c();
        externalReference.LAO_ID__c = laoId ;
        externalReference.SubProject__c = subProjectId;
        externalReference.Project__c = projectId;
        return externalReference;
    }

    public static Site_Type__c buildSiteType() {
        Site_Type__c siteType = new Site_Type__c();
        siteType.Active__c = true;
        siteType.Name = 'Test Site Type';
        return siteType;
    }

    public static Site_Workbook__c buildSiteWorkbook(Id projectId, Id subProjectId) {
        Site_Workbook__c siteWorkbook = new Site_Workbook__c();
        // siteWorkbook.SubProject__c = subProjectId;
        siteWorkbook.Project__c = projectId;
        return siteWorkbook;
    }

    public static Discovery_Workbook_Category__c buildDiscoveryWorkbookCategory(Id dealershipNeedId) {
        Discovery_Workbook_Category__c dwc = new Discovery_Workbook_Category__c();
        dwc.Question_Category__c = dealershipNeedId;
        return dwc;
    }

    public static Discovery_Question_Product__c buildDiscoveryQuestionProduct(Id productId, Id questionId) {
        Discovery_Question_Product__c dqp = new Discovery_Question_Product__c();
        dqp.Product__c = productId;
        dqp.Question__c = questionId;
        return dqp;
    }
    
    // public static Discovery_Question_Category__c buildDiscoveryQuestionCategory(Id questionId, Id questionCategoryId) {
    //     Discovery_Question_Category__c dqc = new Discovery_Question_Category__c();
    //     dqc.Discovery_Question__c = questionId;
    //     dqc.Question_Category__c = questionCategoryId;
    //     return dqc;
    // }

    public static IMP_MarketList__c buildMarketListItem(Enum_MarketList csdm) {
        IMP_MarketList__c market = new IMP_MarketList__c();

        if (csdm == Enum_MarketList.DASH_SMALL_AUTO) {
            market.Name    = LITERAL_DASH_SMALL_AUTO;
            market.Text__c = LITERAL_DASH_SMALL_AUTO;
        } else if (csdm == Enum_MarketList.DMS_AGNOSTIC_APP_SHARED) {
            market.Name    = LITERAL_DMS_AGNOSTIC_APP_SHARED;
            market.Text__c = LITERAL_DMS_AGNOSTIC_APP_SHARED;
        } else if (csdm == Enum_MarketList.DRIVE_BASELINE) {
            market.Name    = LITERAL_DRIVE_BASELINE;
            market.Text__c = LITERAL_DRIVE_BASELINE;
        } else if (csdm == Enum_MarketList.LIGHTSPEED_POWERSPORTS) {
            market.Name    = LITERAL_LIGHTSPEED_POWERSPORTS;
            market.Text__c = LITERAL_LIGHTSPEED_POWERSPORTS;
        } else if (csdm == Enum_MarketList.PFW_HEAVY_EQUIPMENT) {
            market.Name    = LITERAL_PFW_HEAVY_EQUIPMENT;
            market.Text__c = LITERAL_PFW_HEAVY_EQUIPMENT;
        } else if (csdm == Enum_MarketList.MANUAL_INPUT_OF_DEFAULT_VALS) {
            market.Name    = '';
            market.Text__c = '';
        }

        return market;
    }

    public static IMP_ProjectTypeList__c buildProjectTypeItem(Enum_ProjectTypeList csdp) {
        IMP_ProjectTypeList__c product = new IMP_ProjectTypeList__c();

        if (csdp == Enum_ProjectTypeList.ADD_ON) {
            product.Name    = LITERAL_ADD_ON;
            product.Text__c = LITERAL_ADD_ON;
        } else if (csdp == Enum_ProjectTypeList.BUY_SELL) {
            product.Name    = LITERAL_BUY_SELL;
            product.Text__c = LITERAL_BUY_SELL;
        } else if (csdp == Enum_ProjectTypeList.UNHOOK) {
            product.Name    = LITERAL_UNHOOK;
            product.Text__c = LITERAL_UNHOOK;
        } else if (csdp == Enum_ProjectTypeList.UPGRADE) {
            product.Name    = LITERAL_UPGRADE;
            product.Text__c = LITERAL_UPGRADE;
        } else if (csdp == Enum_ProjectTypeList.MANUAL_INPUT_OF_DEFAULT_VALS) {
            product.Name    = '';
            product.Text__c = '';
        }

        return product;
    }

    public static IMP_AutoSaveTimers__c buildAutoSaveTimerItem(Enum_AutoSaveTimers csda) {
        IMP_AutoSaveTimers__c timer = new IMP_AutoSaveTimers__c();

        if (csda == Enum_AutoSaveTimers.AUTO_SAVE) {
            timer.Name     = 'Auto_Save';
            timer.Value__c = 60000;
        } else if (csda == Enum_AutoSaveTimers.MANUAL_INPUT_OF_DEFAULT_VALS) {
            timer.Name     = '';
            timer.Value__c = null;
        }

        return timer;
    }
    
    public static IMP_ProfilesToByPass__c buildProfilesToByPass() {
        IMP_ProfilesToByPass__c profile = new IMP_ProfilesToByPass__c();

        profile.Name     = 'SubProjectSite__c';
        profile.Profile__c = 'IMP - Admin - Integration User';

        return profile;
    }

    public static Question__c buildQuestion(Enum_MarketList em, Enum_ProjectTypeList ep) {
        Question__c q = new Question__c();
        q.Question_Text__c = 'Test Question';
        q.Order__c = 'Order';
        q.Answer_Type__c = 'Text';

        if (em == Enum_MarketList.DASH_SMALL_AUTO) {
            q.Market__c = LITERAL_DASH_SMALL_AUTO;
        } else if (em == Enum_MarketList.DMS_AGNOSTIC_APP_SHARED) {
            q.Market__c = LITERAL_DMS_AGNOSTIC_APP_SHARED;
        } else if (em == Enum_MarketList.DRIVE_BASELINE) {
            q.Market__c = LITERAL_DRIVE_BASELINE;
        } else if (em == Enum_MarketList.LIGHTSPEED_POWERSPORTS) {
            q.Market__c = LITERAL_LIGHTSPEED_POWERSPORTS;
        } else if (em == Enum_MarketList.PFW_HEAVY_EQUIPMENT) {
            q.Market__c = LITERAL_PFW_HEAVY_EQUIPMENT;
        } else if (em == Enum_MarketList.MANUAL_INPUT_OF_DEFAULT_VALS) {
            q.Market__c = '';
        }

        if (ep == Enum_ProjectTypeList.ADD_ON) {
            q.Project_Type__c = LITERAL_ADD_ON;
        } else if (ep == Enum_ProjectTypeList.BUY_SELL) {
            q.Project_Type__c = LITERAL_BUY_SELL;
        } else if (ep == Enum_ProjectTypeList.UNHOOK) {
            q.Project_Type__c = LITERAL_UNHOOK;
        } else if (ep == Enum_ProjectTypeList.UPGRADE) {
            q.Project_Type__c = LITERAL_UPGRADE;
        } else if (ep == Enum_ProjectTypeList.MANUAL_INPUT_OF_DEFAULT_VALS) {
            q.Project_Type__c = '';
        }

        //q.Question_Category__c = dealershipNeededId;
        return q;
    }

    public static Answer__c buildAnswer(Id questionId) {
        Answer__c a = new Answer__c();
        //a.Discovery_Workbook_Category__c = discoveryWkbkCategory;
        a.Question__c = questionId;
        a.Text_Answer__c = 'Test Answer';
        return a;
    }

    public static Opportunity buildOpportunity() {
        Opportunity o = new Opportunity();
        o.CloseDate = Date.today().addDays(10);
        o.Name = 'Test Opportunity';
        o.StageName = LITERAL_0_UNDISCOVERED;
        return o;
    }

    public static SubProjectOpp__c buildSubProjectOpportunity(Id subprojectId) {
        SubProjectOpp__c spo = new SubProjectOpp__c();
        spo.SubProject__c = subprojectId;
        return spo;
    }
    
    public static SubProject_External_Related_Entity__c buildSubProjectExternalRelatedEntity(Id subprojectId) {
        SubProject_External_Related_Entity__c sere = new SubProject_External_Related_Entity__c();
        sere.Entity_Number__c = '1234';
        sere.Entity_Type__c = 'CMF';
        sere.SubProject__c = subprojectId;
        return sere;
    }

    public static User buildUserAdmin() {
        User user = DS_TestObjects.NewAdminUser();
        user.ADID__c = DS_TestObjects.TrueRandomUpToAMillion();
        return user;
    }
    
    public static Profile buildProfileAdmin() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ADPDS - Admin - System Administrator'];
        return p;
    }

    public static IMP_RolesToFields__c buildRolesToFieldsItem(Enum_RolesToFields ertf) {
        IMP_RolesToFields__c rtf = new IMP_RolesToFields__c();

        if (ertf == Enum_RolesToFields.HWSPECIALIST) {
            rtf.Name                   = 'HWSpecialistPFW';
            rtf.SubprojectFieldName__c = FIELD_HWSPECIALIST;
        } else if (ertf == Enum_RolesToFields.PROJECT_MANAGER) {
            rtf.Name                   = 'ProjectManager';
            rtf.SubprojectFieldName__c = FIELD_PROJECT_MANAGER;
        } else if (ertf == Enum_RolesToFields.TRAINING_MANAGER) {
            rtf.Name                   = 'TrainingImplementationClientMgr';
            rtf.SubprojectFieldName__c = FIELD_TRAINING_MANAGER;
        } else if (ertf == Enum_RolesToFields.MANUAL_INPUT_OF_DEFAULT_VALS) {
            rtf.Name                   = '';
            rtf.SubprojectFieldName__c = '';
        }

        return rtf;
    }

    public static Project_log__c buildIssueLog(Id projectId,Id subprojectId) {
        List<RecordType> rtypes = [SELECT Name, Id 
                                     FROM RecordType 
                                    WHERE sObjectType = 'Project_Log__c' 
                                      AND isActive = true];
        
        //Create a map between the Record Type Name and Id for easy retrieval
        Map<String,String> logRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypes)
            logRecordTypes.put(rt.Name,rt.Id);
        
        Project_log__c issue = new Project_Log__c();
        issue.Project_Issue__c = ProjectId;
        issue.Sub_Project_Issue__c = subprojectId;
        issue.RecordTypeId = logRecordTypes.get('Issue');
        issue.Target_Date__c = date.today();
        issue.Category__c = 'CDK Only';
        issue.Type__c = 'Contract';
        issue.Priority_Impact__c = 'High';
        issue.Status__c = 'Active';
        issue.Description__c = 'test';
        return issue;
    }

    public static Project_log__c buildRiskLog(Id projectId,Id subprojectId) {
        List<RecordType> rtypes = [SELECT Name, Id 
                                     FROM RecordType 
                                    WHERE sObjectType = 'Project_Log__c' 
                                      AND isActive = true];
        
        //Create a map between the Record Type Name and Id for easy retrieval
        Map<String,String> logRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypes)
            logRecordTypes.put(rt.Name,rt.Id);
        
        Project_log__c risk = new Project_Log__c();
        risk.Project_Risk__c = ProjectId;
        risk.Sub_Project_Risk__c = subprojectId;
        risk.RecordTypeId = logRecordTypes.get('Risk');
        risk.Review_Date__c = date.today();
        risk.Category__c = 'CDK Only';
        risk.Probability__c = 'High';
        risk.Priority_Impact__c = 'High';
        risk.Description__c = 'test';
        return risk;
    }

    public static Project_log__c buildActionItemLog(Id projectId,Id subprojectId) {
        List<RecordType> rtypes = [SELECT Name, Id 
                                     FROM RecordType 
                                    WHERE sObjectType = 'Project_Log__c' 
                                      AND isActive = true];

        //Create a map between the Record Type Name and Id for easy retrieval
        Map<String,String> logRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypes)
            logRecordTypes.put(rt.Name,rt.Id);
        
        Project_log__c action = new Project_Log__c();
        action.Project_Action_Items__c = ProjectId;
        action.Sub_Project_Action_Items__c = subprojectId;
        action.RecordTypeId = logRecordTypes.get('Action Item');
        action.Description__c = 'test';
        action.Review_Date__c = date.today();
        action.Status__c = 'Open';
        action.Target_Date__c = date.today().addDays(1);
        action.CDK_Assignee__c = userinfo.getUserId();
        return action;
    }

    public static Project_log__c buildChangeRequestLog(Id projectId,Id subprojectId) {
        List<RecordType> rtypes = [SELECT Name, Id 
                                     FROM RecordType 
                                    WHERE sObjectType = 'Project_Log__c' 
                                      AND isActive = true];

        //Create a map between the Record Type Name and Id for easy retrieval
        Map<String,String> logRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypes)
            logRecordTypes.put(rt.Name,rt.Id);
        
        Project_log__c change = new Project_Log__c();
        change.Project_Change_Request__c = ProjectId;
        change.Sub_Project_Change_Request__c = subprojectId;
        change.RecordTypeId = logRecordTypes.get('Change Request');
        change.Type__c = 'Project';
        change.Priority_Impact__c = 'High';
        change.Description__c = 'test';
        change.Impact__c = 'Scope;';
        change.Status__c = 'New';
        return change;
    }

    public static Project_log__c buildLessonLearnedLog(Id projectId,Id subprojectId) {
        List<RecordType> rtypes = [SELECT Name, Id 
                                     FROM RecordType 
                                    WHERE sObjectType = 'Project_Log__c' 
                                      AND isActive = true];

        //Create a map between the Record Type Name and Id for easy retrieval
        Map<String,String> logRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypes)
            logRecordTypes.put(rt.Name,rt.Id);
        
        Project_log__c lesson = new Project_Log__c();
        lesson.Project_Lessons_Learned__c = ProjectId;
        lesson.Sub_Project_Lessons_Learned__c = subprojectId;
        lesson.Description__c = 'test';
        lesson.Process_Step__c = 'Step 1: Discovery';
        lesson.Type__c = 'Success';
        lesson.RecordTypeId = logRecordTypes.get('Lesson Learned');
        return lesson;
    }
    
    public static Project_Milestone_Definition_Product__c buildProjectMilestoneDefinitionProduct(Id milestoneDefinitionId, Id productId) {
        Project_Milestone_Definition_Product__c pmdp = new Project_Milestone_Definition_Product__c();
        pmdp.Milestone_Definition__c = milestoneDefinitionId;
        pmdp.Product__c = productId;
        return pmdp;
    }

    public static IMP_ExternalReferenceRecordTypes__c buildExternalReferenceRecordTypeItem(Enum_ExternalReferenceRecordTypes eerrt) {
        IMP_ExternalReferenceRecordTypes__c errt = new IMP_ExternalReferenceRecordTypes__c();

        if (eerrt == Enum_ExternalReferenceRecordTypes.FO) {
            errt.Name                                        = 'FO';
            errt.Partner_Id__c                               = 'LAO_ID__c';
            errt.Field_Map_API_Name__c                       = 'Source_API_Field_Name__c';
            errt.Record_Type_Map_API_Name__c                 = 'External_Entity_Type__c';
            errt.Source_Object_API_Name__c                   = 'Laser_Artwork_Order__c';
            errt.Target_Activity_Date_Type_API_Field_Name__c = 'Target_Unique_Act_Plus_Date_Type__c';
        } 

        return errt;
    }

    public static Project_Activity_Detail_Mapping_Rule__c buildProjectActivityDetailMappingRuleActualStart() {
        Project_Activity_Detail_Mapping_Rule__c testPADMappingRuleStartDate = new Project_Activity_Detail_Mapping_Rule__c();
        testPADMappingRuleStartDate.External_Entity_Type__c = 'FO';
        testPADMappingRuleStartDate.Target_Activity_Name__c = 'Test_Mapping';
        testPADMappingRuleStartDate.Date_Type__c = 'Actual Start';
        testPADMappingRuleStartDate.Source_API_Field_Name__c = 'A_P_Check_Order_Actual_Start_Date__c';
        testPADMappingRuleStartDate.Active__c = true;
        return testPADMappingRuleStartDate;
    }

    public static Project_Activity_Detail_Mapping_Rule__c buildProjectActivityDetailMappingRuleActualEnd() {
        Project_Activity_Detail_Mapping_Rule__c testPADMappingRuleEndDate = new Project_Activity_Detail_Mapping_Rule__c();
        testPADMappingRuleEndDate.External_Entity_Type__c = 'FO';
        testPADMappingRuleEndDate.Target_Activity_Name__c = 'Test_Mapping';
        testPADMappingRuleEndDate.Date_Type__c = 'Actual End';
        testPADMappingRuleEndDate.Source_API_Field_Name__c = 'A_P_Check_Order_Actual_End_Date__c';
        testPADMappingRuleEndDate.Active__c = true;
        return testPADMappingRuleEndDate;
    }

    public static User buildUserAdminIntegrator() {
        Id integrationProfileId = [SELECT Id FROM Profile WHERE Name like '%Impact Integration User' limit 1].Id;

        User user = DS_TestObjects.NewAdminUser();
        user.ProfileId = integrationProfileId;
        User.ADID__c = DS_TestObjects.TrueRandomUpToAMillion();
        return user;
    }

    public static CMF_Info__c buildCMFInfo(Id accountId) {
        CMF_Info__c cmfInfo = new CMF_Info__c();
        cmfInfo.Account__c = accountId; 
        cmfInfo.Main_CMF__c = '321';
        cmfInfo.Ship_CMF__c = '321';
        cmfInfo.Status__c = 'A';
        return cmfInfo;
    }

    public static Opportunity_Quotes__c buildOpportunityQuotes(Id accountId, Id opportunityId) {
        Opportunity_Quotes__c oq = new Opportunity_Quotes__c();
        oq.Account__c = accountId;
        oq.Name = 'Test Opportunity Quote';
        oq.Deal_ID__c = '555';
        oq.Opportunity__c = opportunityId;
        return oq;
    }

    public static User buildUserImplementationVIC() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'ADPDS - Implementation - VIC'].Id;

        User u = DS_TestObjects.NewUser();
        u.ProfileId = profileId;
        u.ADID__c = DS_TestObjects.TrueRandomUpToAMillion();
        return u;
    }
    
     public static Project_Task__c createTask(Id activityId, String name, Boolean terminal)
    {
        Project_Task__c pt = new Project_Task__c();
        pt.Project_Activity__c = activityId;
        pt.Actual_Start_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() - 1);
        pt.Planned_Start_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() - 1);
        pt.Planned_End_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
        pt.Display_on_PSR__c = true;        
        pt.Comments__c = 'TEST TASK COMMENT ' + name;
        pt.Actual_Time_Spent__c = 1;
        pt.Expected_Time_Spent__c = 1;
        if (terminal) {
            //pt.Terminal_Task__c = true;
        }
        
        return pt;
    }

    public static IMP_ListViewDataSetting__c createListViewDataSetting()
    {
        IMP_ListViewDataSetting__c lvdSetting = new IMP_ListViewDataSetting__c();
        lvdSetting.SObjectAPINames__c = 'SubProject__c\nProject_Log__c\nProject_Task__c';
        lvdSetting.DefaultSObject__c = 'Project_Task__c';
        return lvdSetting;
    }

    public static IMP_DataTableUISetting__c createDataTableUISetting()
    {
        IMP_DataTableUISetting__c uiSetting = new IMP_DataTableUISetting__c();
        uiSetting.MaxNumberOfSearchResults__c = 10;
        uiSetting.MinNumberOfSearchCharacters__c = 5;
        uiSetting.NumberOfRecordsPerObject__c = 20;
        return uiSetting;
    }
    
    public static IMP_FollowedRecordsSetting__c createFollowedRecordSetting()
    {
        IMP_FollowedRecordsSetting__c frSetting = new IMP_FollowedRecordsSetting__c();
        frSetting.SobjectFieldsetPair__c = 'Project__c.ProjectDataTableFields\nSubProject__c.SubProjectDataTableFields';
        return frSetting;
    }

    public static EntitySubscription createFollowedRecord(Id parentId){
        EntitySubscription followRec = new EntitySubscription();
        followRec.ParentId = parentId;
        followRec.SubscriberId = UserInfo.getUserId();
        return followRec;
    }
    
    public static CustomSettings__c buildCustomSettings()
    {
        CustomSettings__c custom = new CustomSettings__c();
        custom.Users_Excluded_from_Business_Rules__c = UserInfo.getName();
        custom.Max_Milestone_Threshold__c = 4;
        custom.Max_Milestone_Tree_Threshold__c = 4;
        custom.SF_Instance_Identifier__c = 'TEST';
        custom.Max_Total_Rec_Count_Threshold__c = 80;
        return custom;
    }

    public static CMFtoSubProjectSite__c buildCmfToSubProjectSiteRecord(Id subProjectSiteId, Id cmfInfoId, String rmsRequestId)
    {
        CMFtoSubProjectSite__c rec = new CMFtoSubProjectSite__c();
        rec.SubProjectSite__c = subProjectSiteId;
        rec.CMF_Info__c = cmfInfoId;
        rec.RMS_Request_Id__c = rmsRequestId;
        return rec;
    }
    
}