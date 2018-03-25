@isTest
public class ALL_UtilitiesData_Test 
{
    public static testmethod void GetDataFromNestedFields()
	{
		Id i = DS_TestObjects.NewAccount_Inserted().Id;
		Account a = [Select Id, Name, CreatedById, CreatedBy.UserName, CreatedBy.CreatedBy.UserName 
			From Account Where Id = :i];
		
		ALL_UtilitiesData.GetDataFromNestedFields('Name', a);
		ALL_UtilitiesData.GetDataFromNestedFields('CreatedBy.CreatedBy.UserName', a);
	}
    
    public static testmethod void PutDataInNestedFields()
	{
		Id i = DS_TestObjects.NewAccount_Inserted().Id;
		Account a = [Select Id, Name, CreatedById, CreatedBy.UserName, CreatedBy.CreatedBy.UserName 
			From Account Where Id = :i];
		
		ALL_UtilitiesData.PutDataInNestedFields('Name', a, 'New Name');
		ALL_UtilitiesData.PutDataInNestedFields('CreatedBy.CreatedBy.UserName', a, 'Test CreatedBy CreatedBy UserName');
	}
    
    public static testMethod void SerializesObjectList()
    {
        list<sObject> accList = new list<sObject> { DS_TestObjects.NewAccount_Inserted(), DS_TestObjects.NewWebID_Inserted() };
        ALL_UtilitiesData.SerializesObjectList(accList, 'Update');        
    }
    
    public static testMethod void OrganizeFieldValueConditionsInaMap()
    {
        getFieldValueConditionsSettings();
        ALL_UtilitiesData.OrganizeFieldValueConditionsInaMap();
    }
    
    public static testMethod list<Field_Value_Conditions__c> getFieldValueConditionsSettings()
    {
        list<Field_Value_Conditions__c> FieldValuesList = new List<Field_Value_Conditions__c>();
        FieldValuesList.add(new Field_Value_Conditions__c(Name='001', Field_Name__c='Order_Status__c', Field_Value__c='At LI Team', Identifier__c='001'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='002', Field_Name__c='Order_Type__c', Field_Value__c='Approved', Identifier__c='002'));
        
        insert FieldValuesList;
        return FieldValuesList;
    }

    
    public static testMethod void CompareTheValues() 
    {
        list<Field_Value_Conditions__c> FieldValuesList = ALL_UtilitiesData_Test.getFieldValueConditionsSettings();

        Laser_ArtWork_Order__c lao = new Laser_Artwork_Order__c();
        lao.Order_Status__c = 'Approved';
        lao.Order_Type__c = 'At LI Team'; 
        
        boolean firstCondition = ALL_UtilitiesData.CompareTheValues('002', lao);
        system.assertEquals(false, firstCondition);
        
        boolean secondCondition = ALL_UtilitiesData.CompareTheValues('001 AND 002', lao);
        system.assertEquals(true, secondCondition);
        
        lao.Order_Status__c = 'Hold CDK';
        lao.Order_Type__c = 'Elite'; 
        
        boolean thirdCondition = ALL_UtilitiesData.CompareTheValues('002', lao);
        system.assertNotEquals(true, thirdCondition);
        
        boolean fourthCondition = ALL_UtilitiesData.CompareTheValues('001 AND 002', lao);
        system.assertNotEquals(true, fourthCondition);
        
        
        
    }
}