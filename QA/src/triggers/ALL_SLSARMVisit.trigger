//2016-02-08- lalitha.adduru@cdk.com- created the trigger SLS_ARM_Visit__c

trigger ALL_SLSARMVisit on SLS_ARM_Visit__c (before insert) {
    
    // isInsert
    if(trigger.isBefore && trigger.isInsert)
    {
     	All_SLSARMVisit_Handler.setSupervisor(trigger.New);   
    }

}