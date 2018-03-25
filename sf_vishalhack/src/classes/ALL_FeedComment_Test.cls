@isTest
private class ALL_FeedComment_Test
{
    //Author: Anirudh Singh
    //Date  : 21st Oct, 2014 
    //Description: This is the test class for the Trigger named ALL_FeedComment.
    
    //The below method is used to cover the Chatter Blacklist functionality, when Blacklisted Word or Phrase is substituted by some text and the comment on a Chatter post is allowed to be inserted.
    //Also, a Blacklist Audit record is created.
    static testMethod void validateCBWhenAllowingComment()
    {
        List<Blacklisted_Word__c> wordList=new List<Blacklisted_Word__c>();
        
        Blacklisted_Word__c firstWord=new Blacklisted_Word__c();
        firstWord.Word_or_Phrase__c='hate';
        firstWord.is_Active__c=true;
        firstWord.Add_to_Compliance_Audit__c=true;
        firstWord.Match_Whole_Words_Only__c=true;
        firstWord.Substitution__c='****';
        wordList.add(firstWord);
        
        Blacklisted_Word__c secondWord=new Blacklisted_Word__c();
        secondWord.Word_or_Phrase__c='all this stuff';
        secondWord.is_Active__c=true;
        secondWord.Add_to_Compliance_Audit__c=true;
        secondWord.Match_Whole_Words_Only__c=true;
        secondWord.Substitution__c='****';
        wordList.add(secondWord);
        insert wordList;
        
        test.startTest();
        FeedItem post=new FeedItem();
        post.Body='this is what i hate';
        post.ParentId=UserInfo.getUserId();
        insert post;
        
        FeedComment comment=new FeedComment();
        comment.CommentBody='all this stuff is tested';
        comment.FeedItemId=post.Id;
        insert comment;
        test.stopTest();
    }
    
    //The below method is used to cover the Chatter Blacklist functionality, when Custom Expression is used and the comment on a Chatter post is allowed to be inserted.
    //Also, a Blacklist Audit record is created.
    static testMethod void validateCBWhenCustomExpressionUsed()
    {
        List<Blacklisted_Word__c> wordList=new List<Blacklisted_Word__c>();
        
        Blacklisted_Word__c firstWord=new Blacklisted_Word__c();
        firstWord.Custom_Expression__c='\b([t|T][e|E][s|S][t|T])\b';
        firstWord.is_Active__c=true;
        firstWord.Add_to_Compliance_Audit__c=true;
        firstWord.Match_Whole_Words_Only__c=true;
        firstWord.Substitution__c='****';
        wordList.add(firstWord);
        
        Blacklisted_Word__c secondWord=new Blacklisted_Word__c();
        secondWord.Word_or_Phrase__c='hate';
        secondWord.is_Active__c=true;
        secondWord.Add_to_Compliance_Audit__c=true;
        secondWord.Match_Whole_Words_Only__c=true;
        secondWord.Substitution__c='****';
        wordList.add(secondWord);
        insert wordList;
        
        test.startTest();
        FeedItem post=new FeedItem();
        post.Body='hate all this';
        post.ParentId=UserInfo.getUserId();
        insert post;
        
        FeedComment comment=new FeedComment();
        comment.CommentBody='this is test';
        comment.FeedItemId=post.Id;
        insert comment;
        test.stopTest();
    }
    
    //The below method is used to cover the Chatter Blacklist functionality, when the comment on a Chatter post, with the Blacklisted Word or Phrase is not allowed to be inserted.
    //Blacklist Audit record is also not created.
    static testMethod void validateCBWhenPreventingComment()
    {
        Blacklisted_Word__c word=new Blacklisted_Word__c();
        word.Word_or_Phrase__c='kill this';
        word.is_Active__c=true;
        word.Add_to_Compliance_Audit__c=true;
        word.Prevent_Post_on_Breach__c=true;
        word.Match_Whole_Words_Only__c=true;
        word.Substitution__c='****';
        insert word;
        
        List<FeedItem> feedItemList=new List<FeedItem>();
        
        test.startTest();
        FeedItem post=new FeedItem();
        post.Body='help me with this';
        post.ParentId=UserInfo.getUserId();
        insert post;
        
        FeedComment comment=new FeedComment();
        comment.CommentBody='i will kill this process';
        comment.FeedItemId=post.Id;
        try
        {
            insert comment;
        }
        catch(Exception ex)
        {
            Boolean expectedError;
            if(ex.getMessage().contains('Comment prevented due to use of a blacklisted word: '))
            {
                expectedError=true;
            }
            System.AssertEquals(expectedError, true);
        }
        
        word.RegexValue__c='\b([k|K][i|I][l|L][l|L][ ][t|T][h|H][i|I][s|S])\b';
        
        ALL_PatternHelper patternHelper=new ALL_PatternHelper(word);
        system.assertEquals(patternHelper.fetchWordRecord, word);
        system.assertEquals(patternHelper.fetchSubstitutionValue, word.Substitution__c);
        system.assertEquals(patternHelper.fetchPreventPostOnMatch, word.Prevent_Post_on_Breach__c);
        system.assertEquals(patternHelper.fetchRegexValue, word.RegexValue__c);
        patternHelper.fetchOrigPostBody=post.Body;
        system.assertEquals(patternHelper.fetchOrigPostBody, post.Body);
        
        test.stopTest();
    }
}