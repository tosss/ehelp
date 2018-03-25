public class CB_Recap
{
    // -- static variables
    
    public static Boolean RunStatusUpdate = true; // used for RecapBeforeInsert method
    public static List<String> UserOwnerList = new List<String> ();
    public static Map<String, String> OwnerRoleMap = new Map<String, String> ();
    public static Boolean isThis_LMA_StatusProcess;
    
    // -- subclass variables
    
    // To call use:
    //   CB_Recap.ObjectResults Results = ObjectResults(Recap, SelectedProducts);
    public class ObjectResults 
    {
        public Boolean Success;  
        
        // return variables
        public Map<String, List<Recap_Field__c>> result_RecapFieldsBySection {get;set;}
        public Map<String, List<Recap_Field__c>> result_RecapFieldsByProduct {get;set;}
        public Map<String, Map<Id, sObject>> sObjectsByType {get;set;}
        
        public Map<String, List<Recap_Field__c>> FieldsBySObject {get;set;}
        public Map<String, List<String>> FieldNamesBySObject {get;set;}
        
        public ObjectResults()
        {
            result_RecapFieldsBySection = new Map<String, List<Recap_Field__c>>();
            result_RecapFieldsByProduct = new Map<String, List<Recap_Field__c>>();
            sObjectsByType = new Map<String, Map<Id, sObject>>();
            
            FieldsBySObject = new Map<String, List<Recap_Field__c>>();
            FieldNamesBySObject = new Map<String, List<String>>();
            
            Success = false; 
        }
    }
    
    // -- static methods
    
    public static String FieldFullName(String LookupSObject, String FieldApiName) 
    {
        return LookupSObject != null ? (LookupSObject + '.' + FieldApiName) : FieldApiName; 
    }
    
    public static CB_Recap.ObjectResults QueryObjectResults(List<Id> RecapIds, List<Recap_Field__c> RecapFields)
    {
        CB_Recap.ObjectResults Results = new CB_Recap.ObjectResults();
        
        // get maps of each sObjects fields
        Map<String, Schema.SObjectField> metadata_RecapFields = Schema.SObjectType.Recap__c.fields.getMap();
        Map<String, Schema.SObjectField> metadata_RecapProductFields = Schema.SObjectType.Recap_Product__c.fields.getMap();
        Map<String, Schema.SObjectField> metadata_RecapWebIDFields = Schema.SObjectType.Recap_WebID__c.fields.getMap();
        
        // sort the fields
        SortUtility FieldSorter = new SortUtility(RecapFields, 'Order__c'); RecapFields = FieldSorter.CustomSort();
        
        for(Recap_Field__c field : RecapFields)
        {
            String FieldApiName = field.Field_API_Name__c;
            String FieldSObjectName = field.sObject__c != null ? field.sObject__c.toLowerCase() : null;
            
            if(FieldApiName != null) 
            {
                FieldApiName = FieldApiName.toLowerCase();
                
                //system.debug('sObject__c=' + FieldSObjectName + ',Field_API_Name__c=' + FieldApiName 
                //    + ',ValidWebIDField=' + (FieldSObjectName == 'recap_webid__c' && (metadata_RecapWebIDFields.keySet().contains(FieldApiName) || field.Lookup_sObject__c != null)));
                
                // make sure all of the fields exist in the metadata for the specified objects
                if((FieldSObjectName == 'recap__c' && (metadata_RecapFields.keySet().contains(FieldApiName) || field.Lookup_sObject__c != null)) 
                   || (FieldSObjectName == 'recap_product__c' && (metadata_RecapProductFields.keySet().contains(FieldApiName) || field.Lookup_sObject__c != null)) 
                   || (FieldSObjectName == 'recap_webid__c' && (metadata_RecapWebIDFields.keySet().contains(FieldApiName) || field.Lookup_sObject__c != null)))
                {
                    //system.debug('    Valid Field: ' + FieldApiName);
                    
                    // create the full field name
                    String FullFieldName = CB_Recap.FieldFullName(field.Lookup_sObject__c, field.Field_API_Name__c);
                    
                    if (FieldSObjectName != null) 
                    {
                        // map the field names by sObject
                        if (Results.FieldNamesBySObject.get(FieldSObjectName) == null) { Results.FieldNamesBySObject.put(FieldSObjectName, new List<String>()); }
                        Results.FieldNamesBySObject.get(FieldSObjectName).add(FullFieldName);
                        
                        // map the fields by sObject
                        if (Results.FieldsBySObject.get(FieldSObjectName) == null) { Results.FieldsBySObject.put(FieldSObjectName, new List<Recap_Field__c>()); }
                        Results.FieldsBySObject.get(FieldSObjectName).add(field);
                    }
                    
                    // convert field sObject Name to lower case for matching later
                    field.sObject__c = field.sObject__c.toLowerCase();
                }
            }
        }
        
        // if there is no RecapId (if insert), there is no need to query
        //   but if there is a RecapId, the objects need to be retrieved
        if(RecapIds != null && !RecapIds.IsEmpty())
        {
            // need to query after gathering fields
            String RecapQueryFields = ALL_UtilitiesString.ListToEnclosedCSV(Results.FieldNamesBySObject.get('recap__c'),'');
            String RecapProductQueryFields = ALL_UtilitiesString.ListToEnclosedCSV(Results.FieldNamesBySObject.get('recap_product__c'),'');
            String RecapWebIdQueryFields = ALL_UtilitiesString.ListToEnclosedCSV(Results.FieldNamesBySObject.get('recap_webid__c'),'') ;
            System.debug('RecapProductQueryFields---'+RecapProductQueryFields);
            
            if(!RecapQueryFields.toLowerCase().contains('product__c')) { RecapQueryFields += ',Product__c'; }
            if(!RecapQueryFields.toLowerCase().contains('account__c')) { RecapQueryFields += ',Account__c'; }
            if(!RecapQueryFields.toLowerCase().contains('account__r.name')) { RecapQueryFields += ',Account__r.Name'; }
            if(!RecapQueryFields.toLowerCase().contains('account__r.dealer_group_name2__c')) { RecapQueryFields += ',Account__r.Dealer_Group_Name2__c'; }
            
            if(!RecapProductQueryFields.toLowerCase().contains('recap__c')) { RecapProductQueryFields += ',Recap__c'; }
            if(!RecapProductQueryFields.toLowerCase().contains('id')) { RecapProductQueryFields += ',id'; }
            if(!RecapProductQueryFields.toLowerCase().contains('recordtype')) { RecapProductQueryFields += ',RecordTypeId,RecordType.Name'; }
            
            system.debug(RecapIds.IsEmpty());
            System.debug('RecapIds---'+RecapIds);
            String RecapQuery = 'Select ' + RecapQueryFields 
                + ' From Recap__c'
                + ' ' + ALL_UtilitiesString.ListToInclusiveCondition('Where', 'Id', RecapIds); 
            system.debug(RecapQuery);
            
            String RecapProductQuery = 'Select ' + RecapProductQueryFields
                + ' From Recap_Product__c'
                + ' ' + ALL_UtilitiesString.ListToInclusiveCondition('Where', 'Recap__c', RecapIds); 
            system.debug(RecapProductQuery);
            
            
            // query recap products even before querying recap webids
            Map<Id, Recap_Product__c> RecapProducts = null;
            try 
            { 
                RecapProducts = new Map<Id, Recap_Product__c>((List<Recap_Product__c>)database.query(RecapProductQuery)); 
            }
            catch(Exception ex)
            {
                system.debug(ex);
            } // loop through recap products and get all the id's of the recap products
            List<Id> RecapProductIds = new List<Id>();
            if(RecapProducts != null && !RecapProducts.isEmpty()){ RecapProductIds.addAll(RecapProducts.keySet()); }
            
            system.debug(RecapProductIds.size());
            
            String RecapWebIdQuery = 'Select ' + RecapWebIdQueryFields
                + ' From Recap_WebId__c'
                + ' ' + ALL_UtilitiesString.ListToInclusiveCondition('Where', 'Recap_Product__c', RecapProductIds);  // replaced RecapIds with RecapProductIds and
                                                                                            // 'Recap__c' with 'Recap_Product__c' 
            system.debug(RecapWebIdQuery);
            
            
            
            Map<Id, Recap__c> Recaps = null;
           // Map<Id, Recap_Product__c> RecapProducts = null;
            Map<Id, Recap_WebID__c> RecapWebIds = null;
            
            try 
            {
                Recaps = new Map<Id, Recap__c>((List<Recap__c>)database.query(RecapQuery));
                //RecapProducts = new Map<Id, Recap_Product__c>((List<Recap_Product__c>)database.query(RecapProductQuery));
                RecapWebIds = new Map<Id, Recap_WebID__c>((List<Recap_WebID__c>)database.query(RecapWebIdQuery));
                System.debug(RecapWebIds.size());
                System.debug(RecapProducts);
            }
            catch(Exception ex)
            {
                system.debug(ex);
            }
            
            // add all the sObjects to a Map to make it easier to loop through multi-object fields
            if(Recaps != null) { Results.sObjectsByType.put('recap__c', Recaps); } 
            else { Results.sObjectsByType.put('recap__c', new Map<Id, Recap__c>()); }
            
            if(RecapProducts != null) { Results.sObjectsByType.put('recap_product__c', RecapProducts); } 
            else { Results.sObjectsByType.put('recap_product__c', new Map<Id, Recap_Product__c>()); }
            
            if(RecapWebIds != null) { Results.sObjectsByType.put('recap_webid__c', RecapWebIds); } 
            else { Results.sObjectsByType.put('recap_webid__c', new Map<Id, Recap_WebID__c>()); }
            
            Results.Success = true;
            System.debug('Results---'+Results);
        }
        
        return Results;
    }
    //2016-6-9 - siva.pragada@cdk.com - commented out since this is not used anywhere
   /* public static void UpdateAccountsOnRecapProducts(Map<Id, Recap__c> RecapNewMap, Map<Id, Recap__c> RecapOldMap)
    {
        // update accounts on Recap Products
        List<Recap__c> RecapsWithUpdatedAccounts = new List<Recap__c>();
        
        for(Recap__c NewRecap : RecapNewMap.values())
        {
            Recap__c OldRecap = RecapOldMap.get(NewRecap.Id);
            if(OldRecap != null && (NewRecap.Account__c != OldRecap.Account__c)) { RecapsWithUpdatedAccounts.add(NewRecap); }
        }
        
        List<Recap_Product__c> RecapProductsToUpdate = new List<Recap_Product__c>();
        
        if(RecapsWithUpdatedAccounts != null && !RecapsWithUpdatedAccounts.IsEmpty()) 
        {
            List<Recap_Product__c> RecapProducts = [
                Select Id, Name, Recap__c, Recap_Account__c 
                From Recap_Product__c 
                Where Recap__c IN :RecapsWithUpdatedAccounts
            ];
            
            if(RecapProducts != null && !RecapProducts.IsEmpty()) 
            {
                for(Recap_Product__c RecapProduct : RecapProducts)
                {
                    if(RecapProduct.Recap__c != null && RecapNewMap != null && !RecapNewMap.IsEmpty()) 
                    {
                        Id NewAccountId = null;
                        Recap__c CurrentRecap = RecapNewMap.get(RecapProduct.Recap__c);
                        RecapProduct.Recap_Account__c = CurrentRecap.Account__c;
                        RecapProductsToUpdate.add(RecapProduct);
                    }
                }
            }
        }
        
        // turn off status update
        CB_Recap.RunStatusUpdate = false;
        
        // update Accounts on Recap Products
        if(RecapProductsToUpdate != null && !RecapProductsToUpdate.IsEmpty()) { update RecapProductsToUpdate; }
    }*/
    
    public static void CheckDuplicateRecapProducts(Map<Id, Recap__c> AllRecaps, List<Recap_Product__c> TriggerRecapProducts)
    {
        Map<Id, RecordType> RecapProductRecordTypes = new Map<Id, RecordType>([
            Select Id, Name, sObjectType 
            From RecordType 
            Where sObjectType = 'Recap_Product__c'
        ]);
        
        for(Recap_Product__c RecapProduct : TriggerRecapProducts) 
        {
            Set<String> ExistingProductTypes = new Set<String>();
            Recap__c CurrentRecap = RecapProduct.Recap__c != null ? AllRecaps.get(RecapProduct.Recap__c) : null;
            
            Map<Id, Recap_Product__c> ExistingRecapProducts = new Map<Id, Recap_Product__c>();
            
            for(Recap_Product__c CurrentRecapProduct : CurrentRecap.getSObjects('Recap_Products__r')) 
            {
                if(CurrentRecapProduct != null 
                   && CurrentRecapProduct.RecordType != null 
                   && CurrentRecapProduct.RecordType.Name != null) { 
                       ExistingProductTypes.add(CurrentRecapProduct.RecordType.Name); }
            }
            
            RecordType RecapProductRecordType = RecapProductRecordTypes.get(RecapProduct.RecordTypeId);
            String RecapProductRecordTypeName = RecapProductRecordType != null ? RecapProductRecordType.Name : null;
            
            System.debug('ExistingProductTypes != null'+ExistingProductTypes != null);
            System.debug(ExistingProductTypes.size()>0);
            System.debug('!ExistingProductTypes.contains(LMA)'+!ExistingProductTypes.contains('LMA'));
            System.debug('RecapProductRecordTypeName == LMA'+RecapProductRecordTypeName == 'LMA');
            System.debug('RecapProductRecordTypeName'+RecapProductRecordTypeName);
            System.debug('ExistingProductTypes.size()'+ExistingProductTypes.size());
            System.debug('ExistingProductTypes'+ExistingProductTypes);
            
            if(ExistingProductTypes != null
               && ExistingProductTypes.size()>0 
               && !ExistingProductTypes.contains('LMA')
               && RecapProductRecordTypeName == 'LMA')
            {
                RecapProduct.addError('LMA record type cannot be added to the current recap, ' 
                                      + 'because it has non-LMA record types already.');
            } 
            
            // update
            if(ExistingProductTypes != null
               && ExistingProductTypes.size()>0
               && ExistingProductTypes.contains(RecapProductRecordTypeName)
               && RecapProductRecordTypeName != 'LMA')
            {
                RecapProduct.addError('A Product with this Record Type already exists for this Recap. ' 
                                      + 'Please modify the existing record instead of adding a new one.');
            }
            
            if(ExistingProductTypes != null 
               && ExistingProductTypes.size()>0
               && ExistingProductTypes.contains('LMA')
               && RecapProductRecordTypeName != 'LMA')
            {
                RecapProduct.addError('Cannot add a non-LMA record type to the current Recap, ' 
                                      + 'because it has LMA record type recap product(s) already.');
            }
            
            if(ExistingProductTypes.size()>=0 
               && (ExistingProductTypes.size()>0?ExistingProductTypes.contains('LMA'):ExistingProductTypes.isEmpty())
               && RecapProductRecordTypeName == 'LMA')
            {
                CB_Recap.isThis_LMA_StatusProcess = True;    
            }
            
            System.debug('111ExistingProductTypes---'+ExistingProductTypes);
            
            if(ExistingProductTypes != null 
               && !ExistingProductTypes.contains('LMA')
               && RecapProductRecordTypeName != 'LMA')
            {
                CB_Recap.isThis_LMA_StatusProcess = False;
            }
            
            System.debug('CB_Recap.isThis_LMA_StatusProcess---'+isThis_LMA_StatusProcess);
        }
        // end check for duplicate
    }
    
    // public static Boolean ValidateRequiredFieldsFilledIn(Map<String, List<sObject>> ObjectsToValidate, List<Recap_Field__c> RequiredFields)
    // Map<String, List<sObject>> ObjectsToValidate - all of the sObjects to validate by their string type, this eliminates the need for a separate
    //   sObjectType variable
   
    public static Boolean ProcessBeforeValidateMethod(Map<String, Map<Id, sObject>> ObjectsToValidateByType, List<Recap_Field__c> RequiredFields)
    {
        
        System.debug(RequiredFields);
        System.debug(ObjectsToValidateByType);
        
        List<Boolean> BooleanList = new List<Boolean>();        
        Map<Id, sObject> ObjectsToValidate = new Map<Id, sObject>();        
        List<String> TypeList = new List<String>();
        Map<String, List<Recap_Field__c>> FieldsMapByType = new Map<String, List<Recap_Field__c>>();
        
        TypeList.addAll(ObjectsToValidateByType.keySet()); 
        
        
        for(integer i=0; i<TypeList.size(); i++){
            
            List<Recap_Field__c> FieldListByType = new List<Recap_Field__c>();
            
            for(Recap_Field__c rf: RequiredFields){
                if(rf.sObject__c.ToLowerCase() == TypeList[i].ToLowerCase()){
                    FieldListByType.add(rf);
                }
                FieldsMapByType.put(TypeList[i], FieldListByType);
            }
        }
        
        System.debug(FieldsMapByType);        
        System.debug(ObjectsToValidateByType.keySet());         
        System.debug(TypeList);
        
        Boolean[] TempBoolList = new Boolean[TypeList.Size()];
        
        for(Integer i=0; i<TypeList.size(); i++){ 
            
            ObjectsToValidate = ObjectsToValidateByType.get(TypeList[i]); 
            System.debug(TypeList[i]);
            Boolean TempBool = TempBoolList[i];
            
            
            TempBool = ValidateRequiredFieldsFilledIn(TypeList[i], ObjectsToValidate.values(), FieldsMapByType.get(TypeList[i]));
            
            System.debug(TempBool); 
            System.debug(TypeList[i]);
            System.debug(ObjectsToValidate);
            System.debug(FieldsMapByType.get(TypeList[i]));
            
            if(TempBool==true){System.debug(TypeList[i]);}
            if(TempBool==false){System.debug(TypeList[i]);}
           
            // BY siva 7/21/2014: had to set this condition to true if there are no fields
            if(FieldsMapByType.get(TypeList[i]) != null 
               && FieldsMapByType.get(TypeList[i]).isEmpty()){ TempBool = True;} 
            // in any of the sobjects to check for if filled.
                       
            System.debug(TypeList[i]);
            System.debug(ObjectsToValidate); 
            System.debug(FieldsMapByType.get(TypeList[i]));
            
            BooleanList.add(TempBool);
            
            System.debug(TempBool);
            System.debug(BooleanList);
        }
        
        for(Boolean b: BooleanList){
            if(b == false){ return false; }
        }
        
        return True;         
    }
    
    public static Boolean ValidateRequiredFieldsFilledIn(String sObjectType, List<sObject> ObjectsToValidate, List<Recap_Field__c> RequiredFields)
    {
        Boolean RequiredFieldsFilledIn = true;
        
        if(sObjectType == 'recap_webid__c'){ system.debug(ObjectsToValidate);}
        
        // validate parameters
        if (ObjectsToValidate == null || ObjectsToValidate.IsEmpty()) { return false; }
        if (RequiredFields == null || RequiredFields.IsEmpty()) { return false; }
        
        for (sObject s : ObjectsToValidate) 
        {
            for (Recap_Field__c field : RequiredFields) 
            {
                Boolean RequireField = false;
                
                try 
                {
                    //system.debug(s.getSObject('RecordType'));
                    if(sObjectType.toLowerCase() == 'recap_product__c') 
                    {
                        if(s.getSObject('RecordType') != null && s.getSObject('RecordType').get('Name') != null)
                        {
                            String RecapProductRecordTypeName = (String) s.getSObject('RecordType').get('Name');
                            String RecapFieldRecordTypeCheckboxName = RecapProductRecordTypeName.replace(' ','_') + '_Product__c'; 
                            
                            system.debug(RecapFieldRecordTypeCheckboxName);
                            system.debug(field.get(RecapFieldRecordTypeCheckboxName));
                            RequireField = (Boolean) field.get(RecapFieldRecordTypeCheckboxName);
                            
                            // it is possible that the field may not contain a checkbox value which will result in RequireField being null
                            //   in that case, RequireField should interpret nulls as false
                            if(RequireField == null) { RequireField = false; }
                        }
                        else { RequireField = true; } // always require fields if there is a configuration error
                    }
                    else { RequireField = true; } // always require fields on Recap and Recap WebId
                }
                catch(Exception exc) 
                { 
                    system.debug(exc); 
                    
                    // if there is a configuration error, do not let the status advance
                    RequiredFieldsFilledIn = false; 
                }
                
                if(RequireField)
                {
                    object FieldValue = null;
                    object OrFieldValue = null;
                    
                    if(field.Lookup_sObject__c != null) 
                    {
                        FieldValue = ALL_UtilitiesData.GetDataFromNestedFields(field.Lookup_sObject__c + '.' + field.Field_API_Name__c, s);
                        
                        if(field.Or_Field_API_Name__c != null) {
                            OrFieldValue = ALL_UtilitiesData.GetDataFromNestedFields(field.Lookup_sObject__c + '.' + field.Or_Field_API_Name__c, s); }
                    }
                    else
                    {
                        FieldValue = s.get(field.Field_API_Name__c);
                        System.debug(FieldValue);
                        System.debug(s);
                        System.debug(field.Field_API_Name__c);
                        if(field.Or_Field_API_Name__c != null) {
                            OrFieldValue = s.get(field.Or_Field_API_Name__c); }
                    }
                    
                    if ((FieldValue == null || FieldValue == '' || FieldValue == false)
                        &&  (OrFieldValue == null || OrFieldValue == '' || OrFieldValue == false)) 
                    {
                        RequiredFieldsFilledIn = false; 
                        system.debug(field.Label__c + ' --- not filled in!');
                    }
                }
            }
        }
        
        return RequiredFieldsFilledIn;
    }
    
    public static void RecapBeforeInsertTriggerHandler(List<Recap__c> RecapNewList) 
    {
        List<Id> RecapIds = new List<Id>();
        for(Recap__c r : RecapNewList) { RecapIds.add(r.Id); UserOwnerList.add(r.OwnerId); }
        UserOwnerList.add(UserInfo.getUserId());        
        
        List<String> AllLMATrueStatusList = new List<String>();
        List<String> OrderList = new List<String>();
        List<String> LMAOrderList = new List<String>();
        Map<String, String> StatusToOrder = new Map<String, String>();
        Map<String, String> OrderToStatus = new Map<String, String>();
        Map<String, String> LMAStatusToOrder = new Map<String, String>();
        Map<String, String> LMAOrderToStatus = new Map<String, String>();
        Map<String, List<Boolean>> AllTrueStatusToBoolMap = new Map<String, List<Boolean>>();
        Map<String, List<Boolean>> AllLMATrueStatusToBoolMap = new Map<String, List<Boolean>>();
        
        // Re-arrange the map keyset() values in a suitable status order for convenience
        
        if(RunStatusUpdate)
        {
            RunStatusUpdate = false;
            
            if(RecapNewList != null && RecapNewList.size() > 0) 
            {   
                // Declare all Status boolean check variables here for availability in both Recap product and Recap loops
                
                Boolean AllWebsiteFieldBool;
                Boolean RecapWebidFieldNameFields = false;
                Boolean RequiredRecapFieldsFilledIn = true;
                Boolean RequiredRecapFieldsFilledIn2 = true;
                Boolean RequiredRecapWebIdFieldsFilledIn = false; //setting this to true in line 641 if all recap webid fields are filled in
                Boolean RequiredRecapProdFieldsFilledIn = true;
                
                // sets
                //set<String> IFSRoleList = new set<String> { 'IFS', 'IFS Booking OS', 'IFS Contract Admin', 'IFS Activation OS', 'IFS Builders', 'System Administrator' }; // test as Siena Gleason
                //set<String> DSCRoleList = new set<String> { 'BZ Migration Outreach', 'System Administrator' }; // test as Johanna Kimura
                
                // collections
                Map<String, Launch__c> LaunchMap = new Map<String, Launch__c>();                
                Map<String, List<Recap_Field__c>> FieldsBySObject = new Map<String, List<Recap_Field__c>>();
                Map<String, List<String>> FieldNamesBySObject = new Map<String, List<String>>();
                
                // MK 2014-01-30 add Launches to Map by RecapId
                for (Launch__c L : [select id, recap__c from Launch__c where recap__c IN : RecapIds]) {
                    LaunchMap.put(L.Recap__c, L); }
                
                // get Custom Settings
                List<Recap_Field__c> RecapFields = Recap_Field__c.getAll().values();
                GlobalSettings__c GlobalSettings = GlobalSettings__c.getInstance();
                
                CB_Recap.ObjectResults Results = CB_Recap.QueryObjectResults(RecapIds, RecapFields);
                
                System.debug('Results---'+Results);
                
                if(Results.FieldsBySObject != null && !Results.FieldsBySObject.IsEmpty()) { 
                    FieldsBySObject = Results.FieldsBySObject; }
                
                if(Results.FieldNamesBySObject != null && !Results.FieldNamesBySObject.IsEmpty()) { 
                    FieldNamesBySObject = Results.FieldNamesBySObject; }
                
                Map<Id, Recap__c> Recaps = new Map<Id, Recap__c>();
                Map<Id, Recap_Product__c> RecapProducts = null;
                Map<Id, Recap_WebID__c> RecapWebIds = null;
                
                //Map<String, List<sObject>> sObjectsByType = new Map<String, List<sObject>> ();
                
                System.debug(Results.sObjectsByType);
                
                if ((Results.sObjectsByType != null && !Results.sObjectsByType.IsEmpty())) 
                {
                    for (String key : Results.sObjectsByType.keySet()) 
                    {
                        Map<Id, sObject> sObjects = Results.sObjectsByType.get(key);
                        
                        if ((sObjects != null && !sObjects.IsEmpty()) || test.isrunningtest()) 
                        {
                            if (key == 'recap__c') { Recaps = (Map<Id, Recap__c>) sObjects; }
                            if (key == 'recap_product__c') { RecapProducts = (Map<Id, Recap_Product__c>) sObjects; }
                            if (key == 'recap_webid__c') { RecapWebIds = (Map<Id, Recap_WebID__c>) sObjects; }
                        }
                    }
                }
                
                system.debug(' ---------- ' + Recaps);
                system.debug(' ---------- ' + RecapProducts);
                system.debug(' ---------- ' + RecapWebIds);
                
                if(RecapProducts != null && !RecapProducts.IsEmpty())
                {
                    List<Schema.RecordTypeInfo> RecordList = new List<Schema.RecordTypeInfo>();
                    Schema.DescribeSObjectResult d = Schema.SObjectType.Recap_Product__c;
                    Map<Id, Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
                    System.debug('RecapProducts---'+RecapProducts);
                    
                    for(recap_product__c rp : RecapProducts.values()) { RecordList.add(rtMapById.get(rp.RecordTypeId)); }
                    
                    Set<String> RecordTypeNameSet = new Set<String>();
                    for(Schema.RecordTypeInfo sr : RecordList) { RecordTypeNameSet.add(sr.getName()); }
                    
                    if(RecordTypeNameSet.contains('LMA')){CB_Recap.isThis_LMA_StatusProcess = True;}
                    else {CB_Recap.isThis_LMA_StatusProcess = False;}
                }
                
                Map<Id, Set<String>> RecapProductsByRecapId = new Map<Id, Set<String>>();
                
                system.debug(RecapProducts);
                
                if(RecapProducts != null && !RecapProducts.IsEmpty())
                {
                    for (Id RecapProdId : RecapProducts.keyset()) 
                    {
                        Recap_Product__c RecapProd = RecapProducts.get(RecapProdId);
                        
                        system.debug(' ---------- '+RecapProd.Recap__c);
                        system.debug(RecapProd.RecordType);
                        
                        if(RecapProd.Recap__c != null && RecapProd.RecordType != null)
                        {
                            system.debug(RecapProductsByRecapId);
                            
                            Set<String> RecapProductSet = RecapProductsByRecapId.get(RecapProd.Recap__c);
                            if(RecapProductSet == null) { RecapProductSet = new Set<String>(); }
                            RecapProductSet.add(RecapProd.RecordType.Name);
                            RecapProductsByRecapId.put(RecapProd.Recap__c, RecapProductSet);
                        }
                        
                        // validate Recap Product Fields
                        Boolean CurrentProductValid = ValidateRequiredFieldsFilledIn(
                            'recap_product__c', 
                            new List<sObject>{RecapProd}, FieldsBySObject.get('recap_product__c')
                        );
                        
                        if(!CurrentProductValid) { RequiredRecapProdFieldsFilledIn = false; }
                        
                        // if Record Type is null, default to checking these values
                        //   or, if not null, and the recap record type is website, check these values
                        
                        List<Recap_Field__c> AllWebsiteFieldsList = new List<Recap_Field__c>();
                        for(Recap_Field__c rf: RecapFields){
                            if(rf.AllWebsiteField__c == True){ AllWebsiteFieldsList.add(rf); } 
                        }
                        
                        if(RecapProd.RecordType == null || (RecapProd.RecordType.Name != null && RecapProd.RecordType.Name.toLowerCase() == 'website'))
                        {                           
                            if(isThis_LMA_StatusProcess != null && !isThis_LMA_StatusProcess)
                            {
                                AllWebsiteFieldBool = ValidateRequiredFieldsFilledIn(
                                    'Recap_Product__c', 
                                    new List<Recap_Product__c>{ RecapProd }, 
                                    AllWebsitefieldsList
                                );
                                
                                System.debug(AllWebsiteFieldBool);
                            }
                        }
                    }
                }
                
                // validate Recap Fields
                RequiredRecapFieldsFilledIn = ValidateRequiredFieldsFilledIn('recap__c', Recaps.values(), FieldsBySObject.get('recap__c'));
                
                System.debug(RecapWebIds);
                if (RecapWebIds != null) 
                {
                    /*Note: validate Recap WebId Fields
                     loop through all the RecapWebIds and check for if the required fields are filled in. Even if one recap webId has it all it's
                     fields filled in then exit the loop and take the RequiredRecapWebIdFieldsFilledIn value as true */
                    
                    Boolean CurrentRecapWebIdValid;
                    
                    for(Recap_WebId__c rw: RecapWebIds.values())
                    {
                        CurrentRecapWebIdValid = ValidateRequiredFieldsFilledIn(
                            'recap_webid__c', 
                            new List<recap_webid__c> {rw}, 
                            FieldsBySObject.get('recap_webid__c')
                        );
                        if(CurrentRecapWebIdValid){ RequiredRecapWebIdFieldsFilledIn = True; break;}
                    }
                    
                   // if(!CurrentRecapWebIdValid) { RequiredRecapWebIdFieldsFilledIn = false; }
                    
                    for (Id RecapWebIDId : RecapWebIds.keyset()) 
                    {
                        Recap_WebID__c RecapWebId = RecapWebIds.get(RecapWebIDId);
                        
                        if (RecapWebId.WebID__c != null || RecapWebId.WebID_Text__c != null) { RecapWebidFieldNameFields = true; break;}
                    }
                    system.debug(CurrentRecapWebIdValid);
                }
                
                system.debug(RequiredRecapWebIdFieldsFilledIn);
                                
                // MK 2014-01-27 pulled query out of loop
                List<User> UsersWithRoles = [select id, UserRoleId, UserRole.Name from User where Id IN :UserOwnerList];
                
                if(UsersWithRoles != null && !UsersWithRoles.isEmpty()) {
                    for (user u : UsersWithRoles) { OwnerRoleMap.put(u.id, u.UserRole.Name); } }
                
                for(Recap__c R : RecapNewlist) 
                {
                    Recap__c QueriedRecap = Recaps.get(R.Id);
                    
                    // default to no value
                    R.Product__c = null;
                    
                    // clear bridge field  
                    //   (field is used to run when Recap Product or Recap WebID is updated or when the Refresh status button is clicked)
                    R.Bridge_Field__c = null;
                    
                    system.debug(RecapProductsByRecapId);
                    System.debug(RecapProductsByRecapId.get(R.Id) != null);
                    
                    // set recap product field
                    if(R != null && RecapProductsByRecapId != null && RecapProductsByRecapId.get(R.Id) != null) 
                    {
                        Set<String> RecapProductSet = RecapProductsByRecapId.get(R.Id);
                        List<String> RecapProductList = new List<String>(); 
                        if(RecapProductSet != null && !RecapProductSet.IsEmpty()) { RecapProductList.addAll(RecapProductSet); } 
                        String RecapProductString = '';  
                        
                        for(Integer i=0; i<RecapProductList.size(); i++) {
                            RecapProductString += (i!=0 ? ', ' : '') + RecapProductList[i]; }
                        
                        R.Product__c = RecapProductString;
                        System.debug('RecapProductString---'+RecapProductString);
                    }
                    
                    // get the Recap Account details
                    if(R.Account__c != null && R.Account__r == null && QueriedRecap != null) { 
                        R.Account__r = (Account) QueriedRecap.getSObject('Account__r'); }
                    
                    system.debug(R.Account__r);
                    
                    // set recap name field
                    if(R.Recap_Name__c == null && R.Account__r != null) {
                        R.Recap_Name__c = R.Account__r.Name + (R.Product__c != null ? ' - ' + R.Product__c : ''); }
                    
                    // check recap project and create if it does not exist
                    if(R.Recap_Project__c == null && R.Account__r != null) 
                    {
                        String DateString = ' - ' + DateTime.now().format('MMM YYYY').toUpperCase();
                        String RecapProjectName = R.Account__r.Name + DateString;
                        
                        Recap_Project__c RecapProject = null;
                        
                        if(R.Account__r.Dealer_Group_Name2__c != null) {
                            RecapProjectName = R.Account__r.Dealer_Group_Name2__c + DateString; }
                        
                        system.debug(RecapProjectName);
                        
                        List<Recap_Project__c> RecapProjects = [Select Id, Name From Recap_Project__c Where Name = :RecapProjectName Limit 1];
                        if(RecapProjects != null && !RecapProjects.IsEmpty()) { RecapProject = RecapProjects[0]; }
                        
                        if(RecapProject == null) {
                            RecapProjectName = R.Account__r.Name + DateString; }
                        
                        if(RecapProject == null) { RecapProject = new Recap_Project__c(Name=RecapProjectName); insert RecapProject; }
                        
                        R.Recap_Project__c = RecapProject.Id;
                    }
                    
                    if(isThis_LMA_StatusProcess != null)
                    {
                        String FinalStatus;
                        if(!isThis_LMA_StatusProcess)
                        {   
                            AllTrueStatusToBoolMap = CB_Recap.NonLMAStatusProcesser(
                                StatusToOrder, OrderToStatus, R, AllWebsiteFieldBool, OwnerRoleMap,
                                RecapWebidFieldNameFields, RequiredRecapProdFieldsFilledIn, RequiredRecapWebIdFieldsFilledIn,
                                AllTrueStatusToBoolMap, LaunchMap,FieldsBySObject);
                            
                            // Loop through and find the top order status that has all conditions true and set it as the status
                            FinalStatus = CB_Recap.StatusStringReturner(AllTrueStatusToBoolMap, StatusToOrder, OrderToStatus, OrderList);  
                        }
                        else
                        { 
                            Map<String, Map<Id, sObject>> ObjectsToValidateByType = Results.sObjectsByType;
                            // Replace the Recap__c record that was obtained by SOQL query with the current Trigger.new member
                            ObjectsToValidateByType.get('recap__c').put(R.Id, R);            
                            AllLMATrueStatusToBoolMap = CB_Recap.LMAStatusProcesser(ObjectsToValidateByType, AllLMATrueStatusToBoolMap, LMAStatusToOrder, LMAOrderToStatus, LaunchMap);
                            
                            // Loop through and find the top order status that has all conditions true and set it as the status                        
                            FinalStatus = CB_Recap.StatusStringReturner(AllLMATrueStatusToBoolMap, LMAStatusToOrder, LMAOrderToStatus, LMAOrderList);                 
                        }
                        
                        R.Status__c = FinalStatus; 
                        
                    }                            
                }
            }
        }
    }
    
    public static Map<String, List<Boolean>> NonLMAStatusProcesser(
        Map<String, String> StatusToOrder, 
        Map<String, String> OrderToStatus, 
        Recap__c R, Boolean AllWebsiteFieldBool, 
        Map<String, String> OwnerRoleMapLocal,
        Boolean RecapWebidFieldNameFields, 
        Boolean RequiredRecapProdFieldsFilledIn, 
        Boolean RequiredRecapWebIdFieldsFilledIn,
        Map<String, List<Boolean>> AllTrueStatusToBoolMap, 
        Map<String, Launch__c> LaunchMap, 
        Map<String, List<Recap_Field__c>> FieldsBySObject)
    {
        String CurrentUserRole = OwnerRoleMapLocal.get(UserInfo.getUserId());
            
        // get all the custom settings for the Non LMA statuses
        Map<String, Recap_NonLMA_Status_Conditions__c> StatusToConditionsMap = Recap_NonLMA_Status_Conditions__c.getAll();
        System.debug(StatusToConditionsMap);
        
        List<Recap_Field__c> RecapFieldList = Recap_Field__c.getAll().Values();
       
        
        List<Recap_Field__c> NonLMAFirstSetFields = new List<Recap_Field__c>();
        List<Recap_Field__c> NonLMASecondSetFields = new List<Recap_Field__c>();
        
        for(Recap_Field__c rf: RecapFieldList)
        {
            if(rf.Recap_Non_LMA_Order__c == '1'){ NonLMAFirstSetFields.add(rf); }
            if(rf.Recap_Non_LMA_Order__c == '2'){ NonLMASecondSetFields.add(rf); }
        }
        
        System.debug(NonLMAFirstSetFields);
        System.debug(NonLMASecondSetFields);
        
        // Declare all collection variables                    
        List<String> FieldList = New List<String>();
        List<Boolean> NewBoolList;
        map<string, List<Boolean>> FieldFilledInByStatus = new map<string, List<Boolean>>();
        
        List<String> StatusToConditionsMapKeyList = new List<String>();
        StatusToConditionsMapKeyList.addAll(StatusToConditionsMap.keySet());
        
        Map<String, integer> StatusToBooleanSizeMap = new Map<String, integer>();
        
        set<String> IFSRoleList = new set<String> { 'IFS', 'IFS Booking OS', 'IFS Contract Admin', 'IFS Activation OS', 'IFS Builders', 'System Administrator' }; // test as Siena Gleason
        
        // get all the fields of the custom setting in the NonLMAFieldMap
        Map<String, Schema.SObjectField> NonLMAFieldMap = Schema.SObjectType.Recap_NonLMA_Status_Conditions__c.fields.getMap();
        
        // loop through all the custom setting fields to collect only custom fields in FieldList
        for(String fieldName : NonLMAFieldMap.keySet()) 
        {
            if(NonLMAFieldMap.get(fieldName).getDescribe().isCustom()) 
            {
                FieldList.add(fieldName);
            }
        }
        
        System.debug(NonLMAFieldMap); 
        
        // loop through to make a map that has the status string (e.g 'Started - working') that points to the number of boolean values
        // or the number of conditions it has to satisfy to display that status
        
        for(integer i=0; i<StatusToConditionsMapKeyList.size(); i++)
        {
            integer k=0;
            for(integer j=0; j<FieldList.Size(); j++)
            {
                if(StatusToConditionsMap.get(StatusToConditionsMapKeyList[i]).get(FieldList[j]) == True){ k = k+1;}
            }
            
            StatusToBooleanSizeMap.put(StatusToConditionsMapKeyList[i], k); 
            StatusToOrder.put(StatusToConditionsMapKeyList[i], StatusToConditionsMap.get(StatusToConditionsMapKeyList[i]).Status_Order__c);
            OrderToStatus.put(StatusToConditionsMap.get(StatusToConditionsMapKeyList[i]).Status_Order__c, StatusToConditionsMapKeyList[i]);
        }
        
        System.debug(StatusToOrder);
        System.debug(FieldList);
        System.debug(StatusToBooleanSizeMap);
        System.debug(StatusToConditionsMap.Values());
        
        // loop through to make a map that has status string (e.g 'Started - Working') that points to a list of boolean variables to store
        // the values for each status string
        
        for(Integer j=0; j<StatusToConditionsMapKeyList.Size(); j++ )
        {
            NewBoolList = new List<Boolean>();
            FieldFilledInByStatus.Put(StatusToConditionsMapKeyList[j], NewBoolList);
            System.debug(NewBoolList.Size());
        }
        
        System.debug(FieldFilledInByStatus);
        System.debug(OwnerRoleMap);
                            
        Boolean CurrentUserInIFSRoleList = IFSRoleList.contains(CurrentUserRole);
        
        List<Boolean> BoolList;             
       
        System.debug(FieldFilledInByStatus);
        
        FieldFilledInByStatus = CB_Recap.NonLMAStatusToBooleanMapBuilder(
            FieldList,
            R,
            NonLMAFirstSetFields,
            NonLMASecondSetFields,
            AllWebsiteFieldBool,
            CurrentUserInIFSRoleList,
            RecapWebidFieldNameFields,
            RequiredRecapProdFieldsFilledIn,
            RequiredRecapWebIdFieldsFilledIn,
            StatusToConditionsMap,
            FieldFilledInByStatus,
            LaunchMap,
            FieldsBySObject);
        
        // Collect all the lists filled enitirely with true values AllTrueStatusToBoolMap
        
        AllTrueStatusToBoolMap =  CB_Recap.StatusToBooleanListReturner(FieldFilledInByStatus);         
        
        System.debug(AllTrueStatusToBoolMap);
        
        return AllTrueStatusToBoolMap;
    }
    
    public static map<string, List<Boolean>> NonLMAStatusToBooleanMapBuilder(
        List<String> FieldList,
        Recap__c R,
        List<Recap_Field__c> NonLMAFirstSetFields,
        List<Recap_Field__c> NonLMASecondSetFields,
        Boolean AllWebsiteFieldBool,
        Boolean CurrentUserInIFSRoleList,
        Boolean RecapWebidFieldNameFields,
        Boolean RequiredRecapProdFieldsFilledIn,
        Boolean RequiredRecapWebIdFieldsFilledIn,
        Map<String, Recap_NonLMA_Status_Conditions__c> StatusToConditionsMap,
        map<string, List<Boolean>> FieldFilledInByStatus,
        Map<String, Launch__c> LaunchMap,
        Map<String, List<Recap_Field__c>> FieldsBySObject){
        
        List<String> StatusStringList = new List<String>();
        StatusStringList.addAll(StatusToConditionsMap.KeySet());
        GlobalSettings__c GlobalSettings = GlobalSettings__c.getInstance();
        String ProductsLower = '';
        if(R.Product__c != null ) { ProductsLower = R.Product__c.toLowerCase(); } 
        
        for(integer i=0; i<StatusStringList.size(); i++){ // SetToListConvert - change name for readability
            
            
            System.debug(StatusStringList.size());
            System.debug(FieldList.Size());
            
            for(integer j=0; j<FieldList.Size(); j++){
                
                System.debug(StatusToConditionsMap.get(StatusStringList[i]).get(FieldList[j]));
                
                // probably can split out into another method
                if(StatusToConditionsMap.get(StatusStringList[i]).get(FieldList[j]) == True){
                    
                    System.debug(FieldList[j]); 
                    
                    if(FieldList[j] == 'AccountAndProduct_fields__c')
                    {                            
                        Boolean AccountAndProductBool = ValidateRequiredFieldsFilledIn('recap__c', new List<Recap__c>{ R }, NonLMAFirstSetFields);
                        FieldFilledInByStatus.get(StatusStringList[i]).add(AccountAndProductBool);
                        
                        System.debug(AccountAndProductBool);
                    }  
                    
                    if(FieldList[j] == 'AllFields__c')
                    {
                        Boolean AllFieldsBool = ValidateRequiredFieldsFilledIn('recap__c', new List<Recap__c>{ R }, NonLMASecondSetFields);
                        FieldFilledInByStatus.get(StatusStringList[i]).add(AllFieldsBool);
                        
                        System.debug(AllFieldsBool);
                    }
                    
                    if(FieldList[j] == 'ContainsWebsite__c')
                    {
                        if(!ProductsLower.contains('website') || AllWebsiteFieldBool){ FieldFilledInByStatus.get(StatusStringList[i]).add(True); }
                        else{ FieldFilledInByStatus.get(StatusStringList[i]).add(False); }
                        System.debug(!ProductsLower.contains('website') || AllWebsiteFieldBool);
                    }
                    
                    if(FieldList[j] == 'IFSRoleCheck__c')
                    {
                        
                        if(CurrentUserInIFSRoleList){  FieldFilledInByStatus.get(StatusStringList[i]).add(True);}
                        else{FieldFilledInByStatus.get(StatusStringList[i]).add(False);}  
                        System.debug(CurrentUserInIFSRoleList);
                    }
                    
                    if(FieldList[j] == 'NotInIFSRoleCheck__c')
                    {
                        
                        if(!CurrentUserInIFSRoleList){  FieldFilledInByStatus.get(StatusStringList[i]).add(True);}
                        else{FieldFilledInByStatus.get(StatusStringList[i]).add(False);}                             
                    }
                    
                    if(FieldList[j] == 'Launch_Attached__c')
                    {
                        
                        If(LaunchMap.get(r.id) != null){ FieldFilledInByStatus.get(StatusStringList[i]).add(True); }
                        else{FieldFilledInByStatus.get(StatusStringList[i]).add(False);}
                        
                        System.debug(LaunchMap.get(r.id) != null);
                    }
                    
                    if(FieldList[j] == 'Recap_WebIdNameFields_Filled__c')
                    {
                        
                        if(RecapWebidFieldNameFields){ FieldFilledInByStatus.get(StatusStringList[i]).add(True); }
                        else{ FieldFilledInByStatus.get(StatusStringList[i]).add(False); }
                        
                        System.debug(RecapWebidFieldNameFields);
                    }
                    
                    if(FieldList[j] == 'Required_ProductFields_Filled__c')
                    {
                        
                        if(RequiredRecapProdFieldsFilledIn){ FieldFilledInByStatus.get(StatusStringList[i]).add(True); }
                        else{ FieldFilledInByStatus.get(StatusStringList[i]).add(False); }
                        
                        System.debug(RequiredRecapProdFieldsFilledIn);
                    }
                    
                    if(FieldList[j] == 'Required_RecapFields_Filled__c')
                    {
                        
                        Boolean RequiredRecapFieldsFilledIn2 = ValidateRequiredFieldsFilledIn('recap__c', new List<Recap__c> {r}, FieldsBySObject.get('recap__c'));
                        
                        if(RequiredRecapFieldsFilledIn2){ FieldFilledInByStatus.get(StatusStringList[i]).add(True); }
                        else{ FieldFilledInByStatus.get(StatusStringList[i]).add(False); }
                        
                        System.debug(RequiredRecapFieldsFilledIn2);
                    }
                    
                    if(FieldList[j] == 'Required_WebIdFields_Filled__c')
                    {
                        
                        if(RequiredRecapWebIdFieldsFilledIn){FieldFilledInByStatus.get(StatusStringList[i]).add(True);}
                        else{ FieldFilledInByStatus.get(StatusStringList[i]).add(False); }
                        
                        System.debug(RequiredRecapWebIdFieldsFilledIn);
                    } 
                    
                    if(FieldList[j] == 'OwnerRoleMap__c')
                    {
                        
                        if(OwnerRoleMap.get(R.ownerId) == GlobalSettings.Recap_Activation_Order_Specialist__c){FieldFilledInByStatus.get(StatusStringList[i]).add(True);}
                        else{ FieldFilledInByStatus.get(StatusStringList[i]).add(False); }
                        
                        System.debug(OwnerRoleMap.get(R.ownerId) == GlobalSettings.Recap_Activation_Order_Specialist__c);
                    }
                    
                    if(FieldList[j] == 'OwnerRoleMapContainsOwnerId__c')
                    {
                        
                        if(OwnerRoleMap.containskey(r.ownerid)){FieldFilledInByStatus.get(StatusStringList[i]).add(True);}
                        else{ FieldFilledInByStatus.get(StatusStringList[i]).add(False); }
                        
                        System.debug(OwnerRoleMap.containskey(r.ownerid));
                        
                    } 
                    
                    if(FieldList[j] == 'LockedRecap__c')
                    {
                        
                        if(R.Lock_Recap__c){FieldFilledInByStatus.get(StatusStringList[i]).add(True);}
                        else{ FieldFilledInByStatus.get(StatusStringList[i]).add(False); }
                        
                        System.debug(R.Lock_Recap__c);
                    }
                    
                    if(FieldList[j] == 'CancelRecap__c')
                    {
                        
                        if(R.Cancel_Recap__c){FieldFilledInByStatus.get(StatusStringList[i]).add(True);}
                        else{ FieldFilledInByStatus.get(StatusStringList[i]).add(False); }
                        
                        System.debug(R.Cancel_Recap__c);
                    }                     
                }
                
                if(StatusToConditionsMap.get(StatusStringList[i]).get(FieldList[j]) == '0')
                {
                    FieldFilledInByStatus.get(StatusStringList[i]).add(True);                                
                }
            }
        }
            
        return FieldFilledInByStatus;
    }
    
    public static Map<String, List<Boolean>> LMAStatusProcesser(
        Map<String, Map<Id, sObject>> ObjectsToValidateByType, 
        Map<String, List<Boolean>> AllLMATrueStatusToBoolMap,
        Map<String, String> LMAStatusToOrder,
        Map<String, String> LMAOrderToStatus,
        Map<String, Launch__c> LaunchMap2)
    {
        // Declare all collections which are accessed locally 
        List<Recap_Field__c> AllRecapCSFieldList = new List<Recap_Field__c>(); 
        AllRecapCSFieldList = Recap_Field__c.getAll().Values();
        
        List<Boolean> LMABoolList;
        Map<String, List<Boolean>> LMAFieldFilledInByStatus = new Map<String, List<Boolean>>();
        List<String> StatusToConditionsList = new List<String>();                              
        List<Recap_LMAStatus_Conditions__c> RecapLMACoditions = Recap_LMAStatus_Conditions__c.getAll().Values();
        Map<String, List<Recap_Field__c>> LMAstatusToRecapFieldListMap = new Map<String, List<Recap_Field__c>>();
        
        // sort the fields
        SortUtility FieldSorter = new SortUtility(RecapLMACoditions, 'Status_Order__c'); RecapLMACoditions = FieldSorter.CustomSort();
        
        for(Recap_LMAStatus_Conditions__c rc: RecapLMACoditions)
        {
            LMAstatusToRecapFieldListMap.put(rc.Name, new List<Recap_Field__c>());
        }
        
        System.debug(LMAstatusToRecapFieldListMap.keyset());                   
        
        for(Recap_Field__c rf: AllRecapCSFieldList)
        {
            
            if(rf.LMA_Started__c != null)
            { 
                LMAstatusToRecapFieldListMap.get(rf.LMA_Started__c).add(rf);
            }
            
            if(rf.LMA_Working__c != null)
            { 
                LMAstatusToRecapFieldListMap.get(rf.LMA_Working__c).add(rf);
            } 
            
            if(rf.LMA_RdRecapComplete__c != null)
            { 
                LMAstatusToRecapFieldListMap.get(rf.LMA_RdRecapComplete__c).add(rf);
            }
            
            if(rf.LMA_WithLMAteam__c != null)
            { 
                LMAstatusToRecapFieldListMap.get(rf.LMA_WithLMAteam__c).add(rf);
            } 
            
            if(rf.LMA_RecapComplete__c != null)
            { 
                LMAstatusToRecapFieldListMap.get(rf.LMA_RecapComplete__c).add(rf);                                
            }
            
            if(rf.LMA_RecapInComplete__c != null)
            { 
                LMAstatusToRecapFieldListMap.get(rf.LMA_RecapInComplete__c).add(rf);
            }                     
        }
        
        System.debug(LMAstatusToRecapFieldListMap);
        
        Map<String, Recap_LMAStatus_Conditions__c> RecapLMAStatusConditions = new Map<String, Recap_LMAStatus_Conditions__c>();
        RecapLMAStatusConditions = Recap_LMAStatus_Conditions__c.getAll();
        
        StatusToConditionsList.addAll(RecapLMAStatusConditions.keySet());
        
        // get all the fields of the custom setting in the LMAFieldMap
        Map<String, Schema.SObjectField> LMAFieldMap = Schema.SObjectType.Recap_LMAStatus_Conditions__c.fields.getMap();
        List<String> LMACsStatusFieldList = new List<String>();
        
        // loop through all the custom setting fields to collect only custom fields in FieldList
        for(String fieldName : LMAFieldMap.keySet()) 
        {
            if(LMAFieldMap.get(fieldName).getDescribe().isCustom())
            {
                LMACsStatusFieldList.add(fieldName);
            }
        }
        
        System.debug(LMACsStatusFieldList);
        
        for(Integer j=0; j<StatusToConditionsList.Size(); j++ )
        {
            LMABoolList = new List<Boolean>();
            LMAFieldFilledInByStatus.Put(StatusToConditionsList[j], LMABoolList);
            LMAStatusToOrder.put(StatusToConditionsList[j], RecapLMAStatusConditions.get(StatusToConditionsList[j]).Status_Order__c);
            LMAOrderToStatus.put(RecapLMAStatusConditions.get(StatusToConditionsList[j]).Status_Order__c, StatusToConditionsList[j]);
            System.debug(LMABoolList.Size());
        }
        
        System.debug(LMAStatusToOrder);
        System.debug(LMAOrderToStatus);
        System.debug(LMAFieldFilledInByStatus);           
        
        System.debug(LMAFieldFilledInByStatus); 
        
        // Collect all the lists filled enitirely with true values AllLMATrueStatusToBoolMap 
        
        LMAFieldFilledInByStatus = CB_Recap.LMAStatusToBooleanMapBuilder(
            LMAFieldFilledInByStatus,
            LMACsStatusFieldList,
            ObjectsToValidateByType,
            RecapLMAStatusConditions,
            LaunchMap2,
            LMAstatusToRecapFieldListMap);
        
        AllLMATrueStatusToBoolMap = CB_Recap.StatusToBooleanListReturner(LMAFieldFilledInByStatus);
        
        System.debug(AllLMATrueStatusToBoolMap);
                                                                    
        return AllLMATrueStatusToBoolMap;                                                          
    }
    
    public Static Map<String, List<Boolean>> LMAStatusToBooleanMapBuilder(
        Map<String, List<Boolean>> LMAFieldFilledInByStatus,
        List<String> LMACsStatusFieldList,
        Map<String, Map<Id, sObject>> ObjectsToValidateByType,
        Map<String, Recap_LMAStatus_Conditions__c> RecapLMAStatusConditions,
        Map<String, Launch__c> LaunchMap2,
        Map<String, List<Recap_Field__c>> LMAstatusToRecapFieldListMap)
    {
        Boolean[] LMAarrayBoolList = new Boolean[LMACsStatusFieldList.size()];
        
        System.debug(LMAarrayBoolList);
        
        for(String key: RecapLMAStatusConditions.KeySet()){
            
            System.debug(RecapLMAStatusConditions.KeySet());
            
            for(integer i=0; i<LMACsStatusFieldList.size(); i++){
                
                // can probably split into a separate method
                if(RecapLMAStatusConditions.get(key).get(LMACsStatusFieldList[i]) == True){
                    
                    if(LMACsStatusFieldList[i] == 'launch_attached__c')
                    {
                        if(LaunchMap2.get(ObjectsToValidateByType.get('recap__c').values()[0].id) != null)
                        {
                            LMAFieldFilledInByStatus.get(key).add(True);
                        }
                        else{ LMAFieldFilledInByStatus.get(key).add(False); }
                    }
                    
                    if(LMACsStatusFieldList[i] == 'withlmateam_check__c')
                    {
                        Boolean TempBool1 = LMAarrayBoolList[i];
                        TempBool1 = ProcessBeforeValidateMethod(ObjectsToValidateByType, LMAstatusToRecapFieldListMap.get(key));
                        LMAFieldFilledInByStatus.get(key).add(TempBool1);                                         
                    }
                    
                    if(LMACsStatusFieldList[i] == 'closedcompletefield_check__c')
                    {
                        Boolean TempBool2 = LMAarrayBoolList[i];
                        TempBool2 = ProcessBeforeValidateMethod(ObjectsToValidateByType, LMAstatusToRecapFieldListMap.get(key));
                        LMAFieldFilledInByStatus.get(key).add(TempBool2);                                  
                    }
                    
                    if(LMACsStatusFieldList[i] == 'closed_incomplete__c')
                    {
                        Boolean TempBool3 = LMAarrayBoolList[i];
                        TempBool3 = ProcessBeforeValidateMethod(ObjectsToValidateByType, LMAstatusToRecapFieldListMap.get(key));
                        LMAFieldFilledInByStatus.get(key).add(TempBool3);                    
                    }
                    
                    if(LMACsStatusFieldList[i] == 'rdrecapcomplete_check__c')
                    {
                        Boolean TempBool4 = LMAarrayBoolList[i];
                        TempBool4 = ProcessBeforeValidateMethod(ObjectsToValidateByType, LMAstatusToRecapFieldListMap.get(key));
                        LMAFieldFilledInByStatus.get(key).add(TempBool4);                                
                    } 
                    
                    if(LMACsStatusFieldList[i] == 'workingfield_check__c')
                    {
                        Boolean TempBool5 = LMAarrayBoolList[i];
                        System.debug(LMAstatusToRecapFieldListMap.get(key));
                        TempBool5 = ProcessBeforeValidateMethod(ObjectsToValidateByType, LMAstatusToRecapFieldListMap.get(key));
                        LMAFieldFilledInByStatus.get(key).add(TempBool5); 
                        System.debug(LMAFieldFilledInByStatus.get(key).add(TempBool5));
                    }
                    
                    if(LMACsStatusFieldList[i] == 'startedfield_check__c')
                    {
                        Boolean TempBool6 = LMAarrayBoolList[i];
                        TempBool6 = ProcessBeforeValidateMethod(ObjectsToValidateByType, LMAstatusToRecapFieldListMap.get(key));
                        LMAFieldFilledInByStatus.get(key).add(TempBool6);                                   
                    }
                }
                
                if(RecapLMAStatusConditions.get(key).get(LMACsStatusFieldList[i]) == '0'){
                    LMAFieldFilledInByStatus.get(key).add(True);
                }
            }
        }
        
        return LMAFieldFilledInByStatus;
    }
    
    public Static Map<String, List<Boolean>> StatusToBooleanListReturner(map<string, List<Boolean>> FieldFilledInByStatus)
    {
        Map<String, List<Boolean>> AllTrueStatusToBoolMap = new Map<String, List<Boolean>>();
             
        for(String key: FieldFilledInByStatus.KeySet())
        {
            for(integer i=0; i<FieldFilledInByStatus.get(key).size(); i++)
            {
                if(FieldFilledInByStatus.get(key)[i] == false){ Break;}
                else if(FieldFilledInByStatus.get(key)[i] == True 
                        && i == FieldFilledInByStatus.get(key).size()-1){ AllTrueStatusToBoolMap.put(key, FieldFilledInByStatus.get(key));}
            }
        }
        
        return AllTrueStatusToBoolMap;
    }
    
    public Static String StatusStringReturner(
        Map<String, List<Boolean>> AllTrueStatusToBoolMap, 
        Map<String, String> StatusToOrder, Map<String, String> OrderToStatus, 
        List<String> OrderList)
    {
        List<String> AllTrueStatusList = new List<String>();  
        AllTrueStatusList.addAll(AllTrueStatusToBoolMap.keySet());
        
        for(integer i=0; i<AllTrueStatusList.size(); i++)
        {
            OrderList.add(StatusToOrder.get(AllTrueStatusList[i]));
            System.debug(StatusToOrder.get(AllTrueStatusList[i]));
        }
        
        OrderList.Sort();  
        if(!OrderList.isEmpty())
        {
            Return OrderToStatus.get(OrderList[OrderList.size()-1]);
        }
        else { Return null; }
    }
    
    public static void InvokeRecapStatusUpdate(List<sObject> objs, String RecapIdField) 
    {
        Map<Id, Recap__c> RecapMap = new Map <Id, Recap__c> ();
        
        // query the recaps
        List<String> RecapIdList = new List<String> ();
        for(sObject s : objs) 
        {
            if(RecapIdField != null) 
            {
                String RecapId = null;
                try { RecapId = (String) s.get(RecapIdField); }
                catch(Exception e) { system.debug(e); }
                
                if(RecapId != null) { RecapIdList.add(RecapId); }
            }
        }
        
        RecapMap = new Map<Id, Recap__c>([
            select Id, Bridge_Field__c
            from Recap__c
            where Id IN :RecapIdList
        ]);
        
        Map<Id, Recap__c> RecapList = new Map<Id, Recap__c> ();
        
        // update the recaps to invoke status update trigger
        for(sObject s : objs) 
        {
            String RecapId = null;
            try { RecapId = (String) s.get(RecapIdField); }
            catch(Exception e) { system.debug(e); }
            
            if(RecapMap.containskey(RecapId)) 
            {
                Recap__c Recap = RecapMap.get(RecapId);
                Recap.Bridge_Field__c = s.Id;
                RecapList.put(RecapId, Recap);
            }
        }
        
        update RecapList.values();
    }
}