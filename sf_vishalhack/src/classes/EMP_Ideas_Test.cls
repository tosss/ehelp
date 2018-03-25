//2016-07-08- anirudh.singh@cdk.com- Created this test class for RQ-07318 Community Builder (Lightning) Ideas Component.
@isTest
public class EMP_Ideas_Test
{
    @TestSetup
    private static void setupData()
    {
        User newUser=DS_TestObjects.NewUser();
        newUser.FirstName='EMP_Ideas_TestUser';
        insert newUser;
        
        List<Idea> ideaList=new List<Idea>();
        Community supportCommunity=[SELECT Id, Name FROM Community WHERE Name='IT Support Community'];
        
        for(Integer i=0; i<5; i++)
        {
            Idea ideaRecord=new Idea();
            ideaRecord.Title='Sample Title'+i;
            ideaRecord.Body='Sample Idea Body'+i;
            ideaRecord.CommunityId=supportCommunity.Id;
            ideaList.add(ideaRecord);
        }
        insert ideaList;
    }
    
    private static testMethod void fetchIdeaRecordsList()
    {
        List<Idea> ideaRecordsList=[SELECT Id FROM Idea ORDER BY CreatedDate DESC];
        Community supportCommunity=[SELECT Id, Name FROM Community WHERE Name='IT Support Community'];
        
        Test.startTest();
        List<Idea> fetchedIdeaRecordsList=EMP_Ideas_Controller.fetchIdeaRecordsList(supportCommunity.Name);
        system.assertEquals(ideaRecordsList.size(), fetchedIdeaRecordsList.size());
        Test.stopTest();
    }
    
    private static testMethod void fetchIdeaRecordDetailList()
    {
        List<Idea> ideaRecordsList=[SELECT Id FROM Idea ORDER BY CreatedDate DESC];
        
        Test.startTest();
        Idea fetchedIdea=EMP_Ideas_Controller.fetchIdeaRecordDetail(ideaRecordsList[1].Id);
        system.assertEquals(ideaRecordsList[1].Id, fetchedIdea.Id);
        Test.stopTest();
    }
    
    private static testMethod void fetchCurrentUserProfilePhotoUrlTest()
    {
        User currentUser=[SELECT SmallPhotoUrl, FullPhotoUrl FROM User WHERE Id=:UserInfo.getUserId()];
        
        Test.startTest();
        String currentUserProfilePhotoUrl=EMP_Ideas_Controller.fetchCurrentUserProfilePhotoUrl();
        system.assertEquals(currentUser.SmallPhotoUrl, currentUserProfilePhotoUrl);
        Test.stopTest();
    }
    
    private static testMethod void saveIdeaCommentTestOne()
    {
        Test.startTest();
        EMP_Ideas_Controller.IdeaWrapper ideaWrapperRecord=EMP_Ideas_Controller.saveIdeaComment(Null, 'Test Comment');
        system.assert(ideaWrapperRecord.errorMessage.containsIgnoreCase('missing required field'));
        Test.stopTest();
    }
    
    private static testMethod void saveIdeaCommentTestTwo()
    {
        List<Idea> ideaRecordsList=[SELECT Id FROM Idea ORDER BY CreatedDate DESC];
        
        Test.startTest();
        EMP_Ideas_Controller.IdeaWrapper ideaWrapperRecord=EMP_Ideas_Controller.saveIdeaComment(ideaRecordsList[2].Id, 'Test Comment');
        List<IdeaComment> ideaCommentsList=[SELECT Id FROM IdeaComment WHERE IdeaId=:ideaRecordsList[2].Id ORDER BY CreatedDate DESC];
        
        system.assertEquals(ideaWrapperRecord.ideaCommentsList.size(), ideaCommentsList.size());
        system.assertEquals(ideaWrapperRecord.errorMessage, '');
        Test.stopTest();
    }
    
    private static testMethod void saveIdeaCommentTestThree()
    {
        User newUser=[SELECT Id, FirstName FROM User WHERE FirstName LIKE '%EMP_Ideas_TestUser%'];
        List<Idea> ideaRecordsList=[SELECT Id FROM Idea ORDER BY CreatedDate DESC];
        
        Test.startTest();
        EMP_Ideas_Controller.IdeaWrapper ideaWrapperRecord=new EMP_Ideas_Controller.IdeaWrapper();
        system.runAs(newUser)
        {
            ideaWrapperRecord=EMP_Ideas_Controller.saveIdeaComment(ideaRecordsList[1].Id, 'Test Comment 1');
        }
        
        List<IdeaComment> ideaCommentsList=[SELECT Id FROM IdeaComment WHERE IdeaId=:ideaRecordsList[1].Id ORDER BY CreatedDate DESC];
        
        system.assertEquals(ideaWrapperRecord.ideaCommentsList.size(), ideaCommentsList.size());
        system.assertEquals(ideaWrapperRecord.errorMessage, '');
        Test.stopTest();
    }
    
    private static testMethod void createIdeaTestOne()
    {
        Community supportCommunity=[SELECT Id, Name FROM Community WHERE Name='IT Support Community'];
        
        Test.startTest();
        //
        EMP_Ideas_Controller.IdeaWrapper ideaWrapperRecord=EMP_Ideas_Controller.createIdea(new Idea(), supportCommunity.Name, '', '', '');
        system.assert(ideaWrapperRecord.errorMessage.containsIgnoreCase('Required fields are missing'));
        Test.stopTest();
    }
    
    private static testMethod void createIdeaTestTwo()
    {
        Community supportCommunity=[SELECT Id, Name FROM Community WHERE Name='IT Support Community'];
        
        Test.startTest();
        //
        EMP_Ideas_Controller.IdeaWrapper ideaWrapperRecord=EMP_Ideas_Controller.createIdea(new Idea(Title='Test New Idea'), supportCommunity.Name, 'test', 'werffafse=', 'image/jpeg');
        List<Idea> ideaRecordsList=[SELECT Id FROM Idea ORDER BY CreatedDate DESC];
        
        system.assertEquals(ideaWrapperRecord.ideasList.size(), ideaRecordsList.size());
        system.assertEquals(ideaWrapperRecord.errorMessage, '');
        Test.stopTest();
    }
    
    private static testMethod void createVoteTestOne()
    {
        List<Idea> ideaRecordsList=[SELECT Id FROM Idea ORDER BY CreatedDate DESC];
        Community supportCommunity=[SELECT Id, Name FROM Community WHERE Name='IT Support Community'];
        
        Test.startTest();
        EMP_Ideas_Controller.IdeaWrapper ideaWrapperRecord=EMP_Ideas_Controller.createVote(ideaRecordsList[3].Id, 'Up', supportCommunity.Name);
        
        system.assert(ideaWrapperRecord.errorMessage.containsIgnoreCase('duplicate value found'));
        Test.stopTest();
    }
    
    private static testMethod void createVoteTestTwo()
    {
        User newUser=[SELECT Id, FirstName FROM User WHERE FirstName LIKE '%EMP_Ideas_TestUser%'];
        List<Idea> ideaRecordsList=[SELECT Id FROM Idea ORDER BY CreatedDate DESC];
        Community supportCommunity=[SELECT Id, Name FROM Community WHERE Name='IT Support Community'];
        
        Test.startTest();
        EMP_Ideas_Controller.IdeaWrapper ideaWrapperRecord=new EMP_Ideas_Controller.IdeaWrapper();
        system.runAs(newUser)
        {
            ideaWrapperRecord=EMP_Ideas_Controller.createVote(ideaRecordsList[3].Id, 'Up', supportCommunity.Name);
        }
        Test.stopTest();
        
        Idea updatedIdeaRecord=[SELECT Id, VoteTotal FROM Idea WHERE Id=:ideaRecordsList[3].Id];
        
        //system.assertEquals(ideaWrapperRecord.ideaTotalVotes, updatedIdeaRecord.VoteTotal);
    }
}