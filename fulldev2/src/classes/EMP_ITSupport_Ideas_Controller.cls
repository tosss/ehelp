/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: 
Test Class: 
History
12/11/14    Rey Austral      Created
------------------------------------------------------------*/
public class EMP_ITSupport_Ideas_Controller
{
    public String communityUrl { get; set; }
    public List<Idea> ideaList { get; set; }   
    
    public EMP_ITSupport_Ideas_Controller()
    {        
        EMP_IT_Support__c cs = [Select name, ID__c from EMP_IT_Support__c where name = 'Idea' Limit 1];
        ideaList = [Select Id, Title,Body from Idea where CommunityId =: cs.ID__c order by VoteScore desc LIMIT 5 ];
       
        communityUrl = Site.getBaseUrl();	
        
    }
}