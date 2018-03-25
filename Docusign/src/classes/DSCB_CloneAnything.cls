/* 
 * 2014-10-07 MK QueryDestinationRecordsInHierarchy Updated 
 *   Only ignore source Account if Type is Account, 
 *     otherwise include records related to source
 * 
    // delete all cases created
    List<sObject> cases = [
        Select Id, CaseNumber
        From Case 
        Where CreatedBy.Name = 'Matt Keefe'
        And CreatedDate > :datetime.now().addDays(-1)];
    //system.debug(cases);
    delete cases;
    
    // delete all Recaps created
    List<sObject> objs = [
        Select Id, Name 
        From Recap__c 
        Where CreatedDate > YESTERDAY 
        And CreatedBy.Name = 'Matt Keefe'];
    //system.debug(objs);
    delete objs;
 * 05977368 - case for testing SEO cases mass clone
 */

global /*with sharing*/ class DSCB_CloneAnything //commented out with sharing when a user with name Hillary Knutzen reported insufficient
                                                 //access error. 3/26/2015 SivaP
{
    public String sType {get;set;}
    public String sId {get;set;}
    public String sSubType {get;set;}
    public String sSelectedTypeAndSubtype {get;set;}
    public Clone_Records_Settings__c sObjectCloneSettings {get;set;}
    public List<SelectOption> SourceObjectTypes {get;set;}
    public String AutocompleteFields {get;set;}
    public sObject SourceRecord {get;set;}
    public List<String> SourceDisplayFields {get;set;}
    public List<sObject> DestinationObjects {get;set;}
    public String DestinationDisplayFields {get;set;}
    public Map<String,sObject> Clones {get;set;}
    public String SourceIdString {get;set;}
    public String DestinationIdsString {get;set;}
    public String SobjectCloneStettingsNameField {get;set;} //   added for addressing link issues with sObjects with no Name field like Case and Task
    public static Boolean DisplayAsOutputFields {get;set;} // RecentChanges    
    public List<string> DestinationFieldsList {get;set;}
    public List<string> REFERENCEfieldsList {get;set;}
    public List<string> AUTONUMBERfieldsList {get;set;}
    public List<string> DATEfieldsList {get;set;}
    public List<string> FilteredSourceDisplayFields {get;set;}
    public boolean isOverrideCloning {get;set;}
    public static boolean InsertFromMassCloneApp = false;
    
      
    // constructor
    public DSCB_CloneAnything() {
        Init(); 
    }
    
    public void UpdateParameter() { system.debug(SourceRecord); }
   
    public void Init() 
    {
        // initialize DisplayAsOutputFields to true
        DisplayAsOutputFields = true;
        isOverrideCloning = false;
               
        // get the page parameters
        sType = ApexPages.currentPage().getParameters().get('sourcetype');
        sId = ApexPages.currentPage().getParameters().get('sourceid');
        sSubType = ApexPages.currentPage().getParameters().get('subtype');
        
        system.debug(sType);
       
        // get the current sObjectCloneSettings from the Query String
        List<Clone_Records_Settings__c> CloneSettings = DSCB_CloneAnything.GetAllSObjectCloneSettingsList();
        Clone_Records_Settings__c sObjectCloneSettings = DSCB_CloneAnything.GetCurrentSObjectCloneSettings(sType, sSubType, CloneSettings);
        
        system.debug(sObjectCloneSettings);      
        
        Map<String, Clone_Profile_Access__c> AllProfileAccessSettings = Clone_Profile_Access__c.getAll();
        Clone_Profile_Access__c CurrentProfileAccess = AllProfileAccessSettings.get(UserInfo.getProfileId());
        
        // set and sort the sObject Type select options
        CloneSettings.sort(); // sort the CloneSettings instead of the SourceObjectTypes because the CloneSettings sort by Name
        SourceObjectTypes = new List<SelectOption> ();
        
        system.debug(CurrentProfileAccess);
        
        
        for (Clone_Records_Settings__c crs : CloneSettings) 
        {
            if(CurrentProfileAccess != null && crs != null)
            {
                Boolean CloneAccess = false;
                
                if(crs.Clone_Profile_Access_Permission_Field__c != null) 
                {
                    try { CloneAccess = (Boolean) CurrentProfileAccess.get(crs.Clone_Profile_Access_Permission_Field__c); }
                    catch(Exception e) { system.debug(e); }
                }
                else if(crs.sObject_API_Name__c == sType && crs.SubType__c == sSubType) 
                {
                    CloneAccess = true; 
                }
                
                if(CurrentProfileAccess != null && CloneAccess == true && !crs.Unsearchable__c)
                {
                    SourceObjectTypes.add(new SelectOption(crs.Id, crs.Name));
                }
            }
        }
               
        // validate sId and sType
        if (sId == null || sType == null) { //system.debug(sId); system.debug(sType);
            DisplayPageWarning('Please select a Source Object and Source Object Type to continue. ');
            return;
        }
        
        // validate clone settings, display error if the selected type does not have settings
        if (sObjectCloneSettings == null) {
            DisplayPageWarning('Invalid sObject Type.');
            return;
        }
        
        //  added for addressing link issues with sObjects with no Name field like Case and Task
        SobjectCloneStettingsNameField = sObjectCloneSettings.Source_Name_Field__c; 
        
        // debug clone settings
        //system.debug('sObjectCloneSettings---'+sObjectCloneSettings);
        
        // set the autocomplete fields and the source display fields
        AutocompleteFields = sObjectCloneSettings.Source_Autocomplete_Fields__c;
        SourceDisplayFields = sObjectCloneSettings.Source_Display_Fields__c.split(',');
        
        String SourceRelationshipToDestination = sObjectCloneSettings.Source_Relationship_to_Destination__c;
        
        String QueryFields = null;
        if (sObjectCloneSettings.Source_Display_Fields__c != null) 
        {
            QueryFields = sObjectCloneSettings.Source_Display_Fields__c;
            
            if (SourceRelationshipToDestination != null &&
                !QueryFields.toLowerCase().contains(SourceRelationshipToDestination.toLowerCase())) 
            {
                QueryFields += ',' + SourceRelationshipToDestination; 
            }
        }
        system.debug(QueryFields);
        // query for the object to clone
        SourceRecord = DSCB_CloneAnything.QuerySourceRecord(QueryFields, sType, sId);
        
        DestinationFieldsList = sObjectCloneSettings.Source_Display_Fields__c.split(',');      
               
        system.debug(SourceRecord);
        
        //sObject RelationshipRecord;
        // getting Destination record from SourceRecord
        //if(sObjectCloneSettings.destination_sObject_Relationship_Field__c != null) { 
            //RelationshipRecord = SourceRecord.getSobject(sObjectCloneSettings.destination_sObject_Relationship_Field__c); } // added 12/10/2014 SivaP
        
        // if the source record was not found, display an error
        if (SourceRecord == null) 
        {
            DisplayPageWarning('Could not find the sObject specified. ');
            return;
        }
        
        // if one of the fields is an error, do not display and display an error instead
        for(Integer i = 0; i<SourceDisplayFields.size(); i++) 
        {
            if(SourceDisplayFields[i].contains('.') && SourceDisplayFields[i].contains('__r')) 
            {
                object o = ALL_UtilitiesData.GetDataFromNestedFields(SourceDisplayFields[i], SourceRecord);
                
                if(o == null) 
                {
                    String ErrorField = SourceDisplayFields.remove(i); 
                    
                    DisplayPageWarning('Field: \'' + ErrorField + '\' referenced a blank object and could not be displayed. ');
                    return; 
                } 
            }
        }
        
        // get the destination objects
        String aid = ApexPages.currentPage().getParameters().get('aid');
        DestinationObjects = new List<sObject> ();
        
        // 2014-10-09 MK need to get the destination field from the source record to determine 
        //   the originating parent then the originating parent must be excluded from the 
        //   queried destination records
        String SourceRecordDestinationField = null;
        system.debug(SourceRecord);
        
        if (aid != null) 
        {
            DestinationDisplayFields = sObjectCloneSettings.Destination_Display_Fields__c;
            
            if(SourceRelationshipToDestination != null) //sourceRecord query could include Account_Plan__c.Secondary_Owner__r.Name, 
                                                        //Account_Plan__c.Additional_Resource__r.Name     added SivaP
            {
                try {
                    SourceRecordDestinationField = String.valueOf(SourceRecord.get(SourceRelationshipToDestination));
                } 
                catch(Exception e) { System.debug(e); }
            }
            
            system.debug(SourceRecordDestinationField);
            system.debug(aid);
            system.debug(DestinationDisplayFields);
            system.debug(sObjectCloneSettings);
            
            //system.debug(SourceRecord.getsObject('account_Plan__r'));
            system.debug(SourceRelationshipToDestination);
            
            DestinationObjects =
                DSCB_CloneAnything.QueryDestinationRecordsInHierarchy(
                    SourceRecordDestinationField, aid,
                    DestinationDisplayFields,
                    sObjectCloneSettings);
            
            system.debug(LOGGINGLEVEL.WARN, DestinationObjects);
            if(DestinationObjects == null || DestinationObjects.isEmpty())
            {
                DisplayPageWarning('Destination Accounts were not found. Check access to the Account Hierarchy. ');
                return; 
            }
        }
        
        
        // check the sourceRecord field types below
        Schema.DisplayType DisplayType;
        Boolean isAutoNumber = false;
        
        REFERENCEfieldsList = new List<string>();
        AUTONUMBERfieldsList = new List<string>();
        DATEfieldsList = new List<string>();
        Map<string, Schema.SObjectField> FieldMap = Schema.getGlobalDescribe().get(sType).getDescribe().fields.getMap();
        
        
        for(string field: SourceDisplayFields)
        {            
            if(FieldMap.keySet().contains(field.toLowerCase())) 
            { 
                DisplayType = Schema.getGlobalDescribe().get(sType).getDescribe().fields.getMap().get(field).getDescribe().getType();
                isAutoNumber = Schema.getGlobalDescribe().get(sType).getDescribe().fields.getMap().get(field).getDescribe().isAutoNumber();
            }
                  
            if(DisplayType != null && DisplayType == Schema.DisplayType.REFERENCE){ REFERENCEfieldsList.add(field);}
            
            if(DisplayType != null && DisplayType == Schema.DisplayType.DATE){ DATEfieldsList.add(field);}
            
            if(isAutoNumber){ AUTONUMBERfieldsList.add(field);} 
        }
        system.debug(REFERENCEfieldsList); 
        
        
        FilteredSourceDisplayFields = new List<string>();
        
        FilteredSourceDisplayFields = DSCB_CloneAnything.EditableFieldsListReturner(SourceDisplayFields, sType, FilteredSourceDisplayFields, sType, sSubType);
        
        system.debug(FilteredSourceDisplayFields);
        system.debug(SourceDisplayFields);
    }
    
    // action function remote method called from visualforce page   
    Public void setDisplayAsOutputFieldsToFalse()
    {          
        DisplayAsOutputFields = false;
        isOverrideCloning = true;
    } 
    
    // SivaP 01/15/2015 below method would help us to exclude fields that are not preferably edited in the visualforce page, all that logic relating to 
    // those fields can be added in this method in the future, depending on the future requirements. 
    public static List<string> EditableFieldsListReturner(
        List<string> SourceDisplayFields, string sType, List<string> FilteredSourceDisplayFields, 
        string SourceTypeName, string sSubType)
    {
        List<Clone_Records_Override_Settings__c> AllOverrideSettings = Clone_Records_Override_Settings__c.getAll().values();
        
        set<string> OverrideReplacementFields = new set<string>();
        
        for (Integer i = 0; i < AllOverrideSettings.size(); i++) 
        {
            if (AllOverrideSettings[i].sObject_API_Name__c == SourceTypeName 
            && (AllOverrideSettings[i].SubType__c == null || AllOverrideSettings[i].SubType__c == sSubType))
            {
                OverrideReplacementFields.add(AllOverrideSettings[i].Replacement_Field_API_Name__c);
            }
        }
        
        for(integer i=0; i<SourceDisplayFields.size(); i++)
        {
            system.debug(SourceDisplayFields[i]);
            schema.DescribeFieldResult ScDescription;        
            
            if(!SourceDisplayFields[i].contains('.'))
            {
                if(sType != null)
                {
                    Schema.SObjectType SchemaSType = Schema.getGlobalDescribe().get(sType);
                    if(SchemaSType != null)
                    {
                        // check SchemaSType for null
                        Schema.SObjectField SourceDisplayField = SchemaSType.getDescribe().fields.getMap().get(SourceDisplayFields[i]);
                        
                        // ScDescription = SchemaSType.getDescribe().fields.getMap().get(SourceDisplayFields[i]).getDescribe();
                        if(SourceDisplayField != null)
                        {
                            ScDescription = SourceDisplayField.getDescribe();
                            
                            boolean isThisFilterField = false; 
                            
                            if(ScDescription.getFilteredLookupInfo() != null)
                            {
                                isThisFilterField = 
                                    Schema.getGlobalDescribe().get(sType).getDescribe().fields.getMap() //stype check for null
                                    .get(SourceDisplayFields[i]).getDescribe().getFilteredLookupInfo().isDependent(); //also check for null sourcedisplayfiled
                                system.debug(SourceDisplayFields[i] + ' is filtered Field : ' + isThisFilterField);
                            }
                            
                            if(!isThisFilterField && !OverrideReplacementFields.contains(SourceDisplayFields[i]))
                            {
                                FilteredSourceDisplayFields.add(SourceDisplayFields[i]);
                            }
                        }
                    }
                }
            }
        }
        system.debug(FilteredSourceDisplayFields);
        
        return FilteredSourceDisplayFields;
    }
    
    Public void setDisplayAsOutputFieldsToTrue()
    {          
        DisplayAsOutputFields = true;   
    }    
    
    public static sObject QuerySourceRecord(String QueryFields, String sObjectType, String sObjectId) 
    {
        sObject sr = null;
        List<sObject> srs = new List<sObject> ();
        
        // query for the object to clone
        String SourceQuery = 'Select '
             + (!(QueryFields.containsIgnoreCase('id,') || QueryFields.containsIgnoreCase('id ')) ? 'Id,' : '')
             + QueryFields + ' From ' + sObjectType + ' Where Id = \'' + sObjectId + '\' Limit 1';
        
        system.debug(SourceQuery);
        
        try {
            //system.debug(LOGGINGLEVEL.WARN, SourceQuery);
            srs = Database.query(SourceQuery);
        } 
        catch (Exception e) {
            system.debug(LOGGINGLEVEL.ERROR, e); 
            return null;
        }
        
        sr = ( (srs != null && srs.size() > 0) ? srs[0] : null );
        
        //system.debug(sr);
        return sr;
    }
    
    public static List<sObject> QueryDestinationRecordsInHierarchy(String SourceRelationshipToDestination,
        String TopAccountIdString, String DestinationQueryFields, Clone_Records_Settings__c sObjectCloneSettings) 
    {
        String DestinationSObjectAPIName = sObjectCloneSettings.Destination_sObject_API_Name__c;
        String DestinationAccountField = sObjectCloneSettings.Destination_sObject_Account_Field__c;
        String DestinationConditions = sObjectCloneSettings.Destination_Conditions__c;
        
        List<sObject> DestinationRecords = new List<sObject> ();
        List<sObject> sObjectsInHierarchy;
        
        // try to convert Id provided
        Id AccountId = null;
        try { AccountId = TopAccountIdString; } catch (Exception e) {}
        
        if (AccountId != null) 
        {
            // new Set for getting Children AccountIds
            // to do: check if AccountId is blank; if so, display error
            Id TopAccountId = AccountHierarchyTools.TopParentAccountId(AccountId);
            
            system.debug(TopAccountId);
            
            Set<Id> TIDs = new Set<Id> ();
            TIDs.add(TopAccountId);
            
            // convert result Set to a List for querying
            List<Id> AllHierarchyAccountIds = new List<Id> ();
            AllHierarchyAccountIds.addAll(AccountHierarchyTools.ChildrenAccountIds(TIDs));
            
            // put together the conditions for querying
            String AccountConditions = '';
            if (AllHierarchyAccountIds.size() > 0) {
                AccountConditions += '(' + ALL_UtilitiesString.ListToCSV(AllHierarchyAccountIds) + ')'; } 
            else { 
                AccountConditions += '(\'' + AccountId + '\')'; }
            
            String DestinationQuery = 'Select '
                + (!(DestinationQueryFields.containsIgnoreCase('id,') || DestinationQueryFields.containsIgnoreCase('id ')) ? 'Id,' : '')
                + DestinationQueryFields + ' From ' + DestinationSObjectAPIName;
            
            String ExcludeSourceAccountIfApplicable = '';
            if(DestinationSObjectAPIName == 'Account') { // 2014-10-07 MK exclude Source Account
                ExcludeSourceAccountIfApplicable += ' And ' + DestinationAccountField + ' != \'' + String.valueOf(AccountId) + '\' '; }
            
            String ExcludeSourceDestinationRecord = '';
            if(SourceRelationshipToDestination != null) { // 2014-10-09 MK exclude Source Destination Parent
                ExcludeSourceDestinationRecord += ' And Id != \'' + String.valueOf(SourceRelationshipToDestination) + '\' '; }
            
            system.debug(SourceRelationshipToDestination);
           
            // this is for case - account plan mass clone
            /* string CurrentUserID = userInfo.getUserID();//'005M0000005stlS'; //userInfo.getUserID();
            if (!string.isEmpty(DestinationConditions) && 
                DestinationConditions.contains(
                   '(OwnerId = userInfo.getUserID() OR Secondary_Owner__c = userInfo.getUserID() OR Additional_Resource__c = userInfo.getUserID())'))
            { 
                DestinationConditions = '(OwnerId = :CurrentUserID OR Secondary_Owner__c = :CurrentUserID OR Additional_Resource__c = :CurrentUserID)'; 
            }*/
            
            // add account hierarchy conditions only if  Evaluate_Account_Hierarchy__c field is checked in the custom settings
            // currently this applies to all the mass cloning settings except Case (Account Plan). 
            //if  Evaluate_Account_Hierarchy__c field is not checked then Destinationconditions should not be null in the custom settings.
            
            if(sObjectCloneSettings.Evaluate_Account_Hierarchy__c) 
            {
                // add conditions to query
                DestinationQuery += ' Where ' + DestinationAccountField + ' IN ' + AccountConditions 
                    + ExcludeSourceAccountIfApplicable + ExcludeSourceDestinationRecord
                    + (DestinationConditions != null ? ' AND ' + DestinationConditions : '');
            }
            else
            {
                 string conditions = DSCB_CloneAnything.QueryConstructorConditionsPackage(sObjectCloneSettings); 
                
                 //DestinationQuery += (DestinationConditions != null ? ' WHERE ' + DestinationConditions : '');
                 DestinationQuery += (DestinationConditions != null ? ' WHERE ' + conditions : '');
            }
            
            system.debug(DestinationQuery);
                        
            // get all sObjects in the hierarchy
            //system.debug(LOGGINGLEVEL.WARN, DestinationQuery);
            sObjectsInHierarchy = new List<sObject> ((List<sObject>)Database.query(DestinationQuery));
            
            system.debug(sObjectsInHierarchy);
            
            for (sObject s : sObjectsInHierarchy) { // 2014-10-07 MK exclude Source Account (if Destination SObject Type is Account)
                if (s.get(DestinationAccountField) != AccountId || DestinationSObjectAPIName != 'Account') { 
                    DestinationRecords.add(s);
                }
            }
        }
        
        return DestinationRecords;
    }
    
    // autocomplete search result
    global class SearchSObjectsResult 
    {
        global List<String> Fields;
        global String AccountField;
        global List<sObject> sObjects;
        
        global SearchSObjectsResult() {
            Fields = new List<String> ();
            AccountField = null;
            sObjects = new List<sObject> ();
        }
        
        global SearchSObjectsResult(List<String> f, String aid) {
            Fields = f;
            AccountField = aid;
            sObjects = new List<sObject> ();
        }
        
        global SearchSObjectsResult(List<String> f, String aid, List<sObject> r) {
            Fields = f;
            AccountField = aid;
            sObjects = r;
        }
    }
    
    @RemoteAction
    global static Map<Id, Clone_Records_Settings__c> GetAllSObjectCloneSettingsMap()
    {
        Map<Id, Clone_Records_Settings__c> CloneSettingsMap = new Map<Id, Clone_Records_Settings__c>();
        
        List<Clone_Records_Settings__c> AllCloneSettings = Clone_Records_Settings__c.getAll().values();
        for(Clone_Records_Settings__c CloneSettings : AllCloneSettings) { 
            CloneSettingsMap.put(CloneSettings.Id, CloneSettings); 
        }
        
        return CloneSettingsMap;
    }
    
    @RemoteAction
    global static List<Clone_Records_Settings__c> GetAllSObjectCloneSettingsList()
    {
        Map<Id, Clone_Records_Settings__c> CloneSettingsMap = DSCB_CloneAnything.GetAllSObjectCloneSettingsMap();
        return (CloneSettingsMap != null && !CloneSettingsMap.IsEmpty()) ? CloneSettingsMap.values() : null;
    }
    
    @RemoteAction
    global static Clone_Records_Settings__c GetCurrentSObjectCloneSettings(String sType, String sSubType, List<Clone_Records_Settings__c> CloneSettings)
    {
        // get Clone Settings
        if(CloneSettings == null) 
        {
            Map<Id, Clone_Records_Settings__c> CloneSettingsMap = DSCB_CloneAnything.GetAllSObjectCloneSettingsMap();
            CloneSettings = (CloneSettingsMap != null && !CloneSettingsMap.IsEmpty()) ? CloneSettingsMap.values() : null;
        }
        
        Clone_Records_Settings__c sObjectCloneSettings = null;
        
        for(Clone_Records_Settings__c CloneSetting : CloneSettings) 
        {                         
            if(CloneSetting.SubType__c == null && CloneSetting.sObject_API_Name__c.toLowerCase() == sType) 
            { 
                sObjectCloneSettings = CloneSetting; 
            }
            else 
            {
                if(CloneSetting.SubType__c == sSubType && CloneSetting.sObject_API_Name__c.toLowerCase() == sType)
                {
                    sObjectCloneSettings = CloneSetting; 
                }
            }
        }
        
        return sObjectCloneSettings;
    }
    
    global Class SearchSObjectsParameters
    {
        global String sObjectType {get;set;}
        global String sSubType {get;set;}
        global String SearchTerm {get;set;}
        global String SourceIdString {get;set;}
        global List<String> DestinationIdsList {get;set;}
        global Map<String, sObject> Clones {get;set;}
        global SObject SourceSObject {get;set;}
        global string SourceRecord {get;set;}       
        global sObject SourceRecordUpdate {get;set;}
        global Map<string, string> LookUpFieldMap {get;set;}
        global boolean DisplayAsOutPutFields2 {get;set;}
    }
    
    @RemoteAction
    global static SearchSObjectsResult SearchSObjectsWithSubType(SearchSObjectsParameters Parameters) 
    {
        List<Clone_Records_Settings__c> CloneSettings = Clone_Records_Settings__c.getAll().values();
        Clone_Records_Settings__c sObjectCloneSettings = null;
        
        for(Clone_Records_Settings__c CloneSetting : CloneSettings) { 
            if(Parameters.sSubType == null && Parameters.sObjectType != null && cloneSetting.SubType__c == null 
            && CloneSetting.sObject_API_Name__c == Parameters.sObjectType)
            { 
                sObjectCloneSettings = CloneSetting; 
            }
            
            if(Parameters.sSubType != null && Parameters.sObjectType != null && cloneSetting.SubType__c == Parameters.sSubType 
            && CloneSetting.sObject_API_Name__c == Parameters.sObjectType)
            {
                sObjectCloneSettings = CloneSetting;
            }
        }
        
        if (sObjectCloneSettings == null) {
            return new SearchSObjectsResult();
        } 
        
        String DisplayFields = sObjectCloneSettings.Source_Autocomplete_Fields__c;
        String SearchFields = sObjectCloneSettings.Source_Autocomplete_Search_Fields__c;
        String AccountField = sObjectCloneSettings.Source_Autocomplete_Account_Field__c;
        String SearchConditions = sObjectCloneSettings.Source_Autocomplete_Conditions__c;
        
        List<sObject> SearchList = new List<sObject> ();
        
        if (Parameters.SearchTerm != null && SearchFields != null) {
            if (SearchFields != null) {
                if (!SearchFields.contains('Id')) {
                    SearchFields += ',Id';
                }
                if (!SearchFields.contains(AccountField)) {
                    SearchFields += ',' + AccountField;
                }
            }
            
            if (Parameters.SearchTerm.length() > 0) 
            {
                String SearchQuery = 'FIND \'' + Parameters.SearchTerm + '\' RETURNING ' + Parameters.sObjectType + ' (' + SearchFields
                     + (SearchConditions != null ? ' Where ' + SearchConditions : '') + ')';
                
                List < List<sObject>> SoslSearchList = search.query(SearchQuery);
                
                if (SoslSearchList != null) {
                    SearchList = (SoslSearchList[0] != null ? SoslSearchList[0] : null);
                }
            } 
            else 
            {
                String query = 'Select ' + SearchFields + ' From ' + Parameters.sObjectType;
                
                SearchList = database.query(query);
            }
        }
        
        return new SearchSObjectsResult(DisplayFields.split(','), AccountField, SearchList);
    }
    
    global class CloneDisplaySettings 
    {
        public String sObjectType;
        public String sSubType;
        public String DisplayFieldsString;
        public Map<String,Clone_Display_Field_Settings__c> DisplayFieldsByAPIName;
        
        public CloneDisplaySettings(String sObjectType, String sSubType) 
        {
            this.DisplayFieldsString = '';
            this.sObjectType = sObjectType;
            this.sSubType = sSubType;
            
            // get Clone Display Field custom settings
            List<Clone_Display_Field_Settings__c> AllCloneDisplayFields = Clone_Display_Field_Settings__c.getAll().values();
            AllCloneDisplayFields.sort();
            
            this.DisplayFieldsByAPIName = new Map<String,Clone_Display_Field_Settings__c> ();
            
            // put together the Source Record Query
            for (Clone_Display_Field_Settings__c CloneDisplayField : AllCloneDisplayFields) 
            {
                // get all Clone Display Field settings that match the current sObject Type
                if (CloneDisplayField.sObject_API_Name__c == sObjectType //&& CloneDisplayField.SubType__c == sSubType)
                && (CloneDisplayField.SubType__c == null || CloneDisplayField.SubType__c == sSubType)) 
                {
                    // if the Display Fields Map already contains the Clone Display Field, do not add it
                    //   but if it does not have it, add it
                    if (this.DisplayFieldsByAPIName.keyset().contains(CloneDisplayField.Field_API_Name__c)) { continue; } 
                    else { AddCloneDisplayField(CloneDisplayField); }
                }
            }
            
            if (!DisplayFieldsString.toLowerCase().contains('id')) {
                DisplayFieldsString = 'Id,' + DisplayFieldsString;
            }
        }
        
        public void AddCloneDisplayField(Clone_Display_Field_Settings__c CloneDisplayField) 
        {
            if(!this.DisplayFieldsString.contains(CloneDisplayField.Field_API_Name__c.toLowerCase()))
            {
                this.DisplayFieldsString += (DisplayFieldsString == '' ?
                                             CloneDisplayField.Field_API_Name__c.toLowerCase() :
                                             ',' + CloneDisplayField.Field_API_Name__c.toLowerCase()); 
            }
            
            system.debug(CloneDisplayField.Field_API_Name__c);
            if(!CloneDisplayField.Hide__c) {
                this.DisplayFieldsByAPIName.put(CloneDisplayField.Field_API_Name__c + CloneDisplayField.Id, CloneDisplayField); } //SivaP 1/24/2015 Added to see how this works
        }
    }
    
    global class CloneDisplayField 
    {
        public Map<String,String> SelectOptions;
        
        public CloneDisplayField() { SelectOptions = new Map<String,String> (); }
    }
    
    global class ClonedDisplayRecord 
    {
        public sObject Record;
        public String Destination;
        public Map<String,CloneDisplayField> Fields;
    }
    
    global class CloneResult 
    {
        public Boolean Success;
        public String Message;
        public Map<String,Clone_Display_Field_Settings__c> Columns;
        public List<DSCB_CloneAnything.ClonedDisplayRecord> Results;
        
        public CloneResult(Boolean s, String m) { Success = s; Message = m; }
    }
     
    @RemoteAction
    global static CloneResult CloneToSelected(String sObjectType, String SourceIdString, List<String> DestinationIdsList) 
    {   
        SearchSObjectsParameters Parameters = new SearchSObjectsParameters();
        parameters.sObjectType = sObjectType;
        Parameters.SourceIdString = SourceIdString;
        Parameters.DestinationIdsList = DestinationIdsList;
        
        return DSCB_Cloneanything.CloneToSelectedWithParameters(Parameters);
    } 
    
    @RemoteAction
    global static CloneResult CloneToSelectedWithParameters(SearchSObjectsParameters Parameters) 
    {
        // get Clone Settings
        List<Clone_Records_Settings__c> CloneSettings = DSCB_CloneAnything.GetAllSObjectCloneSettingsList();
        Clone_Records_Settings__c sObjectCloneSettings = DSCB_CloneAnything.GetCurrentSObjectCloneSettings(Parameters.SObjectType, Parameters.sSubType, CloneSettings);
        
        system.debug(Parameters);
        system.debug(sObjectCloneSettings);
        system.debug(Parameters.SObjectType);
        system.debug(Parameters.SourceRecord);
        system.debug(Parameters.SourceRecordUpdate);
        system.debug(Parameters.DisplayAsOutputFields2);
        
        // get override custom settings
        List<Clone_Records_Override_Settings__c> AllOverrideSettings = Clone_Records_Override_Settings__c.getAll().values();
        List<Clone_Records_Override_Settings__c> OverrideSettings = new List<Clone_Records_Override_Settings__c> ();
        
        CloneResult cr = new CloneResult(false, 'An unexpected error occurred. ');
        
        // ----- 
        
        CloneResult ValidateParametersResult
             = ValidateCloneParameters(sObjectCloneSettings, Parameters.sObjectType, Parameters.SourceIdString, Parameters.DestinationIdsList);
        
        if (!ValidateParametersResult.Success) {
            return ValidateParametersResult;
        }
        
        // convert the Source Id String to an Id
        Id SourceId = Parameters.SourceIdString;
        
        // get Source type
        Schema.sObjectType SourceType = sObjectCloner.IdToType(SourceId);
        Schema.DescribeSObjectResult DescribedSourceType = SourceType.getDescribe();
        String SourceTypeName = DescribedSourceType.getName();
        
        // ----- Put together the display settings
        
        CloneDisplaySettings DisplaySettings = new CloneDisplaySettings(SourceTypeName, Parameters.sSubType);
        System.debug('DisplaySettings---'+DisplaySettings);
        
        // put together the query fields
        String DestinationQueryFields = '';
        String SourceQueryFields = '';
        Set<String> SourceQueryFieldSet = new Set<String> ();
        
        // get all Destination Record query fields for overrides
        for (Integer i = 0; i < AllOverrideSettings.size(); i++) 
        {
            if (AllOverrideSettings[i].sObject_API_Name__c == SourceTypeName 
            && (AllOverrideSettings[i].SubType__c == null || AllOverrideSettings[i].SubType__c == Parameters.sSubType))
            {
                // only get the Override Settings for this specific object type
                OverrideSettings.add(AllOverrideSettings[i]);
                
                // put together a String of comma separated Destination Object Query Fields
                String qf = AllOverrideSettings[i].Query_Field_API_Name__c;
                if (qf != null && !DestinationQueryFields.contains(',' + qf) && !DestinationQueryFields.startsWith(qf)) 
                {
                    DestinationQueryFields += (DestinationQueryFields == '' ? qf : ',' + qf);
                }
                
                // put together a List of Source Object Replacement Fields
                String rf = AllOverrideSettings[i].Replacement_Field_API_Name__c;
                if (rf != null) 
                {
                    SourceQueryFields += (SourceQueryFields == '' ? rf : ',' + rf);
                    SourceQueryFieldSet.add(rf.toLowerCase());
                }
            }
        }
        
        if (sObjectCloneSettings.Destination_sObject_Account_Field__c != null 
        && !DestinationQueryFields.contains(',' + sObjectCloneSettings.Destination_sObject_Account_Field__c) 
        && !DestinationQueryFields.startsWith(sObjectCloneSettings.Destination_sObject_Account_Field__c)) 
        {
            DestinationQueryFields += (DestinationQueryFields != '' ? ',' : '') +
                sObjectCloneSettings.Destination_sObject_Account_Field__c; 
        }
        
        //System.debug('@--OverrideSettings--'+OverrideSettings);
        
        // ----- Query the Destination Records
        
        // put together the conditions (list of Destination IDs) for querying
        String QueryConditions = '(' + ALL_UtilitiesString.ListToCSV(Parameters.DestinationIdsList) + ')';
        Map<String,sObject> DestinationSObjects = new Map<String,sObject> ();        
        
        try 
        {
            // Destination Record query
            String drq = 'Select ' + (DestinationQueryFields.contains(',Id') || DestinationQueryFields.startsWith('Id') ? '' : 'Id,')
                 + DestinationQueryFields
                 + ' From ' + sObjectCloneSettings.Destination_sObject_API_Name__c
                 + ' Where Id IN ' + QueryConditions
                 + ((sObjectCloneSettings.Destination_Conditions__c != null && sObjectCloneSettings.Destination_Conditions__c != 'Dynamically') ?
                    ' And ' + sObjectCloneSettings.Destination_Conditions__c : '');
            
            // perform the query
            system.debug(drq);
            system.debug(DestinationQueryFields);
            DestinationSObjects = new Map<String,sObject> ((List<sObject>)Database.query(drq));
        } 
        catch (Exception e) { system.debug('Exception: '+e);
            return new CloneResult(false, 'An error occured while finding the records associated with the Destination IDs. ');
        }
        
        system.debug(DestinationSObjects);
        // validate destination objects
        if (DestinationSObjects.IsEmpty()) {
            return new CloneResult(false, 'The Destination Records could not be found. ');
        }
        
        // ----- Query Source Record
        
        String AllFields = DSCB_CloneAnything.ConcatenateFields(DisplaySettings.DisplayFieldsString, sObjectCloneSettings.Source_Display_Fields__c);
        
        system.debug(AllFields);
        system.debug(SourceTypeName);
        system.debug(Parameters.SourceIdString);
        
        
        //sObject SourceRecord = QuerySourceRecord(DisplaySettings.DisplayFieldsString, SourceTypeName, Parameters.SourceIdString);
        sObject SourceRecord = QuerySourceRecord(AllFields, SourceTypeName, Parameters.SourceIdString);
        sObject RelationshipRecord;       
       
        system.debug(SourceRecord);
        system.debug(Parameters.SourceRecordUpdate);
        if(Parameters.SourceRecordUpdate != null)
        {   
            Map<string, Schema.SObjectField> FieldMap = Schema.getGlobalDescribe().get(Parameters.sObjectType).getDescribe().fields.getMap(); 
            
            List<string> SourceDisplayFields = new List<String>();
            SourceDisplayFields = sObjectCloneSettings.Source_Display_Fields__c.split(',');

            system.debug(SourceDisplayFields);
            
            List<string> FilteredSourceDisplayFields = new List<string>();
            
            for(integer i=0; i<SourceDisplayFields.size(); i++)
            {
                system.debug(SourceDisplayFields[i]);
                schema.DescribeFieldResult ScDescription;        
                
                if(!SourceDisplayFields[i].contains('.'))
                {
                    ScDescription =  Schema.getGlobalDescribe().get(Parameters.SObjectType).getDescribe().fields.getMap()
                        .get(SourceDisplayFields[i]).getDescribe();
                    
                    boolean isThisFilterField = false; 
                    
                    if(ScDescription.getFilteredLookupInfo() != null)
                    {
                        isThisFilterField = 
                            Schema.getGlobalDescribe().get(Parameters.SObjectType).getDescribe().fields.getMap()
                            .get(SourceDisplayFields[i]).getDescribe().getFilteredLookupInfo().isDependent();
                        system.debug(SourceDisplayFields[i] + ' is filtered Field : ' + isThisFilterField);
                    }
                    
                    if(!isThisFilterField)
                    {
                        FilteredSourceDisplayFields.add(SourceDisplayFields[i]);
                    }
                }
            }
          
            system.debug(FilteredSourceDisplayFields);
            
            for(string field: FilteredSourceDisplayFields)
            {  
                Boolean isAutonumber = true;
                Boolean isUpdateable = true;
                
                if(FieldMap.keySet().Contains(field.toLowerCase()))
                {
                    isAutonumber = FieldMap.get(field).getDescribe().isAutoNumber();
                    isUpdateable = FieldMap.get(field).getDescribe().isUpdateable();
                } 
                system.debug(field);
                
                //system.debug(SourceRecord.get(field));
                //system.debug(Parameters.SourceRecordUpdate.get(field));
                
                if(FieldMap.keySet().Contains(field.toLowerCase()))
                {                    
                    if(SourceRecord.get(field) != Parameters.SourceRecordUpdate.get(field) && !isAutonumber && isUpdateable)
                    { 
                        SourceRecord.put(field, Parameters.SourceRecordUpdate.get(field));
                    }                     
                }
            }            
        }
        
        
       /* sObject SourceRecordClone = SourceRecord.Clone(true, true, true, true);
        system.debug(SourceRecordClone);
        update SourceRecordClone;
        SourceRecordClone = QuerySourceRecord(AllFields, SourceTypeName, Parameters.SourceIdString);*/
        // getting Destination record from SourceRecord
        if(sObjectCloneSettings.destination_sObject_Relationship_Field__c != null) { 
            RelationshipRecord = SourceRecord.getSobject(sObjectCloneSettings.destination_sObject_Relationship_Field__c); } // added 12/4/2014 SivaP
        
        System.debug('@--SourceRecord--'+SourceRecord);
        system.debug(RelationshipRecord);
       
        // make sure SourceRecord exists
        if (SourceRecord == null) {
            return new CloneResult(false, 'Could not find the Source Record. ');
        }
        
        // ----- Perform Overrides
        
        Map<String, sObject> Clones = new Map<String, sObject>(); // Clones to process
        Clones = DSCB_CloneAnything.PerformCloneOverrides(Clones, SourceRecord, DestinationSObjects, sObjectCloneSettings, OverrideSettings);
       
        
        system.debug(Clones);
        Map<String,ClonedDisplayRecord> cdrs = new Map<String,ClonedDisplayRecord> ();
        
        // for each cloned record
        for (String CloneIdKey : Clones.keyset()) 
        {      
            sObject Clone = Clones.get(CloneIdKey); //system.debug(Clone);
            
            // create a new Clone Display Record
            ClonedDisplayRecord cdr = new ClonedDisplayRecord();
            cdr.Record = Clone;
            cdr.Destination = CloneIdKey;
            cdr.Fields = new Map<String,CloneDisplayField> ();
            
            // create a list of fields to display
            List<CloneDisplayField> cdfs = new List<CloneDisplayField> ();
            
            cdrs.put(CloneIdKey, cdr); // add clone display record to list of records to return
        }
        
        // ----- Configure Display Fields
        
        system.debug(DisplaySettings.DisplayFieldsByAPIName.values());
        system.debug(DisplaySettings.DisplayFieldsByAPIName.keyset());
        
        system.debug(DestinationSObjects);
        
        /*cdrs = DSCB_CloneAnything.ConfigureCloneDisplayFields(
                RelationshipRecord, sObjectCloneSettings, DisplaySettings.DisplayFieldsByAPIName.values(), DestinationSObjects, cdrs);*/
        
        // ----- Clone to selected result
       
        system.debug(Parameters.DisplayAsOutputFields2);
        
        if(Parameters.DisplayAsOutputFields2 != null)
        {
            if(Parameters.DisplayAsOutputFields2) 
            {           
                for(string fieldName: DisplaySettings.DisplayFieldsByAPIName.keySet())
                {
                    Clone_Display_Field_Settings__c CurrentDisplayField = DisplaySettings.DisplayFieldsByAPIName.get(FieldName);
                    if(CurrentDisplayField != null && CurrentDisplayField.Include_In_Override_Cloning__c == false)
                    {
                        DisplaySettings.DisplayFieldsByAPIName.remove(FieldName);
                        
                    }else
                    {
                        if(CurrentDisplayField.Override_Do_Not_Display_After_Cloning__c == true)
                        {
                            DisplaySettings.DisplayFieldsByAPIName.remove(FieldName);
                        }
                    }                  
                }
                
            }else
            {           
                for(string fieldName: DisplaySettings.DisplayFieldsByAPIName.keySet())
                { 
                    Clone_Display_Field_Settings__c CurrentDisplayField = DisplaySettings.DisplayFieldsByAPIName.get(FieldName);
                    
                    if(CurrentDisplayField != null && CurrentDisplayField.Include_In_Regular_Cloning__c == false) 
                    {   
                        DisplaySettings.DisplayFieldsByAPIName.remove(FieldName);                       
                    }else
                    {
                        if(CurrentDisplayField.Regular_Do_Not_Display_After_Cloning__c == true)
                        {
                             DisplaySettings.DisplayFieldsByAPIName.remove(FieldName);
                        }
                    }                
                }                       
            }
        } 
        
        cdrs = DSCB_CloneAnything.ConfigureCloneDisplayFields(
                RelationshipRecord, sObjectCloneSettings, DisplaySettings.DisplayFieldsByAPIName.values(), DestinationSObjects, cdrs);
                 
        cr.Success = true;
        cr.Message = 'Success!';
        cr.Columns = DisplaySettings.DisplayFieldsByAPIName;
        cr.Results = cdrs.values();
        
        System.debug(cdrs.values());
        System.debug(DisplaySettings.DisplayFieldsByAPIName);        
        system.debug(cr);
        
        return cr;
    }
    
    public static CloneResult ValidateCloneParameters(Clone_Records_Settings__c sObjectCloneSettings,
        String sObjectType, String SourceIdString, List<String> DestinationIdsList) 
    {
        if (sObjectType == null) { 
            return new CloneResult(false, 'Invalid object type. '); }
        
        if (DestinationIdsList == null) { 
            return new CloneResult(false, 'Please select one or more Destionation Record IDs. '); }
        
        if (DestinationIdsList.size() < 1) {
            return new CloneResult(false, 'Please select one or more Destionation Record IDs. '); }
        
        CloneResult SourceIdStringCloneResult = ValidateSourceIdString(SourceIdString);
        if (!SourceIdStringCloneResult.Success) { return SourceIdStringCloneResult; }
        
        // trim the Destination Ids
        for (String ds : DestinationIdsList) {
            ds = ds.trim();
        }
        
        if (DestinationIdsList.IsEmpty()) {
            return new CloneResult(false, 'Please select one or more Destionation Record IDs. ');
        }
        
        // validate Destination Ids
        String prefix = '';
        if (DestinationIdsList[0].length() >= 3) {
            prefix = DestinationIdsList[0].substring(0, 3); }
        
        for (String s : DestinationIdsList) 
        {
            // if the destination Id is less than fifteen characters in length,
            //   it is not a valid Id, return null
            if (s.length() < 15) {
                return new CloneResult(false, 'Invalid Destination Record ID(s). ');
            }
            
            // if one destination Id does not match the prefix of the first, do not continue
            //   all destination Ids must be of the same type
            if (s.substring(0, 3) != prefix) {
                return new CloneResult(false, 'All Destination Record IDs must be for the same object type. ');
            }
        }
        
        // Convert (validate) all of the destination Ids
        List<Id> DestinationIds = new List<Id> ();
        try {
            for (String s : DestinationIdsList) { Id did = s; DestinationIds.add(s); } } 
        catch (Exception e) {
            return new CloneResult(false, 'Invalid Destination Record ID(s). '); }
        
        return new CloneResult(true, 'Valid. ');
    }
    
    public static CloneResult ValidateSourceIdString(String SourceIdString) 
    {
        if (SourceIdString == null) {
            return new CloneResult(false, 'Source Record ID must not be blank. ');
        }
        
        if (SourceIdString.length() < 15) {
            return new CloneResult(false, 'Invalid Source Record ID. ');
        }
        
        // trim the Source Id
        SourceIdString = SourceIdString.trim();
        
        // Convert the Source Id from a String to an Id
        Id SourceId = null;
        try { SourceId = SourceIdString; } 
        catch (Exception e) { return new CloneResult(false, 'Invalid Source Record ID. '); }
        
        return new CloneResult(true, 'Valid Source Record ID. ');
    }
    
    public static Map<String,sObject> PerformCloneOverrides(Map<String,sObject> Clones, sObject SourceRecord,
        Map<String,sObject> DestinationSObjects, Clone_Records_Settings__c sObjectCloneSettings,
        List<Clone_Records_Override_Settings__c> OverrideSettings) 
    {
        // for each selected destination sObject record
        // for(Integer i=0; i<DestinationSObjects.size(); i++)
        system.debug(Clones);
        system.debug(DestinationSObjects);
        for (String DestinationKey : DestinationSObjects.keySet()) 
        {
            sObject Destination = DestinationSObjects.get(DestinationKey);
            
            system.debug(Destination);
            
            // clone the record
            sObject SourceClone = SourceRecord.clone(false, true); 
            
            system.debug(SourceClone); 
            
            
            // create a new map with the Query sObject string name
            // for example: 'Account' => {'Id'=>'001000000123456','Name'=>'Account Name'}
            //map<String, list<String>> sObjectTypesAndFieldApiNames = new map<string, list<String>>();
            
            map<String, map<String, object>> sObjectTypesAndFieldApiNames = new map<string, map<String, object>>();
            
            for(Clone_Records_Override_Settings__c cros : OverrideSettings)
            {
                // get the FieldToValueMap from the sObject map
                map<String, Object> FieldToValueMap = sObjectTypesAndFieldApiNames.get(cros.Query_sObject__c); 
                if(FieldToValueMap == null) { FieldToValueMap = new map<String, object>(); }
                
                if(cros.Query_Field_Api_Name__c != null) {
                    
                    sObject Replacement = (cros.Use_Source__c == true) ? SourceRecord : Destination;
                    system.debug('Use Source: ' + cros.Use_Source__c + ' - ' + Replacement);
                    system.debug('Replacement: ' + cros.Query_Field_API_Name__c + ' - ' + Replacement);
                    
                    Object ReplacementFieldValue = ALL_UtilitiesData.GetDataFromNestedFields(cros.Query_Field_API_Name__c, Replacement);
                    system.debug(cros.Query_Field_API_Name__c + ' == ' + ReplacementFieldValue);
                    
                    //map<String, Object> FieldTovalueMap1 = new map<String, Object>();
                    FieldToValueMap.put(cros.Query_Field_Api_Name__c, ReplacementFieldValue);
                    //sObjectTypesAndFieldApiNames.put(cros.Query_sobject__c, FieldTovalueMap);
                }
                
                sObjectTypesAndFieldApiNames.put(cros.Query_sObject__c, FieldToValueMap); 
            }
            
            system.debug(sObjectTypesAndFieldApiNames);
                        
            // apply the destination objects to the designated fields on the source object
            // and override fields as designated by the Clone Records Override Settings
            for (Clone_Records_Override_Settings__c cros : OverrideSettings) 
            {
                Object ReplacementFieldValue = null;
                
                // retrieve nested data
                if(cros.Query_Field_API_Name__c != null) {
                    sObject Replacement = (cros.Use_Source__c == true) ? SourceRecord : Destination;
                    ReplacementFieldValue = ALL_UtilitiesData.GetDataFromNestedFields(cros.Query_Field_API_Name__c, Replacement);
                    system.debug(Destination);
                    system.debug(cros.Replacement_Field_API_Name__c + ' == ' + ReplacementFieldValue);
                }
                
                if (cros.Query_Field_API_Name__c != null) 
                {
                    try {
                        // put the data retrieved from the nested field in the sObject
                        system.debug(cros.Replacement_Field_API_Name__c+' '+SourceClone+' '+ReplacementFieldValue);
                        
                        SourceClone = ALL_UtilitiesData.PutDataInNestedFields(cros.Replacement_Field_API_Name__c, SourceClone, ReplacementFieldValue);
                        
                        if(Cros.Relationship_Replacement_Field__c != null)
                        {                          
                            if(Cros.Replacewith_sObject__c != null)
                            {
                                SourceClone.putSobject(Cros.Relationship_Replacement_Field__c, Destination.getSobject(Cros.Replacewith_sObject__c));
                            }
                            else
                            {
                                system.debug(cros.Name);
                                system.debug(Cros.Relationship_Replacement_Field__c);
                                system.debug(Destination);
                                SourceClone.putSobject(Cros.Relationship_Replacement_Field__c, Destination);                                
                            }
                        }
                        system.debug(SourceClone);
                        //System.debug(SourceClone.getSobject('What').get('Name'));
                    } catch(Exception exc) { system.debug(exc); }
                }
                else 
                {
                    // if the Query_Field_Api_Name__c is null, but the Query_sObject__c is not null
                    if(cros.Query_sObject__c != null) 
                    { 
                        //Schema.SObjectType sObjType = Destination.getSObjectType();
                        //sObject ReplacementSObject = sObjType.newSObject(Destination.Id);*/
                        sObject ReplacementSObject = Schema.getGlobalDescribe().get(cros.Query_SObject__c).newSObject();
                        map<String, object> FieldToValueMap = sObjectTypesAndFieldApiNames.get(cros.Query_SObject__c);
                        
                        system.debug(ReplacementSObject);
                        system.debug(FieldToValueMap);
                        
                        if(FieldToValueMap != null)
                        {
                            //sObject obj = sObjType.newSobject();
                            ReplacementSObject = Destination;
                            
                            for(string fieldName : FieldToValueMap.keySet()) 
                            { 
                                system.debug(FieldName);
                                system.debug(FieldToValueMap.get(fieldName));
                                system.debug(cros.Query_sObject__c);
                                system.debug(cros.Query_Field_API_Name__c);
                                system.debug(cros.Replacement_Field_API_Name__c);
                                system.debug(cros.sObject_API_Name__c);
                               
                                //if(FieldName != 'Name') {
                                    //ReplacementSObject.put(fieldName, FieldToValueMap.get(fieldName)); //}
                                /*else{
                                    list<string> Fields = new list<string>(FieldToValueMap.keySet());
                                    string FieldString = ALL_UtilitiesString.ListToDelimitedstring(Fields, ',');
                                    string querystring = 'Select '+ FieldString  + ' From ' + cros.Query_sObject__c + ' Where Id=' + '\'' + DestinationKey + '\'' +' limit 1';
                                    system.debug(querystring);
                                    sObject Destin = Database.query(querystring);
                                    ReplacementSObject = Destin; break;
                                }*/
                               
                            }
                        }
                         
                        
                        system.debug(ReplacementSObject);
                        system.debug(cros.Replacement_Field_API_Name__c);
                        
                        // Query_sObject__c determines the Destination
                        SourceClone.putSObject(cros.Replacement_Field_API_Name__c, ReplacementSObject);
                        system.debug(SourceClone);
                    }                   
                    else { // essentially, if Destination/ReplacementSObject is null
                        SourceClone.put(cros.Replacement_Field_API_Name__c, null); 
                        system.debug(SourceClone);
                    }
                }
            }
            
            //System.debug(SourceClone.getSobject('What').get('Name'));
            
            
            
            //String CloneKey = (String)DestinationSObjects.values()[i].get('Id');           
            if (!Clones.keyset().contains(DestinationKey)) {
                Clones.put(DestinationKey, SourceClone);
            }
            system.debug(Clones);
        }
        
        return Clones;
    }
    
    public static Map<String, ClonedDisplayRecord> ConfigureCloneDisplayFields(sObject RelationshipRecord, Clone_Records_Settings__c sObjectCloneSettings,
        List<Clone_Display_Field_Settings__c> CloneDisplayFieldSettings, Map<String, sObject> DestinationSObjects, Map<String, ClonedDisplayRecord> cdrs) 
    {
        system.debug(sObjectCloneSettings);
        system.debug(CloneDisplayFieldSettings);
        system.debug(DestinationSObjects);
        system.debug(cdrs); 
        system.debug(RelationshipRecord);
        
        // add all of the fields to display for that clone
        for (Clone_Display_Field_Settings__c FieldSettings : CloneDisplayFieldSettings) // (FilteredCloneDisplayFieldSettings)
        {
            if (FieldSettings.Field_Display_Type__c.toLowerCase() == 'picklist'
            && FieldSettings.Field_Options_Query__c != null) 
            {
                Map<String, Map<String,String>> OptionsByKey = new Map<String, Map<String,String>> ();
                
                List<String> AllCloneFieldIds = new List<String> ();
                Map<String, List<String>> DestinationIdsByKeyFields = new Map<String, List<String>> ();
                
                for (String DestinationKey : cdrs.keySet()) 
                {   
                    sObject Destination;
                    if(DestinationSObjects != null)
                    {
                        Destination = DestinationSObjects.get(DestinationKey);                                               
                    }
                    
                    ClonedDisplayRecord cdr = cdrs.get(DestinationKey);                   
                    String CloneKey = (String)cdr.Record.get(sObjectCloneSettings.Source_Key_Field__c);
                    String QueryKey = CloneKey;
                    string DestinationId;
                    
                    // added for Owner picklist display
                    // query from destination record directly
                    if (FieldSettings.Relationship__c != null && cdr.Record.get('Id') == null && 
                        FieldSettings.Destination_Picklist_Option_Fields__c != null)
                    {
                        list<string> FieldList = new list<string>();
                        
                        if(FieldSettings.Destination_Picklist_Option_Fields__c.contains(','))
                        { 
                            FieldList = FieldSettings.Destination_Picklist_Option_Fields__c.split(',');
                        }
                        else
                        { 
                            FieldList.add(FieldSettings.Destination_Picklist_Option_Fields__c);
                        }
                        
                        system.debug(FieldList);
                        for(string field: FieldList)
                        {
                            system.debug(field);
                            system.debug(Destination);
                            sObject RelationshipField;
                            
                            //if(RelationshipRecord != null) { RelationshipField = RelationshipRecord.getSObject(field); }
                            if(Destination != null) { RelationshipField = Destination.getSObject(field); }
                           // system.debug(RelationshipField);
                            
                            if(RelationshipField != null) 
                            {
                                //string Id = (String) OriginalDestination.get(field);
                                //if(Id != null){ AllCloneFieldIds.add(Id); }
                                String value = (String) RelationshipField.get('Id');
                                String text = (String) RelationshipField.get('Name');
                                system.debug(value);
                                system.debug(text);
                                OptionsByKey = DSCB_CloneAnything.AddSelectOptionByKey(DestinationKey, value, text, OptionsByKey, FieldSettings);
                            }
                        }
                    }
                    else if(
                        FieldSettings.sObject_API_Name__c == sObjectCloneSettings.sObject_API_Name__c &&
                        cdr.Record.get('Id') != null && FieldSettings.Relationship__c != null) 
                    {
                        sObject RelationshipSObject = cdr.Record.getSObject(FieldSettings.Relationship__c);
                        system.debug(RelationshipSObject);
                        
                        if(RelationshipSObject != null)
                        {
                            String value = (String) RelationshipSObject.get('Id');
                            String text = (String) RelationshipSObject.get('Name'); 
                            
                            OptionsByKey = DSCB_CloneAnything.AddSelectOptionByKey(DestinationKey, value, text, OptionsByKey, FieldSettings);
                            system.debug(OptionsByKey);                            
                        }
                    }
                    // pulling destination relationship objects
                    else
                    {
                        if(DestinationSObjects != null) 
                        {
                            system.debug(Destination);
                            if(Destination != null) 
                            {
                                QueryKey = (string)Destination.get((string)sObjectCloneSettings.Destination_sObject_Account_Field__c);
                                DestinationId = Destination.Id;
                                system.debug(QueryKey);                          
                            }                        
                        }
                    }
                    
                    // Case clone: SourceKey is AccountId, QueryKey is DestinationKey
                    if (DestinationIdsByKeyFields.get(QueryKey) != null) {
                        DestinationIdsByKeyFields.get(QueryKey).add(DestinationKey);
                    } 
                    else {
                        DestinationIdsByKeyFields.put(QueryKey, new List<String> { DestinationKey });
                    }
                    
                    if(QueryKey != null) { AllCloneFieldIds.add(QueryKey); }
                    if(DestinationId != null) { AllCloneFieldIds.add(DestinationId); }
                    
                    system.debug(FieldSettings.sObject_API_Name__c == sObjectCloneSettings.sObject_API_Name__c);
                    system.debug(FieldSettings);
                    system.debug(FieldSettings.Relationship__c);
                }
                
                // build the query to get the Select Options
                String FieldOptionsQuery = FieldSettings.Field_Options_Query__c;
                
                if (FieldSettings.Field_Options_Query_Clone_Field__c != null) 
                {
                    FieldOptionsQuery += (FieldSettings.Field_Options_Query__c.toLowerCase().contains('where') ? ' And ' : ' Where ')
                        + FieldSettings.Field_Options_Query_Clone_Field__c + ' IN (' + ALL_UtilitiesString.ListToCSV(AllCloneFieldIds) + ')';
                }
                
                List<sObject> OptionObjects = new List<sObject> ();
               
                system.debug(FieldOptionsQuery);
                system.debug(AllCloneFieldIds);
                
                try {
                    OptionObjects = Database.query(FieldOptionsQuery);
                } // perform query to get select options
                catch (Exception e) { system.debug(e); }
                
                system.debug(OptionObjects);
               
                // parse the results of the query into a map of options by key
                for (sObject oo : OptionObjects) 
                {
                    String CloneFieldKey = ''; // CloneFieldKey is the Clone Field Key (Case: AccountId)
                    List<String> DestinationKeys = new List<String> ();
                    
                    if (FieldSettings.Field_Options_Query_Clone_Field__c != null) 
                    {
                        CloneFieldKey = (String)oo.get(FieldSettings.Field_Options_Query_Clone_Field__c);
                        DestinationKeys = DestinationIdsByKeyFields.get(CloneFieldKey);
                    }
                    
                    if(FieldSettings.Field_Options_Query_Value__c != null && FieldSettings.Field_Options_Query_Text__c != null)
                    {
                        String value = (String) oo.get(FieldSettings.Field_Options_Query_Value__c);
                        String text = (String)oo.get(FieldSettings.Field_Options_Query_Text__c);
                        
                        // if there is no specific destination, add to all destinations
                        if(DestinationKeys == null || DestinationKeys.IsEmpty())   
                        {
                            for (String optDestinationKey : cdrs.KeySet()) 
                            { // optKey is DestinationId
                                OptionsByKey = DSCB_CloneAnything.AddSelectOptionByKey(optDestinationKey, 
                                                                                       value, text, OptionsByKey, FieldSettings);
                                system.debug(OptionsByKey);
                            }
                        } 
                        else 
                        {
                            if (DestinationKeys != null) 
                            {
                                for (String DestinationKey : DestinationKeys) 
                                {
                                    OptionsByKey = DSCB_CloneAnything.AddSelectOptionByKey(DestinationKey, 
                                                                                           value, text, OptionsByKey, FieldSettings);
                                    system.debug(OptionsByKey);
                                }
                            }
                        }
                    }
                }
                
                system.debug(OptionsByKey);
                for (String DestinationKey : OptionsByKey.keySet()) {
                    CloneDisplayField cdf = new CloneDisplayField();
                    cdf.SelectOptions = OptionsByKey.get(DestinationKey);
                    system.debug(OptionsByKey);
                    system.debug(cdf);
                    // add the Field to the Clone Display Records list of Fields
                    cdrs.get(DestinationKey).Fields.put(FieldSettings.Field_API_Name__c, cdf);
                }
            }
        }
        system.debug(cdrs);
        return cdrs;
    }
    
    public static Map<String, Map<String,String>> AddSelectOptionByKey(String key, String value, String text, 
        Map<String, Map<String,String>> OptionsByKey, Clone_Display_Field_Settings__c FieldSettings)
    {
        Map<String,String> OptionsForKey = OptionsByKey.get(key);
        
        if (OptionsForKey == null) { OptionsForKey = new Map<String, String> (); }
        
        OptionsForKey.put(value, text);
        OptionsByKey.put(key, OptionsForKey);
        
        return OptionsByKey;
    }
    
    public static void CloneRecapProduct(Id SourceRecap, list<String> DestinationRecapList) 
    {
        List<Recap_Product__c> RecapProdList = New List<Recap_Product__c> ([
            select Id, Name, Recap__c, Recap_Account__C, RecordType.Name 
            From Recap_Product__c 
            Where Recap__c =  : SourceRecap
        ]);
        List<Recap_Product__c> ClonedRecapProductsList = New List < Recap_Product__c > ();

        Map<String, sObject> RecapProductsToInsert = new Map < String, sObject > ();
        
        List<DSCB_CloneAnything.CloneResult> CloneResults = new List<DSCB_CloneAnything.CloneResult>();
        
        system.debug(RecapProdList);
        
        // to do: move this to @future method? // 01/15/2015 - SivaP have to  look at moving to future method.
        for (sObject RecapProduct : RecapProdList) 
        {
            system.debug(DestinationRecapList);
            system.debug(RecapProduct);
            DSCB_CloneAnything.CloneResult CloneResult = DSCB_CloneAnything.CloneToSelected('Recap_Product__c', RecapProduct.Id, DestinationRecapList);
            system.debug(CloneResult);
            CloneResults.add(CloneResult);
            system.debug(CloneResult.Results.size());
            
            RecapProductsToInsert = new Map < String, sObject > ();
                       
            for (DSCB_CloneAnything.ClonedDisplayRecord dr : CloneResult.Results) 
            {
                Id RecapId = (ID)RecapProduct.get('Recap__c');
                RecapProductsToInsert.put(RecapId, dr.Record);
                
                system.debug(RecapProductsToInsert);
                
                sObject obj;
                Map<string, string> NullLookUpMap = new Map<string, string>();
                
                DSCB_CloneAnything.SaveClones('Recap_Product__c', RecapProduct.Id, RecapProductsToInsert, obj, NullLookUpMap);
                
                
            }
        }
    }
    
    global static sObject GetDeepClone(Id SourceId) 
    {
        List<sObject> DeepClonesList = sObjectCloner.CloneRecords(new List<Id> { SourceId });
        if (DeepClonesList != null && !DeepClonesList.IsEmpty()) { return DeepClonesList[0]; }
        return null;
    }
    
    global class OnlySaveClonesResult
    {
        global Boolean Success {get;set;}
        global String ErrorMessage {get;set;}
        global Map<String,sObject> ClonedSObjects {get;set;}
        
        global OnlySaveClonesResult() { Success = false; ErrorMessage = ''; ClonedSObjects = null; }
        global OnlySaveClonesResult(Boolean s, String em, Map<String,sObject> cs) { Success = s; ErrorMessage = em; ClonedSObjects = cs; } 
    }
    
    global static OnlySaveClonesResult OnlySaveClonesWithParameters(SearchSObjectsParameters Parameters)
    {
        Id SourceId = Parameters.SourceSobject.Id;
        
        // get Clone Settings
        List<Clone_Records_Settings__c> CloneSettings = DSCB_CloneAnything.GetAllSObjectCloneSettingsList();
        Clone_Records_Settings__c sObjectCloneSettings = DSCB_CloneAnything.GetCurrentSObjectCloneSettings(Parameters.SObjectType, Parameters.sSubType, CloneSettings);
        
        // get Override Settings
        List<Clone_Records_Override_Settings__c> AllOverrideSettings = Clone_Records_Override_Settings__c.getAll().values();
        
        // validate Clone sObjects
        if (Parameters.Clones == null || Parameters.Clones.size() < 1) {
            return new OnlySaveClonesResult(false, 'Please provide at least one clone to save. ', null);
        }
        
        // then override with passed sObject values
        Map<String,sObject> ClonesToInsert = new Map<String,sObject> ();
        List<sObject> ModifiedDeepClones = new List<sObject> ();
        
        system.debug(Parameters.clones);
        
        for (String CloneKey : Parameters.Clones.keySet()) 
        {
            sObject Clone = Parameters.Clones.get(CloneKey);
            sObject OverrideClone = Parameters.SourceSObject.clone(false, true);
            //sObject OverrideClone = Clone.clone(false, true);
            
            Map<string, Schema.SObjectField> FieldMap = Schema.getGlobalDescribe().get(Parameters.sObjectType).getDescribe().fields.getMap();
            Boolean isthisName;
            for(string field: FieldMap.keySet())
            {
                object FieldValue = Clone.get(field);
                isthisName = Schema.getGlobalDescribe().get(Parameters.sObjectType).getDescribe().fields.getMap().get(field).getDescribe().isNameField();
                if(FieldValue != null && !isthisName)
                {
                    OverrideClone.put(field, FieldValue);
                }
            }           
            
            for (Clone_Records_Override_Settings__c os : AllOverrideSettings) 
            {
                String ReplacementField = (String)os.Replacement_Field_API_Name__c;
                
                system.debug(ReplacementField);
                
                if (os.sObject_API_Name__c == Parameters.sObjectType && (os.SubType__c == Parameters.sSubType || os.SubType__c == null)/*added 11/14/2014 SivaP*/) {
                    if (!string.isEmpty(ReplacementField) && !ReplacementField.contains('.')) {
                        try{ 
                            OverrideClone.put(ReplacementField, Clone.get(ReplacementField));
                        }
                        catch(Exception e){
                            system.debug('---Error---'+e.getMessage());
                        }
                    }
                }
            }
            
            try {
                // added on 2014-03-12 changed from SourceIdString to SourceSObject
                OverrideClone.put('ParentId', Parameters.SourceSObject.Id);
            } 
            catch (Exception e) { /*system.debug(e);*/ }
            
            ClonesToInsert.put(CloneKey, OverrideClone);
        }
        system.debug(ClonesToInsert.values());
        
        /*try 
        {*/
            // set InsertFromMassCloneApp to true to let the new cases to have the owner added to the CaseTeamMember upon insert
            DSCB_CloneAnything.InsertFromMassCloneApp = true;
            insert ClonesToInsert.values();
            
            system.debug(Parameters.sObjectType);
            system.debug(ClonesToInsert.values().size());
            system.debug(ClonesToInsert.values());
            
            if(Parameters.sObjectType == 'Recap__c' && ClonesToInsert.values().size() > 0) 
            {
                List<String> DestinationRecapList = New List<String> ();
                List<string> AccountList = new list<string>();
                
                for(sObject R : ClonesToInsert.values()){
                    string s = (ID)R.get('account__c');
                    AccountList.add(s);
                }
                
                system.debug(AccountList);
               
                map<string,string> AccountMap = new map<string,string>();
                
                for(Account a:[select Id,Name From Account Where Id IN:AccountList]){
                     AccountMap.put(a.Id, a.Name);
                }
                
                system.debug(AccountMap);
                system.debug(ClonesToInsert.values());
                
                for(sObject R : ClonesToInsert.values()) {
                
                    DestinationRecapList.add(R.Id);
                    R.put('Bridge_Field__c',R.Id);
                    string a = (ID)R.get('account__c');
                    R.put('Recap_Name__c', AccountMap.get(a)+(R.get('Product__c') != null ? ' - ' + R.get('Product__c') : '')); //FieldList.get(1)
                    
                }
                
                system.debug(DestinationRecapList);
                system.debug(SourceId);
                
                DSCB_Cloneanything.CloneRecapProduct(SourceId, DestinationRecapList);
                
                
                // to do: update the Recaps to refresh the status update?
                update ClonesToInsert.values();
            }
        /*} 
        catch (Exception e) 
        {
            String ErrorMessage = String.valueOf(e.getMessage());
            
            if (ErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) 
            {
                ErrorMessage = ErrorMessage.substring(
                    ErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION'),
                    ErrorMessage.length());
            }
            
            system.debug(ErrorMessage);
            return new OnlySaveClonesResult(false, ErrorMessage, null);
        }*/
        
        return new OnlySaveClonesResult(true, '', ClonesToInsert);
    }
    
    @RemoteAction
    global static CloneResult SaveClones(String sObjectType, String SourceIdString, Map<String,sObject> Clones, sObject SourceRecordUpdate, 
                                         Map<string, string> LookUpFieldMap) 
    {
        SearchSObjectsParameters Parameters = new SearchSObjectsParameters();    
        
        Parameters.sObjectType = sObjectType;
        Parameters.SourceIdString = SourceIdString;
        Parameters.Clones = Clones;
        if(SourceRecordUpdate != null) { Parameters.SourceRecordUpdate = SourceRecordUpdate; }
        if(LookUpFieldMap.keySet() != null) { Parameters.LookUpFieldMap = LookUpFieldMap; }
        
        return DSCB_Cloneanything.SaveClonesWithParameters(Parameters);
    } 
    
    @RemoteAction // 2014-03-18 MK consolidated because need deep clone for any cloning (otherwise only partial clones are saved)
    global static CloneResult SaveClonesWithParameters(SearchSObjectsParameters Parameters) 
    { 
        system.debug(Parameters);
        // here loop through Clones and replace the LookUp field names with LookUp field Id's       
        For(sObject obj: Parameters.Clones.values())
        {
            if(Parameters.LookUpFieldMap.keySet() != null)
            {
                for(string s: Parameters.LookUpFieldMap.keySet())
                {
                    obj.put(s, Parameters.LookUpFieldMap.get(s));  
                }
            }
        }
        
        // validate Source Id
        CloneResult SourceIdStringCloneResult = ValidateSourceIdString(Parameters.SourceIdString);      
        
        if (!SourceIdStringCloneResult.Success) { return SourceIdStringCloneResult; } // if not success, return error message 
        
        // convert the Id
        Id SourceId = Parameters.SourceIdString;
        
        // need to deep clone source to get all fields on the object
        sObject SourceSObject = DSCB_CloneAnything.GetDeepClone(SourceId);
        SourceSObject.Id = SourceId;        
       
        if (SourceSObject == null) {
            return new CloneResult(false, 'An error occurred when getting all of the fields to clone. ');
        }
        
        List<Clone_Records_Settings__c> CloneSettings = DSCB_CloneAnything.GetAllSObjectCloneSettingsList();
        Clone_Records_Settings__c sObjectCloneSettings = DSCB_CloneAnything.GetCurrentSObjectCloneSettings(
            Parameters.SObjectType, Parameters.sSubType, CloneSettings);
        
        // call OnlySaveClones
        Parameters.SourceSObject = SourceSObject;
       
        DSCB_CloneAnything.OnlySaveClonesResult OnlySaveClonesResult = OnlySaveClonesWithParameters(Parameters);
        
        system.debug(OnlySaveClonesResult);
        
        if(OnlySaveClonesResult.Success == false) { 
            return new CloneResult(false, OnlySaveClonesResult.ErrorMessage); }
                
        Map<String,sObject> ClonesToInsert = OnlySaveClonesResult.ClonedSObjects;
        
        // put together the conditions for querying
        List<String> CloneIds = new List<String> ();
        for (sObject Clone : ClonesToInsert.values()) { CloneIds.add(Clone.Id); }
        
        String QueryConditions = '(' + ALL_UtilitiesString.ListToCSV(CloneIds) + ')';
        
        // get the display settings
        CloneDisplaySettings DisplaySettings = new CloneDisplaySettings(Parameters.sObjectType, Parameters.sSubType);
        System.debug('DisplaySettings---'+DisplaySettings);
        
        String QueryDisplayFields = DisplaySettings.DisplayFieldsString;
        
        if (!QueryDisplayFields.containsIgnoreCase(sObjectCloneSettings.Source_Key_Field__c)) {
            QueryDisplayFields += (QueryDisplayFields.trim() == '' ? '' : ',') + sObjectCloneSettings.Source_Key_Field__c;
        }
        
        // refresh saved object
        String CloneQuery = 'Select ' + QueryDisplayFields + ' '
             + 'From ' + Parameters.sObjectType + ' '
             + 'Where Id IN ' + QueryConditions + '';
        
        CloneResult cr = new CloneResult(false, 'Saving Cloned Records...');
        
        Map<String, DSCB_CloneAnything.ClonedDisplayRecord> cdrs
             = new Map<String, DSCB_CloneAnything.ClonedDisplayRecord> ();
        
        Map<Id,sObject> QueriedClones = new Map<Id,sObject> ();
        
        try {
            system.debug(CloneQuery);
            QueriedClones = new Map<Id,sObject> ((List<sObject>)Database.query(CloneQuery));
        } catch (Exception e) {
            return new CloneResult(false, 'Cloned records were saved, '
                 + 'but there was an error displaying the results.<br/>ERROR DETAILS: ' + e.getMessage());
        }
        
        system.debug(QueriedClones);
        
        for (String CloneKey : ClonesToInsert.keySet()) 
        {
            // for each clone
            sObject Clone = ClonesToInsert.get(CloneKey);
            sObject qc = QueriedClones.get(Clone.Id); //system.debug(Clone.Id); // get the query result
            
            ClonedDisplayRecord cdr = new ClonedDisplayRecord();
            cdr.Record = qc;
            cdr.Destination = CloneKey;
            cdr.Fields = new Map<String,CloneDisplayField> ();
            cdrs.put(CloneKey, cdr);
        }
        system.debug(cdrs);
        
        /*cdrs = DSCB_CloneAnything.ConfigureCloneDisplayFields(
            null, sObjectCloneSettings, DisplaySettings.DisplayFieldsByAPIName.values(), null, cdrs);*/
        
        
        system.debug(Parameters.DisplayAsOutputFields2);
        
        if(Parameters.DisplayAsOutputFields2 != null)
        {
            if(Parameters.DisplayAsOutputFields2) 
            {           
                for(string fieldName: DisplaySettings.DisplayFieldsByAPIName.keySet())
                {
                    Clone_Display_Field_Settings__c CurrentDisplayField = DisplaySettings.DisplayFieldsByAPIName.get(FieldName);
                    if(CurrentDisplayField != null && CurrentDisplayField.Include_In_Override_Cloning__c == false)
                    {
                        DisplaySettings.DisplayFieldsByAPIName.remove(FieldName);
                        
                    }else
                    {
                        if(CurrentDisplayField.Override_Do_Not_Display_After_Saving__c == true)
                        {
                            DisplaySettings.DisplayFieldsByAPIName.remove(FieldName);
                        }
                    }                  
                }
                
            }else
            {           
                for(string fieldName: DisplaySettings.DisplayFieldsByAPIName.keySet())
                { 
                    Clone_Display_Field_Settings__c CurrentDisplayField = DisplaySettings.DisplayFieldsByAPIName.get(FieldName);
                    
                    if(CurrentDisplayField != null && CurrentDisplayField.Include_In_Regular_Cloning__c == false) 
                    {   
                        DisplaySettings.DisplayFieldsByAPIName.remove(FieldName);                       
                    }else
                    {
                        if(CurrentDisplayField.Regular_Do_Not_Display_After_Saving__c == true)
                        {
                             DisplaySettings.DisplayFieldsByAPIName.remove(FieldName);
                        }
                    }                
                }                       
            }
        }
        
        // moved this method from above to here to control DisplaySettings.DisplayFieldsByAPIName.values() selection from Custom Settings
        cdrs = DSCB_CloneAnything.ConfigureCloneDisplayFields(
            null, sObjectCloneSettings, DisplaySettings.DisplayFieldsByAPIName.values(), null, cdrs);
        
        cr.Success = true;
        cr.Message = 'Cloned Records Saved! ';
        cr.Results = cdrs.values();
        cr.Columns = DisplaySettings.DisplayFieldsByAPIName;
        
        system.debug(cdrs.values());
        System.debug('949---DisplaySettings.DisplayFieldsByAPIName---'+DisplaySettings.DisplayFieldsByAPIName);
         
        return cr;
    }
    
    // -- Utility Methods
    
    public void DisplayPageWarning(String WarningMessage) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, WarningMessage));
    }
    
    public static string QueryConstructorConditionsPackage(Clone_Records_Settings__c sObjectCloneSetting)
    {
        DynamicSOQL_Helper.QueryConditionsPacketClass ConditionsPackage = new DynamicSOQL_Helper.QueryConditionsPacketClass();
        
        List<Clone_Destination_Query_Condition__c> CdqcList = Clone_Destination_Query_Condition__c.getAll().Values();
        
        system.debug(sObjectCloneSetting.Name);
        
        for(Clone_Destination_Query_Condition__c cdqc: CdqcList)
        {
            if(cdqc.Cloning_Type_Identifier__c == sObjectCloneSetting.Name)
            {
                DynamicSOQL_Helper.QueryConstructorCondition instance = new DynamicSOQL_Helper.QueryConstructorCondition();
                instance.order = cdqc.Order__c;
                instance.key = cdqc.Key__c;
                instance.operator = cdqc.Operator__c;
                instance.value = cdqc.Value__c;
                instance.className = cdqc.Class_Name__c;
                instance.methodName = cdqc.Method_Name__c;                
                ConditionsPackage.ConditionsList.add(instance);
            }
        }
        
        ConditionsPackage.QueryConditionExpression = sObjectCloneSetting.Query_Conditional_Expression__c;
        
        return DynamicSOQL_Helper.QueryConstructor(ConditionsPackage);
    }
    
    public static string ConcatenateFields(String DisplayFieldsString, String CloneDisplayFieldsString)
    {
        List<String> DisplayFieldsList = new List<String>(DisplayFieldsString.Split(','));
       
        List<String> CloneDisplayFieldsList = new List<String>(CloneDisplayFieldsString.split(','));
        
        system.debug(CloneDisplayFieldsList);
        
        List<String> AllFieldsList = new List<String>(DisplayFieldsList);
        
        AllFieldsList.addAll(CloneDisplayFieldsList);
        
        system.debug(AllFieldsList);
        
        Set<String> AllFieldsSet = new Set<String>(AllFieldsList);
               
        string AllFieldsString = ''; 
        
        List<string> AllFieldsList2 = new List<string>();
        
        AllFieldsList2.addAll(AllFieldsSet);
        
        system.debug(AllFieldsList2);
        
        set<string> FieldStringSet = new set<string>();
        
        for(integer i=0; i<AllFieldsList2.size(); i++)
        {
            system.debug(AllFieldsList2[i]);
            
            if(!FieldStringSet.contains(AllFieldsList2[i].toLowerCase()) || AllFieldsString == '')
            {
                AllFieldsString += AllFieldsList2[i].toLowerCase() + (i==AllFieldsList2.size()-1?'':', ');
                
                system.debug(AllFieldsString);
                
                FieldStringSet.add(AllFieldsList2[i].toLowerCase());
            }            
        }     
        
        AllFieldsString = AllFieldsString.trim().removeEnd(',');
      
        system.debug(AllFieldsString);
        
        return AllFieldsString;
    }   
}