//2016-01-21- anirudh.singh@cdk.com- Created this handler for bringing the Trigger DS_KeyRepChange upto standards it up to the Standards as per Request RQ-06024.
public class DS_KeyRepChange_Handler
{
    public static void addErrorToInsertedRecords(List<Key_Rep_Changes__c> newRecordsList)
    {
        system.debug('Start addErrorToInsertedRecords---->');
        
        //Get all of the Key Reps from the Default Teams
        List<ADP_Default_Team__c> accountTeams=new List<ADP_Default_Team__c>();
        accountTeams=[Select Id, Name, Region__c, Key_Rep__c From ADP_Default_Team__c];
        
        Set<Id> keyReps=new Set<Id>();
        
        //2016-01-21- anirudh.singh@cdk.com- Added the IF Block.
        if(accountTeams.size()>0)
        {
            for(ADP_Default_Team__c rec: accountTeams)
            {
                keyReps.add(rec.Key_Rep__c);
            }
        }
        
        //If any Key Rep on the Key Rep Changes being processed does not exist as a Default Team Key Rep, 
        //add an error to the appropriate record
        for(Key_Rep_Changes__c rec: newRecordsList)
        {
            if(!keyReps.contains(rec.New_Key_Rep__c))
            {
                rec.addError('Unable to save Key Rep Change since there is no ADP Default Team for this Key Rep. '
                             + 'Please contact Support to have them create a new default team.');
            }
        }
        
        system.debug('End addErrorToInsertedRecords---->');
    }
}