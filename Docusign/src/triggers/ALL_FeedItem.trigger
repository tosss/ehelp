trigger ALL_FeedItem on FeedItem(after insert, before insert)
{ 
    //Author: Anirudh Singh
    //Date  : 8th Oct, 2014 
    //Description: This trigger is used to create Cases from Chatter Feed, if words like assist, help and support are used.
    //This trigger is also used for Chatter Blacklist functionality.
    
    if(!System.isBatch() && !System.isFuture())
    {
        //This IF Block is used for Chatter to Case functionality. The below IF Block is executed for after insert.
        if(Trigger.isAfter) 
        {
            //The below map is used for holding the Ids of the FeedItems as Key and Cases as values.
            Map<Id, Case> casesMap=new Map<Id, Case>();
            
            //This Map is used to hold all the Keywords for which a Case should be created, if these keywords are used in the Chatter Posts.
            Map<String, DS_Chatter_to_Case_Keywords__c> allKeywordsMap=DS_Chatter_to_Case_Keywords__c.getAll();
            
            //The list of Chatter Feeds inserted are iterated.
            for(FeedItem feedItem: Trigger.New)
            {
                //The body of the post is checked if it is not Null, so that a Case can be created.
                //If the body of the post is Null, no case should be created.
                if(feedItem.Body!=Null)
                {
                    system.debug('ParentId---->'+feedItem.ParentId);
                    //A custom setting named Chatter to Case Keywords is used for storing the keywords.
                    //The keywords are iterated and it is checked whether the body of the post contains any of the keywords with # at the beginning of the keyword,
                    //Like if help is the keyword, #help will be checked, similarly for other keywords # will be required at the beginning.
                    for(DS_Chatter_to_Case_Keywords__c word: allKeywordsMap.values())
                    {
                        //The keyword is appended to add # at the beginning of it.
                        String keywordWithHash='#'+word.Name.toLowerCase();
                        
                        //If the Keyword is at the 0th position of the post, it should contain a space after it.
                        //Therefore, the keyword is appended to add a space at the end of it.
                        String keywordWithHashAndSpaceAtEnd=keywordWithHash+' ';
                        
                        //If the Keyword is at the last position of the post, it should contain a space before it.
                        //Therefore, the keyword is appended to add a space at the beginning of it.
                        String keywordWithHashAndSpaceAtStart=' '+keywordWithHash;
                        
                        //If the Keyword is in the middle position of the post, it should contain a space before and after it.
                        //Therefore, the keyword is appended to add a space at the beginning and end of it.
                        String keywordWithHashAndSpaceAtBothSides=' '+keywordWithHash+' ';
                        
                        //This is used to determine the position of the keyword.
                        Integer positionOfKeyword=feedItem.Body.indexOf(keywordWithHash);
                        
                        //If the keyword is the last word of the post, then adding the position of it and the length together will be equal to the total length of the post.
                        Integer positionOfKeywordIfPlacedAtLast=positionOfKeyword+keywordWithHash.length();
                        
                        //If the keyword constitutes the whole of the post body, i.e. the post body only contains the keyword like #assist, #help or #support.
                        //The length of the post body will be equal to the length of the keywordWithHash.
                        //If the length of the body is greater than keywordWithHash length, this means that the keyword is either placed at the start, end or middle of the body.
                        if((feedItem.Body.length()==keywordWithHash.length() && feedItem.Body.toLowerCase().contains(keywordWithHash)) || (feedItem.Body.length()>keywordWithHash.length() && ((positionOfKeywordIfPlacedAtLast==feedItem.Body.length() && feedItem.Body.toLowerCase().contains(keywordWithHashAndSpaceAtStart)) || (positionOfKeyword==0 && feedItem.Body.toLowerCase().contains(keywordWithHashAndSpaceAtEnd)) || feedItem.Body.toLowerCase().contains(keywordWithHashAndSpaceAtBothSides))))
                        {
                            Case newCase=new Case();
                            newCase.Subject=UserInfo.getFirstName()+' '+UserInfo.getLastName()+' submitted a Case via Chatter.';
                            newCase.Description=feedItem.Body;
                            newCase.Case_Category__c='Associate Portal';
                            
                            Id HRCaseRecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get(word.Case_Record_Type__c).getRecordTypeId();
                            
                            if(HRCaseRecordTypeId!=Null)
                            {
                                newCase.RecordTypeId=HRCaseRecordTypeId;
                            }
                            
                            casesMap.put(feedItem.Id, newCase);
                            break;
                        }
                    }
                }
            }
            
            //The Map casesToBeInsertedByFeedItem is checked, if it is not empty. The Cases are inserted.
            if(!casesMap.isEmpty())
            {
                insert casesMap.values();
            }
            
            //This list is used to hold the Feed Comments to notify the user that a Case has been created for the post.
            List<FeedComment> feedCommentsList=new List<FeedComment>();
            
            //The Map casesToBeInsertedByFeedItem is iterated.
            for(Id feedItemId: casesMap.keySet())
            {
                Case caseRecord=casesMap.get(feedItemId);
                
                FeedComment feedComment=new FeedComment();
                feedComment.FeedItemId=feedItemId;
                String caseURL=System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+caseRecord.Id;
                feedComment.CommentBody='A new Case has been submitted on your behalf. Case Id: '+caseRecord.Id+'. To go to the case, please click on the following URL: '+caseURL;
                feedCommentsList.add(feedComment);
            }
            
            //The FeedComments are inserted.
            insert feedCommentsList;
        }
        
        //This IF Block is used for Chatter Blacklist functionality. The below IF Block is executed for before insert.
        if(Trigger.isBefore)
        {
            //An instance of ALL_BlacklistFilterDelegate class is created.
            ALL_BlacklistFilterDelegate blacklistFilterDelegate=new ALL_BlacklistFilterDelegate();
            
            //filterFeedItems method of ALL_BlacklistFilterDelegate class is invoked and the list of FeedItem records are passed.
            blacklistFilterDelegate.filterFeedItems(Trigger.New);
        }
    }
}