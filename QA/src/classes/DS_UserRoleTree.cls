global class DS_UserRoleTree 
{
	webservice static Tree GetUserRoleTree() 
	{
		UserRole Role;
		List<UserRole> Roles = [Select Id, Name, ParentRoleId From UserRole];
		
		Tree UserRoleTree = new Tree();
		UserRoleTree.sObjectParentField = 'ParentRoleId';
		UserRoleTree.AddList(Roles);
		
		return UserRoleTree;
	}
	
	webservice static List<UserRole> FindUserRoleList(string RoleName)
	{
		UserRole Role;
		List<UserRole> Roles = [Select Id, Name, ParentRoleId From UserRole];
		
		if(RoleName != null)
		{
			for(UserRole r : Roles) { 
				if(r.Name.toLowerCase() == RoleName.toLowerCase()) { Role = r; } 
			}
		}
		
		Tree UserRoleTree = new Tree();
		UserRoleTree.sObjectParentField = 'ParentRoleId';
		UserRoleTree.AddList(Roles);
		
		Node n = null;
		if(Role != null) { n = UserRoleTree.FindNode(Role.Id); }
		
		Roles = null;
		Roles = UserRoleTree.TreeToList(n);
		
		return Roles;
	}
}