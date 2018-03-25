//2016-02-08- lalitha.adduru@cdk.com- created the handler class for All_SLSARMVisit Trigger on SLS_ARM_Visit__c

public class ALL_SLSARMVisit_Handler {
    
    // before insert, set supervisor
    public static void setSupervisor(List<SLS_ARM_Visit__c> triggerNew)
    {
        // get all accountIds from Visits into a list 
        List<id> accountIdList = new List<id>();
        for(SLS_ARM_Visit__c visit : triggerNew)
        {
            accountIdList.add(visit.Account__c);
        }
        
        // account to region Map
        Map<id,Account> accountMap = new Map<id,Account>([select id, Region__c from Account where id in :accountIdList]);
        
        // get All AVP_RGM_Link list to find the required link
        List<AVP_RGM_Link__c> rgmLinkList = new List<AVP_RGM_Link__c>();
        rgmLinkList = [
            select id, ARM_Supervisor__c , Region__c
            from AVP_RGM_Link__c
        ];
        
        // AVP_RGM_Link__c.region to AVP_RGM_Link__c.supervisor Map
        Map<string,id> regionToSupervisorMap = new Map<String,id>();
        if(rgmLinkList != null && !rgmLinkList.isEmpty())
        {
            for(AVP_RGM_Link__c rgmLink : rgmLinkList)
            {
                regionToSupervisorMap.put(rgmLink.Region__c, rgmLink.ARM_Supervisor__c);
            }
        }
        
        if(regionToSupervisorMap != null && !regionToSupervisorMap.isEmpty())
        {
            for(SLS_ARM_Visit__c ARMVisit : triggerNew)
            {
                // check if ARMVisit.Account__r.region__c is equal to any AVPRGMLink.Region__c
                if(regionToSupervisorMap.get(accountMap.get(ARMVisit.Account__c).region__c) != null)
                {
                    // assign AVP_RGM_Link__c.supervisor to ARMVisit.ARM_Supervisor__c
                    ARMVisit.ARM_Supervisor__c = regionToSupervisorMap.get(accountMap.get(ARMVisit.Account__c).region__c );
                }
            }
        }        
    }
    
}