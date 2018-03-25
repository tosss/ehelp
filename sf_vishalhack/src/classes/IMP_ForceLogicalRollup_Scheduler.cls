/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: 
Test Class: 
History
10/20/15    Kimiko Roberto      Created

------------------------------------------------------------*/
global class IMP_ForceLogicalRollup_Scheduler implements Schedulable { 
    
    global void execute(SchedulableContext sc) { 
        IMP_ForceLogicalRollup_Batch forceLogicalRollupBatch = new IMP_ForceLogicalRollup_Batch(); 
        database.executebatch(forceLogicalRollupBatch); 
    } 
    
}