@isTest
public class ALL_Account_Test 
{
   @testSetUp
    private static void setUp()
    {
        List<Account> accountsToBeInserted = new List<Account>();
        Account parentAccountOne = new Account(Name='ParentAccountOne');
        accountsToBeInserted.add(parentAccountOne);
        Account childAccountOne = new Account(Name = 'ChildAccountOne', parentID = parentAccountOne.ID, CBLTBillState__c = 'NC',DS_LGL_Data_Rights_Opt_Out__c = '9D;APAD for Menu');
        accountsToBeInserted.add(childAccountOne);
        Account childAccountTwo = new Account(Name = 'ChildAccountTwo', parentID = parentAccountOne.ID, CBLTBillState__c = 'CA');
        accountsToBeInserted.add(childAccountTwo);
        Account parentAccountTwo = new Account(Name='ParentAccountTwo', parentID = childAccountOne.ID);
        accountsToBeInserted.add(parentAccountTwo);
        Account childAccountThree = new Account(Name='childAccountThree', parentID = childAccountTwo.ID);
        accountsToBeInserted.add(childAccountThree);
        Account childAccountFour = new Account(Name = 'childAccountFour', parentID = childAccountTwo.ID );
        accountsToBeInserted.add(childAccountFour);        
        insert accountsToBeInserted;
        Account__c dataRightsCustomSettingOne = new Account__c(Name = '00', Data_Rights_Name__c = '9D', Data_Rights_State_to_Skip__c = 'NC');
        insert dataRightsCustomSettingOne;
        Account__c dataRightsCustomSettingTwo = new Account__c(Name = '01', Data_Rights_Name__c = '9D', Data_Rights_State_to_Skip__c = 'CA');
        insert dataRightsCustomSettingTwo;
    }

    private static testmethod void testPropagateDataRights()
    {
        Map<ID, Account> accountMap = new Map<ID,Account>([ SELECT ID, DS_LGL_Data_Rights_Opt_Out__c, Name, ParentID FROM Account]);
        
        Map<ID, Account> clonedAccountMap = new Map<ID,Account>();

        for(Account acc : accountMap.values())
        {
            Account tempAccount = acc.clone();
            tempAccount.ID = null;    		
            clonedAccountMap.put(acc.ID, tempAccount);
        }
        
        accountMap.values()[0].DS_LGL_Data_Rights_Opt_Out__c = '9D;APAD for Menu';
        accountMap.values()[1].DS_LGL_Data_Rights_Opt_Out__c = '9D';
        ALL_Account_Handler.propagateDataRights(accountMap.values(), null);
        ALL_Account_Handler.propagateDataRights(accountMap.values(), clonedAccountMap);        
    }
}