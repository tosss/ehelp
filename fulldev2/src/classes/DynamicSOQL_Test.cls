@isTest
public class DynamicSOQL_Test 
{
    @testSetUp static void setUpData()
    {  
        list<sObject> settingsObjects = new list<sObject>{
            new ALL_Query_Conditions__c(Name='002', sObject__c='Case', Key__c='Name', Operator__c='=', Value__c='Onboarding - OMS', 
                                            Class_Name__c='DynamicSOQL_Helper', Method_Name__c='getRecordTypeId()', Describe_Call__c=true, Identifier__c='002'),
            new ALL_Query_Conditions__c(Name='003', sObject__c='User', Key__c='	UserName', Operator__c='=', 
                                            Class_Name__c='DynamicSOQL_Helper', Method_Name__c='getAdminUser()', Identifier__c='003'),
            new ALL_Field_Value_Assignment_Settings__c(Name='002', 	Receiving_sObject__c='Case', Receiving_Field_Name__c='RecordTypeId', Query_Conditions_Identifier__c='002', 
                                                           Identifier__c='002'), 
            new ALL_Field_Value_Assignment_Settings__c(Name='003', 	Receiving_sObject__c='Case', Receiving_Field_Name__c='Requested_By__c', Query_Field_s__c='ID', 
                                                           Query_sObject__c='User', Query_Conditions_Identifier__c='003',Identifier__c='003')
       };           
       insert settingsObjects;
    }
    
    static testMethod void testForRouteToSpecificMethod()
    {
        ALL_Query_Conditions__c aqc_1 = ALL_Query_Conditions__c.getInstance('002');
        ALL_Query_Conditions__c aqc_2 = ALL_Query_Conditions__c.getInstance('003');
        
        ALL_Field_Value_Assignment_Settings__c afv_1 = ALL_Field_Value_Assignment_Settings__c.getInstance('002');
        ALL_Field_Value_Assignment_Settings__c afv_2 = ALL_Field_Value_Assignment_Settings__c.getInstance('003');
        
        DynamicSOQL_Helper.routeToSpecificMethod(aqc_1, afv_1);
        DynamicSOQL_Helper.routeToSpecificMethod(aqc_2, afv_2);
    }
    
    static testMethod void testForSmallMethods()
    {
        DynamicSOQL_Helper.getAdminUser();
        DynamicSOQL_Helper.getRecordTypeID('Case', 'Onboarding - OMS');
        DynamicSOQL_Helper.QueryValueMethod('DynamicSOQL_Helper', 'CurrentUserId()');
    }
    static testMethod void testForQueryConstructor()
    {
        DynamicSOQL_Helper.QueryConstructorCondition queryParameters = new DynamicSOQL_Helper.QueryConstructorCondition();
        queryParameters.order = 1;
        queryParameters.key = 'OwnerID';
        queryParameters.operator = '=';
        queryParameters.value = 'Dynamic';
        queryParameters.className = 'DynamicSOQL_Helper';
        queryParameters.methodName = 'CurrentUserId()';
        
        DynamicSOQL_Helper.QueryConditionsPacketClass conditionsPacket = new DynamicSOQL_Helper.QueryConditionsPacketClass();
        conditionsPacket.ConditionsList = new list<DynamicSOQL_Helper.QueryConstructorCondition>{ queryParameters };
        conditionsPacket.QueryConditionExpression = '1';
        
        DynamicSOQL_Helper.QueryConstructor(conditionsPacket);
        
    }
}