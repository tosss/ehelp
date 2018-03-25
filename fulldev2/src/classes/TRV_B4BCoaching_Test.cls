// 2015-12-08 endiem@endiem.com - RQ-05509 - Test class for B4B Coaching trigger and handler
@isTest
private class TRV_B4BCoaching_Test {
    
    private static testmethod void testEventCreation() {
        
        Id processCoachVisitId;
        Id nonBillaleTypeId;
        Id pscVisitTypeId;
        
        for(RecordType objRecordType : [
                SELECT Id, DeveloperName, SobjectType 
                FROM RecordType 
                WHERE SobjectType = 'Traver_Coaching__c'
            ]) {
            
            if(objRecordType.DeveloperName == 'Process_Coach_Visit') {
                
                processCoachVisitId = objRecordType.Id;
            }
            
            if(objRecordType.DeveloperName == 'Non_Billable') {
                
                nonBillaleTypeId = objRecordType.Id;
            }
            
            if(objRecordType.DeveloperName == 'PSC_Visit') {
                
                pscVisitTypeId = objRecordType.Id;
            }
        }
        
        List<User> lstUser = [
            SELECT Id, Name 
            FROM User 
            WHERE Id =: UserInfo.getUserId()
        ];
        
        Account objAccount = new Account(Name = 'Test Account');
        insert objAccount;
        
        Contact objContact = new Contact(
            LastName = 'Test Last Contact', 
            FirstName = 'Test First Contact', 
            Email = 'test@test.com', 
            AccountId = objAccount.Id
        );
        insert objContact;
        
        Traver_Project__c objTraverProj = new Traver_Project__c(
            Account__c = objAccount.Id,
            Contact__c = objContact.Id
        );
        insert objTraverProj;
        
        TRV_Resource__c objResource = new TRV_Resource__c(TRV_Resource__c = lstUser[0].Id);
        insert objResource;
        
        Traver_Coaching__c objTraverCoach = new Traver_Coaching__c(
            Status__c = 'Scheduled', 
            Traver_Project__c = objTraverProj.Id,
            TRV_Completed_By__c = objResource.Id,
            Number_of_Days_PSG__c = 18
        );
        
        Traver_Coaching__c objTraverCoach1 = new Traver_Coaching__c(
            Status__c = 'Confirmed', 
            Traver_Project__c = objTraverProj.Id,
            TRV_Completed_By__c = objResource.Id,
            RecordTypeId = nonBillaleTypeId,
            TRV_Number_Of_Days_NonBillable__c = 5
        );
        
        Traver_Coaching__c objTraverCoach2 = new Traver_Coaching__c(
            Status__c = 'Confirmed', 
            Traver_Project__c = objTraverProj.Id,
            TRV_Completed_By__c = objResource.Id,
            RecordTypeId = pscVisitTypeId,
            Visit_Start_Date__c = Date.today(),
            Number_of_Days_PSG__c = 3
        );
        
        insert new List<Traver_Coaching__c>{objTraverCoach, objTraverCoach1, objTraverCoach2}; 
        
        system.assertEquals(0, [SELECT ActivityDate, WhatId FROM Event WHERE WhatId =:objTraverCoach.Id ].size());
        
        objTraverCoach.Status__c = 'Confirmed';
        objTraverCoach.Number_of_Days_Traver__c = 18;
        update objTraverCoach;
        
        objTraverCoach.Visit_Start_Date__c = Date.today() + 1; 
        update objTraverCoach;
        system.assertEquals(2, [SELECT ActivityDate, WhatId FROM Event WHERE WhatId =:objTraverCoach.Id ].size());
        
        objTraverCoach.Status__c = 'Cancelled'; 
        update objTraverCoach;
        
        system.assertEquals(0, [SELECT ActivityDate, WhatId FROM Event WHERE WhatId =:objTraverCoach.Id ].size());
        
        objTraverCoach.RecordTypeId = processCoachVisitId;
        objTraverCoach.Status__c = 'Completed';
        objTraverCoach.TRV_Completed_By__c = null;
        update objTraverCoach;
        
        objTraverCoach.TRV_Completed_By__c = objResource.Id;
        update objTraverCoach;
        
        objTraverCoach1.Visit_Start_Date__c = Date.today() + 2;
        update objTraverCoach1;
        
        objTraverCoach2.Visit_Start_Date__c = Date.today() + 3;
        update objTraverCoach2;
    }
}