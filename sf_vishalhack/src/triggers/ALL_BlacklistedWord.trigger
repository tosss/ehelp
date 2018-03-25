trigger ALL_BlacklistedWord on Blacklisted_Word__c(before insert, before update)
{
    //The list of Blacklisted Words in the Trigger.New are iterated.
    for(Blacklisted_Word__c blacklistWord: Trigger.New)
    {
        //If Custom Expression field value is not Null, that is a Regex Pattern is manually provided.
        //For this the field value of the field Word__c will be cleared.
        //Match_Whole_Words_Only__c field is made false and RegexValue__c field is set with the value of the Custom Expression field value.
        if(blacklistWord.Custom_Expression__c!= Null)
        {
            blacklistWord.Word_or_Phrase__c='';
            blacklistWord.Match_Whole_Words_Only__c=false;
            blacklistWord.RegexValue__c=blacklistWord.Custom_Expression__c;
        }
        //If the Custom Expression field value is Null, then a RegexValue is should be generated.
        //For generating the RegexValue and populating it in the RegexValue__c field of the Blacklist Word Record, 
        //a method named toRegex is invoked from the ALL_RegexHelper class.
        //Word__c field value and Match_Whole_Words_Only__c field value are passed to the toRegex method.
        else
        {
            blacklistWord.RegexValue__c=ALL_RegexHelper.toRegex(blacklistWord.Word_or_Phrase__c, blacklistWord.Match_Whole_Words_Only__c);
        }
    }
}