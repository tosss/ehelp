//2015-12-03- anirudh.singh@cdk.com- Modified the API Version from 26.0 to 34.0.
@IsTest
public class DS_NADA_Test 
{
    public static testmethod GlobalSettings__c GenerateGlobalSettings()
    {
        // custom settings are not available in test classes
        GlobalSettings__c gs = new GlobalSettings__c(
            NADA_Lead_Folder__c = 'NADA 2013',
            NADA_Lead_Status__c = 'Not Yet Contacted By Rep', 
            NADA_Lead_Campaign__c = 'NADA'
        ); 
        
        system.runas(DS_TestObjects.CurrentUser())
        {
            insert gs;
        }
        return gs;
    }
    
    public static testmethod List<NADA_Link_Criteria__c> GenerateNADALinkCriteria()
    {
        List<NADA_Link_Criteria__c> LinkCriteria = new List<NADA_Link_Criteria__c>();
        
        LinkCriteria.add(new NADA_Link_Criteria__c(
            Active__c=true,Contact_Field__c='FirstName',Swipe_Field__c='First_Name__c',Group__c=1,Name='First Name (1)'));
        LinkCriteria.add(new NADA_Link_Criteria__c(
            Active__c=true,Contact_Field__c='LastName',Swipe_Field__c='Last_Name__c',Group__c=1,Name='Last Name (1)'));
        LinkCriteria.add(new NADA_Link_Criteria__c(
            Active__c=true,Contact_Field__c='Email',Swipe_Field__c='Email__c',Group__c=2,Modifier__c='^(.*)$',Replacement__c='$1\\*',Name='Email (3)'));
        
        system.runas(DS_TestObjects.CurrentUser())
        {
            insert LinkCriteria;
        }  
        return LinkCriteria;
    }
    
    public static testmethod void FileUploadTest()
    {
        GlobalSettings__c gs = DS_NADA_Test.GenerateGlobalSettings();
        
        // folders are included in the test data set
        List<Folder> NADAFolder = [Select Id From Folder Where Name = :gs.NADA_Lead_Folder__c]; 
        
        if(NADAFolder.size() > 0)
        {
            DS_NADAFileUpload f = new DS_NADAFileUpload();
            
            // try to upload a new file
            f.FileName = 'ExcelFile.xls';
            f.FileContents = Blob.valueOf('Random file contents; the value here does not matter.');
            f.ReadFile();
            
            // lets try that again, with errors
            f.FileName = 'ExcelFile.csv'; // bad file
            f.FileContents = Blob.valueOf('Random file contents; the value here does not matter.');
            f.ReadFile();
            
            // again, with an invalid global setting for folder name
            gs.NADA_Lead_Folder__c = '';
            update gs;
            
            f.FileName = 'ExcelFile.xls';
            f.FileContents = Blob.valueOf('Random file contents; the value here does not matter.');
            f.ReadFile();
        }
    }
    
    public static testmethod void SwipeDeviceLookupTest()
    {
        // Swipe without matching Apparatus / Device
        NADA_Swipe__c Swipe1 = new NADA_Swipe__c();
        Swipe1.Apparatus_Id__c = '123abc456';
        insert Swipe1;
        
        // Swipe with null Apparatus Id
        NADA_Swipe__c Swipe2 = new NADA_Swipe__c();
        insert Swipe2;
        
        // insert new Device
        NADA_Device__c Device = new NADA_Device__c();
        Device.Name = '789abc012';
        insert Device;
        
        // Swipe with Device
        NADA_Swipe__c Swipe3 = new NADA_Swipe__c();
        Swipe3.Apparatus_Id__c = '789abc012';
        insert Swipe3;
    }
    
    public static testmethod void CompileQuestionsAndAnswers()
    {
        NADA_Swipe__c Swipe = new NADA_Swipe__c();
        
        DS_NADALink.QuestionAndAnswerFieldApiNames ApiNames = DS_NADALink.GenerateQuestionAndAnswerFields();
        
        for(Integer i=0; i<ApiNames.SortedKeys.size(); i++)
        {
            String QuestionField = ApiNames.SortedKeys[i];
            String AnswerField = ApiNames.QuestionAndAnswerFields.get(QuestionField);
            
            String Increment = String.valueOf(i);
            
            Swipe.put(QuestionField, 'q' + Increment);
            Swipe.put(AnswerField, 'a' + Increment);
        }
        
        String CompiledQuestionsAndAnswers = DS_NADALink.CompileQuestionsAndAnswers(Swipe);
        
        for(Integer i=0; i<ApiNames.SortedKeys.size(); i++)
        {
            System.assertEquals(CompiledQuestionsAndAnswers.contains('q'+String.valueOf(i)), true);
        }
    }
    
    public static testmethod void CalculatePriority()
    {
        String Priority = DS_NADALink.CalculatePriority('Cold', new List<NADA_Attendees__c>{new NADA_Attendees__c(Priority__c='HOT')});
    }
    
    public static testmethod void CustomMatchTest()
    {
        GlobalSettings__c gs = DS_NADA_Test.GenerateGlobalSettings();
        List<NADA_Link_Criteria__c> LinkCriteria = GenerateNADALinkCriteria();
        
        NADA_Match__c Match = DS_NADA_Test.CreateAndQueryLeadMatch();
        NADA_Swipe__c Swipe = (NADA_Swipe__c) Match.getSObject('NADA_Swipe__r');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(Swipe);
        PageReference LinkPage = Page.DS_NADA_Link;
        LinkPage.getParameters().put('id',Swipe.Id);
        Test.setCurrentPage(LinkPage);
        DS_NADALink LinkNewContact = new DS_NADALink(sc);
        
        // add search results
        Test.setFixedSearchResults(new List<Id>{Match.Contact__c});
        
        LinkNewContact.PageLoad();
        
        // test without Contact
        LinkNewContact.CustomMatch();
        
        // test with Contact set on Swipe
        Swipe.Linked_Contact__c = Match.Contact__c; update Swipe;
        LinkNewContact.CustomMatch();
    }
    
    public static testmethod void CreateLinkResultsClass()
    {
        // Test LinkResult class
        DS_NADALink.LinkResult lr1 = new DS_NADALink.LinkResult();
        DS_NADALink.LinkResult lr2 = new DS_NADALink.LinkResult(false);
        DS_NADALink.LinkResult lr3 = new DS_NADALink.LinkResult(true,'Success!');
    }
    
    public static testmethod NADA_Match__c CreateAndQueryLeadMatch()
    {
        Campaign ca = new Campaign(Name='NADA',Campaign_Source__c='Inside Sales',StartDate=Date.today(),EndDate=Date.today());
        insert ca;
        
        Account a = DS_TestObjects.NewAccount_Inserted();
        
        Contact c = DS_TestObjects.NewContact();
        c.AccountId = a.Id; 
        c.Phone = '(555) 555-5555';
        c.Email = 'testemail@adp.com.fulldev';
        c.Title = 'Manager';
        c.No_Longer_There__c = false;
        c.Role__c = 'Test Role'; // 9/29
        insert c;
        
        Tradeshow__c ts = new Tradeshow__c();
        ts.Lead_Opp_Owner_Source__c = 'KEY_REP__C';
        ts.Type_Of_Marketing_Interaction__c = 'NADA';
        ts.Lead_Opp_Creation_Status__c = 'Not Yet Contacted By Rep';
        ts.Target_Market__c = 'Auto';
        ts.Lead_Record_Type__c = 'NADA FY14';
        ts.Lead_Source_Value__c = 'Trade Show - NADA';
        insert ts;
        
        NADA_Device__c Device = DS_TestObjects.NewNADADevice();
        Device.Tradeshow_Show_Code__c = ts.Id;
        insert Device;
        
        NADA_Swipe__c Swipe = DS_TestObjects.NewSwipe();
        Swipe.Company__c = 'Lead ' + a.Name;
        Swipe.First_Name__c = 'Lead ' + c.FirstName;
        Swipe.Last_Name__c = 'Lead ' + c.LastName;
        Swipe.Phone__c = c.Phone;
        Swipe.Email__c = c.Email;
        Swipe.NADA_Scan_Device__c = Device.Id;
        Swipe.Swiped_Card_Number__c = '01340';
        insert Swipe;
        
        NADA_Match__c Match = new NADA_Match__c();
        Match.NADA_Swipe__c = Swipe.Id;
        Match.Contact__c = c.Id;
        insert Match;
        
        Match = DS_NADALink.FindMatchById(Match.Id); // query Match
        return Match;
    }
    
    public static testmethod NADA_Match__c CreateAndQueryOpportunityMatch()
    {
        Campaign ca = new Campaign(Name='NADA',Campaign_Source__c='Inside Sales',StartDate=Date.today(),EndDate=Date.today());
        insert ca;
        
        User u = DS_TestObjects.NewUser();
        u.Title = 'DSM';
        insert u;
        
        Account a = DS_TestObjects.NewAccount();
        a.Designated_DSM__c = u.Id;
        a.Key_Rep__c = u.Id;
        insert a;
        
        Contact c = DS_TestObjects.NewContact();
        c.AccountId = a.Id; 
        c.Phone = '(555) 555-5555';
        c.Email = 'testemail@adp.com.fulldev';
        c.Title = 'Manager';
        c.No_Longer_There__c = false;
        c.Role__c = 'Test Role'; // 9/29
        insert c;
        
        Tradeshow__c ts = new Tradeshow__c();
        ts.Lead_Opp_Owner_Source__c = 'DESIGNATED_DSM__C';
        ts.Type_Of_Marketing_Interaction__c = 'NADA';
        ts.Lead_Opp_Creation_Status__c = '0. Undiscovered';
        ts.Lead_Record_Type__c = 'NADA FY14'; // default to Lead (changed later as needed)
        ts.Target_Market__c = 'Cobalt';
        ts.Opportunity_Close_Date__c = '30';
        ts.Opportunity_Lead_Source_Field__c = 'Internal_Lead_Source__c';
        ts.Lead_Source_Value__c = 'NADA';
        insert ts;
        
        NADA_Device__c Device = DS_TestObjects.NewNADADevice();
        Device.Tradeshow_Show_Code__c = ts.Id;
        insert Device;
        
        NADA_Swipe__c Swipe = DS_TestObjects.NewSwipe();
        Swipe.Company__c = 'Opportunity ' + a.Name;
        Swipe.First_Name__c = 'Opportunity ' + c.FirstName;
        Swipe.Last_Name__c = 'Opportunity ' + c.LastName;
        Swipe.Phone__c = c.Phone;
        Swipe.Email__c = c.Email;
        Swipe.NADA_Scan_Device__c = Device.Id;
        Swipe.Swiped_Card_Number__c = '00099';
        insert Swipe;
        
        NADA_Match__c Match = new NADA_Match__c();
        Match.NADA_Swipe__c = Swipe.Id;
        Match.Contact__c = c.Id;
        insert Match;
        
        Match = DS_NADALink.FindMatchById(Match.Id); // query Match
        return Match;
    }
    
    public static testmethod void LinkAndRedirect()
    {
        // setup global data
        GlobalSettings__c gs = DS_NADA_Test.GenerateGlobalSettings();
        List<NADA_Link_Criteria__c> LinkCriteria = GenerateNADALinkCriteria();
        
        // setup Opportunity data
        NADA_Match__c OpportunityMatch = DS_NADA_Test.CreateAndQueryOpportunityMatch();
        NADA_Swipe__c OpportunitySwipe = null;
        if(OpportunityMatch != null)
        {
            OpportunitySwipe = (NADA_Swipe__c) OpportunityMatch.getSObject('NADA_Swipe__r');
        }
        
        if(OpportunityMatch != null 
           && OpportunityMatch.NADA_Swipe__r != null 
           && OpportunityMatch.NADA_Swipe__r.NADA_Scan_Device__r != null
           && OpportunityMatch.NADA_Swipe__r.NADA_Scan_Device__r.getSObject('Tradeshow_Show_Code__r') != null)
        {
            system.debug('Tradeshow_Show_Code__r');
            OpportunityMatch.NADA_Swipe__r.NADA_Scan_Device__r.getSObject('Tradeshow_Show_Code__r').put('Lead_Record_Type__c', null);
            OpportunityMatch.NADA_Swipe__r.NADA_Scan_Device__r.getSObject('Tradeshow_Show_Code__r').put('Opportunity_Record_Type__c', 'Pipeline'); 
            update OpportunityMatch.NADA_Swipe__r.NADA_Scan_Device__r.getSObject('Tradeshow_Show_Code__r');
            system.debug(OpportunityMatch.NADA_Swipe__r.NADA_Scan_Device__r.getSObject('Tradeshow_Show_Code__r'));
        }
        
        // Link and Redirect Opportunity
        ApexPages.StandardController OpportunitySwipeController = new ApexPages.StandardController(OpportunitySwipe);
        PageReference OpportunityLinkPage = Page.DS_NADA_Link;
        OpportunityLinkPage.getParameters().put('id', OpportunitySwipe.Id);
        Test.setCurrentPage(OpportunityLinkPage);
        DS_NADALink OpportunityMatchAndLink = new DS_NADALink(OpportunitySwipeController);
        OpportunityMatchAndLink.SelectedMatchId = OpportunityMatch.Id; system.debug(OpportunityMatch.Id);
        OpportunityMatchAndLink.LinkAndRedirect();
        
        // setup Lead data
        NADA_Match__c LeadMatch = DS_NADA_Test.CreateAndQueryLeadMatch();
        NADA_Swipe__c LeadSwipe = null;
        if(LeadMatch != null)
        {
            LeadSwipe = (NADA_Swipe__c) LeadMatch.getSObject('NADA_Swipe__r');
        }
        
        // Link and Redirect Lead
        ApexPages.StandardController LeadSwipeController = new ApexPages.StandardController(LeadSwipe);
        PageReference LeadLinkPage = Page.DS_NADA_Link;
        LeadLinkPage.getParameters().put('id', LeadSwipe.Id);
        Test.setCurrentPage(LeadLinkPage);
        DS_NADALink LeadMatchAndLink = new DS_NADALink(LeadSwipeController);
        LeadMatchAndLink.SelectedMatchId = LeadMatch.Id;
        LeadMatchAndLink.LinkAndRedirect();
    }
    
    public static testmethod void MatchAndLinkOpportunityTest()
    {
        GlobalSettings__c gs = DS_NADA_Test.GenerateGlobalSettings();
        List<NADA_Link_Criteria__c> LinkCriteria = GenerateNADALinkCriteria();
        
        NADA_Match__c GeneratedMatch = DS_NADA_Test.CreateAndQueryOpportunityMatch();
        
        NADA_Swipe__c GeneratedSwipe = null;
        if(GeneratedMatch != null)
        {
            GeneratedSwipe = (NADA_Swipe__c) GeneratedMatch.getSObject('NADA_Swipe__r');
        }
        
        Tradeshow__c Tradeshow = null;
        if(GeneratedMatch != null && GeneratedMatch.NADA_Swipe__r != null && GeneratedMatch.NADA_Swipe__r.NADA_Scan_Device__r != null)
        {
            Tradeshow = (Tradeshow__c) GeneratedMatch.NADA_Swipe__r.NADA_Scan_Device__r.getSObject('Tradeshow_Show_Code__r');
        }
        
        // update Tradeshow Opportunity Record Type (it is defaulted to Lead)
        if(Tradeshow != null)
        { 
            Tradeshow.Lead_Record_Type__c = null;
            Tradeshow.Opportunity_Record_Type__c = 'Pipeline';
            update Tradeshow;
        }
        
        // requery Match to get the GeneratedMatch.Contact__r, GeneratedMatch.Contact__c, and Tradeshow.Opportunity_Record_Type__c
        GeneratedMatch = DS_NADALink.FindMatchById(GeneratedMatch.Id);
        
        Contact LinkedContact = null;
        List<Contact> LinkedContacts = [Select Id, AccountId From Contact Where Id = :GeneratedMatch.Contact__c Limit 1];
        if(LinkedContact != null && !LinkedContacts.IsEmpty())
        {
            LinkedContact = LinkedContacts[0];
        }
        
        // add search results
        Test.setFixedSearchResults(new List<Id>{GeneratedMatch.Contact__c});
        
        ApexPages.StandardController sc = new ApexPages.StandardController(GeneratedSwipe);
        DS_NADALink MatchAndLink = new DS_NADALink(sc);
        
        //List<RecordType> OpportunityRecordTypes = [
        //    Select Id 
        //    From RecordType 
        //    Where sObjectType='Opportunity' 
        //    And Name = :Tradeshow.Opportunity_Record_Type__c 
        //    Limit 1
        //];
        
        //Id OpportunityRecordTypeId = (OpportunityRecordTypes != null && !OpportunityRecordTypes.IsEmpty()) ? OpportunityRecordTypes[0].Id : null;
        
        // insert a new Opportunity
        //Opportunity o = new Opportunity(); 
        //o.RecordTypeId = OpportunityRecordTypeId;
        //o.Name = 'Test NADA Opportunity';
        //if(LinkedContact != null) { o.AccountId = LinkedContact.AccountId; }
        //o.StageName = 'TEST';
        //o.CloseDate = Date.today();
        //o.ADP_Opportunity_Owner__c = UserInfo.getUserId();
        //insert o; // system.runas(DS_TestObjects.CurrentUser()) { }
        
        MatchAndLink.LinkToOpportunity(GeneratedMatch, Tradeshow);
    }
    
    public static testmethod void MatchAndLinkLeadTest()
    {
        GlobalSettings__c gs = DS_NADA_Test.GenerateGlobalSettings();
        List<NADA_Link_Criteria__c> LinkCriteria = GenerateNADALinkCriteria();
        
        // generate Match
        NADA_Match__c GeneratedMatch = DS_NADA_Test.CreateAndQueryLeadMatch();
        
        NADA_Swipe__c GeneratedSwipe = null;
        if(GeneratedMatch != null)
        {
            GeneratedSwipe = (NADA_Swipe__c) GeneratedMatch.getSObject('NADA_Swipe__r');
        }
        
        Tradeshow__c Tradeshow = null;
        if(GeneratedMatch != null && GeneratedMatch.NADA_Swipe__r != null && GeneratedMatch.NADA_Swipe__r.NADA_Scan_Device__r != null)
        {
            Tradeshow = (Tradeshow__c) GeneratedMatch.NADA_Swipe__r.NADA_Scan_Device__r.getSObject('Tradeshow_Show_Code__r');
        }
        
        if(Tradeshow != null)
        { 
            Tradeshow.Opportunity_Record_Type__c = null; 
            Tradeshow.Lead_Record_Type__c = 'NADA FY14'; 
            update Tradeshow; 
        }
        
        // requery Match to get the GeneratedMatch.Contact__r, GeneratedMatch.Contact__c, and Tradeshow.Opportunity_Record_Type__c
        GeneratedMatch = DS_NADALink.FindMatchById(GeneratedMatch.Id);
        
        // note that the LinkAndRedirect or PageLoad methods cause Sys and DMS to not be set correctly
        Systems__c Sys = new Systems__c(); 
        Sys.Name = 'ADP - 10000';
        Sys.Type__c = 'DMS';
        Sys.SLXSystem_ID__c = 'QYXGKA000A99';
        //2015-12-11- anirudh.singh@cdk.com- Added the below field.
        Sys.SLXVendor_ID__c = 'PYXGKA000A99';
        insert Sys;
        
        System_at_Dealership__c DMS2 = DS_TestObjects.NewDMSSystemAtDealership();
        DMS2.RecordTypeId = [Select Id From RecordType Where sObjectType='System_at_Dealership__c' And Name like '%DMS%' Limit 1].Id;
        DMS2.Vendor__c = Sys.Id;
        DMS2.Install_Date__c = Date.today().addMonths(-36);
        if(GeneratedMatch.Contact__r != null)
        {
            DMS2.Account__c = GeneratedMatch.Contact__r.AccountId;
        }
        DMS2.System_Type__c = 'DMS';
        insert DMS2;
        
        // add search results
        Test.setFixedSearchResults(new List<Id>{GeneratedMatch.Contact__c});
        
        ApexPages.StandardController sc = new ApexPages.StandardController(GeneratedSwipe);
        
        DS_NADALink MatchAndLink = new DS_NADALink(sc);
        
        // test Link (to Lead)
        DS_NADALink.LinkResult lr1 = MatchAndLink.LinkToLead(GeneratedMatch, Tradeshow);
        
        // a container used to set the Manufacturers and Presentation Areas on any generated leads
        List<Lead> LeadsToUpsert = new List<Lead>();
        
        // update the generated lead (if one exists)
        if(lr1.Match.Lead__c != null) 
        { 
            Lead MatchedLead = new Lead(Id=lr1.Match.Lead__c);
            MatchedLead.Manufacturers__c = 'Test1;Test2';
            MatchedLead.Presentation_Areas__c = 'Test1;Test2';
            LeadsToUpsert.add(MatchedLead);
        }
        else // otherwise, create a new Lead
        {
            // create a pre-existing lead
            Id LeadRecordTypeId = null;
            List<RecordType> LeadRecordTypes = [
                Select Id 
                From RecordType 
                Where sObjectType='Lead' 
                And Name = :Tradeshow.Lead_Record_Type__c 
                Limit 1
            ];
            
            if(LeadRecordTypes != null && !LeadRecordTypes.IsEmpty())
            {
                LeadRecordTypeId = LeadRecordTypes[0].Id;
            }
            Contact MatchContact = (Contact) GeneratedMatch.getSObject('Contact__r');
            
            if(MatchContact != null)
            {
                // test with a pre-existing Lead
                Lead MatchLead = new Lead();
                MatchLead.LastName = MatchContact.LastName;
                MatchLead.Current_Account__c = MatchContact.AccountId;
                MatchLead.Company = MatchContact.Account.Name;
                MatchLead.RecordTypeId = LeadRecordTypeId;
                MatchLead.Manufacturers__c = 'Test1;Test2';
                MatchLead.Presentation_Areas__c = 'Test1;Test2';
                LeadsToUpsert.add(MatchLead);
            }
        }
        
        upsert LeadsToUpsert;
        
        // test Link (to Lead) again with a pre-existing lead
        DS_NADALink.LinkResult lr2 = MatchAndLink.LinkToLead(GeneratedMatch, Tradeshow);
    }
    
    public static testmethod void RefreshMatches()
    {
        NADA_Swipe__c Swipe = new NADA_Swipe__c();
        insert Swipe;
        
        NADA_Match__c Match = new NADA_Match__c(NADA_Swipe__c=Swipe.Id);
        insert Match;
        
        DS_NADALink.RefreshMatches(Match.Id);
    }
    
    public static testmethod void NewContactFromSwipeTest()
    {
        GlobalSettings__c gs = DS_NADA_Test.GenerateGlobalSettings();
        List<NADA_Link_Criteria__c> LinkCriteria = GenerateNADALinkCriteria();
        
        // test invalid swipe
        ApexPages.StandardController sc1 = new ApexPages.StandardController(new NADA_Swipe__c());
        DS_NADALink LinkNewContact1 = new DS_NADALink(sc1);
        LinkNewContact1.NewContactFromSwipe();
        
        Account SwipeAccount = DS_TestObjects.NewAccount_Inserted();
        NADA_Swipe__c Swipe = new NADA_Swipe__c();
        insert Swipe;
        
        // test invalid swipe
        ApexPages.StandardController sc2 = new ApexPages.StandardController(Swipe);
        DS_NADALink LinkNewContact2 = new DS_NADALink(sc2);
        LinkNewContact2.NewContactFromSwipe();
        
        Swipe.Linked_Account__c = SwipeAccount.Id; 
        Swipe.First_Name__c = 'First Name Test';
        Swipe.Last_Name__c = 'Last Name Test';
        Swipe.Street_Address__c = '123 Street';
        Swipe.Address2__c = 'Apt B';
        Swipe.City__c = 'Hoffman Estates';
        Swipe.State__c = 'IL';
        Swipe.Postal_Code__c = '60169';
        update Swipe;
        
        // test with valid swipe, invalid Account
        ApexPages.StandardController sc3 = new ApexPages.StandardController(Swipe);
        DS_NADALink LinkNewContact3 = new DS_NADALink(sc3);
        LinkNewContact3.NewContactFromSwipe();
    }
    
    // test marketing interaction
    public static testmethod void CreateMarketingInteraction()
    {
        Tradeshow__c Tradeshow = new Tradeshow__c();
        Tradeshow.Type_Of_Marketing_Interaction__c = 'NADA';
        
        NADA_Presentation_Area__c PresentationArea = new NADA_Presentation_Area__c();
        PresentationArea.Name = 'Test Area';
        
        NADA_Device__c Device = new NADA_Device__c();
        Device.Demo_Location__c = 'Main Booth';
        Device.putSObject('NADA_Presentation_Area__r', PresentationArea);
        
        // test with invalid data
        NADA_Swipe__c Swipe = new NADA_Swipe__c();
        NADA_Match__c Match = new NADA_Match__c();
        
        Match.putSObject('NADA_Swipe__r',Swipe);
        
        DS_NADALink.LinkResult GenericLinkResult = new DS_NADALink.LinkResult();
        GenericLinkResult = DS_NADALink.CreateMarketingInformation(Match, Tradeshow, GenericLinkResult);
        
        // set valid data and test
        Match.NADA_Swipe__r.Swiped_Date_Time__c = DateTime.now();
        Match.NADA_Swipe__r.putSObject('NADA_Scan_Device__r', Device); 
        
        GenericLinkResult = DS_NADALink.CreateMarketingInformation(Match, Tradeshow, GenericLinkResult);
    }
}