global with sharing class Node 
{
	public Id NodeId;
	public sObject Value;
	public Id ParentId;
	public Map<Id, Node> SubTrees;
	
	public Node(sObject s)
	{
		NodeId = s.Id;
		Value = s;
		SubTrees = new Map<Id, Node>();
	}
	
	public Node()
	{
		SubTrees = new Map<Id, Node>();
	}
}