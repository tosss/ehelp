@IsTest(SeeAllData=true)
public class DS_UserRoleTree_Test
{
    public static testmethod void TestRoleTreeTraversal()
    {
        Tree t = DS_UserRoleTree.GetUserRoleTree();
        String n = String.ValueOf(t.TreeToList()[0].get('Name'));
        
        List<UserRole> r = DS_UserRoleTree.FindUserRoleList(n);
        for(UserRole ro : r) { system.debug(ro); }
        
        Node no = new Node();
    }
}