public class IdeaDetailController
{
    public transient Idea ideaObj{get;set;}
    private transient Id ideaId;
    public transient List<IdeaComment> commentsList{get;set;}
    public transient Integer likes{get;set;}
    public transient String likedByCurrentUser{get;set;}
    public transient Map<String,String> userVotes{get;set;}
    public transient IdeaComment newComment{get;set;}
    public IdeaDetailController()
    {
        ideaId = ApexPages.currentPage().getParameters().get('ideaId');
    }
    public void init()
    {
        ideaObj = [Select id, body,votetotal, title,isHtml, creatorname,lastmodifiedDate, creatorsmallphotourl, votescore from idea where id=: ideaId];
        commentsList = [Select id,commentBody,isHtml,creatorsmallphotourl, creatorname,createddate, Upvotes from IdeaComment where ideaid =: ideaId order by createddate desc];
        likes = [select id from vote where parentId =: ideaId and type='Up'].size();    
        List<Vote> votesList= [select id,parentId,type from vote where parent.type='IdeaComment' and CreatedById =: UserInfo.getUserId()];
        List<Vote> votedByUser = [select id,type from Vote where parentId=: ideaId and CreatedById =: UserInfo.getUserId()];
        if(votedByuser!=null && votedByuser.size()>0)
        {
            if(votedByuser[0].type=='Up')
            {
                likedByCurrentUser ='Up';
            }
            else
            {
                likedByCurrentUser ='Down';
            }
        }
        else
        {
            likedByCurrentUser ='None';
        }
        userVotes = new Map<String,String>();
        for(vote voteObj: votesList)
        {
            if(voteObj.type == 'Up')
            {
                userVotes.put(String.valueof(voteObj.parentId).substring(0,15),'Up');
            }
            else
            {
                userVotes.put(String.valueof(voteObj.parentId).substring(0,15),'Down');
            }  
        }
        for(IdeaComment commentObj: commentsList)
        {
            if(!userVotes.keySet().contains(String.valueof(commentObj.id).substring(0,15)))
            {
                userVotes.put(String.valueof(commentObj.id).substring(0,15),'None');
            } 
        }
    }
    @RemoteAction
    public static String addComment(String commentBody,String IdeaId)
    {
        IdeaComment newComment = new IdeaComment();
        newComment.CommentBody = commentBody;
        newComment.IdeaId =  IdeaId;
        try
        {
            insert newComment;
            newComment = [Select commentBody,isHtml,creatorsmallphotourl, creatorname,createddate, Upvotes from IdeaComment where id =: newComment.Id];
            return JSON.serializePretty(newComment);
        }
        catch(Exception e)
        {
            system.debug('Excpetion e: '+e.getMessage()+' at '+e.getLineNumber());
            return null;
        }
    }
    
    @RemoteAction
    public static Boolean Vote(String voteType,String parentId)
    {
        Vote newVote = new Vote();
        newVote.ParentId = parentId;
        newVote.Type = voteType;
        try
        {
            insert newVote;
            return true;
        }
        catch(Exception e)
        {
            system.debug('Excpetion e: '+e.getMessage()+' at '+e.getLineNumber());
            return false;
        }
    }
    
    @RemoteAction
    public static Boolean removeVote(String parentId)
    {
        try
        {
            Vote voteObj = [Select id  from vote where ParentId =: parentId and Type=: 'Up'];
            delete voteObj;
            return true;
        }
        catch(Exception e)
        {
            system.debug('Excpetion e: '+e.getMessage()+' at '+e.getLineNumber());
            return false;
        }
    }
}