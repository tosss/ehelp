public class EMP_MyCommunities_Controller {
    
    public List<CollaborationGroupMember> GroupMembership {get;set;}
    
    public EMP_MyCommunities_Controller(){
        GroupMembership = new list<CollaborationGroupMember>();
        GroupMembership = [ 
            select MemberId, CollaborationGroupId, 
                CollaborationGroup.Name, CollaborationGroup.NetworkID, CollaborationGroup.SmallPhotoUrl, CollaborationGroup.FullPhotoUrl, 
                CollaborationGroup.CollaborationType, CollaborationGroup.Description, CollaborationGroup.InformationTitle, 
                CollaborationGroup.InformationBody, CollaborationGroupMember.CollaborationGroup.OwnerId, 
                CollaborationGroup.Network.UrlPathPrefix 
            from CollaborationGroupMember 
            where MemberId = :UserInfo.getUserId() AND CollaborationGroup.NetworkID != Null 
            ORDER BY CollaborationGroup.name ASC
        ];
    }
}