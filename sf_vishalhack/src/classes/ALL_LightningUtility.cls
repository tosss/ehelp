public with sharing class ALL_LightningUtility 
{
    @AuraEnabled
    public static List<sobject> getSearchList(String ObjectName, String NameField, String searchString)
    {
        return DataBase.query('SELECT Id,'+NameField+' FROM '+ObjectName+' WHERE '+NameField+' LIKE \'%'+searchString+'%\' ');
    }
    
    @AuraEnabled
    public static List<Contact_Relationship__c> getContactRelationshipSearchList(String ObjectName, String NameField, String searchString)
    {
        List<Contact_Relationship__c> contactRelationshipList = (List<Contact_Relationship__c>)DataBase.query(
                        'SELECT Id, Name, Account__c, Account__r.Name, Contact__c, Contact__r.Name '
                        +' FROM Contact_Relationship__c '
                        +' WHERE Contact__r.Name LIKE \'%'+searchString+'%\' '
                        +' AND Status__c=\'Active\'');
        return contactRelationshipList;
    }
}