public class ALL_BlacklistFilterDelegate
{
    private List<ALL_PatternHelper> patternsList;
    
    private Map<Id, ALL_PatternHelper> matchedPostsMap;
    
    public static Boolean isFromCode = false;
    
    public List<ALL_PatternHelper> fetchPatterns
    {
        set
        {
            patternsList=value;
        }
        get
        {
            return patternsList;
        }
    }
    
    public Map<Id, ALL_PatternHelper> fetchMatchedPosts
    {
        set
        {
            matchedPostsMap=value;
        }
        get
        {
            return matchedPostsMap;
        }
    }
    
    //This is the constructor of the Class.
    public ALL_BlacklistFilterDelegate()
    {
        //The patternsList is initialized.
        patternsList=new List<ALL_PatternHelper>();
        
        //The matchedPostsMap is initialized.
        matchedPostsMap=new Map<Id, ALL_PatternHelper>();
        
        //preparePatterns Method is invoked.
        preparePatterns();
    }
    
    //This method is invoked from the constructor.
    private void preparePatterns()
    {
        //All the Blacklisted Words which are having isActive=true are fetched using the below SOQL Query.
        List<Blacklisted_Word__c> blacklistedWordsList=[SELECT Word_or_Phrase__c, RegexValue__c, Substitution__c, Add_to_Compliance_Audit__c, Custom_Expression__c, Prevent_Post_on_Breach__c FROM Blacklisted_Word__c WHERE is_Active__c=true];
        
        for(Blacklisted_Word__c word: blacklistedWordsList)
        {
            //An instance of ALL_PatternHelper is created and blacklisted Words are passed to it one by one.
            ALL_PatternHelper patternHelper=new ALL_PatternHelper(word);
            
            //patternsList is created.
            patternsList.add(patternHelper);
        }
    }
    
    //This method is invoked from the Trigger ALL_FeedItem. It accepts a list of FeedItem records.
    //The records are then filtered against the Blacklisted Words.
    public List<FeedItem> filterFeedItems(List<FeedItem> feedItemList)
    {
        if(!ALL_BlacklistFilterDelegate.isFromCode)
        {
            //A list of FeedItem records is initialized.
            List<FeedItem> feedItemRecList=new List<FeedItem>();
            
            //The list of FeedItem records after being filtered by filterBodyForFeedItems method is fetched in the feedItemRecList.
            feedItemRecList=filterBodyForFeedItems(feedItemList);
            
            //The list is returned to the Trigger ALL_FeedItem.
            return feedItemRecList;
        }
        else 
        {
            return feedItemList;
        }
    }
    
    //This method is invoked from the filterFeedItems method.
    private List<FeedItem> filterBodyForFeedItems(List<FeedItem> feedItemList)
    {
        //This list of FeedItem is used for holding the updated records.
        List<FeedItem> updatedRecords=new List<FeedItem>();
        
        //The below String body will be used to hold the value of the Body field value of FeedItem record. Initially it is set to Null value.
        String body=Null;
        
        //The feedItemList is iterated.
        for(FeedItem feedItemRecord: feedItemList)
        {
            //The below Boolean variable is set to false.
            Boolean preventPost=false;
            
            //The below String is set as REGEX initially.
            String matchedWord='REGEX';
            
            //A Null Check is performed to prevent any further processing if the body of the post is Null.
            //If Null, it means that the Body field of the FeedItem is not set.
            if(feedItemRecord.Body!=Null)
            {
                //If the Body field of the FeedItem has valid value, it is copied to the String body.
                body=feedItemRecord.Body;
                
                //patternsList is iterated.
                for(ALL_PatternHelper patternHelper: patternsList)
                {
                    Matcher myMatcher=patternHelper.fetchPattern.matcher(body);
                    
                    if(myMatcher.find())
                    {
                        body=body.replaceAll(patternHelper.fetchRegexValue, patternHelper.fetchSubstitutionValue);
                        
                        if(!matchedPostsMap.containsKey(patternHelper.fetchWordRecord.Id))
                        {
                            patternHelper.fetchOrigPostBody=feedItemRecord.Body;
                            matchedPostsMap.put(patternHelper.fetchWordRecord.Id, patternHelper);
                        }
                        
                        //only need to set one message per breach - on the first breach
                        if(patternHelper.fetchPreventPostOnMatch)
                        {
                            if(!String.isEmpty(patternHelper.fetchWordRecord.Custom_Expression__c))
                            {
                                matchedWord='Custom Regular Expression';
                            }
                            else
                            {
                                matchedWord=patternHelper.fetchWordRecord.Word_or_Phrase__c;
                            }
                            
                            preventPost=true; 
                            break;
                        }
                    }
                }
            
                if(preventPost)
                {
                    feedItemRecord.addError('Post prevented due to use of a blacklisted word: '+matchedWord);
                }
                else
                {
                    feedItemRecord.Body=body;          
                }
                updatedRecords.add(feedItemRecord);
            }
        }
         
        doAudit();
        
        return updatedRecords;
    }
    
    //Given a list of FeedComments, filter them against the blacklisted words
    public List<FeedComment> filterFeedComments(List<FeedComment> feedCommentsList)
    {
        if(!isFromCode)
        {
            //A list of FeedItem records is initialized.
            List<FeedComment> feedCommRecList=new List<FeedComment>();
            
            //The list of FeedItem records after being filtered by filterBodyForFeedItems method is fetched in the feedItemRecList.
            feedCommRecList=filterBodyForFeedComments(feedCommentsList);
            
            //The list is returned to the Trigger ALL_FeedItem.
            return feedCommRecList;
        }
        else
        {
            return feedCommentsList;
        }
    }
    
    private List<FeedComment> filterBodyForFeedComments(List<FeedComment> feedCommentsList)
    {
        //This list of FeedComment is used for holding the updated records.
        List<FeedComment> updatedRecords=new List<FeedComment>();
        
        //The below String body will be used to hold the value of the Body field value of FeedComment record. Initially it is set to Null value.
        String body=Null;
        
        //The feedCommentsList is iterated.
        for (FeedComment feedCommRec: feedCommentsList)
        {
            //The below Boolean variable is set to false.
            Boolean preventPost=false;
            
            //The below String is set with Blank initially.
            String matchedWord='';
            
            //A Null Check is performed to prevent any further processing if the body of the comment is Null.
            //If Null, it means that the Body field of the FeedComment is not set.
            if(feedCommRec.CommentBody!=Null)
            {
                //If the Body field of the FeedComment has valid value, it is copied to the String body.
                body=feedCommRec.CommentBody;
                
                //patternsList is iterated.
                for(ALL_PatternHelper patrnHelper: patternsList)
                {
                    Matcher myMatcher=patrnHelper.fetchPattern.matcher(body);
                    
                    if(myMatcher.find())
                    {
                        body=body.replaceAll(patrnHelper.fetchRegexValue, patrnHelper.fetchSubstitutionValue);
                        
                        if(!matchedPostsMap.containsKey(patrnHelper.fetchWordRecord.Id))
                        {
                            patrnHelper.fetchOrigPostBody=feedCommRec.CommentBody;
                            matchedPostsMap.put(patrnHelper.fetchWordRecord.Id, patrnHelper);
                        }
                        
                        //Only need to set one message per breach on the first breach.
                        if(!preventPost)
                        {
                            if(patrnHelper.fetchPreventPostOnMatch)
                            {
                                preventPost=true;
                                matchedWord=patrnHelper.fetchWordRecord.Word_or_Phrase__c;
                            }
                        }
                    }
                }
                
                //If Prevent Post on Breach checkbox is checked on the Blacklisted Word Record, an error message is displayed to the User posting the Blacklisted Word. 
                if(preventPost)
                {
                    feedCommRec.addError('Comment prevented due to use of a blacklisted word: '+matchedWord);
                }
                else
                {
                    feedCommRec.CommentBody=body; 
                    updatedRecords.add(feedCommRec);
                }
            }
        }
        
        doAudit();
        
        return updatedRecords;
    }
    
    //Take the matched posts, serialize them (so we can send them to a future method), and async to insert into audit table
    //This allows us to insert audits even if the feeditem transaction rollsback.
    private void doAudit()
    {
        List<String> serializedPH=new List<String>();
        
        for(ALL_PatternHelper patternHelper: matchedPostsMap.values())
        {
            serializedPH.add(JSON.serialize(patternHelper.getSerializable()));
        }
        
        doAuditFuture(serializedPH);
    }
    
    //If a blacklisted word is flagged as save to audit, lets write it to the blacklist audit list.
    //Accepts a serialized list of pattern helpers.
    @future
    static void doAuditFuture(List<String> matchedPosts)
    {
        //This list is used to hold the Blacklist Audit records to be inserted.
        List<Blacklist_Audit__c> blacklistAuditList=new List<Blacklist_Audit__c>();
        
        //Deserialize and work with Pattern Helper.
        for(String serializedPosts: matchedPosts)
        {
            ALL_PatternHelperSerializable patternHelperSer=(ALL_PatternHelperSerializable)JSON.deserialize(serializedPosts, ALL_PatternHelperSerializable.class);
            
            //If the Add to Compliance Audit checkbox is checked on the Blacklisted Word Record, and if the word or phrase was used in a Chatter Post.
            //A Blacklisted Audit record should is created.
            if(patternHelperSer.blacklistedWord.Add_to_Compliance_Audit__c)
            {
                Blacklist_Audit__c blacklistAuditRec= new Blacklist_Audit__c();
                blacklistAuditRec.Breached_By__c=UserInfo.getUserId();
                blacklistAuditRec.Unscrubbed_Post__c=patternHelperSer.origPostBody;
                
                if(patternHelperSer.blacklistedWord.Custom_Expression__c!=Null)
                {
                    blacklistAuditRec.Blacklisted_Word_or_Expression__c=patternHelperSer.blacklistedWord.Custom_Expression__c;
                }
                else
                {
                    blacklistAuditRec.Blacklisted_Word_or_Expression__c=patternHelperSer.blacklistedWord.Word_or_Phrase__c;
                }
                
                blacklistAuditList.add(blacklistAuditRec);
            }
        }
        
        //If the blacklistAuditList contains some records, those are inserted in the database.
        if(!blacklistAuditList.isEmpty())
        {
            Database.SaveResult[] saveResultList=Database.insert(blacklistAuditList);
        }
    }
}