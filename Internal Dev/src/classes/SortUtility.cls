global class SortUtility {

    private List<sObject> sObjects;
    private String FieldName;
    
    // Constructor
    global SortUtility(List<sObject> sObjectsToSort, String SortFieldApiName) {
        sObjects = sObjectsToSort; FieldName = SortFieldApiName; }
    
    // Sort sObjectsToSort by FieldName supplied, returning sorted list
    global List<sObject> CustomSort() 
    {
        List<sObject> Sorted = new List<sObject>(); // Sorted sObjects to Return
        
        // Temporary sort collections
        List<object> SortList = new List<object>(); 
        Map<object, sObject> SortMap = new Map<object, sObject>();
        
        Integer counter = 1;
        
        // add key and sObject to appropriate collections for sorting
        for(sObject s : sObjects)
        {
            object key = s.get(FieldName);
            if(key == null) { key = counter; }
            
            SortList.add(key);
            SortMap.put(key, s);
            
            counter++;
        }
        
        // sort the list of key values
        // Note: type does not matter, integers are sorted as numbers, strings as text, etc
        SortList.sort(); // List.sort is intelligent
        
        // add the sorted values to the return list
        for(object key : SortList) { 
            Sorted.add(SortMap.get(key)); }
        
        // return the sorted list
        return Sorted;
    }
}