trigger DS_LaserRollupTrigger on Laser_Ordered_Forms__c(after insert, after update, after delete) 
{
    if(All_CheckRecursive.runCodeBlockOnce('DS_LaserRollupTrigger') || Test.isRunningTest())
    {
        DS_LaserRollupTriggerHandler.RollupMethod(Trigger.New, Trigger.Old); 
    }
}