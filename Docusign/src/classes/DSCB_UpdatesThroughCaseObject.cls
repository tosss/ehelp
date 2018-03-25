public class DSCB_UpdatesThroughCaseObject 
{
    public static void UpdateMethod(list<Case> newCaseList)
    {
        map<ID, Case> ProcessedCaseMap = new map<ID, Case>();       
        map<ID, Case> ContactIDsToCase = new map<ID, Case>();
        set<ID> ContactIDset = new set<ID>();
        
        for(Case c: newCaseList)
        {
            ProcessedCaseMap.put(c.Id, c);
            ContactIDsToCase.put(c.ContactId, c);
            ContactIDset.add(c.ContactId);
        }
        
        map<ID, Contact> ContactMap;
        
        if(ContactIDset != null && !ContactIDset.isEmpty())
        {
            ContactMap = new map<ID, Contact>([
                SELECT Id, Name, AccountId, ResponseDate__c 
                FROM Contact 
                WHERE Id IN :ContactIDset
            ]);
        }
        
        Boolean OkayToUpdateContacts = false; 
        
        if(ContactMap != null && !ContactMap.keySet().isEmpty())
        {
            for(ID Id: ProcessedCaseMap.keySet())
            {
                Case c = ProcessedCaseMap.get(Id);
                
                if(c.ContactId != null)
                {
                    ContactMap.get(c.ContactId).ResponseDate__c = c.ResponseDate__c;
                    OkayToUpdateContacts = true;
                }
            }
        }
        
        if(ContactMap.values() != null && ContactMap.Values().size() > 0 && OkayToUpdateContacts)
        {     
            database.SaveResult[] results = database.update(ContactMap.values(), false);  
            
            for(Integer i = 0; i < results.size(); i++) //Database.SaveResult dsr: results)
            {
                Database.SaveResult dsr = results[i];
                Contact ContactBeforeSave = ContactMap.values()[i];
                
                if(dsr.isSuccess())
                {
                    system.debug(dsr.getId() + ' is successfully updated');
                }
                else
                {
                    Database.Error [] ErrorArray = dsr.getErrors();
                    
                    for(Database.Error dr: ErrorArray)
                    {                        
                        if(dr.getMessage() != null)
                        { 
                            Case CurrentCase = ContactIDsToCase.get(ContactBeforeSave.Id);
                            
                            if(CurrentCase != null) 
                            {
                                CurrentCase.addError(dr.getMessage()); break;
                            }
                        }                        
                    }                  
                }
            }
        }
    }    
}