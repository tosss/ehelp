/**
 * Test Class for Service Connect Canvas App
 *
 * Canvas App: SC_Canvas
 * Visual Force Page: SC_Launch
 * Canvas App LifcycleHandler: SC_Launch_Handler
 * Test Class: SC_Launch_Test (This Class)
 */

// 2017-03-22 Sudhir.Moolky@cdk.com    Created
// 2017-03-27 Bhadresh.Patel@cdk.com   Rename / Add Comments

@IsTest
public class SC_Launch_Test {

    @testSetup static void setup() {
        createCase('Service Connect', '11111');
        createCase('Tier 1', '11112');
    }

    /**
     * Generate a random string
     */
    public static String genRandomString() {
        return  Math.round(Math.random()*10000).format();
    }

    /**
     * Construct case object with only web ID reference
     */
    public static Case caseWithWebID(String caseRecordType, String partyId) {
        String prefix = 'SC ' + genRandomString();
        Account newAccount = new Account(
            Name = prefix + ' Test Account',
            PartyID__c = partyId
        );
        insert newAccount;

        WebId__c newWebId = new WebId__c (
            Name = prefix + ' Test WebID',
            Vanity_URL__c = prefix + ' Test Vanity URL',
            Account__c = newAccount.Id
        );
        insert newWebId;

        ID scRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', caseRecordType);

        Case newCase = new Case(
            Subject = 'SC Test Case Subject',
            Description = 'SC Test Case Description',
            WebId__c = newWebId.Id,
            RecordTypeId = scRecordTypeId
        );
        return newCase;
    }

    /**
     * Construct case object with only Launch ID reference
     */
    public static Case caseWithLaunchID(String caseRecordType, String partyId) {
        String prefix = 'SC ' + genRandomString();
        Account newAccount = new Account(
            Name = prefix + ' Test Account',
            PartyID__c = partyId
        );
        insert newAccount;

        Launch__c newLaunch = new Launch__c (
            Account__c = newAccount.Id
        );
        insert newLaunch;

        ID scRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', caseRecordType);

        Case newCase = new Case(
            Subject = 'SC Test Case Subject',
            Description = 'SC Test Case Description',
            Launch__c = newLaunch.Id,
            RecordTypeId = scRecordTypeId
        );
        return newCase;
    }

    /**
     * Create case record
     */
    public static String createCase(String caseRecordType, String partyId) {
        String prefix = 'SC ' + genRandomString();
        Account newAccount = new Account(
            Name = prefix + ' Test Account',
            PartyID__c = partyId
        );
        insert newAccount;

        WebId__c newWebId = new WebId__c (
            Name = prefix + ' Test WebID',
            Vanity_URL__c = prefix + ' Test Vanity URL',
            Account__c = newAccount.Id
        );
        insert newWebId;

        Contact newContact = new Contact(
            FirstName = prefix + 'FirstName',
            LastName = 'LastName',
            AccountId = newAccount.Id
        );
        insert newContact;

        Contact_Relationship__c newContactRelationship = new Contact_Relationship__c(
            Account__c = newAccount.Id,
            Contact__c = newContact.Id
        );
        insert newContactRelationship;

        ID scRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', caseRecordType);

        Case newCase = new Case(
            Subject = 'SC Test Case Subject',
            Description = 'SC Test Case Description',
            AccountId = newAccount.Id,
            ContactId = newContact.Id,
            WebId__c = newWebId.Id,
            RecordTypeId = scRecordTypeId
        );
        insert newCase;
        return newCase.Id;
    }

    /**
     * Construct case details JSON object
     */
    public static JSONGenerator createCaseDetailsJSON(String caseNumber, Boolean allDetails) {
        JSONGenerator caseDetails = JSON.createGenerator(false);
        caseDetails.writeStartObject();

        if (caseNumber != null) {
            caseDetails.writeStringField('caseNumber', caseNumber);
        }
        if (allDetails) {
            String randomString = genRandomString();

            caseDetails.writeStringField('caseSubject', 'Test Subject ' + randomString);
            caseDetails.writeStringField('caseDescription', 'Test Description ' + randomString);
            caseDetails.writeStringField('caseInternalComments', 'Test Comments ' + randomString);
        }
        caseDetails.writeEndObject();

        return caseDetails;
    }

    /**
     * Test excluded context types when canvas app passes data to SC
     */
    public static testMethod void testExcludedContentTypes()
    {
        SC_Launch_Handler scLaunchHandler = new SC_Launch_Handler();
        Set<Canvas.ContextTypeEnum> exclusions;

        exclusions = scLaunchHandler.excludeContextTypes();
        System.assert(exclusions.contains(Canvas.ContextTypeEnum.ORGANIZATION));
        System.assert(exclusions.contains(Canvas.ContextTypeEnum.USER));
        System.assert(exclusions.contains(Canvas.ContextTypeEnum.RECORD_DETAIL));
    }

    /**
     * Test SC is not launched if global setting is unchecked
     */
    public static testMethod void testLaunchServiceConnectGlobalSettingUnchecked()
    {
        insert new GlobalSettings__c(Launch_Service_Connect__c = false);

        ID scRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Service Connect');

        Case newCase = new Case(RecordTypeId = scRecordTypeId);

        SC_Launch_Handler scLaunchHandler = new SC_Launch_Handler(
            new ApexPages.StandardController(newCase)
        );

        PageReference pageRef = scLaunchHandler.getForwardPage();
        System.assertNotEquals(null, pageRef);
    }

    /**
     * Test SC is not launched when Account is not preselected and until user selects it
     */
    public static testMethod void testServiceConnectRecordTypeWithoutAccount()
    {
        insert new GlobalSettings__c(Launch_Service_Connect__c = true);

        ID scRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Service Connect');

        Case newCase = new Case(RecordTypeId = scRecordTypeId);

        SC_Launch_Handler scLaunchHandler = new SC_Launch_Handler(
            new ApexPages.StandardController(newCase)
        );

        System.assertEquals(null, scLaunchHandler.newCase.AccountId);
        System.assertEquals(scRecordTypeId, scLaunchHandler.newCase.RecordTypeId);

        PageReference pageRef = scLaunchHandler.getForwardPage();
        System.assertEquals(null, pageRef);

        // simulate user selecting account
        String prefix = 'SC ' + genRandomString();
        String partyId = '12345';

        Account newAccount = new Account(
            Name = prefix + ' Test Account',
            PartyID__c = partyId
        );
        insert newAccount;

        scLaunchHandler.newCase.AccountId = newAccount.Id;
        scLaunchHandler.launchServiceConnect();

        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(scLaunchHandler.canvasAppParameters);
        System.assertEquals(partyId, params.get('storeId'));
    }

    /**
     * Test SC is NOT launched when Account is pre selected and has no Party ID
     */
    public static testMethod void testServiceConnectRecordTypeWithAccountNoPartyId()
    {
        insert new GlobalSettings__c(Launch_Service_Connect__c = true);
        String partyId = '11111';

        ID scRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Service Connect');
        Case newCase = [SELECT Id, CaseNumber, AccountId, RecordTypeId FROM Case WHERE RecordTypeId = :scRecordTypeId];

        Account account = [SELECT Id, PartyID__c FROM Account WHERE Id = :newCase.AccountId];
        account.PartyID__c = null;
        update account;

        SC_Launch_Handler scLaunchHandler = new SC_Launch_Handler(
            new ApexPages.StandardController(newCase)
        );

        System.assertNotEquals(null, scLaunchHandler.newCase.AccountId);
        System.assertEquals(scRecordTypeId, scLaunchHandler.newCase.RecordTypeId);

        PageReference pageRef = scLaunchHandler.getForwardPage();
        System.assertEquals(null, pageRef);
        System.assertEquals('', scLaunchHandler.canvasAppParameters);

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        for (ApexPages.Message msg : ApexPages.getMessages()) {
            System.assert(msg.getSummary().containsIgnoreCase('account does not have a valid Party'));
            System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        }
    }

    /**
     * Test SC is launched when Account is pre selected
     */
    public static testMethod void testServiceConnectRecordTypeWithAccount()
    {
        insert new GlobalSettings__c(Launch_Service_Connect__c = true);
        String partyId = '11111';

        ID scRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Service Connect');
        Case newCase = [SELECT Id, CaseNumber, AccountId, RecordTypeId, WebID__c FROM Case WHERE RecordTypeId = :scRecordTypeId];

        SC_Launch_Handler scLaunchHandler = new SC_Launch_Handler(
            new ApexPages.StandardController(newCase)
        );

        System.assertNotEquals(null, scLaunchHandler.newCase.AccountId);
        System.assertEquals(scRecordTypeId, scLaunchHandler.newCase.RecordTypeId);

        PageReference pageRef = scLaunchHandler.getForwardPage();
        System.assertEquals(null, pageRef);

        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(scLaunchHandler.canvasAppParameters);
        System.assertEquals(partyId, params.get('storeId'));
        System.assertEquals(newCase.WebID__c, params.get('webId'));
    }

    /**
     * Test SC is launched when WebID is pre selected
     */
    public static testMethod void testServiceConnectRecordTypeWithWebID()
    {
        insert new GlobalSettings__c(Launch_Service_Connect__c = true);
        String partyId = '12345';

        Case newCase = caseWithWebID('Service Connect', partyId);
        ID scRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Service Connect');

        SC_Launch_Handler scLaunchHandler = new SC_Launch_Handler(
            new ApexPages.StandardController(newCase)
        );

        System.assertNotEquals(null, scLaunchHandler.newCase.WebID__c);
        System.assertEquals(scRecordTypeId, scLaunchHandler.newCase.RecordTypeId);

        PageReference pageRef = scLaunchHandler.getForwardPage();
        System.assertEquals(null, pageRef);

        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(scLaunchHandler.canvasAppParameters);
        System.assertEquals(partyId, params.get('storeId'));
    }

    /**
     * Test SC is launched when Launch ID is pre selected
     */
    public static testMethod void testServiceConnectRecordTypeWithLaunchID()
    {
        insert new GlobalSettings__c(Launch_Service_Connect__c = true);
        String partyId = '12345';

        Case newCase = caseWithLaunchID('Service Connect', partyId);
        ID scRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Service Connect');

        SC_Launch_Handler scLaunchHandler = new SC_Launch_Handler(
            new ApexPages.StandardController(newCase)
        );

        System.assertNotEquals(null, scLaunchHandler.newCase.Launch__c);
        System.assertEquals(scRecordTypeId, scLaunchHandler.newCase.RecordTypeId);

        PageReference pageRef = scLaunchHandler.getForwardPage();
        System.assertEquals(null, pageRef);

        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(scLaunchHandler.canvasAppParameters);
        System.assertEquals(partyId, params.get('storeId'));
    }

    /**
     * Test forward to standard Case create screen with URL params for non Service Connect record type
     */
    public static testMethod void testNonServiceConnectRecordTypeWithoutAccount()
    {
        ID nonScRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Tier 1');

        Case newCase = new Case(RecordTypeId = nonScRecordTypeId);

        SC_Launch_Handler scLaunchHandler = new SC_Launch_Handler(
            new ApexPages.StandardController(newCase)
        );
        System.assertEquals(null, scLaunchHandler.newCase.AccountId);
        System.assertEquals(nonScRecordTypeId, scLaunchHandler.newCase.RecordTypeId);

        PageReference currentPage = ApexPages.currentPage();
        String testParamKey = 'gobbledy_gook';
        String testParamValue = 'makes_sense';
        currentPage.getParameters().put('save_new', '1');
        currentPage.getParameters().put(testParamKey, testParamValue);

        PageReference forwardPage = scLaunchHandler.getForwardPage();
        System.assertNotEquals(null, forwardPage);
        System.assertEquals(null, forwardPage.getParameters().get('save_new'));
        System.assertEquals(testParamValue, forwardPage.getParameters().get(testParamKey));
    }

    /**
     * Test proper URI generated when canvas app is rendered
     */
    public static testMethod void testCanvasAppOnRender()
    {
        Map<String, String> appValues = new Map<String, String>();
        appValues.put(Canvas.Test.KEY_NAMESPACE, 'SC');

        Map<String, String> envValues = new Map<String, String>();
        envValues.put(Canvas.Test.KEY_LOCATION_URL, 'https://serviceconnect-qat.support.cdk.com');

        Canvas.RenderContext mockRenderContext = Canvas.Test.mockRenderContext(appValues, envValues);

        SC_Launch_Handler scLaunchHandler = new SC_Launch_Handler();
        Canvas.Test.testCanvasLifecycle(scLaunchHandler, mockRenderContext);

        Canvas.ApplicationContext appContext = mockRenderContext.getApplicationContext();
        String appUrl = appContext.getCanvasUrl();
        System.assert(appUrl.containsIgnoreCase('/api/auth.php?_r='));
    }

    /**
     * Test Apex page message is added during launch error
     */
    public static testMethod void testLaunchErrorGeneratesApexPageMessage()
    {
        SC_Launch_Handler scLaunchHandler = new SC_Launch_Handler(
            new ApexPages.StandardController(new Case())
        );

        PageReference currentPage = ApexPages.currentPage();
        currentPage.getParameters().put('sc_launch_error', '1');

        PageReference forwardPage = scLaunchHandler.getForwardPage();
        System.assertEquals(null, forwardPage);

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        for (ApexPages.Message msg : ApexPages.getMessages()) {
            System.assert(msg.getSummary().containsIgnoreCase('error creating'));
            System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        }
    }

    /**
     * Test retrieval of forwarding Page based on good case number
     */
    public static testMethod void testGetCaseEditPageForValidCase()
    {
        ID scRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Service Connect');
        Case newCase = [SELECT Id, CaseNumber FROM Case WHERE RecordTypeId = :scRecordTypeId];

        JSONGenerator caseDetailsJson = createCaseDetailsJSON(newCase.CaseNumber, false);

        PageReference currentPage = ApexPages.currentPage();
        currentPage.getParameters().put('caseDetails', caseDetailsJson.getAsString());
        String embeddedUrl = 'my-embedded-url';
        currentPage.getParameters().put('retURL', 'servlet.integration?retURL=' + embeddedUrl);

        SC_Launch_Handler scLaunchHandler = new SC_Launch_Handler(
            new ApexPages.StandardController(new Case())
        );

        scLaunchHandler.getForwardPage();
        PageReference pageRef = scLaunchHandler.getCaseEditPage();
        String retUrl = pageRef.getUrl();
        System.assert(retUrl.containsIgnoreCase('/' + newCase.Id + '/e'));
        System.assert(retUrl.containsIgnoreCase('?retURL='));
        // System.assertEquals(embeddedUrl, pageRef.getParameters().get('retURL'));
        System.assertEquals('/' + newCase.Id, pageRef.getParameters().get('retURL'));
    }

    /**
     * Test retrieval of forwarding Page based on no case number (500 Vision case create)
     */
    public static testMethod void testGetCaseEditPageForNoCase()
    {
        insert new GlobalSettings__c(Launch_Service_Connect__c = true);
        String partyId = '12345';

        Case newCase = caseWithLaunchID('Service Connect', partyId);

        JSONGenerator caseDetailsJson = createCaseDetailsJSON(null, true);
        String caseDetailsStr = caseDetailsJson.getAsString();
        Map<String, Object> caseDetails = (Map<String, Object>) JSON.deserializeUntyped(caseDetailsStr);

        PageReference currentPage = ApexPages.currentPage();
        currentPage.getParameters().put('caseDetails', caseDetailsStr);
        String testParamKey = 'gobbledy_gook';
        String testParamValue = 'makes_sense';
        currentPage.getParameters().put(testParamKey, testParamValue);

        String embeddedEid = 'my-embedded-eid';
        currentPage.getParameters().put('retURL', 'servlet.integration?eid=' + embeddedEid);

        SC_Launch_Handler scLaunchHandler = new SC_Launch_Handler(
            new ApexPages.StandardController(newCase)
        );

        scLaunchHandler.getForwardPage();
        PageReference caseEditPageRef = scLaunchHandler.getCaseEditPage();
        Map<String, String> pageParams = caseEditPageRef.getParameters();

        System.assertNotEquals(null, caseEditPageRef);
        System.assertEquals((String) caseDetails.get('caseSubject'), pageParams.get('cas14'));
        System.assertEquals(
            (String) caseDetails.get('caseDescription') + '\n\n' + (String) caseDetails.get('caseInternalComments'),
            pageParams.get('cas15')
        );
        System.assertEquals(testParamValue, pageParams.get(testParamKey));
        System.assertEquals('/' + embeddedEid, pageParams.get('retURL'));
    }

    /**
     * Test retrieval of forwarding Page based on Vision case number (202 Vision temp case create)
     */
    public static testMethod void testGetCaseEditPageForVisionCase()
    {
        String customFieldId = '00NcXXXXXX3dEEK';
        insert new CustomSettings__c(SC_Vision_Field_Id__c = customFieldId);

        JSONGenerator caseDetailsJson = createCaseDetailsJSON('90123123', true);
        String caseDetailsStr = caseDetailsJson.getAsString();
        Map<String, Object> caseDetails = (Map<String, Object>) JSON.deserializeUntyped(caseDetailsStr);

        PageReference currentPage = ApexPages.currentPage();
        currentPage.getParameters().put('caseDetails', caseDetailsStr);
        String testParamKey = 'gobbledy_gook2';
        String testParamValue = 'makes_sense2';
        currentPage.getParameters().put(testParamKey, testParamValue);

        SC_Launch_Handler scLaunchHandler = new SC_Launch_Handler(
            new ApexPages.StandardController(new Case())
        );

        scLaunchHandler.getForwardPage();
        PageReference caseEditPageRef = scLaunchHandler.getCaseEditPage();
        System.assertNotEquals(null, caseEditPageRef);
        System.assertEquals((String) caseDetails.get('caseSubject'), caseEditPageRef.getParameters().get('cas14'));
        System.assertEquals(
            (String) caseDetails.get('caseDescription') + '\n\n' + (String) caseDetails.get('caseInternalComments'),
            caseEditPageRef.getParameters().get('cas15')
        );
        System.assertEquals(
            (String) caseDetails.get('caseNumber'),
            caseEditPageRef.getParameters().get(customFieldId)
        );
        System.assertEquals(testParamValue, caseEditPageRef.getParameters().get(testParamKey));
    }
}