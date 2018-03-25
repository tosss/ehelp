public class EMP_MyCommunities_Controller {
    
    public List<CollaborationGroupMember> collabortaiongroupmenbers {get;set;}
    
    public EMP_MyCommunities_Controller(){
        collabortaiongroupmenbers = new list<CollaborationGroupMember>();
        collabortaiongroupmenbers = [ 
            Select
            MemberId, CollaborationGroupMember.CollaborationGroup.OwnerId,CollaborationGroupId,
            CollaborationGroup.name
            from CollaborationGroupMember 
            where MemberId =: UserInfo.getUserId() AND CollaborationGroup.networkID != Null 
            ORDER BY  CollaborationGroup.name ASC
        ];
    }
}