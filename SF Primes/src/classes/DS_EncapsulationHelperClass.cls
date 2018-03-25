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
        newSObjectMap = oldMap;
        oldSObjectMap = newMap;        
    }
    
    public DS_EncapsulationHelperClass(map<string, list<sobject>> newSObjectListByObjectInput)
    {
        newSObjectListByObject = newSObjectListByObjectInput;                            
    }
}