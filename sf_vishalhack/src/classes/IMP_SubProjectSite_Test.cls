/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Test class for the IMP_SubProjectSite_Handler
History
12/29/14     Samuel Oberes      Created
02/06/15     Samuel Oberes      added forcePopulateCMF_Test method
07/29/15     Samuel Oberes      added refreshRMSRequestIdField_Test
08/05/15     Samuel Oberes      added new assertions for refreshRMSRequestIdField_Test
08/06/15     Samuel Oberes      fixed sitetype (active = true)
10/22/15     Samuel Oberes      Added scenario in refreshRMSRequestIdField_Test to check if cmf is getting concatenated as well
11/15/16     Venkata Shrivol	Added preventRMSSitesDeletion_Test testMethod, RQ-07985
12/12/16     Venkata Shrivol	Commented project object and discovery object code as they are no longer needed RQ-08305
------------------------------------------------------------*/
@isTest
private class IMP_SubProjectSite_Test {

    private static final Account account1_parent;
    private static final Account account1;
    private static final Account account2;
    private static final SubProject__c subProject;

    static {

        Site_Type__c siteType = IMP_TestFactory_Helper.buildSiteType();
        siteType.Group_Flag__c = true;
        //siteType.Active__c = true;
        insert siteType;

        account1_parent = IMP_TestFactory_Helper.buildAccount();
        account1_parent.Name = 'PARENT ACCOUNT';
        account1_parent.Site_Type__c = siteType.Id;
        insert account1_parent;

        account1 = IMP_TestFactory_Helper.buildAccount();
        account1.Name = 'CHILD ACCOUNT';
        account1.Site_Type__c = siteType.Id;
        account1.ParentId = account1_parent.Id;
        insert account1;

        account2 = IMP_TestFactory_Helper.buildAccount();
        insert account2;

        /*Project__c project = IMP_TestFactory_Helper.buildProject(0);
        insert project;*/

        subProject = IMP_TestFactory_Helper.buildSubProject();
        insert subProject;

    }
    
    

    private static testmethod void rejectDuplicateSites_Test() {

        List<SubProjectSite__c> site;
        List<SubProjectSite__c> sites;

        String BLANK_SHIP_CMF_NAME = 'BLANK SHIP CMF | USING ACCOUNT 1';
        String NON_BLANK_SHIP_CMF_NAME_1 = 'WITH SHIP CMF | USING ACCOUNT 1';
        String NON_BLANK_SHIP_CMF_NAME_2 = 'WITH SHIP CMF | USING ACCOUNT 2';
        String NON_BLANK_SHIP_CMF_NAME_ACCT_REUSE = 'WITH SHIP CMF | RE-USING ACCOUNT 1';
        String SHIP_CMF_1 = '00000001';
        String SHIP_CMF_2 = '00000002';
        String SHIP_CMF_3 = '00000003';
        
        // -----------------------------------------------------------------------------------------------
        // SCENARIO 1:  Insert a subproject site using a cmf info with blank ship cmf.
        // EXPECTATION: Expect the subproject site to be created without an account, dealer group, and ship cmf.
        // EXPLANATION: Account and dealer group is blank because they are only populated whenever an inserted site has a non-blank ship cmf.

        CMF_Info__c cmfInfo_blankShipCmf = new CMF_Info__c();
        cmfInfo_blankShipCmf.Account__c = account1.Id;
        cmfInfo_blankShipCmf.Name = BLANK_SHIP_CMF_NAME;
        cmfInfo_blankShipCmf.Status__c = 'A';
        insert cmfInfo_blankShipCmf;

        SubProjectSite__c site_using_cmfInfo_blankShipCmf = new SubProjectSite__c();
        site_using_cmfInfo_blankShipCmf.SubProject__c = subProject.Id;
        site_using_cmfInfo_blankShipCmf.CMF_Name__c = cmfInfo_blankShipCmf.Id;
        
        try {
            insert site_using_cmfInfo_blankShipCmf;

            site = [SELECT Account__c, Ship_CMF__c, CMF_Name__r.Name FROM SubProjectSite__c];
            
            System.assertEquals(1                  , site.size());
            System.assertEquals(null               , site.get(0).Account__c);
            //System.assertEquals(null               , site.get(0).Dealer_Group__c);
            System.assertEquals(null               , site.get(0).Ship_CMF__c);
            System.assertEquals(BLANK_SHIP_CMF_NAME, site.get(0).CMF_Name__r.Name);

        } catch (DmlException e) {
            System.assertEquals('Expecting no errors to be encountered.', 'Error(s) encountered:  \n' + e.getMessage());
        }

        // -----------------------------------------------------------------------------------------------
        // SCENARIO 2:  Insert a subproject site using a cmf info with blank ship cmf. (same as in scenario 1)
        // EXPECTATION: Expect the subproject site to be created without an account, dealer group, and ship cmf. Now we have 2 sites with blank ship cmf.
        // EXPLANATION: Account and dealer group is blank because they are only populated whenever an inserted site has a non-blank ship cmf.
        //              A 'duplicate site' scenario will also not be strictly checked because it requires that a site should have a ship cmf.

        SubProjectSite__c site_using_cmfInfo_blankShipCmf_2 = new SubProjectSite__c();
        site_using_cmfInfo_blankShipCmf_2.SubProject__c = subProject.Id;
        site_using_cmfInfo_blankShipCmf_2.CMF_Name__c = cmfInfo_blankShipCmf.Id;
        
        try {
            insert site_using_cmfInfo_blankShipCmf_2;

            sites = [SELECT Account__c, Ship_CMF__c, CMF_Name__r.Name FROM SubProjectSite__c];
            
            System.assertEquals(2, sites.size());

            for (SubProjectSite__c s : sites) {
                System.assertEquals(null               , s.Account__c);
                //System.assertEquals(null               , s.Dealer_Group__c);
                System.assertEquals(null               , s.Ship_CMF__c);
                System.assertEquals(BLANK_SHIP_CMF_NAME, s.CMF_Name__r.Name);
            }
            
        } catch (DmlException e) {
            System.assertEquals('Expecting no errors to be encountered.', 'Error(s) encountered:  \n' + e.getMessage());
        }

        // -----------------------------------------------------------------------------------------------
        // SCENARIO 3:  Insert a subproject site using a cmf info with non-blank ship cmf. Also, account1 will be used by the CMF Info.
        // EXPECTATION: Expect the subproject site to be created with an account and dealer group.
        // EXPLANATION: Account and dealer group has been populated successfully because the inserted site now has a non-blank ship cmf.

        CMF_Info__c cmfInfo_withShipCmf_acct_1 = new CMF_Info__c();
        cmfInfo_withShipCmf_acct_1.Account__c = account1.Id;
        cmfInfo_withShipCmf_acct_1.Name = NON_BLANK_SHIP_CMF_NAME_1;
        cmfInfo_withShipCmf_acct_1.Ship_CMF__c = SHIP_CMF_1;
        cmfInfo_withShipCmf_acct_1.Status__c = 'A';
        insert cmfInfo_withShipCmf_acct_1;

        SubProjectSite__c site_using_cmfInfo_withShipCmf_acct_1 = new SubProjectSite__c();
        site_using_cmfInfo_withShipCmf_acct_1.SubProject__c = subProject.Id;
        site_using_cmfInfo_withShipCmf_acct_1.CMF_Name__c = cmfInfo_withShipCmf_acct_1.Id;
        
        try {

            insert site_using_cmfInfo_withShipCmf_acct_1;

            site = [SELECT Account__c, Ship_CMF__c, CMF_Name__r.Name FROM SubProjectSite__c WHERE Id = :site_using_cmfInfo_withShipCmf_acct_1.Id];
            
            System.assertEquals(1                                    , site.size());
            System.assertEquals(cmfInfo_withShipCmf_acct_1.Account__c, site.get(0).Account__c);
           // System.assertEquals(account1_parent.Id                   , site.get(0).Dealer_Group__c);
            System.assertEquals(SHIP_CMF_1                           , site.get(0).Ship_CMF__c);
            System.assertEquals(NON_BLANK_SHIP_CMF_NAME_1            , site.get(0).CMF_Name__r.Name);

        } catch (DmlException e) {
            System.assertEquals('Expecting no errors to be encountered.', 'Error(s) encountered:  \n' + e.getMessage());
        }

        // -----------------------------------------------------------------------------------------------
        // SCENARIO 4:  Insert a subproject site using a cmf info with non-blank ship cmf. Also, account2 will be used by the CMF Info instead of account1.
        // EXPECTATION: Expect the subproject site to be created with an account and dealer group.
        // EXPLANATION: Account and dealer group has been populated successfully because the inserted site now has a non-blank ship cmf.
        //              The 'duplicate site' error wasn't triggered because the site in this scenario is using a different account compared to the site in scenario 3.

        CMF_Info__c cmfInfo_withShipCmf_acct_2 = new CMF_Info__c();
        cmfInfo_withShipCmf_acct_2.Account__c = account2.Id;
        cmfInfo_withShipCmf_acct_2.Name = NON_BLANK_SHIP_CMF_NAME_2;
        cmfInfo_withShipCmf_acct_2.Ship_CMF__c = SHIP_CMF_2;
        cmfInfo_withShipCmf_acct_2.Status__c = 'A';
        insert cmfInfo_withShipCmf_acct_2;

        SubProjectSite__c site_using_cmfInfo_withShipCmf_acct_2 = new SubProjectSite__c();
        site_using_cmfInfo_withShipCmf_acct_2.SubProject__c = subProject.Id;
        site_using_cmfInfo_withShipCmf_acct_2.CMF_Name__c = cmfInfo_withShipCmf_acct_2.Id;
        
        try {
            insert site_using_cmfInfo_withShipCmf_acct_2;

            site = [SELECT Account__c, Ship_CMF__c, CMF_Name__r.Name FROM SubProjectSite__c WHERE Id = :site_using_cmfInfo_withShipCmf_acct_2.Id];
            
            System.assertEquals(1                                    , site.size());
            System.assertEquals(cmfInfo_withShipCmf_acct_2.Account__c, site.get(0).Account__c);
            //System.assertEquals(cmfInfo_withShipCmf_acct_2.Account__c, site.get(0).Dealer_Group__c);
            System.assertEquals(SHIP_CMF_2                           , site.get(0).Ship_CMF__c);
            System.assertEquals(NON_BLANK_SHIP_CMF_NAME_2            , site.get(0).CMF_Name__r.Name);

        } catch (DmlException e) {
            System.assertEquals('Expecting no errors to be encountered.', 'Error(s) encountered:  \n' + e.getMessage());
        } 

        // -----------------------------------------------------------------------------------------------
        // SCENARIO 5:  Insert a subproject site using a cmf info with non-blank ship cmf. 
        //              Also, account1 will be used by the CMF Info, the first instance account 1 will be used by another cmf info with a non-blank ship cmf.
        // EXPECTATION: Expect the 'duplicate site' error to be triggered.
        // EXPLANATION: Subproject sites should use cmf infos, whose accounts are not used yet by other cmf infos. 
        //              Inserting a site, linked with a cmf info, whose account already exists among the other cmf infos, will result in an error.

        CMF_Info__c cmfInfo_withShipCmf_acct_1_reuse = new CMF_Info__c();
        cmfInfo_withShipCmf_acct_1_reuse.Account__c = account1.Id;
        cmfInfo_withShipCmf_acct_1_reuse.Name = NON_BLANK_SHIP_CMF_NAME_ACCT_REUSE;
        cmfInfo_withShipCmf_acct_1_reuse.Ship_CMF__c = SHIP_CMF_3;
        cmfInfo_withShipCmf_acct_1_reuse.Status__c = 'A';
        insert cmfInfo_withShipCmf_acct_1_reuse;

        SubProjectSite__c site_using_cmfInfo_withShipCmf_acct_1_reuse = new SubProjectSite__c();
        site_using_cmfInfo_withShipCmf_acct_1_reuse.SubProject__c = subProject.Id;
        site_using_cmfInfo_withShipCmf_acct_1_reuse.CMF_Name__c = cmfInfo_withShipCmf_acct_1_reuse.Id;
        
        try {

            insert site_using_cmfInfo_withShipCmf_acct_1_reuse;
            System.assertEquals('Expecting not to reach this part of the code because a duplicate site should trigger an error.', 
                                'This code has been reached. The expected error due to duplicate site wasn\'t triggered');

        } catch (DmlException e) {
            System.assertEquals(true, e.getMessage().contains(IMP_SubProjectSite_Handler.ERR_MESSAGE_DUPLICATE_SITE));
        }

        // -----------------------------------------------------------------------------------------------
        // SCENARIO 6:  Update 'site_using_cmfInfo_blankShipCmf' without changing anything.
        // EXPECTATION: Expect it to get updated. Expect no fields to change.
        // EXPLANATION: This is to test if the update context is not mistakenly treating the site's account as a duplicate.

        try {
            
            String beforeUpdate_name = site_using_cmfInfo_blankShipCmf.CMF_Name__c;

            update site_using_cmfInfo_blankShipCmf;
            
            site = [SELECT Account__c, Ship_CMF__c, CMF_Name__c FROM SubProjectSite__c WHERE Id = :site_using_cmfInfo_blankShipCmf.Id];
            
            System.assertEquals(1                , site.size());
            System.assertEquals(null             , site.get(0).Account__c);
            //System.assertEquals(null             , site.get(0).Dealer_Group__c);
            System.assertEquals(null             , site.get(0).Ship_CMF__c);
            System.assertEquals(beforeUpdate_name, site.get(0).CMF_Name__c);

        } catch (DmlException e) {
            System.assertEquals('Expecting no errors to be encountered.', 'Error(s) encountered:  \n' + e.getMessage());
        }
        
        // -----------------------------------------------------------------------------------------------
        // SCENARIO 7:  Update the 'New CMF#' field of 'site_using_cmfInfo_blankShipCmf'.
        // EXPECTATION: Expect it to get updated.
        // EXPLANATION: This is to test if the update context is not mistakenly treating the site's account as a duplicate, and if normal update scenario is working.
        
        try {
            
            String beforeUpdate_name = site_using_cmfInfo_blankShipCmf.CMF_Name__C;

            site_using_cmfInfo_blankShipCmf.New_CMF__c = '1'; // changed from nothing to 1
            update site_using_cmfInfo_blankShipCmf;
            
            site = [SELECT Account__c,  Ship_CMF__c, CMF_Name__c, New_CMF__c FROM SubProjectSite__c WHERE Id = :site_using_cmfInfo_blankShipCmf.Id];
            
            System.assertEquals(1                , site.size());
            System.assertEquals(null             , site.get(0).Account__c);
           // System.assertEquals(null             , site.get(0).Dealer_Group__c);
            System.assertEquals(null             , site.get(0).Ship_CMF__c);
            System.assertEquals(beforeUpdate_name, site.get(0).CMF_Name__c);
            System.assertEquals('1'               , site.get(0).New_CMF__c);

        } catch (DmlException e) {
            System.assertEquals('Expecting no errors to be encountered.', 'Error(s) encountered:  \n' + e.getMessage());
        }
        
        // -----------------------------------------------------------------------------------------------
        // SCENARIO 8:  Update 'CMF Name' field of 'site_using_cmfInfo_blankShipCmf' and use 'cmfInfo_withShipCmf_acct_1_reuse'
        // EXPECTATION: Expect the 'duplicate site' error to be triggered.
        // EXPLANATION: 'cmfInfo_withShipCmf_acct_1_reuse' uses account1, a previously used account by another cmfInfo (cmfInfo_withShipCmf_acct_1). 
        //              A site cannot use a cmf info whose account is already used by another cmf info.

        try {

            site_using_cmfInfo_blankShipCmf.CMF_Name__c = cmfInfo_withShipCmf_acct_1_reuse.Id;
            update site_using_cmfInfo_blankShipCmf;

            System.assertEquals('Expecting not to reach this part of the code because a duplicate site should trigger an error.', 
                                'This code has been reached. The expected error due to duplicate site wasn\'t triggered');

        } catch (DmlException e) {
            System.assertEquals(true, e.getMessage().contains(IMP_SubProjectSite_Handler.ERR_MESSAGE_DUPLICATE_SITE));
        }

        // -----------------------------------------------------------------------------------------------
        // SCENARIO 9:  Update 'site_using_cmfInfo_withShipCmf_acct_1' without changing anything.
        // EXPECTATION: Expect it to get updated. Expect no fields to change.
        // EXPLANATION: This is to test if the update context is not mistakenly treating the site's account as a duplicate.
        //              The only difference of this scenario with scenario 6 is that this site's cmf info's ship cmf is not blank.
        
        try {
            
            update site_using_cmfInfo_withShipCmf_acct_1;
            
            site = [SELECT Account__c, Ship_CMF__c, CMF_Name__r.Name FROM SubProjectSite__c WHERE Id = :site_using_cmfInfo_withShipCmf_acct_1.Id];
            
            System.assertEquals(1                         , site.size());
            System.assertEquals(account1.Id               , site.get(0).Account__c);
            //System.assertEquals(account1_parent.Id        , site.get(0).Dealer_Group__c);
            System.assertEquals(SHIP_CMF_1                , site.get(0).Ship_CMF__c);
            System.assertEquals(NON_BLANK_SHIP_CMF_NAME_1 , site.get(0).CMF_Name__r.Name);

        } catch (DmlException e) {
            System.assertEquals('Expecting no errors to be encountered.', 'Error(s) encountered:  \n' + e.getMessage());
        }

        // -----------------------------------------------------------------------------------------------
        // SCENARIO 10: Update the 'New CMF#' field of 'site_using_cmfInfo_withShipCmf_acct_1'.
        // EXPECTATION: Expect it to get updated.
        // EXPLANATION: This is to test if the update context is not mistakenly treating the site's account as a duplicate, and if normal update scenario is working.
        
        try {
            
            site_using_cmfInfo_withShipCmf_acct_1.New_CMF__c = '2'; // changed from nothing to 2
            update site_using_cmfInfo_withShipCmf_acct_1;
            
            site = [SELECT Account__c,  Ship_CMF__c, CMF_Name__r.Name, New_CMF__c FROM SubProjectSite__c WHERE Id = :site_using_cmfInfo_withShipCmf_acct_1.Id];
            
            System.assertEquals(1                         , site.size());
            System.assertEquals(account1.Id               , site.get(0).Account__c);
            //System.assertEquals(account1_parent.Id        , site.get(0).Dealer_Group__c);
            System.assertEquals(SHIP_CMF_1                , site.get(0).Ship_CMF__c);
            System.assertEquals(NON_BLANK_SHIP_CMF_NAME_1 , site.get(0).CMF_Name__r.Name);
            System.assertEquals('2'                         , site.get(0).New_CMF__c);

        } catch (DmlException e) {
            System.assertEquals('Expecting no errors to be encountered.', 'Error(s) encountered:  \n' + e.getMessage());
        }

        // -----------------------------------------------------------------------------------------------
        // SCENARIO 11: Update 'CMF Name' field of 'site_using_cmfInfo_withShipCmf_acct_1' and use 'cmfInfo_withShipCmf_acct_1_reuse'
        // EXPECTATION: Expect the 'duplicate site' error to be triggered.
        // EXPLANATION: 'cmfInfo_withShipCmf_acct_1_reuse' uses account1, a previously used account by another cmfInfo (cmfInfo_withShipCmf_acct_1). 
        //              A site cannot use a cmf info whose account is already used by another cmf info.

        try {

            site_using_cmfInfo_withShipCmf_acct_1.CMF_Name__c = cmfInfo_withShipCmf_acct_1_reuse.Id;
            update site_using_cmfInfo_withShipCmf_acct_1;

            System.assertEquals('Expecting not to reach this part of the code because a duplicate site should trigger an error.', 
                                'This code has been reached. The expected error due to duplicate site wasn\'t triggered');

        } catch (DmlException e) {
            System.assertEquals(true, e.getMessage().contains(IMP_SubProjectSite_Handler.ERR_MESSAGE_DUPLICATE_SITE));
        }

    }

    private static testmethod void populateAccountAndDealerGroup_Test() {

        CMF_Info__c cmfInfo = new CMF_Info__c();
        cmfInfo.Account__c = account1.Id;
        cmfInfo.Name = 'TEST CMF NAME';
        cmfInfo.Ship_CMF__c = '12345678';
        cmfInfo.Status__c = 'A';
        insert cmfInfo;

        SubProjectSite__c subProjectSite = new SubProjectSite__c();
        subProjectSite.SubProject__c = subProject.Id;
        subProjectSite.CMF_Name__c = cmfInfo.Id;
        insert subProjectSite;

        List<SubProjectSite__c> site = [SELECT Account__c FROM SubProjectSite__c];

        // there should be 1 new successfully created site
        System.assertEquals(1, site.size());

        // the account of the site should be the same with the account of the cmf info
        System.assertEquals(cmfInfo.Account__c, site.get(0).Account__c);

        // the dealer group of the site should be the same with the top most parent of its account
       // System.assertEquals(account1_parent.Id, site.get(0).Dealer_Group__c);

    }

    private static testmethod void forcePopulateCMF_Test() {
        CMF_Info__c cmfInfo = new CMF_Info__c();
        cmfInfo.Account__c = account1.Id;
        cmfInfo.Name = 'TEST CMF NAME 1';
        cmfInfo.Ship_CMF__c = 'ABCDE';
        cmfInfo.Status__c = 'A';
        insert cmfInfo;

        CMF_Info__c cmfInfo2 = new CMF_Info__c();
        cmfInfo2.Account__c = account2.Id;
        cmfInfo2.Name = 'TEST CMF NAME 2';
        cmfInfo2.Ship_CMF__c = '12345';
        cmfInfo2.Status__c = 'A';
        insert cmfInfo2;

        SubProjectSite__c subProjectSite = new SubProjectSite__c();
        subProjectSite.SubProject__c = subProject.Id;
        subProjectSite.CMF_Name__c = cmfInfo.Id;
        subProjectSite.CMF_Numbers__c = 'ABC,DEF,GHI,JKL';
        insert subProjectSite;

        List<SubProjectSite__c> site = [SELECT Account__c, CMF_Numbers__c FROM SubProjectSite__c];

        // there should be 1 new successfully created site
        System.assertEquals(1, site.size());

        // the account of the site should be the same with the account of the cmf info
        System.assertEquals(cmfInfo.Account__c, site.get(0).Account__c);

        // check equality for the cmf numbers of the sps
        System.assertEquals('ABC,DEF,GHI,JKL', site.get(0).CMF_Numbers__c);

        // update SPS. since cmfinfo2 has a different account compared to cmfinfo1, expect the SPS CMF_Numbers field to get overwritten with the value of cmfinfo2 Ship_CMF__c
        subProjectSite.CMF_Name__c = cmfInfo2.Id;
        update subProjectSite;

        site = [SELECT Account__c, CMF_Numbers__c FROM SubProjectSite__c];

        // there should be 1 existing site since we did not delete it
        System.assertEquals(1, site.size());

        // the account of the site should be the same with the account of the new cmf info
        System.assertEquals(cmfInfo2.Account__c, site.get(0).Account__c);

        // the SPS cmfnumbers field should now contain the ship cmf of its new cmf info
        System.assertEquals(cmfInfo2.Ship_CMF__c, site.get(0).CMF_Numbers__c);
    }
    
     private static testmethod void preventReparentOfSites_Test() 
     {

        List<SubProjectSite__c> site;
        List<SubProjectSite__c> sites;
       
        String NON_BLANK_SHIP_CMF_NAME_1 = 'WITH SHIP CMF | USING ACCOUNT 1';      
        String NON_BLANK_SHIP_CMF_NAME_ACCT_REUSE = 'WITH SHIP CMF | RE-USING ACCOUNT 1';
        String SHIP_CMF_1 = '00000001';       

        CMF_Info__c cmfInfo_withShipCmf_acct_1 = new CMF_Info__c();
        cmfInfo_withShipCmf_acct_1.Account__c = account1.Id;
        cmfInfo_withShipCmf_acct_1.Name = NON_BLANK_SHIP_CMF_NAME_1;
        cmfInfo_withShipCmf_acct_1.Ship_CMF__c = SHIP_CMF_1;
        cmfInfo_withShipCmf_acct_1.Status__c = 'A';
        insert cmfInfo_withShipCmf_acct_1;

        SubProjectSite__c site_using_cmfInfo_withShipCmf_acct_1 = new SubProjectSite__c();
        site_using_cmfInfo_withShipCmf_acct_1.SubProject__c = subProject.Id;
        site_using_cmfInfo_withShipCmf_acct_1.CMF_Name__c = cmfInfo_withShipCmf_acct_1.Id;
      
         
        try {

            insert site_using_cmfInfo_withShipCmf_acct_1;

            site = [SELECT Account__c, Ship_CMF__c, CMF_Name__r.Name FROM SubProjectSite__c WHERE Id = :site_using_cmfInfo_withShipCmf_acct_1.Id];
            
            System.assertEquals(1                                    , site.size());
            System.assertEquals(cmfInfo_withShipCmf_acct_1.Account__c, site.get(0).Account__c);
            //System.assertEquals(account1_parent.Id                   , site.get(0).Dealer_Group__c);
            System.assertEquals(SHIP_CMF_1                           , site.get(0).Ship_CMF__c);
            System.assertEquals(NON_BLANK_SHIP_CMF_NAME_1            , site.get(0).CMF_Name__r.Name);

        } catch (DmlException e) {
            System.assertEquals('Expecting no errors to be encountered.', 'Error(s) encountered:  \n' + e.getMessage());
        }
         //Insert a new project
        /* Project__c project = IMP_TestFactory_Helper.buildProject(0);
         insert project;*/
         
         Subproject__c subProject2 = IMP_TestFactory_Helper.buildSubProject();
         insert subProject2;
         test.startTest();
         //test if the site is reparent to another subproject that has different project
         try
         {
             site_using_cmfInfo_withShipCmf_acct_1.SubProject__c = subProject2.id;
             update site_using_cmfInfo_withShipCmf_acct_1;
         } 
         catch (DmlException e) 
         {
             system.assert(e.getMessage().contains('Cannot reparent subproject site to another subproject that has different project'));
         }
         //test if the site is already associated with 1 or more milestone records
         Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject2.Id, 'test');
         milestone.Site__c = site_using_cmfInfo_withShipCmf_acct_1.Id;
         insert milestone;
         
         Subproject__c subProject3 = IMP_TestFactory_Helper.buildSubProject();
         insert subProject3;
         try
         {
             site_using_cmfInfo_withShipCmf_acct_1.SubProject__c = subProject3.id;
             update site_using_cmfInfo_withShipCmf_acct_1;
         } 
         catch (DmlException e) 
         {
             system.assert(e.getMessage().contains('Cannot reparent subproject site if it is already associated with 1 or more milestone records'));
         }
         
         Delete milestone;
         /*Site_Workbook__c siteWorkbook = IMP_TestFactory_Helper.buildSiteWorkbook(subProject3.Project__c,subProject.id);
         siteWorkbook.SubProject__c = subProject.id;
         siteWorkbook.site__c = account1.Id;
         
         insert siteWorkbook;*/
         
         /*try
         {
             site_using_cmfInfo_withShipCmf_acct_1.SubProject__c = subProject3.id;
             update site_using_cmfInfo_withShipCmf_acct_1;
         } 
         catch (DmlException e) 
         {
             system.assert(e.getMessage().contains('Cannot reparent subproject site if it is already associated with 1 or more discovery records'));
         }*/         

         test.stopTest();
     }

     private static testmethod void refreshRMSRequestIdField_Test()
    {
        // -----------------------------------------------------------------------------------------------
        // This test is initiated from insertion of record to junction object CMFtoSubProjectSite__c

        // -----------------------------------------------------------------------------------------------
        // INITIALIZATION:

        CMF_Info__c cmfInfo = new CMF_Info__c();
        cmfInfo.Account__c = account1.Id;
        cmfInfo.Name = 'TEST CMF NAME';
        cmfInfo.Ship_CMF__c = '00000001';
        cmfInfo.Status__c = 'A';
        insert cmfInfo;

        SubProjectSite__c site = new SubProjectSite__c();
        site.SubProject__c = subProject.Id;
        site.CMF_Name__c = cmfInfo.Id;
        insert site;

        IMP_EntityTypeHelper__c eh1 = new IMP_EntityTypeHelper__c(Name = 'CMF', Entity_Field_Name__c = 'CMF_Numbers__c');
        IMP_EntityTypeHelper__c eh2 = new IMP_EntityTypeHelper__c(Name = 'RMS Request', Entity_Field_Name__c = 'RMS_Request_Ids__c');
        insert new List<IMP_EntityTypeHelper__c>{ eh1, eh2 };
        
        // -----------------------------------------------------------------------------------------------
        // TEST PROPER:

        Test.startTest();

        // SCENARIO 1: Insertion of 1 record
        String ENTITY_NUMBER_1 = '00000000000000000001';
        String ENTITY_NUMBER_2 = '00000000000000000002';
        String ENTITY_NUMBER_3 = '00000000000000000003';
        String ENTITY_NUMBER_4 = '00000000000000000004';

        CMFtoSubProjectSite__c rec1 = IMP_TestFactory_Helper.buildCmfToSubProjectSiteRecord(site.Id, cmfInfo.Id, ENTITY_NUMBER_1);
        insert rec1;
        rec1 = [SELECT RMS_Request_Id__c, Ship_CMF__c FROM CMFtoSubProjectSite__c WHERE Id = :rec1.Id].get(0);

        // check if the record got inserted in the CMFtoSubProjectSite__c
        System.assertEquals(1, [SELECT Id FROM CMFtoSubProjectSite__c WHERE SubProjectSite__c = :site.Id AND CMF_Info__c = :cmfInfo.Id AND RMS_Request_Id__c = :ENTITY_NUMBER_1].size());

        // check if the entity number got stamped in its respective field in the related SubProjectSite object
        List<SubProjectSite__c> siteList = [SELECT RMS_Request_Ids__c, CMF_Numbers__c FROM SubProjectSite__c WHERE Id = :site.Id];
        String singleRmsRequestId = siteList.get(0).RMS_Request_Ids__c;
        System.assertEquals(rec1.RMS_Request_Id__c, singleRmsRequestId);
        System.assertEquals(true, siteList.get(0).CMF_Numbers__c.contains(rec1.Ship_CMF__c));

        // check if a spere got created in its related subproject object
        System.assertEquals(1, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE SubProject__c = :subProject.Id AND Entity_Type__c = 'RMS Request' AND Entity_Number__c = :ENTITY_NUMBER_1].size());


        // SCENARIO 2: Reject duplicate unique combination of CMF Info, SubProjectSite, and RMS Request ID when a list of records is inserted.
        CMFtoSubProjectSite__c rec1_duplicate1 = IMP_TestFactory_Helper.buildCmfToSubProjectSiteRecord(site.Id, cmfInfo.Id, ENTITY_NUMBER_1);
        CMFtoSubProjectSite__c rec2            = IMP_TestFactory_Helper.buildCmfToSubProjectSiteRecord(site.Id, cmfInfo.Id, ENTITY_NUMBER_2);
        CMFtoSubProjectSite__c rec1_duplicate2 = IMP_TestFactory_Helper.buildCmfToSubProjectSiteRecord(site.Id, cmfInfo.Id, ENTITY_NUMBER_1);

        List<Database.SaveResult> dsrList = Database.insert(new List<CMFtoSubProjectSite__c> { rec1_duplicate1, rec2, rec1_duplicate2 }, false);

        // assert that there are 3 records processed: 1st and 3rd failed, 2nd passed.
        // REFERENCE: whole error message -> "DUPLICATE_VALUE, duplicate value found: SiteCmfRmsReqId__c duplicates value on record with id:"
        System.assertEquals(3, dsrList.size());

        // 1st record assertions:
        System.assertEquals(false, dsrList.get(0).isSuccess());                                             // 1st record should fail because it is a duplicate of rec1
        System.assertEquals(1, dsrList.get(0).getErrors().size());                                          // there will only be 1 error, and that is the duplicate value error
        System.assertEquals(StatusCode.DUPLICATE_VALUE, dsrList.get(0).getErrors().get(0).getStatusCode()); // there will only be 1 error, and that is the duplicate value error

        // 2nd record assertions:
        System.assertEquals(true,  dsrList.get(1).isSuccess());                                             // 2nd record should pass because it is a new record (its RMS Request ID is different from all the rec1* records)
        
        // 3rd record assertions:
        System.assertEquals(false, dsrList.get(2).isSuccess());                                             // 3rd record should fail because it is a duplicate of rec1 and rec1_duplicate1
        System.assertEquals(1, dsrList.get(2).getErrors().size());                                          // there will only be 1 error, and that is the duplicate value error
        System.assertEquals(StatusCode.DUPLICATE_VALUE, dsrList.get(2).getErrors().get(0).getStatusCode()); // there will only be 1 error, and that is the duplicate value error


        // SCENARIO 3: Reject duplicate unique combination of CMF Info, SubProjectSite, and RMS Request ID when a single record is inserted.
        Database.SaveResult dsr = Database.insert(rec1_duplicate1, false);
        
        System.assertEquals(false, dsr.isSuccess());                                             // should fail because it is a duplicate of rec1
        System.assertEquals(1, dsr.getErrors().size());                                          // there will only be 1 error, and that is the duplicate value error
        System.assertEquals(StatusCode.DUPLICATE_VALUE, dsr.getErrors().get(0).getStatusCode()); // there will only be 1 error, and that is the duplicate value error



        // SCENARIO 4: Insertion of multiple records
        CMFtoSubProjectSite__c rec3 = IMP_TestFactory_Helper.buildCmfToSubProjectSiteRecord(site.Id, cmfInfo.Id, ENTITY_NUMBER_3);
        CMFtoSubProjectSite__c rec4 = IMP_TestFactory_Helper.buildCmfToSubProjectSiteRecord(site.Id, cmfInfo.Id, ENTITY_NUMBER_4);
        insert new List<CMFtoSubProjectSite__c> { rec3, rec4 };

        // check if the entity number got stamped in its respective field in the related subproject site object
        List<SubProjectSite__c> siteWithMultipleRMSRequestIdsList = [SELECT RMS_Request_Ids__c FROM SubProjectSite__c WHERE Id = :site.Id];
        Set<String> delimitedRequestIds = new Set<String>(IMP_Project_Utility.parseDelimitedString(siteWithMultipleRMSRequestIdsList.get(0).RMS_Request_Ids__c, ',', true));
        System.assertEquals(true, delimitedRequestIds.contains(rec1.RMS_Request_Id__c));
        System.assertEquals(true, delimitedRequestIds.contains(rec2.RMS_Request_Id__c));
        System.assertEquals(true, delimitedRequestIds.contains(rec3.RMS_Request_Id__c));
        System.assertEquals(true, delimitedRequestIds.contains(rec4.RMS_Request_Id__c));

        // check if a spere got created in its related subproject object
        List<SubProject_External_Related_Entity__c> speresToCheckIfCreated = [SELECT Id, Entity_Number__c
                                                                                FROM SubProject_External_Related_Entity__c 
                                                                               WHERE SubProject__c = :subProject.Id 
                                                                                 AND Entity_Type__c = 'RMS Request' 
                                                                                 AND (   Entity_Number__c = :ENTITY_NUMBER_1
                                                                                      OR Entity_Number__c = :ENTITY_NUMBER_2
                                                                                      OR Entity_Number__c = :ENTITY_NUMBER_3
                                                                                      OR Entity_Number__c = :ENTITY_NUMBER_4)];
        Set<String> entityNumbersSet = new Set<String>();
        for (SubProject_External_Related_Entity__c spere : speresToCheckIfCreated) 
        {
            entityNumbersSet.add(spere.Entity_Number__c);
        }
        System.assertEquals(4, speresToCheckIfCreated.size());
        System.assertEquals(4, entityNumbersSet.size());
        System.assertEquals(true, entityNumbersSet.contains(ENTITY_NUMBER_1));
        System.assertEquals(true, entityNumbersSet.contains(ENTITY_NUMBER_2));
        System.assertEquals(true, entityNumbersSet.contains(ENTITY_NUMBER_3));
        System.assertEquals(true, entityNumbersSet.contains(ENTITY_NUMBER_4));

        Test.stopTest();
    }
    
    private static testMethod void preventRMSSitesDeletion_Test()
    {
        CMF_Info__c cmfInfo_blankShipCmf = new CMF_Info__c();
        cmfInfo_blankShipCmf.Account__c = account1.Id;
        cmfInfo_blankShipCmf.Name = 'Test CMF';
        cmfInfo_blankShipCmf.Status__c = 'A';
        insert cmfInfo_blankShipCmf;
        
        SubProjectSite__c rmsSite = new SubprojectSite__c();
        rmsSite.RMS_Request_Ids__c = '3456238';
        rmsSite.SubProject__c = subproject.Id;
        rmsSite.CMF_Name__c = cmfInfo_blankShipCmf.Id;
        insert rmsSite;
        
        try{
            delete rmsSite;
        }
        catch(DMLException e)
        {
            system.assertEquals(e.getDmlType(0), StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
            system.assert(e.getMessage().contains('SubProjectSite with RMS Request Ids cannot be deleted'));
        }
        
    }
}