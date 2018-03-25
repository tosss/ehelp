trigger DS_KeyRepChange on Key_Rep_Changes__c (before insert) 
{
    // get all of the Key Reps from the Default Teams
    List<ADP_Default_Team__c> AccountTeams = [Select Id, Name, Region__c, Key_Rep__c From ADP_Default_Team__c];
    
    Set<Id> KeyReps = new Set<Id>(); 
    for(ADP_Default_Team__c d : AccountTeams) { KeyReps.add(d.Key_Rep__c); }
    
    // if any Key Rep on the Key Rep Changes being processed does not exist as a Default Team Key Rep, 
    // add an error to the appropriate record
    for(Key_Rep_Changes__c k : Trigger.new)
    {
        if(!KeyReps.contains(k.New_Key_Rep__c))
        {
            k.addError('Unable to save Key Rep Change since there is no ADP Default Team for this Key Rep. '
                + 'Please contact Support to have them create a new default team.');
        }
    }
}