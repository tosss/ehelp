//RQ-05035 
//2015-10-13 - lakshmi.addanki@cdk.com - Created new Test Class
//
@IsTest
public with sharing class DS_CampaignMemberStatus_Test {
    
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
    private static boolean insertCampaignMemStatusPos = false;
    private static boolean insertCampaignMemStatusNeg= false;
    private static boolean updateCampaignMemStatusNeg = false;
    private static boolean updateCampaignMemberStatusName = false;
    
    private static boolean notImplemented = false;    
    //
    @testSetup static void initialDataSetup() {
        Campaign newCamp = new Campaign();
        newCamp.Name='Campaign I';
        insert newCamp;
        
        Account acct = new Account(Name='Campaign I Account I');
        insert acct;
        
        //inserting record with default sttaus = true
        Campaign_Member_Status__c status1= new Campaign_Member_Status__c(Campaign__c=newCamp.Id,Name='Status1',Default_Status__c=true);
        insert status1;
        
        //inserting record with default sttaus = true
        Campaign_Member_Status__c status2= new Campaign_Member_Status__c(Campaign__c=newCamp.Id,Name='Status2',Default_Status__c=false);
        insert status2;
        
        Campaign_Account_Members__c CAM1= new Campaign_Account_Members__c(Account__c=acct.Id, Campaign__c=newCamp.Id,Campaign_Member_Status__c=status1.Name );
        insert CAM1;
        
    }
    
    
    //*******************************************************************************************************
    //Insert Second record for 'Campaign Member Status' for a specific Campaign with defalut status=false;
    //Since a record is already inserted with default status in the test data septup , insert should process with no issues*/
    
    
    
    private static testMethod void insertCampaignMemStatusPos(){
        if(runAll || insertCampaignMemStatusPos) {
            setHeader('DS_CampaignMemStatusTrigger_Test:insertCampaignMemStatusPos');
            Campaign newCamp = [Select  Id From Campaign where name='Campaign I' 
                                limit 1];
            try {
                Campaign_Member_Status__c status2a= new Campaign_Member_Status__c(Campaign__c=newCamp.Id,Name='Status2p',Default_Status__c=false);
                insert status2a;
                system.assert(true,'insertCampaignMemStatusPos');
            } catch(Exception x){
                showDebug('Failure--->insert of Campaign Memebet Status  failed with message:  ' + x.getMessage());
                system.assert(false, 'insertCampaignMemStatusPos');
            }
        }
    }
    //
    //********************************************************************************************************
    //Insert Second record for 'Campaign Member Status' for a specific Campaign with defalut status=true;
    //Since a record is already inserted with default status in the test data septup , insert should fail with error
    //
    
    private static testMethod void insertCampaignMemStatusNeg(){
        if(runAll || insertCampaignMemStatusNeg) {
            setHeader('DS_CampaignMemStatusTrigger_Test:insertCampaignMemStatusNeg');
            Campaign newCamp = [
                Select  Id 
                From Campaign 
                where name='Campaign I' 
                limit 1
            ];
            try {
                Campaign_Member_Status__c status2a= new Campaign_Member_Status__c(Campaign__c=newCamp.Id,Name='Status2n',Default_Status__c=true);
                insert status2a;
                system.assert(false,'insertCampaignMemStatusNeg');
            } catch(Exception x){
                showDebug('insert of Campaign Memeber Status duplicate Default Status failed with message:  ' + x.getMessage());
                system.assert(true,'insertCampaignMemStatusNeg');
            }
        }
    }
    
    //
    //********************************************************************************************************
    //Update record for 'Campaign Member Status' for a specific Campaign and set defalut status=true;
    //Since a record is already inserted with default status in the test data septup , update should fail with error
    //
    
    private static testMethod void updateCampaignMemStatusNeg(){
        
        if(runAll || updateCampaignMemStatusNeg) {
            setHeader('DS_CampaignMemStatusTrigger_Test:updateCampaignMemStatusNeg');
            Campaign newCamp = [
                Select  Id 
                From Campaign 
                where name='Campaign I' 
                limit 1
            ];
            // get the Campaign_Member_Status for this status
            Campaign_Member_Status__c camMemStats = [
                Select c.Id, c.Campaign__c, c.name ,c.Default_Status__c
                From Campaign_Member_Status__c c 
                where Campaign__c=:newCamp.Id 
                and Name ='Status2'
                limit 1
            ];
            System.debug('Test:updateCampaignMemStatusNeg camMemStats ' + camMemStats); 
            System.debug('Test:updateCampaignMemStatusNeg camMemStats' + camMemStats.Default_Status__c); 
            Campaign_Member_Status__c cmsUpdate= new Campaign_Member_Status__c(Id=camMemStats.Id, Campaign__c=newCamp.Id,Default_Status__c = true);
            try {
                update cmsUpdate;
                system.assert(false,'updateCampaignMemStatusNeg');
            } catch(Exception x){
                showDebug('update of Campaign Memeber Status duplicate Default Status failed with message:  ' + x.getMessage());
                system.assert(true,'updateCampaignMemStatusNeg');
            }
        }
    }
    
    
    
    //
    //***************************************************************************************************************
    //If a Campaign Member Status is updated all Campaign Account Members having the old status should be updated 
    //
    
    public static testMethod void updateCampaignMemberStatusName(){
        try{
            if(runAll || updateCampaignMemberStatusName) {
                setHeader('DS_CampaignMemStatusTrigger_Test:updateCampaignMemberStatusName');
                Campaign newCamp = [
                    Select  Id 
                    From Campaign 
                    where name='Campaign I' 
                    limit 1
                ];
                system.debug('newCamp ' + newCamp);                                         
                Account acct  = [
                    Select  Id , Name 
                    From Account 
                    where name='Campaign I Account I' 
                    limit 1
                ];
                system.debug('acct ' + acct);   
                //get Campaign Account member and  select the status
                Campaign_Account_Members__c tobeUpdatedCam = [
                    Select  Campaign__c, Campaign_Member_Status__c 
                    From Campaign_Account_Members__c  
                    where Campaign__c=:newCamp.Id 
                    and Account__c= :acct.Id 
                    limit 1
                ];
                system.debug('tobeUpdatedCam ' + tobeUpdatedCam);   
                String oldStatus = tobeUpdatedCam.Campaign_Member_Status__c;
                system.debug(' old status before update '+ oldStatus);
                
                // get the Campaign_Member_Status for this status
                Campaign_Member_Status__c tobeUpdatedCamMemStats = [
                    Select c.Id, c.Campaign__c, c.name 
                    From Campaign_Member_Status__c c 
                    where Campaign__c=:newCamp.Id 
                    and Name =:oldStatus 
                    limit 1
                ];
                
                String newStatus='StatusUpdated';
                Campaign_Member_Status__c status1b= new Campaign_Member_Status__c(Id=tobeUpdatedCamMemStats.Id, Campaign__c=newCamp.Id,Name=newStatus);
                system.debug(' updating StatusUpdated '); 
                update status1b;
                
                system.debug(' after update before select ' + tobeUpdatedCam.Campaign_Member_Status__c );  
                
                Campaign_Account_Members__c updatedCam = [
                    Select  Campaign__c, Campaign_Member_Status__c From Campaign_Account_Members__c  
                    where Campaign__c=:newCamp.Id 
                    and Account__c= :acct.Id 
                    limit 1
                ];
                
                system.assert(updatedCam.Campaign_Member_Status__c.equals(status1b.name),'updateCampaignMemberStatusName');
                
            }
        } catch(Exception x){
            showDebug(x.getMessage());
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