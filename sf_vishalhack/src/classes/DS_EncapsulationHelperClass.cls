public class DS_EncapsulationHelperClass 
{
    public list<sObject> newSObjectList {get; set;}
    public list<sObject> oldSObjectList {get; set;}
    public map<Id, sObject> newSObjectMap {get; set;}
    public map<Id, sObject> oldSObjectMap {get; set;}
    
    public map<string, list<sobject>> newSObjectListByObject {get; set;}
    
    public DS_EncapsulationHelperClass(list<sObject> newList, List<sObject> oldList, map<Id, sObject> oldMap, map<Id, sObject> newMap )
    {
        newSObjectList = newList;
        oldSObjectList = oldList;
        newSObjectMap = newMap;
        oldSObjectMap = oldMap;        
    }
    
    //below consructor needs to be removed after checking if not used elsewhere.
    public DS_EncapsulationHelperClass(list<sObject> newList, map<Id, sObject> newMap, map<Id, sObject> oldMap, map<string, list<sobject>> newSObjectListByObjectInput)
    {
        newSObjectList = newList;
        newSObjectMap = newMap;
        oldSObjectMap = oldMap; 
        newSObjectListByObject = newSObjectListByObjectInput;                            
    }
    
    public DS_EncapsulationHelperClass(list<sObject> newList, List<sObject> oldList, map<Id, sObject> newMap, 
                                       map<Id, sObject> oldMap, map<string, list<sobject>> newSObjectListByObjectInput )
    {
        newSObjectList = newList;
        oldSObjectList = oldList;
        newSObjectMap = newMap;
        oldSObjectMap = oldMap;
        newSObjectListByObject = newSObjectListByObjectInput;        
    }
}