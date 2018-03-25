//RQ-05035 
//2015-10-13 - lakshmi.addanki@cdk.com - Created new Test Class*/
@IsTest
public class DS_CampaignAccountMember_Test {
    
    //  Developers: Addanki, Lakshmi
    
    private static integer recordCount = 3;                     
    
    //to show debug values set this to true
    //
    private static boolean generateDebugStatements = true;
    //
    //run all tests?
    //
    private static boolean runAll = true;
    //
    //or run specific tests?
    //
    private static boolean insertCam= false;
    private static boolean checkifStatusUpdatedToDefaultOnInsert = false;
    private static boolean checkifStatusUpdatedToDefaultOnUpdate= false;      
    
    //
    //
    //
    //run tests for not implemented trigger functions
    //
    private static boolean notImplemented = false;    
    // insert Campaign Account Member with status --None--
    @testSetup static void initialDataSetup() {
        Campaign newCamp = new Campaign();
        newCamp.Name = 'Test Case for Campaign';
        newCamp.Status = 'In Progress'; 
        insert newCamp;
        Account acc = new Account();
        acc.Name = 'Test Case for Account';
        insert acc;
        Campaign_Member_Status__c status1= new Campaign_Member_Status__c(Campaign__c=newCamp.Id,Name='Status Default',Default_Status__c=true);
        insert status1;
        Campaign_Account_Members__c  cam = new Campaign_Account_Members__c();
        cam.Account__c = acc.Id;
        cam.Campaign__c = newCamp.Id;   
        cam.Campaign_Member_Status__c = '--None--'; 
        insert cam;
    }
    //
    //
    //***********************************************************************************
    //
    //positive testing
    //
    
    
    private static testMethod void insertCAM(){
        if(runAll || insertCam) {
            setHeader('DS_CampaignAccountMemberTrigger_Test:insertCAM');
            //use sub query
            Campaign camp1 = [
                SELECT Id 
                FROM Campaign 
                WHERE Name='Test Case for Campaign' 
                LIMIT 1
            ];
            Account acc =  [
                SELECT Id 
                FROM Account 
                WHERE Name='Test Case for Account' 
                LIMIT 1
            ];
            Campaign_Account_Members__c  insertedCam = [
                SELECT Id,Composite_Id__c ,Campaign__c,Account__c
                FROM Campaign_Account_Members__c 
                WHERE Campaign__c=:camp1.Id
                and Account__c = :acc.Id 
                LIMIT 1
            ];
            //inserted Campaign Account Member Id should contains campaign id &account id
            if(insertedCam.Composite_Id__c != null){
                system.debug('insertedCam.Composite_Id__c' + insertedCam.Composite_Id__c);
                system.assert(insertedCam.Composite_Id__c.contains(insertedCam.Campaign__c)
                              && insertedCam.Composite_Id__c.contains(insertedCam.Account__c) ,'insertCAM');
            }
        }
    }
    
    
    public static testMethod void checkifStatusUpdatedToDefaultOnInsert(){
        
        if(runAll || checkifStatusUpdatedToDefaultOnInsert) {
            setHeader('DS_CampaignAccountMemberTrigger_Test:checkifStatusUpdatedToDefaultOnInsert');
            
            Campaign_Account_Members__c  insertedCam = [
                SELECT Id,Campaign_Member_Status__c 
                FROM Campaign_Account_Members__c 
                WHERE Campaign__c IN (
                    SELECT Id 
                    FROM Campaign 
                    WHERE Name='Test Case for Campaign'                 		
                )              
                and Account__c in (
                    SELECT Id 
                    FROM Account 
                    WHERE Name='Test Case for Account'                 	
                ) 
                LIMIT 1
            ];
            
            //get the default status for the Campaign
            Campaign_Member_Status__c camStatus = [
                Select  Id, name
                From Campaign_Member_Status__c 
                Where Campaign__c IN  (
                    SELECT Id 
                    FROM Campaign 
                    WHERE Name='Test Case for Campaign'                 		
                )   
                AND Default_Status__c = true
            ];           
            
            //When a record is inserted with '--None--' value in the status the value should be changed to the 
            //default status.                                           
            
            system.assert(insertedCam.Campaign_Member_Status__c.equals(camStatus.name),'checkifStatusUpdatedToDefaultOnInsert');
            system.debug(' ***Campaign_Member_Status__c in test class after'+insertedCam.Campaign_Member_Status__c);
            
            
        }
        
    }
    //Very similar to the above method but testing ' update ' coverage.
    //Update a Campaign Account Member with a '--None-- ' status and it should default to the default Status. 
    public static testMethod void checkifStatusUpdatedToDefaultOnUpdate(){
        
        if(runAll || checkifStatusUpdatedToDefaultOnUpdate) {
            setHeader('DS_CampaignAccountMemberTrigger_Test:checkifStatusUpdatedToDefaultOnUpdate');
            Campaign_Account_Members__c  insertedCam = [
                SELECT Id,Campaign_Member_Status__c 
                FROM Campaign_Account_Members__c 
                WHERE Campaign__c IN (
                    SELECT Id 
                    FROM Campaign 
                    WHERE Name='Test Case for Campaign'                 		
                )              
                and Account__c in (
                    SELECT Id 
                    FROM Account 
                    WHERE Name='Test Case for Account'                 	
                ) 
                LIMIT 1
            ];
            //set update value to --None-- and update
            insertedCam.Campaign_Member_Status__c = '--None--'; 
            try{
                update insertedCam;
            }catch(Exception e){
                system.debug('update failed');
            } 
            Campaign_Account_Members__c  updatedCam = [
                SELECT Id,Campaign_Member_Status__c 
                FROM Campaign_Account_Members__c 
                WHERE Campaign__c IN (
                    SELECT Id 
                    FROM Campaign 
                    WHERE Name='Test Case for Campaign'                 		
                )              
                and Account__c in (
                    SELECT Id 
                    FROM Account 
                    WHERE Name='Test Case for Account'                 	
                ) 
                LIMIT 1
            ];
            system.debug('updatedCam after update ' + updatedCam.Campaign_Member_Status__c); 
            
            //get the default status for the Campaign
            Campaign_Member_Status__c camStatus = [
                Select  Id,name 
                From Campaign_Member_Status__c 
                Where Campaign__c IN  (
                    SELECT Id 
                    FROM Campaign 
                    WHERE Name='Test Case for Campaign' 
                )   
                AND Default_Status__c = true
            ];           
            system.debug('camStatus after update ' + camStatus.name);           
            system.assert(updatedCam.Campaign_Member_Status__c.equals(camStatus.name),'checkifStatusUpdatedToDefaultOnUpdate');
            system.debug(' ***updatedCam.Campaign_Member_Status__c'+updatedCam.Campaign_Member_Status__c);
            
        }
        
    }
    
    private static void setHeader(string txt){
        if(generateDebugStatements){
            system.debug('****************************************');
            system.debug('** ' + txt);            
            system.debug('****************************************');
        }
    } 
    
    private static void showDebug(object obj){
        if(generateDebugStatements){
            system.debug(obj);
        }
    } 
    
}