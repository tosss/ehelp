// 2015-11-27 endiem@endiem.com - RQ-05509 - Resource Management Controller to show filtered Resources and B4B Coaching Associated to a resource.
public with sharing class TRV_ResourceManagement_Controller{
    
    public static list<WrapperClass> lstwrapperClass {get;set;}    // List of Wrapper
    public static String strSelectedRole {get; set;}               // String of selected Role 
    public static String strSelectedStatus {get; set;}             // String of selected Status
    public static String strSelectedResource {get;set;}            // String of selected Resource
    public static String strSelectedLocation {get;set;}            // String of selected Location 
    public static TRV_Skillset__c objSkillSetForFilters {get;set;}     // Skill Set Object Instance used for filters
    public static Map<Integer, Set<String>> mapOfSkillLevelToValues = new Map<Integer, Set<String>>();  // Map of SKill Level To Values
    public static Map<String, String> mapOfPicklistToColorValue = new Map<String, String>();            // Map of Picklist Value to Color
    
    public TRV_Resource_Management_Filters__c objRMFilters {get;set;}  // Resource Management Custom Setting Filters
    
    /* Start - Static method to prepopulate the Map onLoad of page */
    static {

        mapOfSkillLevelToValues.put(0, new Set<String>{'0', '1', '2', '3', '4'});
        mapOfSkillLevelToValues.put(1, new Set<String>{'1', '2', '3', '4'});
        mapOfSkillLevelToValues.put(2, new Set<String>{'2', '3', '4'});
        mapOfSkillLevelToValues.put(3, new Set<String>{'3', '4'});
        mapOfSkillLevelToValues.put(4, new Set<String>{'4'});

        mapOfPicklistToColorValue.put('Confirmed', '#78c953');
        mapOfPicklistToColorValue.put('Completed', '#e27001');
        mapOfPicklistToColorValue.put('Cancelled', '#B8B8B8'); 
        mapOfPicklistToColorValue.put('Tentative', '#0b6fce'); 
        mapOfPicklistToColorValue.put('Pushed', '#a53711');
    }
    /* End - Static method to prepopulate the Map onLoad of page */
    
    /* Start - Constructor */
    public TRV_ResourceManagement_Controller() {

        strSelectedRole = '';
        strSelectedStatus = '';
        strSelectedResource = '';
        strSelectedLocation = '';
        lstwrapperClass = new list<WrapperClass>();
        objSkillSetForFilters = new TRV_Skillset__c();

        objRMFilters = TRV_Resource_Management_Filters__c.getInstance();
        strSelectedRole = objRMFilters.TRV_Role__c;
        strSelectedStatus = objRMFilters.TRV_Resource_Status__c;
        strSelectedResource = objRMFilters.TRV_Resource__c;
        strSelectedLocation = objRMFilters.TRV_Resource_Location__c;
        objSkillSetForFilters.TRV_Expertise_Major__c = objRMFilters.TRV_Expertise_Major__c;
        objSkillSetForFilters.TRV_Expertise_Minor__c = objRMFilters.TRV_Expertise_Minor__c;
        objSkillSetForFilters.TRV_Skill_Level_Major__c = objRMFilters.TRV_Skill_Level_Major__c;
        objSkillSetForFilters.TRV_Skill_Level_Minor__c = objRMFilters.TRV_Skill_Level_Minor__c;
    } 
    /* End - Constructor */
    
    /* Start - Wrapper Class */ 
    public class WrapperClass {
        
        public Traver_Coaching__c objB4BCoaching {get;set;}
        public TRV_Resource__c resource {get;set;}
        public String b4bColorValue {get;set;}

        public WrapperClass(Traver_Coaching__c objB4BCoaching, TRV_Resource__c resource, String b4bColorValue) {
            
            this.objB4BCoaching = objB4BCoaching;
            this.resource = resource;
            this.b4bColorValue = b4bColorValue;
        }
    }
    /* End - Wrapper Class */
    
    // This method is used to fetch the Custom Setting instance.
    @RemoteAction 
    public static TRV_Resource_Management_Filters__c getFilterPreferences() {

        return TRV_Resource_Management_Filters__c.getInstance();
    }
    
    //This method will return List of B4B Coaching records based on filters selected on the RM page.
    @RemoteAction 
    public static List<WrapperClass> getB4BCoaching(String strRole, String strStatus, String strResource, String strLocation, String expertiseMajor, String expertiseMinor, String skillMajor, String skillMinor, boolean isOnLoad) {

        lstwrapperClass = new List<WrapperClass>();
        Set<Id> setResourceId = new Set<Id>();
        Set<Id> setSkillSetId = new Set<Id>();
        String strInitialQuery = '';
        TRV_Resource_Management_Filters__c objRMFilters = TRV_Resource_Management_Filters__c.getInstance();
        
        /*
         If all the filters are blank then it will enter in if Block where
        - We will query on B4B coaching records whose completed by is not Null and store all the resource Id.
        - Will query on resource and fetch all the resources which are not in the above set which will provide us all the resource use B4B records is not there.
         otherwise else
        - We will query on Resource with Inner query on skill set based on Filters applied and fetch all the resources.
        - Will query on B4B object where Completed By IN above set.
        */ 
        if(strRole == '' && strStatus == '' && strResource == '' && strLocation == '' && expertiseMajor == '' && 
            expertiseMinor == '' && skillMajor == '' && skillMinor == ''){
                 
                lstwrapperClass = fetchB4BWithoutFilters();
        }
        else{

            lstwrapperClass = fetchB4BWithFilters(strRole, strStatus, strResource, strLocation, expertiseMajor, expertiseMinor, skillMajor, skillMinor);
        }
            
        if(!isOnLoad) {

            objRMFilters.TRV_Role__c = strRole;
            objRMFilters.TRV_Resource_Status__c = strStatus;
            objRMFilters.TRV_Resource__c = strResource;
            objRMFilters.TRV_Resource_Location__c = strLocation;
            objRMFilters.TRV_Expertise_Major__c = expertiseMajor;
            objRMFilters.TRV_Expertise_Minor__c = expertiseMinor;
            objRMFilters.TRV_Skill_Level_Major__c = skillMajor;
            objRMFilters.TRV_Skill_Level_Minor__c = skillMinor;

            upsert objRMFilters;
        }

        return lstwrapperClass;
    }
    
    //This method will return List of B4B Coaching records with no filters.
    public static List<WrapperClass> fetchB4BWithoutFilters(){
        
        List<WrapperClass> lstOfWrapper = new List<WrapperClass>();
        Set<Id> setOfResourceId = new Set<Id>();   

        for(Traver_Coaching__c taverCoaching : [    
            SELECT Id, Name, TRV_Completed_By__c, TRV_Completed_By__r.Id, Status__c, RecordType.Name, Project_Account__c, 
            Traver_Project__c, Traver_Project__r.Name, Traver_Project__r.TRV_Manager__r.Name, Traver_Project__r.TRV_Manager__c, 
            Traver_Project__r.Contact__r.Name, Number_of_Days_Traver__c,
            Traver_Project__r.Contact__c, Traver_Project__r.TRV_PSC__c, Traver_Project__r.TRV_PSC__r.Name, Traver_Project__r.TRV_EPC__c, 
            Traver_Project__r.TRV_EPC__r.Name, TRV_Completed_By__r.TRV_Resource__r.Name, TRV_Completed_By__r.TRV_Location_City__c,
            TRV_Completed_By__r.TRV_Location_State__c, Visit_Start_Date__c, TRV_Number_Of_Days_NonBillable__c, Number_of_Days_PSG__c,
            Traver_Project__r.Account__r.BillingCity, Traver_Project__r.Account__r.BillingState, Delivery_Location__c,
            Delivery_Location__r.BillingCity, Delivery_Location__r.BillingState, TRV_Completed_By__r.TRV_Termination_Date__c,
            RecordType.DeveloperName
            FROM Traver_Coaching__c 
            WHERE TRV_Completed_By__c != null 
            AND Status__c NOT IN ('Cancelled', 'Pushed')
            AND TRV_Completed_By__r.TRV_Status__c NOT IN ('Terminated')
            order by TRV_Completed_By__r.TRV_Resource__r.Name ASC
        ]){

            setOfResourceId.add(taverCoaching.TRV_Completed_By__c);
            lstOfWrapper.add(new WrapperClass(taverCoaching, taverCoaching.TRV_Completed_By__r, 
                                mapOfPicklistToColorValue.containsKey(taverCoaching.Status__c) ? mapOfPicklistToColorValue.get(taverCoaching.Status__c) : ''));
        }
        
        String resourceQuery =  ' Select Id, Name, TRV_Resource__c, TRV_Resource__r.Name, TRV_Location_City__c, TRV_Location_State__c ' +
                                ' FROM TRV_Resource__c WHERE Id NOT IN: setOfResourceId AND TRV_Resource__c != null AND ' +
                                ' TRV_Status__c NOT IN (\'Terminated\') order by TRV_Resource__r.Name ASC ';

        for(TRV_Resource__c objResource : Database.query(resourceQuery)) {

            lstOfWrapper.add(new WrapperClass(new Traver_Coaching__c(), objResource, ''));
        }
            
        return lstOfWrapper;
    }
    
    //This method will return List of B4B Coaching records based on filters selected on the RM page.
    public static List<WrapperClass> fetchB4BWithFilters(String strRole, String strStatus, String strResource, String strLocation, String expertiseMajor, String expertiseMinor, String skillMajor, String skillMinor){
        
        Set<String> setOfSkillMajorSet = new Set<String>();
        Set<String> setOfSkillMinorSet = new Set<String>();
        String strFilterQuery = '';
        String strResourceFilterQuery = '';
        
        if(String.isNotBlank(skillMajor) && mapOfSkillLevelToValues.containsKey(Integer.valueOf(skillMajor))){

            setOfSkillMajorSet = mapOfSkillLevelToValues.get(Integer.valueOf(skillMajor));
        }

        if(String.isNotBlank(skillMinor) && mapOfSkillLevelToValues.containsKey(Integer.valueOf(skillMinor))){

            setOfSkillMinorSet = mapOfSkillLevelToValues.get(Integer.valueOf(skillMinor));
        }

        strFilterQuery += String.isBlank(expertiseMajor) ? '' : 'AND TRV_Expertise_Major__c =: expertiseMajor ';
        strFilterQuery += String.isBlank(expertiseMinor) ? '' : 'AND TRV_Expertise_Minor__c =: expertiseMinor ';

        strResourceFilterQuery += String.isBlank(strRole) ? '' : 'AND TRV_Role__c =: strRole ';
        strResourceFilterQuery += String.isBlank(strStatus) ? 'AND TRV_Status__c NOT IN (\'Terminated\')' : 'AND TRV_Status__c =: strStatus ';
        strResourceFilterQuery += String.isBlank(strResource) ? '' : 'AND Id =: strResource ';
        strResourceFilterQuery += String.isBlank(strLocation) ? '' : 'AND TRV_Region__c =: strLocation ';

        if(String.isNotBlank(skillMajor)) {

            strFilterQuery += 'AND TRV_Skill_Level_Major__c' + (mapOfSkillLevelToValues.containsKey(Integer.valueOf(skillMajor)) ? ' IN: setOfSkillMajorSet ' : ' =: skillMajor ');
        }
        
        if(String.isNotBlank(skillMinor)) {

            strFilterQuery += 'AND TRV_Skill_Level_Minor__c' + (mapOfSkillLevelToValues.containsKey(Integer.valueOf(skillMinor)) ? ' IN: setOfSkillMinorSet ' : ' =: skillMinor ');
        }

        String strFinalQuery = ' Select Id, Name, TRV_Resource__c, TRV_Resource__r.Name, TRV_Location_City__c, TRV_Location_State__c ' + 
                                (strFilterQuery != '' ? ' , ( SELECT Id FROM Resource_Skillsets__r WHERE TRV_Resource__c != null ' + strFilterQuery + ')' : '') + 
                               ' FROM TRV_Resource__c WHERE TRV_Resource__c != null ' + strResourceFilterQuery + 'order by TRV_Resource__r.Name ASC';

        Set<Id> setOfResourceId = new Set<Id>();
        List<WrapperClass> lstOfWrapper = new List<WrapperClass>();

        for(TRV_Resource__c objResource : Database.query(strFinalQuery)) {

            if(String.isNotBlank(strFilterQuery)){
                if(!objResource.Resource_Skillsets__r.isEmpty()){
                    setOfResourceId.add(objResource.Id);
                    lstOfWrapper.add(new WrapperClass(new Traver_Coaching__c(), objResource, ''));
                }
            }
            else{
               setOfResourceId.add(objResource.Id); 
               lstOfWrapper.add(new WrapperClass(new Traver_Coaching__c(), objResource, ''));
            }
        }
        
        for(Traver_Coaching__c taverCoaching : [    
            SELECT Id, Name, TRV_Completed_By__c, TRV_Completed_By__r.Id, Status__c, RecordType.Name, Project_Account__c, Traver_Project__c, 
            Traver_Project__r.Name, Traver_Project__r.TRV_Manager__r.Name, Traver_Project__r.TRV_Manager__c, 
            Traver_Project__r.Contact__r.Name, Number_of_Days_Traver__c, Traver_Project__r.Contact__c, 
            Traver_Project__r.TRV_PSC__c, Traver_Project__r.TRV_PSC__r.Name, Traver_Project__r.TRV_EPC__c, 
            Traver_Project__r.TRV_EPC__r.Name, TRV_Completed_By__r.TRV_Resource__r.Name, TRV_Completed_By__r.TRV_Location_City__c,
            TRV_Completed_By__r.TRV_Location_State__c, Visit_Start_Date__c, TRV_Number_Of_Days_NonBillable__c, Number_of_Days_PSG__c,
            Traver_Project__r.Account__r.BillingCity, Traver_Project__r.Account__r.BillingState, Delivery_Location__c,
            Delivery_Location__r.BillingCity, Delivery_Location__r.BillingState, TRV_Completed_By__r.TRV_Termination_Date__c,
            RecordType.DeveloperName
            FROM Traver_Coaching__c
            WHERE TRV_Completed_By__c != null
            AND TRV_Completed_By__c IN: setOfResourceId
            AND Status__c NOT IN ('Cancelled', 'Pushed')
            order by TRV_Completed_By__r.TRV_Resource__r.Name ASC
        ]){
                                                    
            lstOfWrapper.add(new WrapperClass(taverCoaching, taverCoaching.TRV_Completed_By__r, 
                                mapOfPicklistToColorValue.containsKey(taverCoaching.Status__c) ? mapOfPicklistToColorValue.get(taverCoaching.Status__c) : ''));
        }
        
        return lstOfWrapper;
    }
    
    //This method will update existing B4B record if user Drag and drop a B4B on RM Page.
    @RemoteAction
    public static Boolean updateB4BCoachingRecord(String b4bCoachingId, String resourceId, String visitStartDate){
        
        try{
            List<Traver_Coaching__c> lstOfB4BCoaching = [   
                SELECT Id, TRV_Completed_By__c, Visit_Start_Date__c 
                FROM Traver_Coaching__c 
                WHERE Id =: b4bCoachingId
            ]; 
            
            Date dt = Date.valueOf(visitStartDate);
            
            if(!lstOfB4BCoaching.isEmpty()){

                lstOfB4BCoaching[0].Visit_Start_Date__c = dt;
                lstOfB4BCoaching[0].TRV_Completed_By__c = resourceId;
                update lstOfB4BCoaching;
            }
        }
        catch(DMLException ex){
            return false;
        }
        
        return true;
    }
    
    //This method will fetch Picklist Value of Role
    public List<SelectOption> getSkillsetRole() {

        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> lstPicklistEntry = TRV_Resource__c.TRV_Role__c.getDescribe().getPicklistValues();
        
        options.add(new SelectOption('', 'None'));

        for(Schema.PicklistEntry picklistEntry : lstPicklistEntry) {

            options.add(new SelectOption(picklistEntry.getLabel(), picklistEntry.getValue()));
        }      

        return options; 
    }
    
    //This method will fetch Picklist Value of Status
    public List<SelectOption> getStatus() {

        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> lstPicklistEntry = TRV_Resource__c.TRV_Status__c.getDescribe().getPicklistValues();

        options.add(new SelectOption('', 'None'));     

        for(Schema.PicklistEntry picklistEntry : lstPicklistEntry) {

            options.add(new SelectOption(picklistEntry.getLabel(), picklistEntry.getValue()));
        }       
        return options;
    }
    
    //This method will fetch Picklist Value of Location
    public List<SelectOption> getLocation() {

        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> lstPicklistEntry = TRV_Resource__c.TRV_Region__c.getDescribe().getPicklistValues();

        options.add(new SelectOption('', 'None'));

        for( Schema.PicklistEntry picklistEntry : lstPicklistEntry) {

            options.add(new SelectOption(picklistEntry.getLabel(), picklistEntry.getValue()));
        }    
        return options;
    }
    
    //This method will re-initialize all the variables declared.
    public void resetFilters() {

        strSelectedRole = '';
        strSelectedStatus = '';
        strSelectedResource = '';
        strSelectedLocation = '';
        lstwrapperClass = new list<WrapperClass>();
        objSkillSetForFilters = new TRV_Skillset__c();
        
        if(TRV_Resource_Management_Filters__c.getInstance().Id != null) {

            delete TRV_Resource_Management_Filters__c.getInstance(); 
        }
    }
}