/*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas
Description: Test class for IMP_SetUsersAsFollowerHandler
Test Class:
History:
10/06/14     Kimiko Roberto      Created
11/06/14     Samuel Oberes       Added custom setting population and the assert statements at the end of each method
11/18/14     Samuel Oberes       Expounded the comments on the existing assertions
11/19/14     Samuel Oberes       Implemented IMP_TestFactory_Helper methods
------------------------------------------------------------*/
@isTest
private class IMP_SetUsersAsFollowerHandler_Test{
    
    //static testMethod void setUsersAsFollower_Test(){
    //    //create test data that will enable us creating a subproject and adding users to it
    //    User testUser = IMP_TestFactory_Helper.buildUserAdmin();
    //    testUser.LastName = 'Testing';
    //    testUser.ADID__c = 'testAdid'; // IMPORTANT: To avoid encountering DUPLICATE_VALUE error, add a unique value for this
    //    insert testUser;

    //    User testUser2 = IMP_TestFactory_Helper.buildUserAdmin();
    //    testUser2.LastName = 'Testing2';
    //    testUser2.ADID__c = 'testAdid2'; // IMPORTANT: To avoid encountering DUPLICATE_VALUE error, add a unique value for this
    //    insert testUser2;
        
    //    User testUser3 = IMP_TestFactory_Helper.buildUserAdmin();
    //    testUser3.LastName = 'Testing3';
    //    testUser3.ADID__c = 'testAdid3'; // IMPORTANT: To avoid encountering DUPLICATE_VALUE error, add a unique value for this
    //    insert testUser3;
        
    //    User testUser4 = IMP_TestFactory_Helper.buildUserAdmin();
    //    testUser4.LastName = 'Testing4';
    //    testUser4.ADID__c = 'testAdid4'; // IMPORTANT: To avoid encountering DUPLICATE_VALUE error, add a unique value for this
    //    insert testUser4;
        
    //    Account testChildAccount = IMP_TestFactory_Helper.buildAccount();
    //    insert testChildAccount;
        
    //    Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
    //    testProject.Dealer_Group__c = testChildAccount.Id;
    //    insert testProject;

    //    // populate custom setting to be used by subproject
    //    List<IMP_RolesToFields__c> rtfList = new List<IMP_RolesToFields__c>();
    //    rtfList.add(IMP_TestFactory_Helper.buildRolesToFieldsItem(IMP_TestFactory_Helper.Enum_RolesToFields.HWSPECIALIST));
    //    rtfList.add(IMP_TestFactory_Helper.buildRolesToFieldsItem(IMP_TestFactory_Helper.Enum_RolesToFields.PROJECT_MANAGER));
    //    rtfList.add(IMP_TestFactory_Helper.buildRolesToFieldsItem(IMP_TestFactory_Helper.Enum_RolesToFields.TRAINING_MANAGER));
    //    //rtfList.add(new IMP_RolesToFields__c(Name = 'TrainingImplementationClientMgr', SubprojectFieldName__c = 'Training_Implementation_Client_Mgr__c'));
    //    insert rtfList;

    //    //create the subproject and add users
    //    //this will automatically set the users as followers of the project and Subproject if still not following
    //    SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
    //    testSubProject.Dealer_Group__c = testChildAccount.Id;
    //    testSubProject.Project_Manager__c = testUser.Id;
    //    testSubProject.Training_Implementation_Client_Mgr__c = testUser2.Id;
    //    testSubProject.H_W_Specialist_PFW__c = testUser3.Id;
    //    insert testSubProject;
        
    //    EntitySubscription testFollower = new EntitySubscription(ParentId = testSubProject.Id, SubscriberId = testUser4.Id);
    //    insert testFollower;
        
    //    EntitySubscription testFollower2 = new EntitySubscription(ParentId = testProject.Id, SubscriberId = testUser4.Id);
    //    insert testFollower2;

    //    // Why are we expecting 8 below as the total number of entries in the EntitySubscription table
    //    //  - The business rule states that if a user is supplied for either of the 3 positions (Project_Manager__c, Training_Implementation_Client_Mgr__c, H_W_Specialist_PFW__c), 
    //    //    that user will be added as a follower for both the PROJECT and SUBPROJECT simultaneously, unless it's already a follower.
    //    //    Above, we created a subproject with 3 different users assigned to the 3 positions. The 3 useres weren't followers yet neither for PROJECT nor SUBPROJECT. Therefore, 
    //    //    3 followers were created each for PROJECT and SUBPROJECT -- a total of 6 new entries in the EntitySubscription table. In addition, 2 additional followers were
    //    //    explicitly added as followers -- 1 for PROJECT and 1 for SUBPROJECT. Total number of entries now in the EntitySubscription table is 8.
    //    System.assertEquals(8, [SELECT COUNT() FROM EntitySubscription]);
    //}
    
    //static testMethod void updateSubProjectFollower_Test(){
    //    //create test data that will enable us creating a subproject and adding users to it
    //    User testUser = IMP_TestFactory_Helper.buildUserAdmin();
    //    testUser.LastName = 'Testing';
    //    testUser.ADID__c = 'testAdid'; // IMPORTANT: To avoid encountering DUPLICATE_VALUE error, add a unique value for this
    //    insert testUser;

    //    User testUser2 = IMP_TestFactory_Helper.buildUserAdmin();
    //    testUser2.LastName = 'Testing2';
    //    testUser2.ADID__c = 'testAdid2'; // IMPORTANT: To avoid encountering DUPLICATE_VALUE error, add a unique value for this
    //    insert testUser2;
        
    //    User testUser3 = IMP_TestFactory_Helper.buildUserAdmin();
    //    testUser3.LastName = 'Testing3';
    //    testUser3.ADID__c = 'testAdid3'; // IMPORTANT: To avoid encountering DUPLICATE_VALUE error, add a unique value for this
    //    insert testUser3;
        
    //    User testUser4 = IMP_TestFactory_Helper.buildUserAdmin();
    //    testUser4.LastName = 'Testing4';
    //    testUser4.ADID__c = 'testAdid4'; // IMPORTANT: To avoid encountering DUPLICATE_VALUE error, add a unique value for this
    //    insert testUser4;

    //    User testUser5 = IMP_TestFactory_Helper.buildUserAdmin();
    //    testUser5.LastName = 'Testing5';
    //    testUser5.ADID__c = 'testAdid5'; // IMPORTANT: To avoid encountering DUPLICATE_VALUE error, add a unique value for this
    //    insert testUser5;

    //    User testUser6 = IMP_TestFactory_Helper.buildUserAdmin();
    //    testUser6.LastName = 'Testing6';
    //    testUser6.ADID__c = 'testAdid6'; // IMPORTANT: To avoid encountering DUPLICATE_VALUE error, add a unique value for this
    //    insert testUser6;

    //    User testUser7 = IMP_TestFactory_Helper.buildUserAdmin();
    //    testUser7.LastName = 'Testing7';
    //    testUser7.ADID__c = 'testAdid7'; // IMPORTANT: To avoid encountering DUPLICATE_VALUE error, add a unique value for this
    //    insert testUser7;
        
    //    Account testChildAccount = IMP_TestFactory_Helper.buildAccount();
    //    insert testChildAccount;
        
    //    Project__c testProject = IMP_TestFactory_Helper.buildProject(1);
    //    testProject.Dealer_Group__c = testChildAccount.Id;
    //    insert testProject;

    //    // populate custom setting to be used by subproject
    //    List<IMP_RolesToFields__c> rtfList = new List<IMP_RolesToFields__c>();
    //    rtfList.add(IMP_TestFactory_Helper.buildRolesToFieldsItem(IMP_TestFactory_Helper.Enum_RolesToFields.HWSPECIALIST));
    //    rtfList.add(IMP_TestFactory_Helper.buildRolesToFieldsItem(IMP_TestFactory_Helper.Enum_RolesToFields.PROJECT_MANAGER));
    //    rtfList.add(IMP_TestFactory_Helper.buildRolesToFieldsItem(IMP_TestFactory_Helper.Enum_RolesToFields.TRAINING_MANAGER));
    //    insert rtfList;

    //    //create the subproject and add users
    //    //this will not set the users as followers since they are already following
    //    SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
    //    testSubProject.Dealer_Group__c = testChildAccount.Id;
    //    testSubProject.Project_Manager__c = testUser.Id;
    //    testSubProject.Training_Implementation_Client_Mgr__c = testUser2.Id;
    //    testSubProject.H_W_Specialist_PFW__c = testUser3.Id;
    //    insert testSubProject;
        
    //    EntitySubscription testFollower = new EntitySubscription(ParentId = testSubProject.Id, SubscriberId = testUser4.Id);
    //    insert testFollower;
        
    //    EntitySubscription testFollower2 = new EntitySubscription(ParentId = testProject.Id, SubscriberId = testUser4.Id);
    //    insert testFollower2;

    //    // Why are we expecting 14 below as the total number of entries in the EntitySubscription table
    //    //  - The business rule states that if a user is supplied for either of the 3 positions (Project_Manager__c, Training_Implementation_Client_Mgr__c, H_W_Specialist_PFW__c), 
    //    //    that user will be added as a follower for both the PROJECT and SUBPROJECT simultaneously, unless it's already a follower.
    //    //    Above, we created a subproject with 3 different users assigned to the 3 positions. The 3 useres weren't followers yet neither for PROJECT nor SUBPROJECT. Therefore, 
    //    //    3 followers were created each for PROJECT and SUBPROJECT -- a total of 6 new entries in the EntitySubscription table. In addition, 2 additional followers were
    //    //    explicitly added as followers -- 1 for PROJECT and 1 for SUBPROJECT. Total number of entries now in the EntitySubscription table is 8.
    //    System.assertEquals(8, [SELECT COUNT() FROM EntitySubscription]);
        
    //    // Now we try to update the subproject and change all the 3 positions with 3 new users.
    //    // Expect that there will 3 new followers each both for PROJECT and SUBPROJECT, for a total of 6 new entries in the EntitySubscription table
    //    // Please note: The original assignees to the 3 roles are not removed as followers. As a result, 6 more followers are added to the original 8, totalling 14.
    //    SubProject__c subProjectToUpdate = [SELECT Project_Manager__c, Training_Implementation_Client_Mgr__c, H_W_Specialist_PFW__c FROM SubProject__c WHERE Id = :testSubProject.Id];
    //    subProjectToUpdate.Project_Manager__c = testUser5.Id;
    //    subProjectToUpdate.Training_Implementation_Client_Mgr__c = testUser6.Id;
    //    subProjectToUpdate.H_W_Specialist_PFW__c = testUser7.Id;
        
    //    update subProjectToUpdate;

    //    System.assertEquals(14, [SELECT COUNT() FROM EntitySubscription]);

    //    // Lastly, we'll now make Project_Manager__c and Training_Implementation_Client_Mgr__c be represented by the same person -- testUser5.
    //    // With this move, testUser6 will be replaced by testUser5.
    //    // Expect that there will be no new entries in the EntitySubscription table because testUser5 already exists. As a result, the total follower count remains 14.
    //    subProjectToUpdate.Training_Implementation_Client_Mgr__c = testUser5.Id;

    //    update subProjectToUpdate;

    //    System.assertEquals(14, [SELECT COUNT() FROM EntitySubscription]);
    //}
    
}