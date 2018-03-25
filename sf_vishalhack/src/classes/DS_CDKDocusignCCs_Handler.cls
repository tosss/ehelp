//2016-12-22   vishal.bandari@cdk.com    RQ-08092-created the class
public class DS_CDKDocusignCCs_Handler 
{
    public static void beforeInsert(List<CDK_Docusign_CCs__c> newList)
    {
        updateEmailAndName(newList);
    }
    public static void beforeUpdate(List<CDK_Docusign_CCs__c> newList)
    {
        updateEmailAndName(newList);
    }
    
    public static void updateEmailAndName(List<CDK_Docusign_CCs__c> newList)
    {
        List<Id> contactIds = new List<Id>();
        List<Id> userIds = new List<Id>();
        for(CDK_Docusign_CCs__c cdkDocusignCC : newList)
        {
            if(cdkDocusignCC.Contact__c != null)
            {
                contactIds.add(cdkDocusignCC.Contact__c);
            }
            else if(cdkDocusignCC.User__c != null )
            {
                userIds.add(cdkDocusignCC.User__c);
            }
        }
        Map<Id,Contact> contactsMap;
        Map<Id,User> usersMap;
        if(contactIds != null)
        {
           contactsMap = new Map<Id,Contact>([SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id IN :contactIds ]);
        }
        if(userIds != null)
        {
           usersMap = new Map<Id,User>([SELECT Id, FirstName, LastName, Email FROM User WHERE Id IN :userIds ]);
        }
        for(CDK_Docusign_CCs__c cdkDocusignCC : newList)
        {           
            if(cdkDocusignCC.Email__c == null || cdkDocusignCC.First_Name__c == null || cdkDocusignCC.Last_Name__c == null)
            {
                if(cdkDocusignCC.Contact__c != null)
                {
                    Contact contactObj = contactsMap.get(cdkDocusignCC.Contact__c);
                    if(contactObj != null)
                    {
                        cdkDocusignCC.Email__c = cdkDocusignCC.Email__c==null ? contactObj.Email: cdkDocusignCC.Email__c;
                        cdkDocusignCC.First_Name__c = cdkDocusignCC.First_Name__c == null? contactObj.FirstName : cdkDocusignCC.First_Name__c;
                        cdkDocusignCC.Last_Name__c = cdkDocusignCC.Last_Name__c == null ? contactObj.LastName : cdkDocusignCC.Last_Name__c;
                    }
                }
                else if(cdkDocusignCC.User__c != null)
                {
                    User userObj = usersMap.get(cdkDocusignCC.User__c);
                    if(userObj != null)
                    {
                        cdkDocusignCC.Email__c = cdkDocusignCC.Email__c == null ? userObj.Email : cdkDocusignCC.Email__c;
                        cdkDocusignCC.First_Name__c = cdkDocusignCC.First_Name__c == null ? userObj.FirstName : cdkDocusignCC.First_Name__c;
                        cdkDocusignCC.Last_Name__c = cdkDocusignCC.Last_Name__c == null ? userObj.LastName : cdkDocusignCC.Last_Name__c;
                    }
                }
            }
        }
    }
    public static void beforeDelete(List<CDK_Docusign_CCs__c> oldList)
    {
        List<Id> opportunityIdsList = new List<Id>();
        for(CDK_Docusign_CCs__c cdkDocusignCC : oldList)
        {
            if(cdkDocusignCC.Required_CC_Contact__c)
            {
                opportunityIdsList.add(cdkDocusignCC.Opportunity__c);
            }
        }
        
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>([SELECT RecordType.Name FROM Opportunity WHERE Id IN: opportunityIdsList]);
        
        for(CDK_Docusign_CCs__c cdkDocusignCC : oldList)
        {
            Opportunity opportunityObject = opportunityMap.get(cdkDocusignCC.Opportunity__c);
            if(opportunityObject != null
               && (new Set<String>{'1 - Baseline Multi-channel Opportunity', '5 - Inside Sales Opportunity', '3 - Network Solutions Opportunity'}).contains(opportunityObject.RecordType.Name)
              )
            {
                cdkDocusignCC.addError('Cannot remove Required CC');
            }
        }
    }
}