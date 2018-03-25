@IsTest
public class EMP_Idea_Test 
{
    @TestSetup
    private static void setupTestData()
    {
        User newUser = DS_TestObjects.NewUser();
        insert newUser;
        
        Id communityId;
        Idea ideaObject;
        System.runAs(newUser)
        {
            communityId = [select id, name from community where name = 'Internal Ideas'][0].Id;
            Idea ideaObj = new Idea();
            ideaObj.Title = 'Sample Title';
            ideaobj.Body = 'Sample Idea Body';
            ideaObj.Categories = 'Others';
            ideaObj.CommunityId = communityId;
            insert ideaObj;
        }
    }
    
    public static testmethod void tes1()
    {
        EMP_IdeaController empController = new EMP_IdeaController();
        Idea ideaObject;
        Id communityId = [select id, name from community where name = 'Internal Ideas'][0].Id;
        ideaObject = [select id from Idea where communityId =: communityId];
        String communityName = EMP_IdeaController.getCommunityName(communityId);
        
        EMP_IdeaController.newIdea = ideaObject;
        EMP_IdeaController.Vote('Down', ideaObject.Id);
        EMP_IdeaController.Vote('Up', ideaObject.Id);
        EMP_IdeaController.getIdeas(CommunityId);
    }
}