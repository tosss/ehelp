// 2015-12-3 endiem@endiem.com - RQ-05509 - This is helper class for creating B4B Coaching record from flow.
public with sharing class TRV_ResourceManagement_Helper {
    
    // Instance fields
    public String searchTerm {get; set;}                                            // Variable to store search Term for Consulting Project
    public String selectedProject {get; set;}                                       // Variable to store Selected Project Id
    public String searchAccountTerm {get; set;}                                     // Variable to store search Term for Account
    public String selectedAccount {get; set;}                                       // Variable to store Id for Selected Account
    public Flow.Interview.B4BCoaching_Record_Creation b4bCoachingRecord {get;set;}  // Variable to Store b4B Coaching Instance
    public Boolean bRenderFlow {get;set;}                                           // Boolean variable to render Flow section on page
    public String strResourceId {get;set;}                                          // To Store Resource Id passed from URL
    public String expertiseMajor {get;set;}                                         // To Store Expertise Major passed from URL           
    public String expertiseMinor {get;set;}                                         // To Store Expertise Minor passed from URL           
    public String skillLevelMajor {get;set;}                                        // To Store Skill Level Major passed from URL           
    public String skillLevelMinor {get;set;}                                        // To Store Skill Level Minor passed from URL           
    public Date strVisitStartDate {get;set;}                                        // To Store Resource Id passed from URL           
    public Boolean bCanCreateB4B {get;set;}

    private final static Integer PERCENT_OF_DAYS_USED = 100;                        // Constant Variable 

    /* Start - Constructor */
    public TRV_ResourceManagement_Helper(){

        bRenderFlow = false;
        bCanCreateB4B = false;
        strResourceId = expertiseMajor = expertiseMinor = skillLevelMajor = skillLevelMinor = '';
        strResourceId = ApexPages.currentPage().getParameters().get('resourceId');
        
        Date dt = Date.valueOf(ApexPages.currentPage().getParameters().get('visitStartDate'));
        List<TRV_Resource__c> lstResource = [   
            SELECT TRV_Termination_Date__c 
            FROM TRV_Resource__c 
            WHERE Id =: strResourceId
        ];
        
        if(lstResource[0].TRV_Termination_Date__c != null && dt >= lstResource[0].TRV_Termination_Date__c){

            bCanCreateB4B = true;
        }
        
    }
    /* End - Constructor */
    
    //This method is used to find out Consulting Project bassed on selected account
    @RemoteAction
    public static List<Traver_Project__c> searchProject(String searchTerm, String selectedAcc) { 
        
        String projectQuery = ' Select Id, Name, TRV_Consulting_Project_Name__c from Traver_Project__c where Project_Status__c IN (\'Active\',\'Backlog\') ' +
                              ' AND PSG_FRM_of_Days_PSG_Used__c <: PERCENT_OF_DAYS_USED AND TRV_FRM_of_Day_Traver_Used__c <: PERCENT_OF_DAYS_USED AND Account__c =: selectedAcc ' +
                              ' AND (B4B_Account_Name__c like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' OR ' +
                              ' TRV_Consulting_Project_Name__c like \'%' + String.escapeSingleQuotes(searchTerm) + '%\')';

        List<Traver_Project__c> Project = Database.query(projectQuery);
        return Project;
    }

    //This method is used to search for account based on search Term.
    @RemoteAction
    public static List<Account> searchAccount(String searchTerm) {
        
        List<Account> acc = Database.query('Select Id, Name from Account where name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        return acc;
    }

    //This method is to find out if there is any B4B Coaching record whose X5_Star_Guarantee__c is checked.
    @RemoteAction
    public static Boolean five_Star_Gaurantee_B4B(String accountId, String resourceId) {
        
        List<Traver_Coaching__c> lstTraverCoaching = [  
            SELECT Id 
            FROM Traver_Coaching__c 
            WHERE TRV_Completed_By__c =: resourceId 
            AND Traver_Project__r.Account__c =: accountId 
            AND X5_Star_Guarantee__c = TRUE
         ];

        if(lstTraverCoaching.isEmpty()){

            return false;
        }
        else {

            return true;
        }
    }
    
    //This method is used to set the URL parameters to getter setter variables.
    public void redirectToFlow() {
        
        bRenderFlow = true;
        strVisitStartDate = Date.valueOf(ApexPages.currentPage().getParameters().get('visitStartDate'));
        
        strResourceId = ApexPages.currentPage().getParameters().get('resourceId');
        expertiseMajor = ApexPages.currentPage().getParameters().get('ExMajor');
        expertiseMinor = ApexPages.currentPage().getParameters().get('ExMinor');
        skillLevelMajor = ApexPages.currentPage().getParameters().get('skLevMajor');
        skillLevelMinor = ApexPages.currentPage().getParameters().get('skLevMinor');   
        
    }

    //This method is used to fetch B4B record Id which is being created from Flow.
    public String getmyID() {
        
        if (b4bCoachingRecord == null) {
        
            return '';
        }
        else {
            
            return b4bCoachingRecord.B4BRecordId;
        }  
    }
    
    //This method will redirect the flow page to the standard edit page of B4B Coaching record page.
    public PageReference getB4BId() {
    
        PageReference p = new PageReference('/' + getmyID() + '/e?retURL=' + getmyID());
        p.setRedirect(true);
        
        return p;
    }

}