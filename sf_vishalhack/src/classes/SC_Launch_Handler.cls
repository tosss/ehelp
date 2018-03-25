/**
 * Class for handling Service Connect Canvas App
 *
 * In New Case workflow, if the selected Record Type is "Service Connect" embed Service Connect
 * Otherwise, continues with selected record type page layout.
 *
 * Canvas App: SC_Canvas
 * Visual Force Page: SC_Launch
 * Canvas App LifcycleHandler: SC_Launch_Handler (This Class)
 * Test Class: SC_Launch_Test
 */

// 2017-03-22 Sudhir.Moolky@cdk.com    Created
// 2017-03-27 Bhadresh.Patel@cdk.com   Rename / Add Comments

public class SC_Launch_Handler implements Canvas.CanvasLifecycleHandler {
    public boolean showSearch { get; private set; }
    public boolean showCanvasApp { get; private set; }

    public Case newCase { get; set; }
    public String canvasAppParameters { get; private set; }

    private Map <String, String> pageParams;
    private String retUrl;

    public SC_Launch_Handler()
    {
    }

    public SC_Launch_Handler(ApexPages.StandardController stdController)
    {
        showSearch = true;
        showCanvasApp = false;
        canvasAppParameters = '';

        newCase = (Case) stdController.getRecord();
    }

    public PageReference getCaseEditPage()
    {
        String                  caseDetailsJson = ApexPages.currentPage().getParameters().get('caseDetails');
        Map<String, Object>     caseDetails = (Map<String, Object>) JSON.deserializeUntyped(caseDetailsJson);
        String                  caseNumber = (String) caseDetails.get('caseNumber');
        PageReference           caseEditPageRef;

        if (caseNumber != null) {
            try {
                Case selectedCase = [
                    SELECT Id
                    FROM Case
                    WHERE CaseNumber = :caseNumber
                    LIMIT 1
                ];

                // 6/13/2017 - Override return URL and send to newly created case details
                caseEditPageRef = new PageReference('/' + selectedCase.Id + '/e');
                caseEditPageRef.getParameters().put('retURL', '/' + selectedCase.Id);
                return caseEditPageRef;
            } catch (Exception exc) {
            }
        }

        caseEditPageRef = new PageReference('/500/e');
        caseEditPageRef.getParameters().put('nooverride', '1');
        caseEditPageRef.getParameters().put('retURL', retUrl);
        caseEditPageRef.setRedirect(true);
        for (String paramKey : pageParams.KeySet()) {
            caseEditPageRef.getParameters().put(paramKey, pageParams.get(paramKey));
        }

        if (caseNumber != null) {
            System.debug('SUDHIR - case number ' + caseNumber);
            CustomSettings__c customSettings = CustomSettings__c.getInstance();
            System.debug(customSettings);
            String visionFieldId = customSettings.SC_Vision_Field_Id__c;
            System.debug('SUDHIR ' + visionFieldId);
            if (String.isNotEmpty(visionFieldId)) {
                caseEditPageRef.getParameters().put(visionFieldId.left(15), caseNumber);
            }
        }
        if (caseDetails.get('caseSubject') != null) {
            caseEditPageRef.getParameters().put('cas14', (String) caseDetails.get('caseSubject'));
        }

        // @todo merge description and case comments in SC frontend itself
        if (caseDetails.get('caseDescription') != null) {
            caseEditPageRef.getParameters().put(
                'cas15',
                (String) caseDetails.get('caseDescription') + '\n\n' + (String) caseDetails.get('caseInternalComments')
            );
        }

        return caseEditPageRef;
    }

    public PageReference getForwardPage()
    {
        PageReference embeddedPage;

        pageParams = ApexPages.currentPage().getParameters();
        retUrl = pageParams.get('retURL');

        // Certain new case custom buttons result in embedded retURL OR eid inside the main retURL parameter. To route
        // back to the originating object details page, we need to extract and use them.
        // If the main retURL parameter is used, either the routing will go back to the new case record type selection
        // page or the user will get a stale session error.
        if ((retUrl != null) && retUrl.containsIgnoreCase('servlet.integration')) {
            embeddedPage = new PageReference(retUrl);
            if (retUrl.containsIgnoreCase('returl')) {
                retUrl = embeddedPage.getParameters().get('retURL');
            } else if (retUrl.containsIgnoreCase('eid')) {
                retUrl = '/' + embeddedPage.getParameters().get('eid');
            }
        }

        if (pageParams.get('sc_launch_error') != null) {
            showSearch = true;
            showCanvasApp = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'There was an error creating the Service Connect case.'));
            return null;
        }

        ID scRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Service Connect');
        GlobalSettings__c globalSettings = GlobalSettings__c.getInstance();

        if (globalSettings.Launch_Service_Connect__c && (newCase.RecordTypeId == scRecordTypeId)) {
            pageParams.remove('retURL');
            pageParams.remove('save_new');
            pageParams.remove('sfdc.override');

            if (newCase.AccountId != null) {
                launchCanvasApp(newCase.AccountId);
            } else if (newCase.WebID__c != null) {
                WebID__c selectedWebId = [
                    SELECT Account__c
                    FROM WebID__c
                    WHERE Id = :newCase.WebID__c
                    LIMIT 1
                ];
                launchCanvasApp(selectedWebId.Account__c);
            } else if (newCase.Launch__c != null) {
                Launch__c selectedLaunchId = [
                    SELECT Account__c
                    FROM Launch__c
                    WHERE Id = :newCase.Launch__c
                    LIMIT 1
                ];
                launchCanvasApp(selectedLaunchId.Account__c);
            }
            return null;
        }

        PageReference forwardPage = new PageReference('/500/e');

        for (String paramKey : pageParams.KeySet()) {
            if (!paramKey.equalsIgnoreCase('save_new')) {
                forwardPage.getParameters().put(paramKey, pageParams.get(paramKey));
            }
        }

        forwardPage.getParameters().put('nooverride', '1');
        forwardPage.setRedirect(true);

        return forwardPage;
    }

    private void launchCanvasApp(ID accountId)
    {
        Account selectedAccount = [
            SELECT PartyID__c
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];

        if (selectedAccount.PartyID__c == null) {
            showSearch = true;
            showCanvasApp = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'The account does not have a valid Party ID.'));
            return;
        }

        JSONGenerator scParams = JSON.createGenerator(false);
        scParams.writeStartObject();
        scParams.writeStringField('storeId', selectedAccount.PartyID__c);
        scParams.writeStringField('loginId', UserInfo.getUserEmail());

        if (newCase.WebID__c != null) {
            scParams.writeStringField('webId', newCase.WebID__c);
        }

        scParams.writeFieldName('pageParams');
        scParams.writeObject(pageParams);
        scParams.writeEndObject();

        canvasAppParameters = scParams.getAsString();

        showCanvasApp = true;
        showSearch = false;
    }

    public PageReference launchServiceConnect()
    {
        if (newCase.AccountId != null) {
            launchCanvasApp(newCase.AccountId);
        }

        return null;
    }

    public Set<Canvas.ContextTypeEnum> excludeContextTypes()
    {
        Set<Canvas.ContextTypeEnum> excluded = new Set<Canvas.ContextTypeEnum>();
        excluded.add(Canvas.ContextTypeEnum.ORGANIZATION);
        excluded.add(Canvas.ContextTypeEnum.USER);
        excluded.add(Canvas.ContextTypeEnum.RECORD_DETAIL);

        return excluded;
    }

    public void onRender(Canvas.RenderContext renderContext)
    {
        DateTime dt = System.now();
        Canvas.ApplicationContext app = renderContext.getApplicationContext();

        app.setCanvasUrlPath('/api/auth.php?_r=' + dt.getTime());
    }
}