/*
 * Author       Vishal Bandari
 * Created      22 April 2015
 * Description  Changes the Previous Process Coach and Previous EPC fields
 * 
 * History
 * 22 April 2015    Vishal Bandari    Created Trigger
 */
trigger ALL_TraverProject on Traver_Project__c (before Update) 
{
    if(Trigger.IsBefore && Trigger.IsUpdate)
    {
        TraverProjectUpdate_Handler.updateEPCandProcessCoachField(Trigger.New,Trigger.OldMap);
    }
}