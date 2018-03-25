global with sharing class Node implements Comparable
{
    public Id NodeId {get;set;}
    public sObject Value {get;set;}
    public String sortField {get;set;} 
    public Id ParentId {get;set;}
    public List<sObject> SortedFirstLevelSObjects {get;set;}
    
    public Map<Id, Node> SubTrees {get;set;}
    public list<Node> SortedNextLevel {
        get { list<Node> vs = SubTrees.values(); vs.sort(); return vs; }
        set;
    }
    
    public Node() {
        SubTrees = new Map<Id, Node>();
        SortedNextLevel = new list<Node>();
    }
    
    public Node(sObject s) {
        Initialize(s);
    }
    
    public Node(sObject s, String SortFieldApiName) {
        Initialize(s);
        
        //SortFieldApiName must be a valid api name from sObject s 
        // of type Integer or String for flawless sorting capability
        sortField  = SortFieldApiName;
    }
    
    public void Initialize(sObject s) {
        NodeId = s.Id;
        Value = s;
        
        SubTrees = new Map<Id, Node>();
        SortedNextLevel = new list<Node>();
    }
    
    public Integer compareTo(Object compareTo) {
        Node NodeToCompare = (Node) compareTo;
        
        if(Value.get(sortField) instanceof Integer) {
            system.debug('isInteger');
            if (Integer.valueOf(Value.get(sortField)) == Integer.valueOf(NodeToCompare.Value.get(sortField))) { return 0; }
            else if (Integer.valueOf(Value.get(sortField)) > Integer.valueOf(NodeToCompare.Value.get(sortField))) { return 1; }
            else { return -1; }
        }
        
        // if not returned because not an integer
        try // try to compare string
        {
            system.debug('isString');
            return String.valueOf(Value.get(sortField)).compareTo(
                String.valueOf(NodeToCompare.Value.get(sortField))
            );
        }
        catch(Exception e) {
            system.debug(e);
            return -1;
        }
    }
}