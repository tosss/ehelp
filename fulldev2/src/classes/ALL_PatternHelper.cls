public class ALL_PatternHelper
{
    private Blacklisted_Word__c wordRecord;
    
    private String substitutionValue;
    
    private Boolean preventPostOnMatch;
    
    private String regexValue;
    
    private Pattern patternToBeMatched;
    
    private String origPostBody;
    
    public Blacklisted_Word__c fetchWordRecord
    {
        set
        {
            wordRecord=value;
        }
        get
        {
            return wordRecord;
        }
    }
    
    public String fetchSubstitutionValue
    {
        set
        {
            substitutionValue=value;
        }
        get
        {
            return substitutionValue;
        }
    }
    
    public boolean fetchPreventPostOnMatch
    {
        set
        {
            preventPostOnMatch=value;
        }
        get
        {
            return preventPostOnMatch;
        }
    }
    
    public String fetchRegexValue
    {
        set
        {
            regexValue=value;
        }
        get
        {
            return regexValue;
        }
    }
    
    public Pattern fetchPattern
    {
        set
        {
            patternToBeMatched=value;
        }
        get
        {
            return patternToBeMatched;
        }
    }
    
    public String fetchOrigPostBody
    {
        set
        {
            origPostBody=value;
        }
        get
        {
            return origPostBody;
        }
    }
    
    public ALL_PatternHelper(Blacklisted_Word__c blacklstWord)
    {
        wordRecord=blacklstWord;
        substitutionValue=blacklstWord.Substitution__c;
        preventPostOnMatch=blacklstWord.Prevent_Post_on_Breach__c;
        regexValue=blacklstWord.RegexValue__c;
        patternToBeMatched=Pattern.compile(blacklstWord.RegexValue__c);
    }
    
    //Returns a serializable version of the ALL_PatternHelper.
    public ALL_PatternHelperSerializable getSerializable()
    {
        return new ALL_PatternHelperSerializable(wordRecord, patternToBeMatched.pattern(), origPostBody);
    }
}