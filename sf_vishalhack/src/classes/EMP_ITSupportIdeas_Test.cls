@isTest
public class EMP_ITSupportIdeas_Test {
    testMethod static void testLoadData() 
    {
        string chatterId = generateCustomSettings();
        test.startTest();
        EMP_ITSupport_Ideas_Controller controller = new EMP_ITSupport_Ideas_Controller();
        test.stopTest();
        system.assertEquals(controller.ideaList.size(),5);        
    }
    
    private static string generateCustomSettings()
    {   
        Community commId = [Select Id from Community where Name ='IT Support Community'];
        List<Idea> lstIdea = new List<Idea>();
        for(Integer ctr= 0; ctr < 5; ctr++)
        {
            Idea ideas = new Idea();        
            ideas.Body = 'Test body ' + ctr;
            ideas.Title = 'Test ' + ctr;
            ideas.CommunityId = commId.Id;
            lstIdea.add(ideas);
        }
        insert lstIdea;
        
        EMP_IT_Support__c it = new EMP_IT_Support__c();
        it.Name = 'Idea';
        it.Id__c = commId.Id;
        insert it;
        return it.Id__c;
    }
}