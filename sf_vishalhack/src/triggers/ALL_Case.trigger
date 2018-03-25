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
 //2017-Sep-30  vishal.bandari@cdk.com - Added Code to Invoke JIRA Sync Methods 

trigger ALL_Case on Case (before insert, before update, after insert, after update) 
{
    All_Case_Handler.ToggleController(Trigger.New, Trigger.Old, Trigger.newMap, Trigger.oldMap);
    
    //JIRA to Salesforce Sync code Methos Invoked 
    if(Trigger.isInsert && Trigger.IsAfter)
    {
    	//To Create JIRA Issue
        All_Case_Handler.createJIRAIssue(Trigger.New);
    }
    if(Trigger.isUpdate && Trigger.IsAfter && All_Case_Handler.runFutureOnce != 'Jira Create')
    {
    	//To Update JIRA Issue
        All_Case_Handler.updateJIRAIssue(Trigger.New,Trigger.OldMap);
    }
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