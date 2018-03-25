/* ALL_Case is dependent on the Trigger_Toggle__c Custom Settings
 * 
 * Trigger_Toggle__c Custom Settings contains multiple code block references for specific sObjects. 
 * 
 * For example:
 * 
 * Name                          sObject  Code Reference         Record Type  On__c
 * ----------------------------  -------  ---------------------  -----------  ---------
 * ALL DS_CaseDefaultAccount     Case     DS_CaseDefaultAccount  NULL         FALSE     <- ALL RecordTypes Custom Setting
 * HR DS_CaseDefaultAccount      Case     DS_CaseDefaultAccount  HR           TRUE      <- HR  RecordType  Custom Setting
 * 
 * In the above example, DS_CaseDefaultAccount is turned OFF (FALSE) for ALL Profiles, but it is turned on for Cases with
 * an HR RecordType. 
 * 
 */

trigger ALL_Case on Case (before insert, before update, after insert, after update) 
{
    All_Case_Handler.ToggleController(Trigger.New, Trigger.Old, Trigger.newMap, Trigger.oldMap);
}

/*
//Test Code

List<Case> Cases = new List<Case>();

for(integer count = 1; count <= 2; count++)
{
    Cases.add(new Case(
        RecordTypeId = [Select Id From RecordType Where sObjectType='Case' And Name='IFS - Contract Admin'].Id, 
        AccountId='0014000000dKtBB',
        WebID__c='a1Me000000004AC',
        Subject='TEST '+String.valueOf(count),
        Description='TEST '+String.valueOf(count),
        Type='Customer Buy/Sell',
        Assumption_Approved__c='Yes',
        Seller__c='0014000000JvzRv',
        Buyer_Contact_Details__c='Test',
        End_Billing_Date__c = Date.valueOf('2013-02-'+String.valueOf(count))
    ));
}

insert Cases;
*/