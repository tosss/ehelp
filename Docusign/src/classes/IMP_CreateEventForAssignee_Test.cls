/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Test class for the IMP_CreateEventForAssignee trigger
History
10/09/14     Samuel Oberes      Created
10/22/14     Samuel Oberes      Changed test fixture class name from "IMP_TestFactory" to "IMP_TestFactory_Helper"
11/06/14     Samuel Oberes      Refactored: Updated param signature of IMP_TestFactory_Helper.buildUser()
11/13/14     Samuel Oberes      Refactored: Replaced "Field Service" with IMP_CreateEventForAssignee_Helper.FIELD_SERVICE_LITERAL
11/18/14     Samuel Oberes      Fixed buildSubProject parameter
------------------------------------------------------------*/
@isTest
private class IMP_CreateEventForAssignee_Test {
    private testmethod static void testCreateOrUpdateEventsForAssignee() {
        
        Test.startTest();
        
        // +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        // INIT
        
        User user1 = IMP_TestFactory_Helper.buildUser();
        insert user1;
        
        User user2 = IMP_TestFactory_Helper.buildUser();
        insert user2;
        
        User userPM = IMP_TestFactory_Helper.buildUser();
        insert userPM;
        
        Project__c project = IMP_TestFactory_Helper.buildProject(1);
        insert project; 
        
        SubProject__c subProject = IMP_TestFactory_Helper.buildSubProject(project.Id);
        subProject.Project_Manager__c = userPM.Id;
        insert subProject; 
        
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneStandard(subProject.Id);
        insert milestone;
        
        Integer eventCount;
        
        // +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        // TESTS PROPER
        
        // insert new project activity where CDK_Assignee_Role__c is 'Field Service'
        // expect event to be created
        Project_Activity__c pa1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.id);
        pa1.CDK_Assignee__c = user1.Id;
        pa1.CDK_Assignee_Role__c = IMP_CreateEventForAssignee_Helper.FIELD_SERVICE_LITERAL;

        try {
            insert pa1;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'DBG: MESSAGE >> ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'DBG: STACK TRACE >> ' + e.getStackTraceString());
        }
        
        eventCount = [SELECT COUNT() FROM Event WHERE WhatId = :pa1.Id];
        system.assertEquals(1, eventCount);
        
        // -----
        //         
        // insert new project activity where CDK_Assignee_Role__c is NOT 'Field Service'
        // expect event NOT to be created
        Project_Activity__c pa2 = IMP_TestFactory_Helper.buildProjectActivity(milestone.id);
        pa2.CDK_Assignee__c = user1.Id;
        pa2.CDK_Assignee_Role__c = 'Install Specialist (ICD)';

        try {
            insert pa2;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'DBG: MESSAGE >> ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'DBG: STACK TRACE >> ' + e.getStackTraceString());
        }
        
        eventCount = [SELECT COUNT() FROM Event WHERE WhatId = :pa2.Id];
        system.assertEquals(0, eventCount);
        
        // -----
        // 
        // update existing activity's Planned_Start_Date__c
        // expect event's ActivityDate and StartDateTime to be updated
        List<Event> eventOriginals = [SELECT ActivityDate, StartDateTime FROM Event WHERE WhatId = :pa1.Id];
        
        pa1.Planned_Start_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() + 1);
        update pa1;
        
        List<Event> eventChanges = [SELECT ActivityDate, StartDateTime FROM Event WHERE WhatId = :pa1.Id];
        
        System.assertEquals(1, eventChanges.size());
        System.assertNotEquals(eventOriginals.get(0).ActivityDate, eventChanges.get(0).ActivityDate);
        System.assertNotEquals(eventOriginals.get(0).StartDateTime, eventChanges.get(0).StartDateTime);
        
        // -----
        // 
        // update existing activity's Planned_End_Date__c
        // expect event's EndDateTime to be updated
        Datetime oldEndDateTime = [SELECT EndDateTime FROM Event WHERE WhatId = :pa1.Id].EndDateTime;
        
        pa1.Planned_End_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() + 2);
        update pa1;
        
        Datetime newEndDateTime = [SELECT EndDateTime FROM Event WHERE WhatId = :pa1.Id].EndDateTime;
        
        System.assertNotEquals(oldEndDateTime, newEndDateTime);
        
        // -----
        // 
        // update existing activity's CDK_Assignee__c
        // expect event's OwnerId to be updated
        String oldOwnerId = [SELECT OwnerId FROM Event WHERE WhatId = :pa1.Id].OwnerId;
        
        pa1.CDK_Assignee__c = user2.Id;
        update pa1;
        
        String newOwnerId = [SELECT OwnerId FROM Event WHERE WhatId = :pa1.Id].OwnerId;
        
        System.assertNotEquals(oldOwnerId, newOwnerId);
        
        // -----
        // 
        // update existing activity's CDK_Assignee_Role__c to anything EXCEPT 'Field Service'
        // expect the event to be deleted
        pa1.CDK_Assignee_Role__c = 'Virtual Implementation Consultant';
        update pa1;
        
        eventCount = [SELECT COUNT() FROM Event WHERE WhatId = :pa1.Id];
        
        System.assertEquals(0, eventCount);
        
        // +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        
        Test.stopTest();
    }
}