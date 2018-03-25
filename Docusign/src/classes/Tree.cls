/*

List<sObject> Roles = [Select Id, Name, ParentRoleId From UserRole];
//for(sObject r : Roles) { system.debug(r); }

Tree t = new Tree();
t.sObjectParentField = 'ParentRoleId';
t.AddList(Roles);
List<sObject> objs = t.TreeToList();
for(sObject r : objs) { system.debug(LOGGINGLEVEL.WARN,r); }

 */

global with sharing class Tree 
{
	// the parent id field in the supplied sObjects
	global string sObjectParentField;
	
	// tree data (or root node)
	global Map<Id,Node> Roots;
	public Set<Id> ParentIds;
	
	// tree constructors
	global Tree() { Roots = new Map<Id, Node>(); }
	global Tree(List<sObject> o) { Roots = new Map<Id, Node>(); AddList(o); }
	
	// add a list of sObjects to the tree
	public void AddList(List<sObject> o)
	{
		if(ParentIds == null) { ParentIds = new Set<Id>(); }
		
		for(sObject s : o)
		{
			// log the current object - for debugging
			//system.debug(LOGGINGLEVEL.WARN,'Current sObject - '+s);
			
			Id ParentId = (Id)s.get(sObjectParentField);
			
			if(ParentIds.contains(ParentId)) 
			{
				Node Parent = FindNode(ParentId); 
				if(parent != null) 
				{
					// look for children in the Roots ...
					// there is no need to search for children in the entire tree
					// because orphaned nodes are only added to the root level
					Map<Id, Node> Children = SearchRootsForChildren(s.Id);
					
					//system.debug(LOGGINGLEVEL.WARN,'Putting new Node in Roots with any Children found');
					Node NewNode = new Node(s); // create a new node
					NewNode.SubTrees = Children; // add the children to the new node
					Parent.SubTrees.put(s.Id, NewNode); // add the new node to its found parent node
					ParentIds.add(s.Id); // save the current id to check for parents later
				}
			}
			else 
			{
				//system.debug(LOGGINGLEVEL.WARN,'Parent Does Not Exist');
				
				// look for children in the Roots ...
				Map<Id, Node> Children = SearchRootsForChildren(s.Id);
				
				//system.debug(LOGGINGLEVEL.WARN,'Putting new Node in Roots with any Children found');
				Node NewNode = new Node(s);
				NewNode.SubTrees = Children;
				Roots.put(s.Id, NewNode); 
				ParentIds.add(s.Id);
			}
			
			// log the tree after every node is added
			// this is so that we can see the tree being built
			//system.debug(LOGGINGLEVEL.WARN,'---START---');
			//DebugTree();
			//system.debug(LOGGINGLEVEL.WARN,'---END-----');
		}
	}
	
	public Map<Id, Node> SearchRootsForChildren(Id ParentId)
	{
		Map<Id, Node> Children = new Map<Id, Node>();
		
		for(Node n : Roots.values())
		{
			if((Id)n.Value.get(sObjectParentField) == ParentId)
			{
				Roots.remove(n.NodeId);
				Children.put(n.NodeId, n);
			}
		}
		
		return Children;
	}
	
	public Node RecursiveSearchById(Id NodeId, Map<Id,Node> Nodes)
	{
		if(Nodes != null)
		{
			if(Nodes.containsKey(NodeId)) { return Nodes.get(NodeId); }
			else 
			{
				// for all the nodes at this level
				for(Node n : Nodes.values()) 
				{
					// if the node has sub trees
					if(n.SubTrees != null && !n.SubTrees.IsEmpty()) 
					{ 
						// recursively search all subtrees
						Node f = RecursiveSearchById(NodeId, n.SubTrees);
						if(f != null) { return f; }  
					} 
				}
			}
		}
		
		return null;
	}
	
	public Node FindNode(Id NodeId)
	{
		return RecursiveSearchById(NodeId, Roots);
	}
	
	public List<sObject> RecursiveTreeToList(Integer level, Map<Id,Node> Nodes, List<sObject> objects)
	{
		if(Nodes != null)
		{
			for(Node n : Nodes.values()) 
			{
				objects.add(n.Value);
				system.debug(LOGGINGLEVEL.INFO,RepeatString('    ',level) + n.Value.get('Name') + ' ' + n.NodeId); 
				RecursiveTreeToList(level+1, n.SubTrees, objects);
			}
		}
		
		return objects;
	}
	
	public List<sObject> TreeToList(Node n)
	{
		Map<Id, Node> NodeMap = new Map<Id, Node>();
		NodeMap.put(n.NodeId,n);
		
		return RecursiveTreeToList(0, NodeMap, new List<sObject>());
	}

	public List<sObject> TreeToList(Map<Id, Node> NodeMap)
	{
		return RecursiveTreeToList(0, NodeMap, new List<sObject>());
	}
	
	public List<sObject> TreeToList()
	{
		return RecursiveTreeToList(0, Roots, new List<sObject>());
	}
	
	public string RepeatString(String s, Integer times) { String v = s; s=String.valueOf(times)+s; for(Integer i=0; i<times; i++) { s+=v; } return s; }
}