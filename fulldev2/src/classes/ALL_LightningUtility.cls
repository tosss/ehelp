public with sharing class ALL_LightningUtility 
{
    @AuraEnabled
    public static List<sobject> getSearchList(String ObjectName, String NameField, String searchString)
    {
        return DataBase.query('Select Id,'+NameField+' from '+ObjectName+' where '+NameField+' like \'%'+searchString+'%\' ');
    }
    @AuraEnabled
    public static String getName(String ObjectName, String NameField, String selectedId)
    {
        List<sobject> sobjectList = DataBase.query('Select Id,'+NameField+' from '+ObjectName+' where Id = \''+selectedId+'\'');
        return String.valueOf(sobjectList[0].get(NameField));
    }
}