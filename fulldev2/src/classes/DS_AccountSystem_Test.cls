//2015-11-19- anirudh.singh@cdk.com- Created this test class for DS_AccountSystem. Earlier no test class existed for DS_AccountSystem.
@isTest
public class DS_AccountSystem_Test
{
    testMethod static void opportunityController()
    {
        DS_AccountSystem asys = new DS_AccountSystem();
        asys.getAcctId();
        asys.setAcctId('x');
        asys.getAccountName();
        asys.setAccountName('x');
        asys.getCity();
        asys.setCity('x');
        asys.getState();
        asys.setState('x');
        asys.getPhone();
        asys.setPhone('x');
        asys.getCampStatus();
        asys.setCampStatus('x');
        asys.getVendorSystem();
        asys.setVendorSystem('x');
        asys.getSoldVendorSystem();
        asys.setSoldVendorSystem('x');
        asys.getBoxOnsite();
        asys.setBoxOnsite('x');
        asys.getAge();
        asys.setAge('x');
        asys.getInstallDate();
        asys.setInstallDate('x');
        asys.getdoNotSolicit();
        asys.setdoNotSolicit('x');
    }
}