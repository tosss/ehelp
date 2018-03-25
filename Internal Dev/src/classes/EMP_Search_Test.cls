@isTest
public class EMP_Search_Test {
  	@testSetup static void prepareTestData()
    {
        CollaborationGroup oCG = new CollaborationGroup(
            Name = 'unique testGroup',  
            CanHaveGuests = false,
            IsArchived= false,
            OwnerId= UserInfo.getUserId(),
            NetworkId = Network.getNetworkId(),
            CollaborationType = 'public'
        );
        insert oCG;
        
    	List<FeedItem> someFeeds = new List<FeedItem>();
        for(Integer ctr=0; ctr<5; ctr++)
        {
            FeedItem oFI = new FeedItem();
            oFI.ParentId = oCG.Id;
            oFI.Title = 'test ' + ctr;
      		oFI.Body = 'test ' + ctr;
      		oFI.Type = 'TextPost';
            someFeeds.add(oFI);
        }
		insert someFeeds;
        system.debug('someFeeds: ' + someFeeds);
        
        List<FeedComment> someFeedComments = new List<FeedComment>();
        for(Integer ctr=0; ctr<5; ctr++)
        {
            FeedComment oFC = new FeedComment();
      		oFC.CommentBody = 'legal test';
      		oFC.FeedItemId = someFeeds[0].Id;
            someFeedComments.add(oFC);
        }
		insert someFeedComments;
    }
    
    static testMethod void testSearchFromPage() 
    {
        test.startTest();
        
        PageReference pageRef = Page.EMP_Search;
        pageRef.getParameters().put('str', 'test');
		Test.setCurrentPage(pageRef);
        EMP_Search_Controller ctrSearch = new EMP_Search_Controller();
        
        test.stopTest();
    }
    
    static testMethod void testSearch() 
    {
        test.startTest();
        
        EMP_Search_Controller cntl = new EMP_Search_Controller();
        List<SelectOption> optns = cntl.getChatterGroupOptions();
        List<FeedItem> allFeeds = EMP_Search_Controller.searchChatterFeeds('test', '');
        system.debug('allFeeds: ' + allFeeds);
        system.debug('allFeeds size is: ' + allFeeds.size());

        List<EMP_Search_Controller.FeedItemWrapper> retrieveAllFeeds = new List<EMP_Search_Controller.FeedItemWrapper>();
        retrieveAllFeeds = EMP_Search_Controller.retrieveAllPosts('test', '');
        system.debug(retrieveAllFeeds);
        system.assertNotEquals(retrieveAllFeeds, null);
        Map<String, List<EMP_Search_Controller.FeedItemWrapper>> allFeedItemWrappers = EMP_Search_Controller.transformRetrieveAllPosts(retrieveAllFeeds);
        
        test.stopTest();
    }
}