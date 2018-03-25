//2016-06-30- anirudh.singh@cdk.com- Created this class for RQ-07318 Community Builder (Lightning) Ideas Component.
public class EMP_Ideas_Controller
{
    @AuraEnabled
    public static List<Idea> fetchIdeaRecordsList(String communityName)
    {
        system.debug('Start fetchIdeaRecordsList---->'+communityName);
        Id selectedCommunityId=fetchCommunityId(communityName);
        
        system.debug('End fetchIdeaRecordsList---->');
        return fetchIdeasList(selectedCommunityId);
    }
    
    private static List<Idea> fetchIdeasList(Id selectedCommunityId)
    {
        List<Idea> ideaRecordsList=new List<Idea>([
            SELECT Id, CreatorSmallPhotoUrl, CreatorFullPhotoUrl, NumComments, Title, CreatorName, 
            CreatedDate, VoteScore, VoteTotal 
            FROM Idea 
            WHERE CommunityId=:selectedCommunityId
            ORDER BY CreatedDate DESC
        ]);
        
        return ideaRecordsList;
    }
    
    @AuraEnabled
    public static String fetchCurrentUserProfilePhotoUrl()
    {
        system.debug('Start fetchCurrentUserProfilePhotoUrl---->');
        User currentUser=[SELECT SmallPhotoUrl, FullPhotoUrl FROM User WHERE Id=:UserInfo.getUserId()];
        
        system.debug('End fetchCurrentUserProfilePhotoUrl---->');
        return currentUser.SmallPhotoUrl;
    }
    
    @AuraEnabled
    public static Idea fetchIdeaRecordDetail(Id selectedIdeaId)
    {
        system.debug('Start fetchIdeaRecordDetail---->');
        Idea ideaRecord=[
            SELECT Id, Title, Body, VoteTotal, AttachmentName, 
            (
                SELECT CreatorSmallPhotoUrl, CommentBody, CreatedDate 
                FROM Comments 
                ORDER BY CreatedDate
            ), 
            (
                SELECT Id, Type 
                FROM Votes 
                WHERE CreatedById=:UserInfo.getUserId()
            ) 
            FROM Idea 
            WHERE Id=:selectedIdeaId
        ];
        
        system.debug('End fetchIdeaRecordDetail---->');
        return ideaRecord;
    }
    
    @AuraEnabled
    public static IdeaWrapper createVote(String ideaId, String voteType, String communityName)
    {
        system.debug('Start createVote---->');
        IdeaWrapper ideaWrapperRecord=new IdeaWrapper();
        
        Vote userVote=new Vote();
        userVote.ParentId=ideaId;
        userVote.Type=voteType;
        Database.SaveResult userVoteInsertResult=Database.insert(userVote, false);
        
        if(!userVoteInsertResult.isSuccess())
        {
            //Operation failed, so get all errors.
            ideaWrapperRecord.errorMessage=processErrorMessages(userVoteInsertResult.getErrors());
        }
        else
        {
            //We can simply update the Idea Voted but that will not update the Vote Score calculated by internal Salesforce algorithm,
            //so, this is done so that the calculated Vote Score is also updated for all the Ideas.
            ideaWrapperRecord.ideasList=fetchIdeaRecordsList(communityName);
        }
        
        system.debug('End createVote---->');
        return ideaWrapperRecord;
    }
    
    @AuraEnabled
    public static IdeaWrapper saveIdeaComment(Id selectedIdeaId, String newIdeaComment)
    {
        system.debug('Start saveIdeaComment---->');
        
        IdeaComment ideaCommentRecord=new IdeaComment();
        ideaCommentRecord.IdeaId=selectedIdeaId;
        ideaCommentRecord.CommentBody=newIdeaComment;
        Database.SaveResult ideaCommentInsertResult=Database.insert(ideaCommentRecord, false);
        
        IdeaWrapper ideaWrapperRecord=new IdeaWrapper();
        
        if(ideaCommentInsertResult.isSuccess())
        {
            //Operation was successful, so get the ID of the record that was processed.
            ideaWrapperRecord.ideaCommentsList=[SELECT CreatorSmallPhotoUrl, CommentBody, CreatedDate FROM IdeaComment WHERE IdeaId=:selectedIdeaId ORDER BY CreatedDate];
        }
        else
        {
            //Operation failed, so get all errors.
            ideaWrapperRecord.errorMessage=processErrorMessages(ideaCommentInsertResult.getErrors());
        }
        
        system.debug('End saveIdeaComment---->');
        return ideaWrapperRecord;
    }
    
    @AuraEnabled
    public static IdeaWrapper createIdea(Idea newIdea, String communityName, String fileName, String base64Data, String contentType)
    {
        system.debug('Start createIdea---->');
        Id selectedCommunityId=fetchCommunityId(communityName);
        if(selectedCommunityId!=Null)
        {
            newIdea.CommunityId=selectedCommunityId;
        }
        
        if(base64Data!='')
        {
            base64Data=EncodingUtil.urlDecode(base64Data, 'UTF-8');
            
            newIdea.AttachmentName=fileName;
            newIdea.AttachmentBody=EncodingUtil.base64Decode(base64Data);
            newIdea.AttachmentContentType=contentType;
        }
        
        Database.SaveResult newIdeaInsertResult=Database.insert(newIdea, false);
        
        IdeaWrapper ideaWrapperRecord=new IdeaWrapper();
        if(newIdeaInsertResult.isSuccess())
        {
            //Operation was successful, so get the new List of Idea Records.
            ideaWrapperRecord.ideasList=fetchIdeasList(selectedCommunityId);
        }
        else
        {
            //Operation failed, so get all errors.
            ideaWrapperRecord.errorMessage=processErrorMessages(newIdeaInsertResult.getErrors());
        }
        
        system.debug('End createIdea---->'+ideaWrapperRecord);
        return ideaWrapperRecord;
    }
    
    private static Id fetchCommunityId(String communityName)
    {
        Id communityId;
        List<Community> communityList=new List<Community>([SELECT Id, Name FROM Community WHERE Name=:communityName]);
        if(communityList.size()>0)
        {
            communityId=communityList[0].Id;
        }
        return communityId;
    }
    
    private static String processErrorMessages(List<Database.Error> errorsList)
    {
        system.debug('Start processErrorMessages---->');
        String errorMessage='';
        
        for(Database.Error error: errorsList)
        {
            errorMessage+=((errorMessage=='')?'' : '\n')+error.getMessage();
        }
        
        system.debug('End processErrorMessages---->');
        return errorMessage;
    }
    
    public class IdeaWrapper
    {
        @AuraEnabled
        public List<Idea> ideasList{get; set;}
        
        @AuraEnabled
        public List<IdeaComment> ideaCommentsList{get; set;}
        
        @AuraEnabled
        public String errorMessage{get; set;}
        
        public IdeaWrapper()
        {
            ideasList=new List<Idea>();
            ideaCommentsList=new List<IdeaComment>();
            errorMessage='';
        }
    }
}