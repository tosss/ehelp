public class DS_NADALink
{
    // -- custom settings variables
    
    public static List<NADA_Link_Criteria__c> LinkCriteria = NADA_Link_Criteria__c.getall().values();
    public static GlobalSettings__c gs = GlobalSettings__c.getInstance();
    
    // -- page variables
    
    public NADA_Swipe__c Swipe {get;set;}
    public List<NADA_Match__c> Matches {get;set;}
    public String SelectedMatchId {get;set;}
    
    public String InvalidAccountError {get;set;}
    public String InvalidContactError {get;set;}
    
    // -- constructor
    
    public DS_NADALink(ApexPages.StandardController controller)
    {
        this.Swipe = (NADA_Swipe__c)controller.getRecord();
    }
    
    // -- static methods
    
    public static NADA_Match__c FindMatchById(String MatchId)
    {
        List<NADA_Match__c> AllMatches = [
            Select Id, Name, 
                Lead__c, Opportunity__c, Lead_Attendee__c, 
                NADA_Swipe__c, NADA_Swipe__r.Id, NADA_Swipe__r.NADA_Scan_Device__c, 
                NADA_Swipe__r.NADA_Scan_Device__r.Tradeshow_Show_Code__c, 
                NADA_Swipe__r.NADA_Scan_Device__r.Tradeshow_Show_Code__r.Name, 
                NADA_Swipe__r.NADA_Scan_Device__r.Tradeshow_Show_Code__r.Campaign__c, 
                NADA_Swipe__r.NADA_Scan_Device__r.Tradeshow_Show_Code__r.Campaign__r.Name, 
                NADA_Swipe__r.NADA_Scan_Device__r.Tradeshow_Show_Code__r.Guarantee_Uniqueness__c, 
                NADA_Swipe__r.NADA_Scan_Device__r.Tradeshow_Show_Code__r.Party_Tickets_Only__c, 
                NADA_Swipe__r.NADA_Scan_Device__r.Tradeshow_Show_Code__r.Target_Market__c, 
                NADA_Swipe__r.NADA_Scan_Device__r.Tradeshow_Show_Code__r.Lead_Record_Type__c, 
                NADA_Swipe__r.NADA_Scan_Device__r.Tradeshow_Show_Code__r.Opportunity_Record_Type__c,
                NADA_Swipe__r.NADA_Scan_Device__r.Tradeshow_Show_Code__r.Opportunity_Close_Date__c, 
                NADA_Swipe__r.NADA_Scan_Device__r.Tradeshow_Show_Code__r.Lead_Opp_Creation_Status__c, 
                NADA_Swipe__r.NADA_Scan_Device__r.Tradeshow_Show_Code__r.Lead_Opp_Owner_Source__c, 
                NADA_Swipe__r.NADA_Scan_Device__r.Tradeshow_Show_Code__r.Opportunity_Lead_Source_Field__c, 
                NADA_Swipe__r.NADA_Scan_Device__r.Tradeshow_Show_Code__r.Lead_Source_Value__c, 
                NADA_Swipe__r.NADA_Scan_Device__r.Tradeshow_Show_Code__r.Type_Of_Marketing_Interaction__c, 
                NADA_Swipe__r.NADA_Scan_Device__r.Demo_Location__c, 
                NADA_Swipe__r.NADA_Scan_Device__r.NADA_Presentation_Area__c, 
                NADA_Swipe__r.NADA_Scan_Device__r.NADA_Presentation_Area__r.Name,  
                NADA_Swipe__r.Demo_Location__c, NADA_Swipe__r.Presentation_Area__c, 
                NADA_Swipe__r.Swiped_Date_Time__c, NADA_Swipe__r.Manufacturers_Picklist__c, NADA_Swipe__r.Notes__c, 
                NADA_Swipe__r.Company__c, NADA_Swipe__r.Company2__c, NADA_Swipe__r.Lead_Type__c, NADA_Swipe__r.Registration_Type__c, 
                NADA_Swipe__r.First_Name__c, NADA_Swipe__r.Last_Name__c, NADA_Swipe__r.Phone__c, NADA_Swipe__r.Fax__c, NADA_Swipe__r.Email__c, 
                NADA_Swipe__r.Street_Address__c, NADA_Swipe__r.Address2__c, 
                NADA_Swipe__r.City__c, NADA_Swipe__r.State__c, NADA_Swipe__r.Postal_Code__c, NADA_Swipe__r.Country__c, NADA_Swipe__r.Priority__c, 
                NADA_Swipe__r.Question_1__c, NADA_Swipe__r.Answer_1__c,
                NADA_Swipe__r.Question_2__c, NADA_Swipe__r.Answer_2__c,
                NADA_Swipe__r.Question_3__c, NADA_Swipe__r.Answer_3__c,
                NADA_Swipe__r.Question_4__c, NADA_Swipe__r.Answer_4__c,
                NADA_Swipe__r.Question_5__c, NADA_Swipe__r.Answer_5__c,
                NADA_Swipe__r.Question_6__c, NADA_Swipe__r.Answer_6__c,
                NADA_Swipe__r.Question_7__c, NADA_Swipe__r.Answer_7__c,
                NADA_Swipe__r.Question_8__c, NADA_Swipe__r.Answer_8__c,
                NADA_Swipe__r.Question_9__c, NADA_Swipe__r.Answer_9__c,
                NADA_Swipe__r.Question_10__c, NADA_Swipe__r.Answer_10__c,
                NADA_Swipe__r.Question_11__c, NADA_Swipe__r.Answer_11__c,
                NADA_Swipe__r.Question_12__c, NADA_Swipe__r.Answer_12__c,
                NADA_Swipe__r.Question_13__c, NADA_Swipe__r.Answer_13__c,
                NADA_Swipe__r.Question_14__c, NADA_Swipe__r.Answer_14__c, 
                NADA_Swipe__r.Question_15__c, NADA_Swipe__r.Answer_15__c, 
                NADA_Swipe__r.Demographic_1_Name__c, NADA_Swipe__r.Demographic_1_Value__c,
                NADA_Swipe__r.Demographic_2_Name__c, NADA_Swipe__r.Demographic_2_Value__c,
                NADA_Swipe__r.Demographic_3_Name__c, NADA_Swipe__r.Demographic_3_Value__c,
                NADA_Swipe__r.Demographic_4_Name__c, NADA_Swipe__r.Demographic_4_Value__c,
                NADA_Swipe__r.Demographic_5_Name__c, NADA_Swipe__r.Demographic_5_Value__c,
                NADA_Swipe__r.Demographic_6_Name__c, NADA_Swipe__r.Demographic_6_Value__c,
                NADA_Swipe__r.Demographic_7_Name__c, NADA_Swipe__r.Demographic_7_Value__c,
                NADA_Swipe__r.Demographic_8_Name__c, NADA_Swipe__r.Demographic_8_Value__c,
                NADA_Swipe__r.Demographic_9_Name__c, NADA_Swipe__r.Demographic_9_Value__c,
                NADA_Swipe__r.Demographic_10_Name__c, NADA_Swipe__r.Demographic_10_Value__c,
                NADA_Swipe__r.Demographic_11_Name__c, NADA_Swipe__r.Demographic_11_Value__c,
                NADA_Swipe__r.Demographic_12_Name__c, NADA_Swipe__r.Demographic_12_Value__c,
                NADA_Swipe__r.Demographic_13_Name__c, NADA_Swipe__r.Demographic_13_Value__c,
                NADA_Swipe__r.Demographic_14_Name__c, NADA_Swipe__r.Demographic_14_Value__c,
                NADA_Swipe__r.Demographic_15_Name__c, NADA_Swipe__r.Demographic_15_Value__c, 
                Contact__c, Contact__r.Salutation, Contact__r.Name, Contact__r.LastName, Contact__r.FirstName, 
                Contact__r.AccountId, Contact__r.Account.Name
            From NADA_Match__c 
            Where Id = :MatchId Limit 1
        ];
        
        NADA_Match__c Match = null;
        if(AllMatches != null) { if(!AllMatches.IsEmpty()) { Match = AllMatches[0]; } }
        
        return Match;
    }
    
    public class QuestionAndAnswerFieldApiNames
    {
        public List<String> SortedKeys {get;set;}
        public Map<String, String> QuestionAndAnswerFields {get;set;}
        
        public QuestionAndAnswerFieldApiNames() 
        {
            SortedKeys = new List<String>();
            QuestionAndAnswerFields = new Map<String, String>();
        }
    }
    
    public static QuestionAndAnswerFieldApiNames GenerateQuestionAndAnswerFields()
    {
        QuestionAndAnswerFieldApiNames ApiNames = new QuestionAndAnswerFieldApiNames();
        
        for(Integer i=0; i<15; i++)
        {
            String QuestionField = 'Question_'+String.valueOf(i+1)+'__c';
            String AnswerField = 'Answer_'+String.valueOf(i+1)+'__c';
            
            ApiNames.SortedKeys.add(QuestionField);
            ApiNames.QuestionAndAnswerFields.put(QuestionField, AnswerField);
        }
        
        return ApiNames;
    }
    
    public static String CompileQuestionsAndAnswers(NADA_Swipe__c Swipe)
    {
        QuestionAndAnswerFieldApiNames ApiNames = GenerateQuestionAndAnswerFields();
        
        String CompiledQuestionsAndAnswers = '';
        
        for(String QuestionField : ApiNames.SortedKeys)
        {
            String AnswerField = ApiNames.QuestionAndAnswerFields.get(QuestionField);
            
            if(Swipe.get(QuestionField) != null)
            {
                CompiledQuestionsAndAnswers += Swipe.get(QuestionField) + '\r\n' + Swipe.get(AnswerField) + '\r\n' + '--' + '\r\n'; 
            }
        }
        
        return CompiledQuestionsAndAnswers;
    }
    
    public static String CalculatePriority(String CurrentPriority, List<sObject> Attendees)
    {
        Map<String, Integer> PriorityValues = new Map<String, Integer>{'hot'=>10,'medium'=>5,'cold'=>0};
        
        if(Attendees != null && !Attendees.IsEmpty())
        {
            for(sObject Attendee : Attendees) 
            { 
                //system.debug(Attendee.Name + ' - ' + Attendee);
                
                if(Attendee.get('Priority__c') != null) 
                {
                    String AttendeePriority = (String) Attendee.get('Priority__c');
                    
                    Integer PriorityValue = PriorityValues.get(AttendeePriority.trim().toLowerCase()); 
                    Integer CurrentPriorityValue = PriorityValues.get(CurrentPriority != null ? CurrentPriority.trim().toLowerCase() : ''); 
                    
                    if(PriorityValue != null) {
                        if(CurrentPriorityValue == null || PriorityValue > CurrentPriorityValue) {
                            CurrentPriority = AttendeePriority; }
                    }
                } 
            }
        }
        
        return CurrentPriority;
    }
    
    public static DS_NADALink.LinkResult CreateMarketingInformation(NADA_Match__c Match, Tradeshow__c Tradeshow, DS_NADALink.LinkResult GenericResult)
    {
        NADA_Swipe__c Swipe = (NADA_Swipe__c) Match.getSObject('NADA_Swipe__r');
        
        if(Swipe != null && Match != null)
        {
            Date SwipedDateTime = Swipe.Swiped_Date_Time__c != null ? Swipe.Swiped_Date_Time__c.Date() : Date.today();
            String DemoLocation = Swipe.NADA_Scan_Device__r != null ? Swipe.NADA_Scan_Device__r.Demo_Location__c : null; system.debug(DemoLocation);
            String PresentationArea = Swipe.NADA_Scan_Device__r != null && Swipe.NADA_Scan_Device__r.NADA_Presentation_Area__r != null ? 
                Swipe.NADA_Scan_Device__r.NADA_Presentation_Area__r.Name : null; 
            
            String Details = '';
            if(SwipedDateTime != null) { Details += SwipedDateTime.format() + ' at '; }
            if(DemoLocation != null) { Details += DemoLocation + ' for '; }
            Details += PresentationArea;
            
            system.debug(Details);
            
            Marketing_Interaction__c MarketingInteraction = new Marketing_Interaction__c();
            
            MarketingInteraction.Type_of_Interaction__c = Tradeshow.Type_Of_Marketing_Interaction__c;
            MarketingInteraction.Date_Of_Interaction__c = SwipedDateTime;
            MarketingInteraction.Details__c = Details;
            MarketingInteraction.Trade_Show_Lead__c = Match.Lead__c;
            MarketingInteraction.Trade_Show_Attendee__c = Match.Lead_Attendee__c;
            MarketingInteraction.Trade_Show_Digital_Opportunity__c = Match.Opportunity__c;
            MarketingInteraction.Account__c = Match.Contact__c != null ? Match.Contact__r.AccountId : null;
            MarketingInteraction.Contact__c = Match.Contact__c;
            MarketingInteraction.NADA_Swipe__c = Swipe.Id;
            MarketingInteraction.Campaign__c = Tradeshow != null ? Tradeshow.Campaign__c : null;
            
            try 
            {
                insert MarketingInteraction;
                
                GenericResult.MarketingInteraction = MarketingInteraction; 
                GenericResult.Success = true; 
            }
            catch(Exception exc) {
                system.debug(exc); GenericResult.Success = false; }
        }
        
        return GenericResult;
    }
    
    // -- methods
    
    // page load action called by the Visualforce page tag action
    public void PageLoad()
    {
        String SwipeId = ApexPages.currentPage().getParameters().get('id');
        if(SwipeId != null) { Matches = Match(SwipeId); }
    }
    
    // -- match methods
    
    public List<NADA_Match__c> Match(String NADA_Swipe_Id)
    {
        NADA_Swipe__c CurrentSwipe = null;
        Matches = new List<NADA_Match__c>();
        
        try
        {
            ID tempid = NADA_Swipe_Id;
        } catch (Exception e) { return Matches; }
        
        CurrentSwipe = [
            Select Id, Name, 
                Linked_Contact__c, Linked_Contact__r.Name, 
                Linked_Account__c, Linked_Account__r.Name,
                NADA_Lead__c, NADA_Lead__r.Name,
                NADA_Attendee__c, NADA_Attendee__r.Name 
            From NADA_Swipe__c Where Id = :NADA_Swipe_Id Limit 1];
        
        List<NADA_Match__c> PreviousMatches = [Select Id From NADA_Match__c Where NADA_Swipe__r.Id = :NADA_Swipe_Id];
        delete PreviousMatches;
        
        String SwipeQueryFields = '';
        Set<String> SwipeFieldSet = new Set<String>();
        
        String ContactQueryFields = '';
        Set<String> ContactFieldSet = new Set<String>();
        
        // loop through Custom Settings for link/match criteria
        for(NADA_Link_Criteria__c lc : LinkCriteria)
        {
            if(lc.Active__c)
            {
                String SwipeField = lc.Swipe_Field__c;
                SwipeFieldSet.add(SwipeField);
                
                String ContactField = lc.Contact_Field__c;
                ContactFieldSet.add(ContactField);
            }
        }
        
        if(!SwipeFieldSet.IsEmpty())
        {
            List<String> SwipeFieldsList = new List<String>();
            SwipeFieldsList.addAll(SwipeFieldSet);
            
            for(Integer i = 0; i < SwipeFieldsList.size(); i++) {
                SwipeQueryFields += ((i > 0) ? ', ' : '') + SwipeFieldsList[i]; }
        }
        
        if(!ContactFieldSet.IsEmpty())
        {
            List<String> ContactFieldsList = new List<String>();
            ContactFieldsList.addAll(ContactFieldSet);
            
            for(Integer i = 0; i < ContactFieldsList.size(); i++) {
                ContactQueryFields += ((i > 0) ? ', ' : '') + ContactFieldsList[i]; }
        }
        
        system.debug(SwipeQueryFields);
        
        String SwipeQuery = 'Select Id, ' + SwipeQueryFields + ' From NADA_Swipe__c Where Id = \'' + NADA_Swipe_Id + '\'';
        sObject s = Database.query(SwipeQuery);
        
        Map<Decimal, List<String>> ConditionsMap = new Map<Decimal, List<String>>();
        
        // build the conditions map
        for(NADA_Link_Criteria__c lc : LinkCriteria)
        {
            if(lc.Active__c)
            {
                if(!ConditionsMap.keyset().contains(lc.Group__c)) { 
                    ConditionsMap.put(lc.Group__c, new List<String>()); }
                
                object SwipeObject = s.get(lc.Swipe_Field__c);
                String SwipeValue = '';
                
                try
                {
                    SwipeValue = String.valueOf(SwipeObject);
                    
                    if(lc.Modifier__c != null && lc.Modifier__c != '')
                    {
                        //system.debug(SwipeValue);
                        //system.debug(lc);
                        
                        String rep = '';
                        if(lc.Replacement__c != null) { rep = lc.Replacement__c; }
                        
                        String m = lc.Modifier__c;
                        Pattern p = Pattern.compile(m);
                        
                        Matcher msv = p.matcher(SwipeValue);
                        SwipeValue = msv.replaceAll(rep);
                        
                        system.debug(SwipeValue);
                    }
                }
                catch(Exception e) { }
                
                ConditionsMap.get(lc.Group__c).add(SwipeValue);
            }
        }
        
        List<String> Groups = new List<String>();
        
        // build the search query
        if(!ConditionsMap.IsEmpty())
        {
            for(Decimal d : ConditionsMap.keyset())
            {
                List<String> Conditions = ConditionsMap.get(d);
                
                String g = '';
                Integer c = 0;
                
                if(Conditions.size() > 0)
                {
                    g = '(';
                    
                    for(Integer i = 0; i < Conditions.size(); i++)
                    {
                        if(Conditions[i] != null)
                        {
                            if(c > 0) { g += ' and '; }
                            
                            // remove special characters (except wildcards ? and *)
                            g += '\"' + Conditions[i].replaceAll(
                                '([\\&\\|\\!\\{\\}\\[\\]\\(\\)\\^\\~\\:\\\"\\\'\\+\\-\\\\]{1})','\\\\$1') + '\"';
                            
                            c++; // increment counter
                        }
                    }
                    
                    g += ')';
                }
                
                if(g != '' && c > 0) { Groups.add(g); }
            }
        }
        
        String query = ''
            + 'FIND {' + String.join(Groups,' or ') + '} ' 
            + 'Returning Contact(Id, Name, AccountId, ' + ContactQueryFields + ' ' + 'Where No_Longer_There__c = false)';
        
        system.debug(query);
        List<List<sObject>> objs = search.query(query);
        
        // add all search results to the Matches list
        for(sObject obj : objs[0]) {
            Matches.add(new NADA_Match__c(NADA_Swipe__c=NADA_Swipe_Id,Contact__c=obj.Id)); }
        
        // write all matches to the debugger
        for(NADA_Match__c m : Matches) { system.debug(m); }
        
        // try to insert the search results as Matches
        try { insert Matches; }
        catch (Exception exc) { return new List<NADA_Match__c>(); }
        
        // query the Matches to get the full data set
        Matches = [
            Select Id, NADA_Swipe__c, 
                Contact__c, Contact__r.Salutation, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, 
                Contact__r.AccountId, Contact__r.Phone, Contact__r.Email,  
                Contact__r.Account.Name, Contact__r.Account.BillingStreet, Contact__r.Account.BillingCity, 
                Contact__r.Account.BillingState, Contact__r.Account.BillingPostalCode, 
                Contact__r.Account.Site_Type__r.Name
            From NADA_Match__c 
            Where Id IN :Matches
            ORDER BY Contact__r.Account.Name, Contact__r.LastName, Contact__r.FirstName];
        
        // return Matches
        return Matches;
    }
    
    public PageReference CustomMatch()
    {
        InvalidAccountError = '';
        InvalidContactError = '';
        
        // clear the Linked_Account__c field for display on the Visualforce page
        Swipe.Linked_Account__c = null;
        
        // SelectedContactId is passed in using the Swipe object (from the controller)
        // The NADA_Swipe__c.Linked_Contact__c field is displayed on the page and set by the User
        String SelectedContactId = Swipe.Linked_Contact__c;
        
        // refresh the Swipe
        NADA_Swipe__c SwipeData = null;
        List<NADA_Swipe__c> MatchingSwipes = [Select Id, Name, Linked_Contact__c From NADA_Swipe__c Where Id = :Swipe.Id];
        if(MatchingSwipes != null) { if(!MatchingSwipes.IsEmpty()) { SwipeData = MatchingSwipes[0]; } }
        
        // validate
        Boolean InvalidContact = true;
        List<Contact> Contacts = [Select Id, Name, AccountId From Contact Where Id = :SelectedContactId Limit 1];
        if(Contacts != null) { if(!Contacts.IsEmpty()) { InvalidContact = false; } }
        
        if(!InvalidContact)
        {
            // prepare and insert a Match with the new Contact
            NADA_Match__c Match = new NADA_Match__c(NADA_Swipe__c=SwipeData.Id,Contact__c=SelectedContactId);
            insert Match;
            
            // refresh Match after insert
            //  -- no need if calling LinkAndRedirect()
            // RefreshMatches();
            
            SelectedMatchId = Match.Id;
            return LinkAndRedirect();
        }
        else
        {
            String ErrorMessage = 'The supplied Contact is invalid. Please select a Contact from the Lookup Contact field. ';
            
            InvalidContactError = ErrorMessage;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ErrorMessage)); 
        }
        
        return ApexPages.currentPage();
    }
    
    public static List<NADA_Match__c> RefreshMatches(String MatchId)
    {
        List<NADA_Match__c> Matches = [
            Select Id, NADA_Swipe__c, 
                Contact__c, Contact__r.Salutation, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, 
                Contact__r.AccountId, Contact__r.Phone, Contact__r.Email,  
                Contact__r.Account.Name, Contact__r.Account.BillingStreet, Contact__r.Account.BillingCity, 
                Contact__r.Account.BillingState, Contact__r.Account.BillingPostalCode
            From NADA_Match__c 
            Where Id = :MatchId Limit 1];
        
        return Matches;
    }
    
    // -- link methods
    
    public class LinkResult 
    {
        public boolean Success;
        public String Message;
        
        public NADA_Swipe__c Swipe { get; set; }
        public NADA_Match__c Match { get; set; }
        public Marketing_Interaction__c MarketingInteraction { get; set; }
        
        public LinkResult() { Success = false; Message = ''; }
        public LinkResult(boolean s) { Success = s; Message = ''; }
        public LinkResult(boolean s, String m) { Success = s; Message = m; }
    }
    
    public PageReference LinkAndRedirect()
    {
        LinkResult r = Link(SelectedMatchId);
        system.debug(r);
        
        if(r != null && r.Success == true && r.Swipe != null) 
        {
            String SwipeId = r.Swipe.Id; // convert from Id to String for String manipulation methods
            PageReference ReturnToSwipe = null;
            
            // navigate to Swipe by default
            ReturnToSwipe = new ApexPages.Standardcontroller(r.Swipe).view();
            
            // override Swipe ID to navigate to the list of Swipes
            if(SwipeId != null) { ReturnToSwipe = new PageReference('/'+SwipeId.substring(0,3)); }
            
            ReturnToSwipe.setRedirect(true);
            return ReturnToSwipe;
        }
        
        String ErrorMessage = 'An unexpected error occurred; please contact an administrator. ';
        if(r != null && r.Message != null) { ErrorMessage = r.Message; } 
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, r.Message)); 
        return ApexPages.currentPage();
    }
    
    public LinkResult Link(String MatchId)
    {
        LinkResult GenericLinkResult = new LinkResult();
        
        NADA_Match__c Match = null;
        NADA_Swipe__c Swipe = null;
        NADA_Device__c ScanDevice = null;
        Tradeshow__c Tradeshow = null;
        
        Match = FindMatchById(MatchId);
        if(Match == null) { GenericLinkResult.Message = 'Invalid Match Id.'; return GenericLinkResult; }
        
        if(Match != null)
        {
            system.debug(Match);
            
            Swipe = (NADA_Swipe__c) Match.getSObject('NADA_Swipe__r');
        
            if(Swipe != null)
            {
                ScanDevice = (NADA_Device__c) Swipe.getSObject('NADA_Scan_Device__r');
                if(ScanDevice != null) { Tradeshow = (Tradeshow__c) ScanDevice.getSObject('Tradeshow_Show_Code__r'); }
            }
        }
        
        // 2014-01-22 MK - added debug
        system.debug(Tradeshow);
        
        if(Tradeshow != null)
        {
            if(Tradeshow.Lead_Record_Type__c != null) 
            {
                GenericLinkResult = LinkToLead(Match, Tradeshow); 
            }
            else if(Tradeshow.Opportunity_Record_Type__c != null) 
            {
                GenericLinkResult = LinkToOpportunity(Match, Tradeshow); 
            }
            else 
            {
                GenericLinkResult.Success = false;
                GenericLinkResult.Message = 'The Tradeshow data (on the Scan Device) is incomplete; ' 
                    + 'please supply a valid Lead or Opportunity Record Type.';
            }
            
            if(GenericLinkResult.Match != null) 
            {
                GenericLinkResult = DS_NADALink.CreateMarketingInformation(Match, Tradeshow, GenericLinkResult);
                GenericLinkResult = UpdateSwipeAfterLink(GenericLinkResult);
            }
        }
        else 
        {
            GenericLinkResult.Success = false;
            GenericLinkResult.Message = 'The Tradeshow (on the Scan Device) is blank. Please make sure Tradeshow is set on the Device.';
        }
        
        return GenericLinkResult;
    }
    
    public Id QueryOwnerSource(String SourceField, String AccountId)
    {
        if(SourceField != null) { SourceField = SourceField.toLowerCase(); }
        String AddKeyRepField = !SourceField.contains('key_rep__c') ? 'Key_Rep__c, ' : '';
        
        // get the Owner Id from the designated Account source field
        String OwnerSourceQuery = ''
            + 'Select Id, Name, ' + AddKeyRepField + SourceField + ' ' 
            + 'From Account Where Id = \'' + AccountId + '\' ';
        
        system.debug(OwnerSourceQuery);
        Account MatchAccount = Database.query(OwnerSourceQuery);
        
        Id SourceOwnerId = null;
        
        try { SourceOwnerId = (Id) MatchAccount.get(SourceField); } catch (Exception e) { }
        if(SourceOwnerId == null) { SourceOwnerId = (Id) MatchAccount.get('Key_Rep__c'); }
        
        system.debug(SourceOwnerId);
        return SourceOwnerId;
    }
    
    public LinkResult LinkToOpportunity(NADA_Match__c Match, Tradeshow__c Tradeshow)
    {
        LinkResult LinkToOpportunityResult = new LinkResult();
        
        RecordType OpportunityRecordType = [Select Id From RecordType 
            Where sObjectType = 'Opportunity' And Name = :Tradeshow.Opportunity_Record_Type__c];
        
        Id OpportunityRecordTypeId = OpportunityRecordType != null ? OpportunityRecordType.Id : null;
        
        Opportunity MatchOpportunity = null;
        
        // 2014-01-20 MK - Always create a new Opportunity (for FY14) per instructions from Dave, commented out for use later if needed
        //List<Opportunity> Opportunities = Database.query(''
        //    + 'Select Id, Name, AccountId, OwnerId, MSR_Notes__c '
        //    + 'From Opportunity ' 
        //    + 'Where AccountId = :Match.Contact__r.AccountId ' 
        //    + 'And Opportunity.RecordTypeId = :OpportunityRecordTypeId '
        //    + 'And (NOT Opportunity.Status like \'Closed%\') '
        //    + 'And (NOT Opportunity.Status like \'Inactive%\') '
        //    + (Tradeshow.Campaign__c != null && Tradeshow.Campaign__r.Name != null ? ('And Opportunity.Name like \'' + Tradeshow.Campaign__r.Name + '%\'') : '') 
        //);
        
        //if(Opportunities != null && Opportunities.IsEmpty())
        //{
            system.debug('No previous Opportunities...');
            MatchOpportunity = new Opportunity(RecordTypeId = OpportunityRecordTypeId);
            
            DateTime SwipedDateTime = Match.NADA_Swipe__r.Swiped_Date_Time__c;
            MatchOpportunity.Name = Tradeshow.Campaign__r.Name + (SwipedDateTime != null ? (' - ' + SwipedDateTime.format('yyyy-MM-dd h:mm:ss a')) : '');
            
            MatchOpportunity.ADP_Opportunity_Owner__c = QueryOwnerSource(Tradeshow.Lead_Opp_Owner_Source__c, Match.Contact__r.AccountId);
            MatchOpportunity.StageName = Tradeshow.Lead_Opp_Creation_Status__c;
            MatchOpportunity.CampaignId = Tradeshow.Campaign__c;
            MatchOpportunity.AccountId = Match.Contact__r.AccountId;
            //MatchOpportunity.Description = Match.NADA_Swipe__r.Notes__c;
           
        //}
        //else
        //{
        //    MatchOpportunity = Opportunities[0];
        //    system.debug('Found existing Opportunity: ' + Opportunities[0]);
        //}
        
        // set Opportunity fields
        MatchOpportunity.Description = '-----Notes-----' + '\r\n' + Match.NADA_Swipe__r.Notes__c + '\r\n' + '------------------' + '\r\n' + CompileQuestionsAndAnswers(Match.NADA_Swipe__r); 
        
        if(Tradeshow.Opportunity_Lead_Source_Field__c != null) { 
            MatchOpportunity.put(Tradeshow.Opportunity_Lead_Source_Field__c, Tradeshow.Lead_Source_Value__c); }
        
        Integer DaysToAdd = Tradeshow.Opportunity_Close_Date__c != null ? 
            Integer.valueOf(Tradeshow.Opportunity_Close_Date__c) : 0;
        
        MatchOpportunity.CloseDate = Date.Today().addDays(DaysToAdd);
        
        // set Opportunity Swipe field
        MatchOpportunity.NADA_Swipe__c = Match.NADA_Swipe__c; // MK - 20140120 confirmed set swipe
        
        // insert Match Opportunity
        try { insert MatchOpportunity; }
        catch (Exception exc)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exc.getMessage())); 
            return LinkToOpportunityResult;
        }
        
        // update Match
        Match.Opportunity__c = MatchOpportunity != null ? MatchOpportunity.Id : null;
        try { update Match; }
        catch (Exception exc)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exc.getMessage())); 
            return LinkToOpportunityResult;
        }
        
        LinkToOpportunityResult.Match = Match;
        
        return LinkToOpportunityResult;
    }
    
    public LinkResult LinkToLead(NADA_Match__c Match, Tradeshow__c Tradeshow)
    {
        LinkResult LinkToLeadResult = new LinkResult();
        
        RecordType LeadRecordType = [Select Id From RecordType Where sObjectType = 'Lead' And Name = :Tradeshow.Lead_Record_Type__c];
        Id LeadRecordTypeId = LeadRecordType != null ? LeadRecordType.Id : null;
        
        // find and set Lead on Swipe; if Lead is not found, create Lead then set on Swipe
        
        Lead MatchLead = null;
        List<Lead> Leads = [
            Select Id, Name, Current_Account__c, Manufacturers__c, MSR_Notes__c, Presentation_Areas__c, Priority__c, 
                (Select Id, Name, Priority__c From Lead.Lead_Attendees__r)
            From Lead 
            Where Current_Account__c = :Match.Contact__r.AccountId 
            And Lead.RecordTypeId = :LeadRecordTypeId
        ];
        
        system.debug(Leads);
        
        if(Leads != null && Leads.IsEmpty()) 
        {
            system.debug('No previous Lead...');
            MatchLead = new Lead(RecordTypeId = LeadRecordTypeId);
            
            MatchLead.LastName = Match.NADA_Swipe__r.Last_Name__c; 
            MatchLead.FirstName = Match.NADA_Swipe__r.First_Name__c; 
            MatchLead.Contact__c = Match.Contact__c; 
            
            MatchLead.Phone_NADA__c = Match.NADA_Swipe__r.Phone__c; 
            MatchLead.Email_NADA__c = Match.NADA_Swipe__r.Email__c; 
            MatchLead.Title = Match.NADA_Swipe__r.Registration_Type__c; 
            MatchLead.Company = Match.NADA_Swipe__r.Company__c; 
            
            MatchLead.Current_Account__c = Match.Contact__r.AccountId; 
            
            MatchLead.Status = Tradeshow.Lead_Opp_Creation_Status__c;
            MatchLead.ADP_Campaign__c = Tradeshow.Campaign__c;
            
            MatchLead.LeadSource = Tradeshow.Lead_Source_Value__c;
            
            MatchLead.NADA_Swipe__c = Match.NADA_Swipe__c;
            MatchLead.OwnerId = QueryOwnerSource(Tradeshow.Lead_Opp_Owner_Source__c, Match.Contact__r.AccountId);
            
            // no longer needed because lead type is set dynamically (see below)
            //MatchLead.Lead_Type__c = Match.NADA_Swipe__r.Lead_Type__c;
            
            // determine and set Lead Type
            MatchLead.Lead_Type__c = 'Unhook'; // default
            
            System_at_Dealership__c DMS = null;
            List<System_at_Dealership__c> MatchDMSs = [
                Select Id, Name, Vendor__c, Vendor__r.Name, Install_Date__c, Age__c 
                From System_at_Dealership__c 
                Where Account__c = :Match.Contact__r.AccountId 
                And System_Type__c = 'DMS'
            ]; system.debug(MatchDMSs);
            if(MatchDMSs != null) { if(!MatchDMSs.IsEmpty()) { DMS = MatchDMSs[0]; } }
            system.debug(DMS);
            
            if(DMS != null && DMS.Vendor__c != null)
            {
                if(DMS.Vendor__r.Name.toLowerCase().startsWith('adp'))
                {
                    MatchLead.Lead_Type__c = 'Add-on';
                    
                    if(DMS.Install_Date__c != null) {
                        if(DMS.Install_Date__c.monthsBetween(Date.today()) >= 32) { 
                            MatchLead.Lead_Type__c = 'Upgrade'; } }
                }
            }
            // end Lead Type
        }
        else
        {
            MatchLead = Leads[0]; //system.debug('Found existing Lead: ' + Leads[0]);
        }
        
        // set Lead Priority value based on Attendees
        MatchLead.Priority__c = CalculatePriority(Match.NADA_Swipe__r.Priority__c, MatchLead.getSObjects('Lead_Attendees__r'));
        
        // Cumulative Manufacturers
        if(MatchLead.Manufacturers__c != null)
        {
            if(Match.NADA_Swipe__r.Manufacturers_Picklist__c != null)
            {
                MatchLead.Manufacturers__c += ';' + Match.NADA_Swipe__r.Manufacturers_Picklist__c;
            }
            
            // dedupe manufacturers
            List<String> ManufacturersList = MatchLead.Manufacturers__c.split(';');
            
            Set<String> ManufacturersSet = new Set<String>();
            ManufacturersSet.addAll(ManufacturersList);
            
            List<String> UniqueManufacturersList = new List<String>();
            UniqueManufacturersList.addAll(ManufacturersSet);
            
            String UniqueManufacturersString = '';
            for(Integer i = 0; i < UniqueManufacturersList.size(); i++)
            {
                if(i != 0) { UniqueManufacturersString += ';' + UniqueManufacturersList[i]; }
                else { UniqueManufacturersString += UniqueManufacturersList[i]; }
            }
            
            MatchLead.Manufacturers__c = UniqueManufacturersString;
        }
        else
        {
            MatchLead.Manufacturers__c = Match.NADA_Swipe__r.Manufacturers_Picklist__c;
        }
        
        // [2014-02-012T09:10:00Z] yesterday notes [2014-02-12]
        
        // Cumulative Notes
        if(Match.NADA_Swipe__r.Notes__c != null)
        {
            DateTime DateTimeSwiped = Match.NADA_Swipe__r.Swiped_Date_Time__c;
            String NoteMarkerStart = '[' + String.valueOf(DateTimeSwiped) + ']';
            String NoteMarkerEnd = '[' + String.valueOf(DateTimeSwiped.Date()) + ']';
            
            MatchLead.MSR_Notes__c = NoteMarkerStart + ' ' + Match.NADA_Swipe__r.Notes__c + ' ' + NoteMarkerEnd 
                + (MatchLead.MSR_Notes__c != null ? ' ' + MatchLead.MSR_Notes__c : '');
            
            if(MatchLead.MSR_Notes__c.length() > 32000) { MatchLead.MSR_Notes__c = MatchLead.MSR_Notes__c.substring(0,31995) + '...'; }
        }
        
        // [2014-02-013T09:10:00Z] swipe notes [2014-02-13]
        // [2014-02-012T09:10:00Z] yesterday notes [2014-02-12]
        
        system.debug(MatchLead);
        
        // Cumulative Presentation Areas
        if(MatchLead.Presentation_Areas__c != null)
        {
            MatchLead.Presentation_Areas__c += ';' + Match.NADA_Swipe__r.Presentation_Area__c;
            
            // dedupe presentation areas
            List<String> PresentationAreasList = MatchLead.Presentation_Areas__c.split(';');
            
            Set<String> PresentationAreasSet = new Set<String>();
            PresentationAreasSet.addAll(PresentationAreasList);
            
            List<String> UniquePresentationAreasList = new List<String>();
            UniquePresentationAreasList.addAll(PresentationAreasSet);
            
            String UniquePresentationAreasString = '';
            for(Integer i = 0; i < UniquePresentationAreasList.size(); i++)
            {
                if(i != 0) { UniquePresentationAreasString += ';' + UniquePresentationAreasList[i]; }
                else { UniquePresentationAreasString += UniquePresentationAreasList[i]; }
            }
            
            MatchLead.Presentation_Areas__c = UniquePresentationAreasString;
            
            if(MatchLead.Presentation_Areas__c.length() > 5000) { 
                MatchLead.Presentation_Areas__c = MatchLead.Presentation_Areas__c.substring(0,4995) + '...'; }
        }
        else
        {
            MatchLead.Presentation_Areas__c = Match.NADA_Swipe__r.Presentation_Area__c;
        }
        
        system.debug(MatchLead);
        
        // insert Lead
        try { upsert MatchLead; }
        catch (Exception exc)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exc.getMessage())); 
            return LinkToLeadResult;
        }
        
        // insert Attendee
        NADA_Attendees__c Attendee = CreateLeadAttendee(Match, MatchLead.Id);
        try { insert Attendee; }
        catch (Exception exc)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exc.getMessage())); 
            return LinkToLeadResult;
        }
        
        // update Match
        Match.Lead__c = MatchLead != null ? MatchLead.Id : null;
        Match.Lead_Attendee__c = Attendee != null ? Attendee.Id : null; // MK - 20140113 Added Lead_Attendee__c field on match
        
        try { update Match; }
        catch (Exception exc)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exc.getMessage())); 
            return LinkToLeadResult;
        }
        
        LinkToLeadResult.Match = Match;
        
        // update results with Success status
        LinkToLeadResult.Success = true;
        LinkToLeadResult.Message = 'Success';
        
        return LinkToLeadResult;
    }
    
    public NADA_Attendees__c CreateLeadAttendee(NADA_Match__c Match, Id MatchLeadId)
    {
        NADA_Attendees__c Attendee = new NADA_Attendees__c(
            Lead__c = MatchLeadId, 
            NADA_Swipe_Lookup__c = Match.NADA_Swipe__c, 
            Scanned_First_Name__c = Match.NADA_Swipe__r.First_Name__c, 
            Scanned_Last_Name__c = Match.NADA_Swipe__r.Last_Name__c, 
            Scanned_Phone__c = Match.NADA_Swipe__r.Phone__c, 
            Scanned_Fax__c = Match.NADA_Swipe__r.Fax__c, 
            Scanned_Email__c = Match.NADA_Swipe__r.Email__c, 
            Scanned_Title__c = Match.NADA_Swipe__r.Registration_Type__c, 
            Scanned_Company__c = Match.NADA_Swipe__r.Company__c, 
            Scanned_Company2__c = Match.NADA_Swipe__r.Company2__c, 
            Scanned_Address__c = (Match.NADA_Swipe__r.Street_Address__c != null ? Match.NADA_Swipe__r.Street_Address__c 
                + (Match.NADA_Swipe__r.Address2__c != null ? ' ' + Match.NADA_Swipe__r.Address2__c : '') : ''), 
            Scanned_City__c = Match.NADA_Swipe__r.City__c, 
            Scanned_State__c = Match.NADA_Swipe__r.State__c, 
            Scanned_Postal_Code__c = Match.NADA_Swipe__r.Postal_Code__c, 
            Scanned_Country__c = Match.NADA_Swipe__r.Country__c, 
            Scanned_Notes__c = Match.NADA_Swipe__r.Notes__c, 
            Scanned_Manufacturers__c = Match.NADA_Swipe__r.Manufacturers_Picklist__c, 
            Contact__c = Match.Contact__c, 
            Presentation_Area__c = Match.NADA_Swipe__r.Presentation_Area__c, 
            NADA_Presentation_Area_Lookup__c = (Match.NADA_Swipe__r.NADA_Scan_Device__c != null ? 
                Match.NADA_Swipe__r.NADA_Scan_Device__r.NADA_Presentation_Area__c : null), 
            Demo_Location__c = Match.NADA_Swipe__r.Demo_Location__c, 
            Date_Time_of_Scan__c = Match.NADA_Swipe__r.Swiped_Date_Time__c, 
            Demo_Date__c = Date.valueOf(Match.NADA_Swipe__r.Swiped_Date_Time__c), 
            Priority__c = Match.NADA_Swipe__r.Priority__c
        ); 
        
        Attendee.Questions_and_Answers__c = CompileQuestionsAndAnswers(Match.NADA_Swipe__r);
        
        // add attendee demographics
        Map<String, String> DemographicFields = new Map<String, String>{
            'Demographic_1_Name__c' => 'Demographic_1_Value__c',
            'Demographic_2_Name__c' => 'Demographic_2_Value__c',
            'Demographic_3_Name__c' => 'Demographic_3_Value__c',
            'Demographic_4_Name__c' => 'Demographic_4_Value__c',
            'Demographic_5_Name__c' => 'Demographic_5_Value__c',
            'Demographic_6_Name__c' => 'Demographic_6_Value__c',
            'Demographic_7_Name__c' => 'Demographic_7_Value__c',
            'Demographic_8_Name__c' => 'Demographic_8_Value__c',
            'Demographic_9_Name__c' => 'Demographic_9_Value__c',
            'Demographic_10_Name__c' => 'Demographic_10_Value__c',
            'Demographic_11_Name__c' => 'Demographic_11_Value__c',
            'Demographic_12_Name__c' => 'Demographic_12_Value__c',
            'Demographic_13_Name__c' => 'Demographic_13_Value__c',
            'Demographic_14_Name__c' => 'Demographic_14_Value__c',
            'Demographic_15_Name__c' => 'Demographic_15_Value__c'
        };
        
        for(String DemographicNameField : DemographicFields.keySet())
        {
            String DemographicValueField = DemographicFields.get(DemographicNameField);
            
            Attendee.put(DemographicNameField, Match.NADA_Swipe__r.get(DemographicNameField));
            Attendee.put(DemographicValueField, Match.NADA_Swipe__r.get(DemographicValueField));
        }
        
        return Attendee;
    }
    
    public LinkResult UpdateSwipeAfterLink(LinkResult CurrentResult)
    {
        if(CurrentResult.Match == null) { 
            CurrentResult.Success = false; 
            CurrentResult.Message = 'Unable to update Swipe information after linking. Match data not found. '; 
            return CurrentResult; 
        }
        
        // update NADA Swipe
        NADA_Swipe__c s = new NADA_Swipe__c(Id = CurrentResult.Match.NADA_Swipe__c);
        s.NADA_Match__c = CurrentResult.Match.Id;
        s.Marketing_Interaction__c = CurrentResult.MarketingInteraction.Id; 
        s.Linked_Contact__c = CurrentResult.Match.Contact__c;
        s.Linked_Account__c = CurrentResult.Match.Contact__r.AccountId;
        s.NADA_Lead__c = CurrentResult.Match.Lead__c;
        s.NADA_Attendee__c = CurrentResult.Match.Lead_Attendee__c;
        s.NADA_Opportunity__c = CurrentResult.Match.Opportunity__c;
        
        try { update s; }
        catch (Exception exc)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exc.getMessage())); 
            return CurrentResult;
        }
        
        // refresh Swipe in results
        CurrentResult.Swipe = [
            Select Id, Name, Linked_Contact__c, Linked_Contact__r.Name, Linked_Contact__r.Account.Name, NADA_Lead__r.Name 
            From NADA_Swipe__c 
            Where Id = :CurrentResult.Match.NADA_Swipe__c Limit 1
        ];
        
        return CurrentResult;
    }
    
    public PageReference NewContactFromSwipe()
    {
        InvalidAccountError = '';
        InvalidContactError = '';
        
        // clear the Linked_Contact__c field for display on the Visualforce page
        Swipe.Linked_Contact__c = null;
        
        // SelectedAccountId is passed in using the Swipe object (from the controller)
        // The NADA_Swipe__c.Linked_Account__c field is displayed on the page and set by the User
        String SelectedAccountId = Swipe.Linked_Account__c;
        system.debug(SelectedAccountId);
        
        // refresh the Swipe
        NADA_Swipe__c SwipeData = null;
        List<NADA_Swipe__c> MatchingSwipes = [
            Select Id, Name, Linked_Account__c, First_Name__c, Last_Name__c, Phone__c, Fax__c, Email__c, Registration_Type__c, 
                Street_Address__c, Address2__c, City__c, State__c, Postal_Code__c, Country__c
            From NADA_Swipe__c
            Where Id = :Swipe.Id
        ];
        
        if(MatchingSwipes != null) {
            if(!MatchingSwipes.IsEmpty()) { SwipeData = MatchingSwipes[0]; } }
        
        if(SwipeData == null)
        { 
            String ErrorMessage = 'Could not find the referenced Swipe. ';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ErrorMessage)); 
            
            return ApexPages.currentPage();
        }
        
        Account ContactAccount = null;
        List<Account> MatchingAccounts = [Select Id From Account Where Id = :SelectedAccountId];
        
        if(MatchingAccounts != null) {
            if(!MatchingAccounts.IsEmpty()) { ContactAccount = MatchingAccounts[0]; } }
        
        if(ContactAccount == null) 
        { 
            String ErrorMessage = 'The selected Account is invalid. Please select an Account from the Lookup Account field. ';
            
            InvalidAccountError = ErrorMessage;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ErrorMessage)); 
            
            return ApexPages.currentPage();
        }
        
        Contact SwipeContact = new Contact();
        
        SwipeContact.AccountId = ContactAccount.Id;
        SwipeContact.FirstName = SwipeData.First_Name__c;
        SwipeContact.LastName = SwipeData.Last_Name__c;
        SwipeContact.Phone = SwipeData.Phone__c;
        SwipeContact.Fax = SwipeData.Fax__c;
        SwipeContact.Email = SwipeData.Email__c;
        SwipeContact.Title = SwipeData.Registration_Type__c;
        SwipeContact.MailingStreet = SwipeData.Street_Address__c + (SwipeData.Address2__c != null ? '\n' + SwipeData.Address2__c : '');
        SwipeContact.MailingCity = SwipeData.City__c;
        SwipeContact.MailingState = SwipeData.State__c;
        SwipeContact.MailingPostalCode = SwipeData.Postal_Code__c;
        SwipeContact.MailingCountry = SwipeData.Country__c;
        
        try 
        {
            insert SwipeContact;
            
            system.debug(SwipeContact);
            
            // prepare and insert a Match with the new Contact
            NADA_Match__c Match = new NADA_Match__c(NADA_Swipe__c=SwipeData.Id,Contact__c=SwipeContact.Id);
            insert Match;
            
            system.debug(Match);
            
            // refresh Match after insert
            //  -- no need if calling LinkAndRedirect()
            // RefreshMatches();
            
            SelectedMatchId = Match.Id;
            return LinkAndRedirect();
        } 
        catch (Exception exc) 
        { 
            system.debug(exc.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exc.getMessage())); 
        }
        
        return ApexPages.currentPage();
    }
}