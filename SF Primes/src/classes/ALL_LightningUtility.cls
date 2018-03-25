public with sharing class ALL_LightningUtility 
{
    @AuraEnabled
    public static List<sobject> getSearchList(String ObjectName, String NameField, String searchString)
    {
        return DataBase.query('Select Id,'+NameField+' from '+ObjectName+' where '+NameField+' like \'%'+searchString+'%\' ');
    }
}