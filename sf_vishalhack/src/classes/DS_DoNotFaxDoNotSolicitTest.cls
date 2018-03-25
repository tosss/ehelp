@isTest
public class DS_DoNotFaxDoNotSolicitTest {
    testMethod static void testDnfDnsUpdate(){
        Account a = new Account();
        a.Name = 'TOWN OF MARKHAM';
        insert a;
        Account accInfo=[select Id, Do_Not_Fax__c, Do_Not_Solicit__c from Account where name = 'TOWN OF MARKHAM'];
        system.assert(accInfo !=null);
        accInfo.Do_Not_Fax__c = true;
        accInfo.Do_Not_Solicit__c = true;
        update accInfo;
        Account accTest = [select Id, Name, Do_Not_Fax__c, Do_Not_Solicit__c from account where name = 'TOWN OF MARKHAM'];
        System.debug(accTest);
    }
}