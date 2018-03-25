//2017-06-01- anirudh.singh@cdk.com- Created this class for RQ-09310 and RQ-09228.
@isTest
public class EMP_DeleteSobjectRecs_Test
{
    @TestSetup
    private static void setupData()
    {
        Id wrkflwRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('WorkFlow__c', 'COM - Employees Termination');
        
        List<WorkFlow__c> workflowList=new List<WorkFlow__c>();
        WorkFlow__c wrkflwRec1=new WorkFlow__c();
        wrkflwRec1.RecordTypeId=wrkflwRecordTypeId;
        workflowList.add(wrkflwRec1);
        
        WorkFlow__c wrkflwRec2=new WorkFlow__c();
        wrkflwRec2.RecordTypeId=wrkflwRecordTypeId;
        workflowList.add(wrkflwRec2);
        
        WorkFlow__c wrkflwRec3=new WorkFlow__c();
        wrkflwRec3.RecordTypeId=wrkflwRecordTypeId;
        workflowList.add(wrkflwRec3);
        
        WorkFlow__c wrkflwRec4=new WorkFlow__c();
        wrkflwRec4.RecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('WorkFlow__c', 'HR - New Hire');
        workflowList.add(wrkflwRec4);
        insert workflowList;
        
        Id pfRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'Manager Termination Form');
        
        List<Portal_Form__c> portalFormList=new List<Portal_Form__c>();
        Portal_Form__c pfRec1=new Portal_Form__c();
        pfRec1.RecordTypeId=pfRecordTypeId;
        portalFormList.add(pfRec1);
        
        Portal_Form__c pfRec2=new Portal_Form__c();
        pfRec2.RecordTypeId=pfRecordTypeId;
        portalFormList.add(pfRec2);
        
        Portal_Form__c pfRec3=new Portal_Form__c();
        pfRec3.RecordTypeId=pfRecordTypeId;
        portalFormList.add(pfRec3);
        
        Portal_Form__c pfRec4=new Portal_Form__c();
        pfRec4.RecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'COM Bank of America');
        portalFormList.add(pfRec4);
        insert portalFormList;
        
        Datetime twoYearsAgo=Datetime.now().addYears(-2).addSeconds(-1);
        Test.setCreatedDate(workflowList[0].Id, twoYearsAgo);
        Test.setCreatedDate(workflowList[2].Id, twoYearsAgo);
        Test.setCreatedDate(portalFormList[0].Id, twoYearsAgo);
        Test.setCreatedDate(portalFormList[2].Id, twoYearsAgo);
    }
    
    private static testMethod void schedulerTestOne()
    {
    	Test.startTest();
    	String jobId=System.schedule('Test EMP_DeleteSobjectRecs_Scheduler', 
                                     '0 0 1 ? * MON', 
                                     new EMP_DeleteSobjectRecs_Scheduler());
    	Test.stopTest();
        
        system.assertEquals(1, [SELECT Count() FROM WorkFlow__c WHERE RecordType.Name='COM - Employees Termination']);
        system.assertEquals(1, [SELECT Count() FROM Portal_Form__c WHERE RecordType.Name='Manager Termination Form']);
    }
}