/*
 * Author        : Vishal Bandari (vishal.bandari@cdk.com)
 * Description   : Controller of All Idea Component Pages like EMP_IdeaList,  EMP_IdeaDetail, EMP_IdeaNew and Idea_Section Component
 * Test Class    : EMP_Idea_Test
 * Code Coverage : 100%
 * Created Date  : 2016-02-10
 */

/* History
 * 2016-02-10    vishal.bandari@cdk.com Created Class and Methods
*/
public class EMP_IdeaController 
{
    //For Idea Section and Idea List Page
    public transient static List<IdeaWrapper> ideasList{get;set;}
    public transient static List<SelectOption> categoriesList{get;set;}
    public transient static String communityName{get;set;}
    
    //For Idea List Page
    public transient static Integer maxPages{get;set;}
    
    //For New Idea Page
    public transient static Idea newIdea{get;set;}
    
    public static String communityId {get; set;}
    public List<IdeaWrapper> ideas {get;set;}
    
    public String communityIdValue
    {
        get{
            return communityId;
        }
        set {
            communityId = value;
            communityName = getCommunityName(communityId);
            ideas = getIdeas(communityId);
        }
    }
    
    public EMP_IdeaController() {}
        
    public static List<IdeaWrapper> getIdeas(String ideaCommunityId) {
        List<IdeaWrapper> ideas = getIdeas(1,6,'all',ideaCommunityId);
        system.debug(ideas);
        return ideas;
    }
    
    /*
     * Parameters  : Page Number on the view
     *               Records Limit on each page
     *               Category of Ideas on the view
     *               CommunityId (Zone) of Ideas on the view
     * Description : This method finds the Vote casted by Current User on Current Idea
     * Returns     : None
    */
    public static List<IdeaWrapper> getIdeas( Integer pageNumber,Integer recordLimit,String category,String Community)
    {
        Integer offset = (pageNumber-1)*recordLimit;
        Map<Id,Idea> ideaMap;
        
        ideaMap= new Map<Id,Idea>((List<Idea>)(Database.Query(
            'SELECT Id, Title, CreatorName, VoteScore, CreatedById,'
            +'CommunityId, LastModifiedDate, VoteTotal, NumComments '
            +'FROM Idea '
            +'WHERE communityId=:Community '
            + (category=='all'?'':' '+'AND categories  includes (:category) ')
            +'ORDER BY VoteTotal desc LIMIT :recordLimit OFFSET :offset'
        )));
        
        ideasList = new List<IdeaWrapper>();
        
        List<Vote> voteList = [
            SELECT Id, Type, ParentId, CreatedById 
            FROM Vote 
            WHERE Parent.Type = 'Idea' 
            AND ParentId IN: ideaMap.keySet() 
            AND CreatedById =: UserInfo.getUserId()
        ];
        
        Map<Id,String> votePerIdea = new Map<Id,String>();
        
        for(Vote v : voteList)
        {
            votePerIdea.put(v.parentId,v.type); 
        }
        
        for(Id key : ideaMap.keySet())
        {
            IdeaWrapper ideaWrapperObject;
            Idea ideaObj = ideaMap.get(key);
            if(ideaObj.CreatedById == UserInfo.getUserId())
            {
                ideaWrapperObject = new IdeaWrapper(ideaObj, '');
            }
            else
            {
                ideaWrapperObject = new IdeaWrapper(ideaObj,(votePerIdea.get(key)==null?'':votePerIdea.get(key)));
            }
            ideasList.add(ideaWrapperObject);
        }
        return ideasList;
    }
        
    /*
     * Parameters  : CommunityId
     * Description : This method finds Community Name for a given CommunityId
     * Returns     : Community Name
    */
    @RemoteAction
    public static String getCommunityName(String community)
    {
        Community communityObject = [
            SELECT Name 
            FROM Community 
            WHERE Id=:community 
            LIMIT 1
        ];
        return communityObject.Name;
    }
    
    /*
     * Parameters  : Vote Type 'Up' or 'Down' 
     *               Idea Id
     * Description : This method votes for given Idea Id
     * Returns     : Community Name
    */
    @RemoteAction
    public static String Vote(String voteType,String ideaId)
    {
        
        Vote alreadyExistingVote = null;
        try
        {
            alreadyExistingVote = [
                SELECT Id 
                FROM Vote 
                WHERE ParentId=: IdeaId 
                AND Type!= :voteType 
                AND CreatedById =: UserInfo.getUserId()
            ];
        }
        catch(Exception e)
        {
            system.debug('Excpetion e: '+e.getMessage()+' at '+e.getLineNumber());
        }
        if(alreadyExistingVote!=null)
        {
            delete alreadyExistingVote;
        }
        Vote v = new Vote(parentId = ideaId,type=voteType);
        insert v;
        
        Integer upVotes = [
            SELECT Id 
            FROM Vote 
            WHERE parentId =: ideaId 
            AND Type = 'Up'
        ].size();
        Integer downVotes = [
            SELECT Id 
            FROM Vote 
            WHERE parentId =: ideaId 
            AND Type = 'Down'
        ].size();
        
        Integer Total = upVotes-downVotes;
        return  '+'+upVotes+','+Total+',-'+downVotes;
    }
        
    //Wrapper Class to hold Idea and its Vote Information
    class IdeaWrapper
    {
        public Idea IdeaObj{get;set;}
        public String VoteType{get;set;}
        public String CreatorName {get;set;}
        public IdeaWrapper(Idea IdeaObj,String VoteType)
        {
            this.IdeaObj = IdeaObj;
            this.VoteType = VoteType;
        }
    }
}