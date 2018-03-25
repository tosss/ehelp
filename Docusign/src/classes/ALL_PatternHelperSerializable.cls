public class ALL_PatternHelperSerializable
{
    public String regexValue {set; get;}
    public String pRegEx {set; get;}
    public String substitutionValue {set; get;}
    public boolean preventPostOnMatch {set; get;}
    public Blacklisted_Word__c blacklistedWord {set; get;}
    public String origPostBody {set; get;}
    
    //Pass in Blacklisted word and also the regExPattern from the Pattern class.
    //Serializing the Pattern.class is not supported. We just need to pass the regEx representation of it.
    public ALL_PatternHelperSerializable(Blacklisted_Word__c word, String regExPattern, String originalPostBody)
    {
        regexValue=word.RegexValue__c;
        pRegEx=regExPattern;
        substitutionValue=word.Substitution__c;
        preventPostOnMatch=word.Prevent_Post_on_Breach__c;
        blacklistedWord=word;
        origPostBody=originalPostBody;
    }
}