public class DSCB_UpdatesThroughCaseObject 
{
    public static void UpdateMethod(list<Case> newCaseList, Map<Id, Case> oldMap)
    { 
        try
        {
            map<ID, Case> ContactIDsToCase = new map<ID, Case>();
            set<ID> ContactIDset = new set<ID>();
            map<ID, Contact> contactUpdateMap = new map<ID, Contact>();
            
            for(Case c: newCaseList)
            {
                ContactIDsToCase.put(c.ContactId, c);
                ContactIDset.add(c.ContactId);
            }
            
            map<ID, Contact> ContactMap;
            
            if(!ContactIDset.isEmpty())
            {
                ContactMap = new map<ID, Contact>([
                    SELECT Id, Name, AccountId, ResponseDate__c, Most_Recent_CSI_Sent_Date__c 
                    FROM Contact 
                    WHERE Id IN :ContactIDset
                ]);
            }
            
            Boolean OkayToUpdateContacts = false; 
            
            if(ContactMap != null && !ContactMap.keySet().isEmpty())
            {
                for(Case currentCase: newCaseList)
                { 
                    case currentOldCase = oldMap != null ? oldMap.get(currentCase.ID) : null;
                    boolean responseDateChanged = false;
                    boolean CSIsentChanged = false;
                    
                    if(currentOldCase != null)
                    {
                        if(currentOldCase.ResponseDate__c != currentCase.ResponseDate__c)
                        {
                            responseDateChanged = true;
                        }
                        if(currentOldCase.CSI_Sent__c != currentCase.CSI_Sent__c)
                        {
                            CSIsentChanged = true;
                        }
                    }
                    else
                    {
                        if(currentCase.CSI_Sent__c)
                        {
                            CSIsentChanged = true; 
                        }
                        if(currentCase.ResponseDate__c != null)
                        {
                            responseDateChanged = true;
                        }
                    }
                    
                    if(currentCase.ContactId != null)
                    {
                        Contact currentContact = ContactMap.get(currentCase.ContactId);
                        
                        if(currentContact != null)
                        {
                            if(responseDateChanged)
                            {
                                currentContact.ResponseDate__c = currentCase.ResponseDate__c;
                                contactUpdateMap.put(currentContact.ID, currentContact);
                                OkayToUpdateContacts = true;
                            }
                            
                            if(CSIsentChanged)
                            {
                                Contact tempContact = contactUpdateMap.get(currentContact.ID);
                                
                                if(tempContact != null)
                                {
                                    tempContact.Most_Recent_CSI_Sent_Date__c = Date.today();
                                    contactUpdateMap.put(tempContact.ID, tempContact);
                                    OkayToUpdateContacts = true;
                                }
                                else
                                {
                                    currentContact.Most_Recent_CSI_Sent_Date__c = Date.today();
                                    contactUpdateMap.put(currentContact.ID, currentContact);
                                    OkayToUpdateContacts = true;
                                }
                            }
                        }
                    }                    
                }
            }
            
            if(contactUpdateMap.size() > 0 && OkayToUpdateContacts)
            {     
                update contactUpdateMap.values();
            }
        }
        catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
        }
    }
    
    public static void retrieveValuesFromLookUpsToCase(list<Case> newCaseList)
    {
        try{
            Set<ID> partnerContactIDset = new Set<ID>();
            Map<ID, Partner_Contacts__c> partnerContactMap;
            
            for(Case c: newCaseList)
            {
                partnerContactIDset.add(c.Partner_Contact__c);
            }
            
            if(!partnerContactIDset.isEmpty())
            {
                partnerContactMap = new Map<ID, Partner_Contacts__c>([
                    SELECT ID, Name, Email__c, Partner_Organization__c, Phone__c, Security_Code__c, Status__c
                    FROM Partner_Contacts__c 
                    WHERE ID IN : partnerContactIDset
                ]);
            }
            
            for(Case currentCase: newCaseList)
            {        
                if(currentCase.Partner_Contact__c != null)
                {
                    Partner_Contacts__c partContact = partnerContactMap.get(currentCase.Partner_Contact__c);
                    
                    if(partContact != null)
                    {
                        currentCase.partner_Contact_Email__c = partContact.Email__c;
                    }
                }
            }
        }
        catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
        }
    }    
}