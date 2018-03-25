//2017-05-19- anirudh.singh@cdk.com- Created this class for RQ-09062.
public class EMP_GroupMembers_Controller
{
    @AuraEnabled
    public static FieldsCommunityInfoWrapper fetchGrpMembrsFieldsList()
    {
        List<EMP_GroupMembersFields__c> grpMembrsFieldsList=new List<EMP_GroupMembersFields__c>([
            SELECT Name, Field_Label__c, Order__c 
            FROM EMP_GroupMembersFields__c
            ORDER BY Order__c ASC
        ]);
        
        FieldsCommunityInfoWrapper wrapperRec=new FieldsCommunityInfoWrapper();
        String networkUrl=(Network.communitiesLanding()!=Null) ? Network.communitiesLanding().getUrl() : Null;
        wrapperRec.communityUrl=(String.isNotBlank(networkUrl)) ? networkUrl+'profile/' : URL.getSalesforceBaseUrl().toExternalForm()+'/';
        wrapperRec.grpMembrsFieldsList=grpMembrsFieldsList;
        
        return wrapperRec;
    }
    
    @AuraEnabled
    public static List<CollaborationGroupMember> fetchGrpMembrsList(String groupId)
    {
        List<CollaborationGroupMember> grpMembrsList=new List<CollaborationGroupMember>([
            SELECT Id, MemberId, Member.SmallPhotoURL, Member.Name, Member.Title, Member.CompanyName, CollaborationRole 
            FROM CollaborationGroupMember WHERE CollaborationGroupId=:groupId
        ]);
        
        return grpMembrsList;
    }
    
    @AuraEnabled
    public static String saveMembership(String membershipType, String grpMemberId)
    {
        String result='';
        
        CollaborationGroupMember memberRec=new CollaborationGroupMember();
        memberRec.Id=grpMemberId;
        memberRec.CollaborationRole=membershipType;
        
        try
        {
            update memberRec;
        }
        catch(Exception ex)
        {
            result=ex.getMessage();
        }
        
        return result;
    }
    
    @AuraEnabled
    public static String deleteMember(String grpMemberId)
    {
        String result='';
        
        List<CollaborationGroupMember> grpMembrsList=new List<CollaborationGroupMember>([
            SELECT Id FROM CollaborationGroupMember WHERE Id=:grpMemberId
        ]);
        
        try
        {
            if(grpMembrsList.size()>0)
            {
                delete grpMembrsList[0];
            }
        }
        catch(Exception ex)
        {
            result=ex.getMessage();
        }
        
        return result;
    }
    
    public class FieldsCommunityInfoWrapper
    {
        @AuraEnabled
        public String communityUrl{get; set;}
        
        @AuraEnabled
        public List<EMP_GroupMembersFields__c> grpMembrsFieldsList{get; set;}
    }
}