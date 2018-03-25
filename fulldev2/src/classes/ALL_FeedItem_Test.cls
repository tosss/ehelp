@isTest
private class ALL_FeedItem_Test
{
    //Author: Anirudh Singh
    //Date  : 14th Oct, 2014 
    //Description: This is the test class for the Trigger named ALL_FeedItem.
    
    //The below method is used to cover the Chatter to Case functionality.
    static testMethod void validateChatterToCase()
    {     
        List<DS_Chatter_to_Case_Keywords__c> keywordsList=new List<DS_Chatter_to_Case_Keywords__c>();
        
        DS_Chatter_to_Case_Keywords__c keyword=new DS_Chatter_to_Case_Keywords__c();
        keyword.Name='help';
        keyword.Case_Record_Type__c='HR';
        keywordsList.add(keyword);
        
        DS_Chatter_to_Case_Keywords__c newKeyword=new DS_Chatter_to_Case_Keywords__c();
        newKeyword.Name='assist';
        newKeyword.Case_Record_Type__c='HR';
        keywordsList.add(newKeyword);
        
        insert keywordsList;
        
        test.startTest();
        FeedItem feedItem=new FeedItem();
        feedItem.Body='this is #help';
        feedItem.ParentId=UserInfo.getUserId();
        insert feedItem;
        test.stopTest();
    }
    
    //The below method is used to cover the Chatter Blacklist functionality, when Blacklisted Word or Phrase is substituted by some text and the post is allowed to be inserted.
    //Also, a Blacklist Audit record is created.
    static testMethod void validateCBWhenAllowingPost()
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
        secondWord.Custom_Expression__c='\b([t|T][e|E][s|S][t|T])\b';
        secondWord.is_Active__c=true;
        secondWord.Add_to_Compliance_Audit__c=true;
        secondWord.Match_Whole_Words_Only__c=false;
        secondWord.Substitution__c='****';
        wordList.add(secondWord);
        
        Blacklisted_Word__c thirdWord=new Blacklisted_Word__c();
        thirdWord.Word_or_Phrase__c='all this stuff';
        thirdWord.is_Active__c=true;
        thirdWord.Add_to_Compliance_Audit__c=true;
        thirdWord.Match_Whole_Words_Only__c=true;
        thirdWord.Substitution__c='****';
        wordList.add(thirdWord);
        insert wordList;
        
        List<FeedItem> feedItemList=new List<FeedItem>();
        
        test.startTest();
        FeedItem firstPost=new FeedItem();
        firstPost.Body='this is what i hate';
        firstPost.ParentId=UserInfo.getUserId();
        feedItemList.add(firstPost);
        
        FeedItem secondPost=new FeedItem();
        secondPost.Body='tested this';
        secondPost.ParentId=UserInfo.getUserId();
        feedItemList.add(secondPost);
        
        FeedItem thirdPost=new FeedItem();
        thirdPost.Body='all this stuff will go waste';
        thirdPost.ParentId=UserInfo.getUserId();
        feedItemList.add(thirdPost);
        
        FeedItem fourthPost=new FeedItem();
        fourthPost.Body='all this stuff is test';
        fourthPost.ParentId=UserInfo.getUserId();
        feedItemList.add(fourthPost);
        
        insert feedItemList;
        test.stopTest();
    }
    
    //The below method is used to cover the Chatter Blacklist functionality, when the post with the Blacklisted Word or Phrase is not allowed to be inserted.
    //Blacklist Audit record is also not created.
    static testMethod void validateCBWhenPreventingPost()
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
        FeedItem firstPost=new FeedItem();
        firstPost.Body='kill this test';
        firstPost.ParentId=UserInfo.getUserId();
        try
        {
            insert firstPost;
        }
        catch(Exception ex)
        {
            Boolean expectedError;
            if(ex.getMessage().contains('Post prevented due to use of a blacklisted word: '))
            {
                expectedError=true;
            }
            System.AssertEquals(expectedError, true);
        }
        test.stopTest();
    }
}