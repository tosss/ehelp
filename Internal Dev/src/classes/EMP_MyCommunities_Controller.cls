// 07/31/2017 - vishal.bandari@cdk.com -  commented and added some code - GLOBIT-1846
// 2017-08-02 matt.keefe@cdk.com - updated to 
// 2017-08-17 vijay.manimaran@cdk.com updated link 30 - 47 
public class EMP_MyCommunities_Controller {
    
    public List<CollaborationGroupMember> GroupMembership {get;set;}
    
    public EMP_MyCommunities_Controller(){
        GroupMembership = new list<CollaborationGroupMember>();
        //added for more test code coverage - vishal.bandari@cdk.com - GLOBIT-1846
        GroupMembership = getGroupsForCurrentUser(null);
        //commented for more test code coverage - vishal.bandari@cdk.com - GLOBIT-1846
        //GroupMembership = getGroupsForCurrentUser(UserInfo.getUserId(),Null);
        system.debug(' ');
    }
    
    @AuraEnabled
    public static list<CollaborationGroupMember> getGroupsForCurrentUser(String CommunityNetworkId) {
        system.debug('*CommunityNetworkId  : '+CommunityNetworkId);
        return getGroupsForCurrentUser(UserInfo.getUserId(),CommunityNetworkId);
        //commented to return right value - vishal.bandari@cdk.com - GLOBIT-1846
        //return null;
    }
    
    public static list<CollaborationGroupMember> getGroupsForCurrentUser(Id UserId, String CommunityNetworkId) {
        
        // 2017-08-02 matt.keefe@cdk.com - added condition check for network ID
        //   if CommunityNetworkId is blank, it is assumed all are requested, so check for != null
        //   if CommunityNetworkId is not blank, filter based on that CommunityNetworkId
        String NetworkCondition;
        if(CommunityNetworkId == null || CommunityNetworkId == '') {  
            NetworkCondition = 'AND CollaborationGroup.NetworkID != null ';
        }else{
            NetworkCondition = 'AND CollaborationGroup.NetworkID = :CommunityNetworkId ';
        }
        String Squery =' '+ 
            'SELECT MemberId, CollaborationGroupId, ' +
            'CollaborationGroup.Name, CollaborationGroup.NetworkID, CollaborationGroup.SmallPhotoUrl, CollaborationGroup.FullPhotoUrl,CollaborationGroup.IsArchived,' +
            'CollaborationGroup.CollaborationType, CollaborationGroup.Description, CollaborationGroup.InformationTitle, ' +
            'CollaborationGroup.InformationBody, CollaborationGroupMember.CollaborationGroup.OwnerId, ' +
            'CollaborationGroup.Network.UrlPathPrefix ' +
            'FROM CollaborationGroupMember ' + 
            'WHERE MemberId = :UserId ' +
            NetworkCondition + 
            'ORDER BY CollaborationGroup.name ASC ' ;
        list<CollaborationGroupMember> CollaborationGroupMembers= database.query(Squery);
        return CollaborationGroupMembers;
        
    }
}