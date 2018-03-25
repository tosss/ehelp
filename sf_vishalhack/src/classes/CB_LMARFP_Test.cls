@isTest
public class CB_LMARFP_Test 
{
    static testMethod void invokeMainMethodTest()
    {
        Account acc = DS_TestObjects.NewAccount_Inserted();
        Contact conLMA = DS_TestObjects.NewContact();
        conLMA.Role__c = 'LMA President';
        conLMA.AccountId = acc.ID;
        Insert conLMA;
        
        Manufacturer__c mfg = new Manufacturer__c();
        mfg.Inactive__c = false;
        mfg.Manufacturers_Parent_Name__c = 'Chevrolet';
        mfg.Migration_ID__c = 'Chevy - cv';
        insert mfg;
        
        LMA_Pipeline__c lmaPipeLine = new LMA_Pipeline__c();
        lmaPipeLine.Jan__c = 10000;
        lmaPipeLine.LMA_Account__c = acc.ID;
        lmaPipeLine.Brand__c = mfg.ID;
        
        LMA_Pipeline__c lmaPipeLine2 = new LMA_Pipeline__c();
        lmaPipeLine2.Jan__c = 10000;
        lmaPipeLine2.LMA_Account__c = acc.ID;
        lmaPipeLine2.Brand__c = mfg.ID;
        
        insert new list<LMA_Pipeline__c> { lmaPipeLine, lmaPipeLine2 };
        
        LMA_RFP__c lmaRFP = new LMA_RFP__c(); 
        lmaRFP.Budget__c = 100000;
        lmaRFP.IO_Start_Date__c = Date.today();
        lmaRFP.IO_End_Date__c = Date.today() + 180;
        lmaRFP.LMA_Pipeline__c = lmaPipeLine.ID;
        lmaRFP.LMA__c = acc.ID;
        lmaRFP.LMA_President__c = conLMA.ID;
        
        LMA_RFP__c lmaRFP2 = new LMA_RFP__c(); 
        lmaRFP2.Budget__c = 100000;
        lmaRFP2.IO_Start_Date__c = Date.today()-90;
        lmaRFP2.IO_End_Date__c = Date.today() + 90;
        lmaRFP2.LMA_Pipeline__c = lmaPipeLine2.ID;
        lmaRFP2.LMA__c = acc.ID;
        lmaRFP2.LMA_President__c = conLMA.ID;
        
        insert new list<LMA_RFP__c> { lmaRFP, lmaRFP2 };
        
        lmaRFP.IO_End_Date__c = Date.today() + 181;
        update lmaRFP;
    }
}