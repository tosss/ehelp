/***********************************************************************
12/23/2016 created vijay.manimaran@cdk.com chattersearch for communities
***********************************************************************/

@isTest
public class EMP_ChatterSearch_Test {
    
    @testSetup static void prepareTestData()
    {
        CollaborationGroup oCG = new CollaborationGroup(
            Name = 'testGroup_1 ',  
            CanHaveGuests = false,
            IsArchived= false,
            OwnerId= UserInfo.getUserId(),
            CollaborationType = 'public'
        );
        insert oCG;
        
        List<FeedItem> someFeeds = new List<FeedItem>();
        for(Integer ctr=0; ctr<5; ctr++)
        {
            FeedItem oFI = new FeedItem();
            oFI.ParentId = oCG.Id;
            oFI.Title = 'test ';
            oFI.Body = 'test ';
            oFI.Type = 'TextPost';
            someFeeds.add(oFI);
        }
        insert someFeeds;

        List<FeedComment> someFeedComments = new List<FeedComment>();
        for(Integer ctr=0; ctr<5; ctr++)
        {
            FeedComment oFC = new FeedComment();
            oFC.CommentBody = 'test';
            oFC.FeedItemId = someFeeds[0].Id;
            someFeedComments.add(oFC);
        }
        insert someFeedComments;
    }
 
   public static testMethod void testSearch() 
    {
        test.startTest();
            
        EMP_ChatterSearch_Controller cntl = new EMP_ChatterSearch_Controller();
        cntl.searchTerm ='test';
        List<FeedItem> allFeeds = EMP_ChatterSearch_Controller.searchChatterFeeds('test');
        FeedItem fs =[select id,body, createdbyId from feeditem limit 1];
        Id[] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = fs.Id;
        
        Test.setFixedSearchResults(fixedSearchResults);
        List<List<SObject>> searchList = [FIND 'Hey'
                                          IN ALL FIELDS RETURNING
                                          Feeditem(id)];
        system.assert(searchList[0].size() > 0);
        
        List<EMP_ChatterSearch_Controller.FeedItemWrapper> retrieveAllFeeds = new List<EMP_ChatterSearch_Controller.FeedItemWrapper>();
        retrieveAllFeeds = EMP_ChatterSearch_Controller.retrieveAllPosts('test');
        system.assertNotEquals(retrieveAllFeeds, null);
        
        test.stopTest();
    }
}