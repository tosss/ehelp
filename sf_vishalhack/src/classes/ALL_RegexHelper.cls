public class ALL_RegexHelper
{
    //This method accepts the blacklistedWord and matchWholeWordsOnly as parameters.
    //It then generates and returns the RegexValue.
    public static String toRegex(String blacklistWord, boolean matchWholeWordsOnly)
    {
        //If the matchWholeWordsOnly is false, the RegexValue will have Blank at the start and end of the RegexValue.
        String wordBoundary='';
        
        //If the matchWholeWordsOnly is false, the RegexValue will have \b at the start and end of the RegexValue.
        if(matchWholeWordsOnly)
        {
            wordBoundary='\\b';
        }
        
        //This String regex will hold the RegexValue.
        String regex=wordBoundary+'(';
        
        //The blacklistedWord is splitted and a list is created with each character constituting the blacklistedWord.
        List<String> charsList=blacklistWord.split('',0);
        
        //The position is started as 1, as the first position of the regex will be wordBoundary i.e. blank or \b.
        for(Integer position=1; position<charsList.size(); position++)
        {
            if(charsList[position]==' ')
            {
                regex+='[ ]';
            }
            else
            {
                regex+='['+charsList[position].toLowerCase()+'|'+charsList[position].toUpperCase()+']';
            }
        }
        
        //The regex value is returned from where this method is invoked.
        return regex+')'+wordBoundary;
    }
}