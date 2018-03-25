/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Test Class to test ALL_UpdateFormOrders_Test
Created on:    17 July 2015.
Code Coverage: 100%
------------------------------------------------------------
History
17 July 2015    Vishal Bandari      RQ-04982: Added setUpTestdata method
17 July 2015    Vishal Bandari      RQ-04982: Added validateHandler method
17 July 2015    Vishal Bandari      RQ-04982: Added test1 method
17 July 2015    Vishal Bandari      RQ-04982: Added test2 method
17 July 2015    Vishal Bandari      RQ-04982: Added test3 method
17 July 2015    Vishal Bandari      RQ-04982: Added test4 method
17 July 2015    Vishal Bandari      RQ-04982: Added negitiveTest method
------------------------------------------------------------*/
@IsTest
public class ALL_UpdateFormOrders_Test 
{
    private static Boolean runAll = false;
    private static Boolean runSetUpData = true;
    private static Boolean runNegitiveTest = true;
    private static Boolean dataFetched = false;
    
    private static Boolean runTest1 = true;
    private static Boolean runTest2 = true;
    private static Boolean runTest3 = true;
    private static Boolean runTest4 = true;
    
    private static User userObj = new User();
    private static List<Account> accList = new List<Account>();
    private static List<CMF_Info__c> cmfInfoList = new List<CMF_Info__c>();
    private static Laser_Artwork_Order__c laoObj = new Laser_Artwork_Order__c();
    
    @TestSetup
    public static void setUpTestdata()
    {
        if(runSetUpData || runAll)
        {
            //Inserting Sample User object 
            userObj = DS_TestObjects.NewUser();
            userobj.FirstName = 'Sample';
            userobj.LastName = 'User';
            userobj.Email = 'sampleuser@cdk.com';
            insert userObj;
            
            //Inserting Sample Account objects
            accList = new List<Account>();
            for(Integer i=0;i<2;i++)
            {
                Account accObj = DS_TestObjects.NewAccount();
                accObj.Name = 'SampleFormCollectionUpdate'+i;
                if(i==0)
                {
                    accObj.Key_Rep__c = userObj.Id;
                }
                accList.add(accObj);
            }
            insert accList;
            
            //Inserting Sample CMF_Info__c objects
            cmfInfoList = new List<CMF_Info__c>();
            for(Integer i=0;i<2;i++)
            {       
                CMF_Info__c cmfObj = new CMF_Info__c();
                cmfObj.Account__c = accList[i].Id;
                cmfObj.Name = 'SampleCMF'+i;
                cmfInfoList.add(cmfObj);
            }
            insert cmfInfoList;
            
            //Inserting Sample Laser_Artwork_Order__c or Forms_Order__c object
            laoObj = DS_TestObjects.NewLaserArtworkOrder();
            laoObj.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Laser_Artwork_Order__c','Laser Imaging');
            laoObj.Ship_CMF_Info__c = cmfInfoList[0].Id;
            insert laoObj;
            FetchValues();
        }
    }
    
    //to fetch test Object values 
    public static void FetchValues()
    {
        if(!dataFetched && runSetUpData)
        {
            userObj = [
                SELECT ID 
                FROM User 
                WHERE Name = 'Sample User' 
                LIMIT 1 
            ];
            
            accList = [
                SELECT ID, Key_Rep__c 
                FROM Account 
                WHERE Name 
                LIKE 'SampleFormCollectionUpdate%' 
            ];
            
            cmfInfoList = [
                SELECT Id, Account__c 
                FROM CMF_Info__c 
                WHERE Name 
                LIKE 'SampleCMF%' 
                ORDER BY Name];
            
            laoObj = [
                SELECT Id, Key_Rep__c 
                FROM Laser_Artwork_Order__c 
                order by CreatedDate desc
            ];
            
            dataFetched = true;
        }
    }
    
    
    //Scenario 1: Updating Key_Rep__c of Account Object to null
    public static testmethod void test1()
    {
        if(runTest1 || runAll)
        {
            if(!dataFetched)
            {
                FetchValues();
            }
            accList[0].Key_Rep__c = null;
            
            Test.startTest();
            update accList[0];
            Test.stopTest();
            
            laoObj = [
                SELECT Id, Key_Rep__c 
                FROM Laser_Artwork_Order__c 
                WHERE Id =: laoObj.Id
            ];
            
            System.assertEquals(null, laoObj.Key_Rep__c, 'Key_Rep__c field not updated on updating Account Key_Rep__c to null');
        }
    }
    
    //Scenario 2: Updating Key_Rep__c of Account Object
    public static testmethod void test2()
    {
        if(runTest2 || runAll)
        {
            if(!dataFetched)
            {
                FetchValues();
            }
            accList[0].Key_Rep__c = userObj.Id;
            
            Test.startTest();
            update accList[0];
            Test.stopTest();
            
            laoObj = [
                SELECT Id, Key_Rep__c 
                FROM Laser_Artwork_Order__c 
                WHERE Id =: laoObj.Id
            ];
            
            System.assertEquals(userObj.Id, laoObj.Key_Rep__c, 'Key_Rep__c field not updated on updating Account Key_Rep__c');
        }
    }
    
    //Scenario 3:Updating Ship_CMF_Info__c of Laser Artwork Order Object 
    public static testmethod void test3()
    { 
        if(runTest3 || runAll)
        {  
            if(!dataFetched)
            {
                FetchValues();
            }    
            laoObj.Ship_CMF_Info__c = cmfInfoList[1].Id;
            
            Test.startTest();
            update laoObj;
            Test.stopTest();
            
            laoObj = [
                SELECT Id, Key_Rep__c 
                FROM Laser_Artwork_Order__c 
                WHERE Id =: laoObj.Id
            ];
            
            System.assertEquals(UserInfo.getUserId(), laoObj.Key_Rep__c, 'Key_Rep__c field not updated on updating Laser_Artwork_Order__c Ship_CMF_Info__c');
        }
    }
    
    //Scenario 4:Updating Ship_CMF_Info__c of Laser Artwork Order Object to null
    public static testmethod void test4()
    {
        if(runTest4 || runAll)
        {
            if(!dataFetched)
            {
                FetchValues();
            }
            laoObj.Ship_CMF_Info__c = null;
            
            Test.startTest();
            update laoObj;
            Test.stopTest();
            
            laoObj = [
                SELECT Id, Key_Rep__c 
                FROM Laser_Artwork_Order__c 
                WHERE Id =: laoObj.Id
            ];
            System.assertEquals(null, laoObj.Key_Rep__c,'Key_Rep__c field not updated on updating Laser_Artwork_Order__c Ship_CMF_Info__c to null');
        }
    }
    
    //To perform negitive test
    public static testmethod void negitiveTest()
    {
        if(runNegitiveTest || runAll)
        {
            ALL_UpdateFormOrders_Handler.updateFormsOrderAccountChanged(null,null);
            ALL_UpdateFormOrders_Handler.updateFormsOrderChanged(null);
            ALL_UpdateFormOrders_Handler.futureUpdateFormOrders(null);
        }
    }
}