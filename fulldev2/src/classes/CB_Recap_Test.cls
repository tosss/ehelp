@IsTest 
public class CB_Recap_Test
{
    public static testmethod void InstantiateObjectResults()
    {
        CB_Recap.ObjectResults ObjectResults = new CB_Recap.ObjectResults();
        
        ObjectResults.Success = true;
        ObjectResults.result_RecapFieldsBySection = new Map<String, List<Recap_Field__c>>();
        ObjectResults.result_RecapFieldsByProduct = new Map<String, List<Recap_Field__c>>();
        ObjectResults.sObjectsByType = new Map<String, Map<Id, sObject>>();
    }
    
    public static testmethod void QueryObjectResults()
    {
        // generate some recap fields
        List<Recap_Field__c> RecapFields = GenerateRecapFields();
        
        // insert a new recap account
        Account RecapAccount = DS_TestObjects.NewAccount_Inserted();
        
        // create, insert, and requery the recap
        RecordType GlobalRecapRecordType = [Select Id, Name From RecordType Where sObjectType = 'Recap__c' And Name like '%Global%' limit 1];
        Recap__c Recap = new Recap__c(Account__c = RecapAccount.Id); 
        if(GlobalRecapRecordType != null) { Recap.RecordTypeId = GlobalRecapRecordType.Id; } 
        insert Recap;
        
        //list<Recap__C> testlist= new list<Recap__c>();
        //testlist.add(recap);
        Recap = [Select Id, Name, RecordTypeId From Recap__c Where Id = :Recap.Id];
        //Insert Recap product
        Recap_Product__c rp = NewRecapProduct();
        rp.recap__c = Recap.Id;  
        insert rp;
        
        Launch__c l = new Launch__c();
        l.Recap__c = Recap.Id;
        Insert l;
        
        //CB_Recap.RecapBeforeInsertTriggerHandler(testlist);
        // Insert WebId
        WebID__c WebId = new WebID__c();
        WebId.Name = 'test-webid-001';
        WebId.Account__c = RecapAccount.Id;
        WebId.Account__r = RecapAccount;
        insert WebId;
        
        // Insert Recap webid
        Recap_WebID__c rw = new Recap_WebID__c();
        rw.Recap__c = Recap.Id;
        rw.webid__c = WebId.Id;
        rw.Product__c = 'Website';
        rw.WebID_Text__c = 'test-webid-001';
        insert rw;
        
        
        
        // if the recordtype was not found, query what recordtype was used on the recap
        RecordType RecapRecordType = [Select Id, Name From RecordType Where Id = :Recap.RecordTypeId Limit 1];
        
        CB_Recap.ObjectResults ObjectResults = CB_Recap.QueryObjectResults(new List<Id>{Recap.Id}, RecapFields); 
        
        
    }
    
    public static testmethod void GetRequiredFields()
    {
        // generate some recap fields
        List<Recap_Field__c> RecapFields = GenerateRecapFields();
    }
    
    public static testmethod void UpdateAccountsOnRecapProducts()
    {
        // generate some recap fields
        List<Recap_Field__c> RecapFields = GenerateRecapFields();
        
        User u = DS_TestObjects.NewUser_Inserted();
        Account a = DS_TestObjects.NewAccount_Inserted(); 
        Account a2 = DS_TestObjects.NewAccount_Inserted(); 
        Contact c = DS_TestObjects.NewContact(); c.AccountId = a.Id; 
        c.Role__c = 'Test Role'; // 9/29
        insert c;
        Contact c2 = DS_TestObjects.NewContact(); c2.AccountId = a2.Id; insert c2;
        
        // create, insert, and requery the recap
        RecordType GlobalRecapRecordType = [Select Id, Name From RecordType Where sObjectType = 'Recap__c' And Name like '%Global%' limit 1];
        
        // Recap
        Recap__c r = NewRecap();
        r.account__c = c.AccountId;
        r.Primary_Contact__c = c.Id;
        r.Product__c = 'Website';
        if(GlobalRecapRecordType != null) { r.RecordTypeId = GlobalRecapRecordType.Id; } 
        insert r;
        
        Launch__c l = new Launch__c();
        l.Recap__c = r.Id;
        Insert l;
        
        // RecapProduct
        Recap_Product__c rp = NewRecapProduct();
        rp.recap__c = r.Id;  
        insert rp;
        
        Map<Id, Recap__c> NewMap = new Map<Id, Recap__c>{r.Id=>r.clone(true,true)};
        
        r.Account__c = c2.AccountId;
        r.Primary_Contact__c = c2.Id;
        Map<Id, Recap__c> OldMap = new Map<Id, Recap__c>{r.Id=>r.clone(true,true)};
        
        CB_Recap.UpdateAccountsOnRecapProducts(NewMap, OldMap);
    }
    
    public static testmethod void CheckDuplicateRecapProducts()
    {
        // generate some recap fields
        List<Recap_Field__c> RecapFields = GenerateRecapFields();
        
        // insert a new recap account
        Account RecapAccount = DS_TestObjects.NewAccount_Inserted();
        
        // create, insert, and requery the recap
        RecordType GlobalRecapRecordType = [Select Id, Name From RecordType Where sObjectType = 'Recap__c' And Name like '%Global%' limit 1];
        Recap__c Recap = new Recap__c(Account__c = RecapAccount.Id); 
        if(GlobalRecapRecordType != null) { Recap.RecordTypeId = GlobalRecapRecordType.Id; } 
        insert Recap;
        
        Launch__c l = new Launch__c();
        l.Recap__c = Recap.Id;
        Insert l;
        
        RecordType RecapProductRecordType 
            = [Select Id, Name From RecordType Where Name like '%Website%' And sObjectType='Recap_Product__c'];
        
        List<Recap_Product__c> RecapProducts = new List<Recap_Product__c>();
        RecapProducts.add(new Recap_Product__c(Recap__c=Recap.Id,RecordTypeId=RecapProductRecordType.Id));
        RecapProducts.add(new Recap_Product__c(Recap__c=Recap.Id,RecordTypeId=RecapProductRecordType.Id));
        insert RecapProducts;
        
        Recap = [
            Select Id, Name, RecordTypeId, (Select Id, Name, Recap__c, RecordTypeId, RecordType.Name From Recap_Products__r) 
            From Recap__c 
            Where Id = :Recap.Id
        ];
        
        CB_Recap.CheckDuplicateRecapProducts(new Map<Id, Recap__c>{Recap.Id => Recap}, RecapProducts);
        
    }
    public static testmethod void CheckDuplicateRecapProducts2()
    {
        // generate some recap fields
        List<Recap_Field__c> RecapFields = GenerateRecapFields();
        
        // insert a new recap account
        Account RecapAccount = DS_TestObjects.NewAccount_Inserted();
        
        // create, insert, and requery the recap
        RecordType GlobalRecapRecordType = [Select Id, Name From RecordType Where sObjectType = 'Recap__c' And Name like '%Global%' limit 1];
        Recap__c Recap = new Recap__c(Account__c = RecapAccount.Id); 
        if(GlobalRecapRecordType != null) { Recap.RecordTypeId = GlobalRecapRecordType.Id; } 
        insert Recap;
        
        Launch__c l = new Launch__c();
        l.Recap__c = Recap.Id;
        Insert l;
        
         RecordType RecapProductRecordType2 
            = [Select Id, Name From RecordType Where Name like '%lma%' And sObjectType='Recap_Product__c'];
            
        List<Recap_Product__c> RecapProducts2 = new List<Recap_Product__c>();
        RecapProducts2.add(new Recap_Product__c(Recap__c=Recap.Id,RecordTypeId=RecapProductRecordType2.Id));
        RecapProducts2.add(new Recap_Product__c(Recap__c=Recap.Id,RecordTypeId=RecapProductRecordType2.Id));
        insert RecapProducts2;
        
        Recap = [
            Select Id, Name, RecordTypeId, (Select Id, Name, Recap__c, RecordTypeId, RecordType.Name From Recap_Products__r) 
            From Recap__c 
            Where Id = :Recap.Id
        ];
        
        
        CB_Recap.CheckDuplicateRecapProducts(new Map<Id, Recap__c>{Recap.Id => Recap}, RecapProducts2);
    }
    
    static testMethod void TestRecapTriggers()
    {
        GlobalSettings__c gs = new GlobalSettings__c(Recap_Activation_Order_Specialist__c='IFS Activation OS'); insert gs;
        
        User u = DS_TestObjects.NewUser_Inserted();
        Account a = DS_TestObjects.NewAccount_Inserted(); 
        a.CBLTBillStreet__c ='abcd'; a.CBLTBillCity__c ='Seattle'; a.CBLTBillState__c ='WA'; a.CBLTBillZip__c = '12345';
        a.CBLTBillCountry__c = 'USA'; a.Phone = '1234567890'; a.Account_Number__c = '1234'; Update a;
        Contact c = DS_TestObjects.NewContact(); c.AccountId = a.Id;
        c.Role__c = 'Test Role'; // 9/29
        insert c;
        
        // Get Recap, LMA and Non-LMA recap Product custom settings
        List<Recap_Field__c> RecapFields = CB_Recap_Test.GenerateRecapFields();
        List<Recap_LMAStatus_Conditions__c> RecapLMAConditions = CB_Recap_Test.GenerateRecapLMACoditionsCustomSettings();
        List<Recap_NonLMA_Status_Conditions__c > RecapNonLMAConditions = CB_Recap_Test.GenerateRecapNonLMACoditionsCustomSettings();
        
        // 2014-01-20 MK - should make this test class generic to use the Custom Settings instead 
        // of the hard-coded field names in the future.
        
        // create, insert, and requery the recap
        RecordType GlobalRecapRecordType = [Select Id, Name From RecordType Where sObjectType = 'Recap__c' And Name like '%Global%' limit 1];
        
        // Recap
        Recap__c r = CB_Recap_Test.NewRecap();
        r.Account__c = c.AccountId;
        r.Brand__c = 'Acura';
        r.product__c = 'website';
        r.Primary_Contact__c = c.id;
        if(GlobalRecapRecordType != null) { r.RecordTypeId = GlobalRecapRecordType.Id; } 
        insert r;
        
        Launch__c l = new Launch__c();
        l.Recap__c = r.Id;
        Insert l;
        
        // RecapProduct
        Recap_Product__c rp = CB_Recap_Test.NewRecapProduct();
        rp.recap__c = r.Id;  
        insert rp;
        
        // WebID
        WebID__c WebId = new WebID__c();
        WebId.Name = 'test-webid-001';
        WebId.Account__c = a.Id;
        WebId.Account__r = a;
        insert WebId;
        
        // Recap WebID
        Recap_WebID__c rw = new Recap_WebID__c();
        rw.Recap__c = r.Id;
        rw.WebID__c = WebId.Id;
        rw.Product__c = 'Website';
        rw.WebID_Text__c = 'test-webid-001';
        insert rw;
        
        system.debug('---Testing before Insert Trigger Handler for Recap');
        
        CB_Recap.RunStatusUpdate = true;
        CB_Recap.RecapBeforeInsertTriggerHandler(new list<Recap__c>{r});
        
        RecordType LmaRecapProductRecordType = [
            Select Id, Name From RecordType Where sObjectType = 'Recap_Product__c' And Name like '%lma%' limit 1];
        
        rp.RecordTypeId = LmaRecapProductRecordType.Id;
        rp.RecordType = LmaRecapProductRecordType;
        rp.RecordType.Name = LmaRecapProductRecordType.Name;
        Update rp;
        
        rw.Product__c = 'lma';
        Update rw;
        
        system.debug('---Testing before Insert Trigger Handler for LMA Recap Product');
        
        CB_Recap.RunStatusUpdate = true;
        CB_Recap.RecapBeforeInsertTriggerHandler(new list<Recap__c>{r});
    }
    
    public static testmethod void ValidateRequiredFieldsFilledIn()
    {
        Account a = DS_TestObjects.NewAccount_Inserted(); 
        Contact c = DS_TestObjects.NewContact(); c.AccountId = a.Id;
        c.Role__c = 'Test Role'; // 9/29
        insert c;
        
        List<Recap_Field__c> RecapFields = GenerateRecapFields();
        
        // Recap
        Recap__c r = NewRecap();
        r.account__c = c.AccountId;
        r.Primary_Contact__c = c.id;
        insert r;
        
        Launch__c l = new Launch__c();
        l.Recap__c = r.Id;
        Insert l;
        
        // RecapProduct
        Recap_Product__c rp = NewRecapProduct();
        rp.recap__c = r.Id;
        insert rp;
        
        CB_Recap.ValidateRequiredFieldsFilledIn('recap_product__c', new List<Recap_Product__c>{rp}, RecapFields);
    }
    
    public static testmethod void ProcessBeforeValidateMethod()
    {
        Account a = DS_TestObjects.NewAccount_Inserted(); 
        Contact c = DS_TestObjects.NewContact(); c.AccountId = a.Id; insert c;
        List<Recap_Field__c> RecapFields = CB_Recap_Test.GenerateRecapFields();
        List<Recap_LMAStatus_Conditions__c> RecapLMAConditions = CB_Recap_Test.GenerateRecapLMACoditionsCustomSettings();
        GlobalSettings__c gs = new GlobalSettings__c(Recap_Activation_Order_Specialist__c='IFS Activation OS'); insert gs;
        // create, insert, and requery the recap
        RecordType GlobalRecapRecordType = [Select Id, Name From RecordType Where sObjectType = 'Recap__c' And Name like '%Global%' limit 1];
        
        // Recap
        Recap__c r = CB_Recap_Test.NewRecap();
        r.Account__c = c.AccountId;
        r.Brand__c = 'Acura';
        r.product__c = 'website';
        r.Primary_Contact__c = c.id;
        if(GlobalRecapRecordType != null) { r.RecordTypeId = GlobalRecapRecordType.Id; } 
        insert r;
        
        Launch__c l = new Launch__c();
        l.Recap__c = r.Id;
        Insert l;
        
        // RecapProduct
        Recap_Product__c rp = CB_Recap_Test.NewRecapProduct();
        rp.recap__c = r.Id;  
        insert rp;
        
        // WebID
        WebID__c WebId = new WebID__c();
        WebId.Name = 'test-webid-001';
        WebId.Account__c = a.Id;
        WebId.Account__r = a;
        insert WebId;
        
        // Recap WebID
        Recap_WebID__c rw = new Recap_WebID__c();
        rw.Recap__c = r.Id;
        rw.WebID__c = WebId.Id;
        rw.Product__c = 'Website';
        rw.WebID_Text__c = 'test-webid-001';
        insert rw;
        
        Map<String, Map<Id, sObject>> ObjectsToValidateByType = new Map<String, Map<Id, sObject>>();
        ObjectsToValidateByType.put('Recap__c', new Map<Id, Recap__c>{r.Id => r});
        ObjectsToValidateByType.put('Recap_Product__c', new Map<Id, Recap_Product__c>{rp.Id => rp});
        ObjectsToValidateByType.put('Recap_WebId__c', new Map<Id, Recap_WebId__c>{rw.Id => rw});
        
        CB_Recap.ProcessBeforeValidateMethod(ObjectsToValidateByType, RecapFields);
    }
    
    public static testmethod Recap__c NewRecap()
    {
        // get the global record type
        RecordType GlobalRecapRecordType = [Select Id, Name From RecordType Where sObjectType = 'Recap__c' And Name like '%Global%' limit 1];
        
        // Recap
        Recap__c r = new Recap__c();
        r.BAC_Dealer_Code__c = '123456';
        r.Product__c = 'lma';
        r.BAC_Dealer_Code__c = 'yh890';
        r.Lock_Recap__c = false;
        r.Cancel_Recap__c = false;
        if(GlobalRecapRecordType != null) { r.RecordTypeId = GlobalRecapRecordType.Id; } 
        
        return r;
    }
    
    public static testmethod Recap_Product__c NewRecapProduct()
    {
        // get the website record type
        RecordType WebsiteRecapProductRecordType = [Select Id, Name From RecordType Where sObjectType = 'Recap_Product__c' And Name like '%Website%' limit 1];
        
        Recap_Product__c rp = new Recap_Product__c();
        rp.OEM__c = 'Honda';
        rp.Design__c = 'Capella';
        rp.Theme__c = 'Black';
        rp.Layout__c = 'Home Page Flex';
        rp.Color__c = 'Safari';
        rp.Background__c = 'Black';
        rp.Mock_Up_Attached__c = true;
        rp.RecordTypeId = WebsiteRecapProductRecordType.Id;
        rp.RecordType = WebsiteRecapProductRecordType;
        rp.RecordType.Name = WebsiteRecapProductRecordType.Name;
        
        return rp;
    }
    
    public static testmethod List<Recap_NonLMA_Status_Conditions__c > GenerateRecapNonLMACoditionsCustomSettings()
    {
        // Generate some recap NonLMA conditions custom settings
        List<Recap_NonLMA_Status_Conditions__c> RecapNonLMAConditions = new List<Recap_NonLMA_Status_Conditions__c>();
        RecapNonLMAConditions.add(new Recap_NonLMA_Status_Conditions__c(Name = 'Started - Working', Status_Order__c = '1', AccountAndProduct_fields__c = True));
        RecapNonLMAConditions.add(new Recap_NonLMA_Status_Conditions__c(Name = 'Ready For IFS', Status_Order__c = '2', AccountAndProduct_fields__c = True, AllFields__c = True, ContainsWebsite__c = True, NotInIFSRolecheck__c = True));
        RecapNonLMAConditions.add(new Recap_NonLMA_Status_Conditions__c(Name = 'With IFS - Starting', Status_Order__c = '3', AccountAndProduct_fields__c = True, AllFields__c = True, ContainsWebsite__c = True, IFSRoleCheck__c = True));
        RecapNonLMAConditions.add(new Recap_NonLMA_Status_Conditions__c(Name = 'With IFS - Booked', Status_Order__c = '4', AccountAndProduct_fields__c = True, AllFields__c = True, ContainsWebsite__c = True, IFSRoleCheck__c = True, Launch_Attached__c = True, Recap_WebIdNameFields_Filled__c = True));
        RecapNonLMAConditions.add(new Recap_NonLMA_Status_Conditions__c(Name = 'With IFS - Working', Status_Order__c = '5', AccountAndProduct_fields__c = True, AllFields__c = True, ContainsWebsite__c = True, IFSRoleCheck__c = True, Launch_Attached__c = True, Recap_WebIdNameFields_Filled__c = True, OwnerRoleMapContainsOwnerId__c = True));
        RecapNonLMAConditions.add(new Recap_NonLMA_Status_Conditions__c(Name = 'Recap Complete', Status_Order__c = '6', AccountAndProduct_fields__c = True, AllFields__c = True, ContainsWebsite__c = True, IFSRoleCheck__c = True, Launch_Attached__c = True, Recap_WebIdNameFields_Filled__c = True, OwnerRoleMapContainsOwnerId__c = True, Required_ProductFields_Filled__c = True, Required_RecapFields_Filled__c = True, Required_WebIdFields_Filled__c = True));
        RecapNonLMAConditions.add(new Recap_NonLMA_Status_Conditions__c(Name = 'Closed - Complete', Status_Order__c = '7', AccountAndProduct_fields__c = True, AllFields__c = True, ContainsWebsite__c = True, IFSRoleCheck__c = True, Launch_Attached__c = True, Recap_WebIdNameFields_Filled__c = True, Required_ProductFields_Filled__c = True, Required_RecapFields_Filled__c = True, Required_WebIdFields_Filled__c = True, LockedRecap__c = True));
        RecapNonLMAConditions.add(new Recap_NonLMA_Status_Conditions__c(Name = 'Closed - Incomplete', Status_Order__c = '8', CancelRecap__c = True));
        RecapNonLMAConditions.add(new Recap_NonLMA_Status_Conditions__c(Name = 'Open', Status_Order__c = '0'));
        
        insert RecapNonLMAConditions;
        return RecapNonLMAConditions;
        
    }
    
    public static testmethod List<Recap_LMAStatus_Conditions__c > GenerateRecapLMACoditionsCustomSettings()
    {
        // Generate some recap LMA conditions custom settings
        List<Recap_LMAStatus_Conditions__c> RecapLMAConditions = new List<Recap_LMAStatus_Conditions__c>();
        RecapLMAConditions.add(new Recap_LMAStatus_Conditions__c(Name = 'Started', Status_Order__c = '1', StartedField_Check__c = True));
        RecapLMAConditions.add(new Recap_LMAStatus_Conditions__c(Name = 'Working', Status_Order__c = '2', WorkingField_Check__c = True));
        RecapLMAConditions.add(new Recap_LMAStatus_Conditions__c(Name = 'RD Recap Complete', Status_Order__c = '3', RdRecapComplete_Check__c = True));
        RecapLMAConditions.add(new Recap_LMAStatus_Conditions__c(Name = 'With LMA Team', Status_Order__c = '4', WithLMAteam_Check__c = True));
        RecapLMAConditions.add(new Recap_LMAStatus_Conditions__c(Name = 'Closed - Complete', Status_Order__c = '5', ClosedCompleteField_Check__c = True, Launch_Attached__c = True));
        RecapLMAConditions.add(new Recap_LMAStatus_Conditions__c(Name = 'Closed - Incomplete', Status_Order__c = '6', Closed_Incomplete__c = True));
        RecapLMAConditions.add(new Recap_LMAStatus_Conditions__c(Name = 'Open', Status_Order__c = '0'));
        
        insert RecapLMAConditions;
        return RecapLMAConditions;
        
    }
    
    public static testmethod List<Recap_Field__c> GenerateRecapFields()
    {
        // generate some recap fields
        List<Recap_Field__c> RecapFields = new List<Recap_Field__c>();
        RecapFields.add(new Recap_Field__c(Name = '0001', sObject__c = 'Recap__c', Section__c = 'Order Information', Label__c = 'Name', Field_API_Name__c = 'Name', Required__c = true));
        RecapFields.add(new Recap_Field__c(Name = '0002', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Name', Field_API_Name__c = 'Name', Website_Product__c = true, Required__c = true));
        RecapFields.add(new Recap_Field__c(Name = '0003', sObject__c = 'Recap_WebId__c', Section__c = 'Order Information', Label__c = 'Name', Field_API_Name__c = 'Name', Required__c = true));
        
        RecapFields.add(new Recap_Field__c(Name = '0004', sObject__c = 'Recap_WebId__c', Section__c = 'Order Information', Label__c = 'WebID', Field_API_Name__c = 'WebId__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0005', sObject__c = 'Recap_WebId__c', Section__c = 'Order Information', Label__c = 'WebID Text', Field_API_Name__c = 'WebId_Text__c', Required__c = false));
        
        RecapFields.add(new Recap_Field__c(Name = '0006', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'OEM', Field_API_Name__c = 'Oem__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0007', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Design', Field_API_Name__c = 'Design__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0008', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Color', Field_API_Name__c = 'Color__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0009', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Theme', Field_API_Name__c = 'Theme__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0010', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Layout', Field_API_Name__c = 'Layout__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0011', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Background', Field_API_Name__c = 'Background__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0012', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Mock Up Attached', Field_API_Name__c = 'Mock_Up_Attached__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0013', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'LMA code', Field_API_Name__c = 'LMA_code__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0014', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Brand', Field_API_Name__c = 'Brand__c', Required__c = false));
        
        RecapFields.add(new Recap_Field__c(Name = '0015', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Region', Field_API_Name__c = 'Region__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0016', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'DMA Code', Field_API_Name__c = 'DMA_code__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0017', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Dealers in LMA', Field_API_Name__c = 'Dealers_in_LMA__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0018', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'LMA super group', Field_API_Name__c = 'LMA_Super_group__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0019', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Order Submitter', Field_API_Name__c = 'Order_Submitter__c', Required__c = false));
        
        RecapFields.add(new Recap_Field__c(Name = '0020', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'LMA meeting date', Field_API_Name__c = 'LMA_meeting_date__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0021', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'LMA history overview', Field_API_Name__c = 'LMA_History_Overview__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0022', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'LMA hurts', Field_API_Name__c = 'LMA_Hurts__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0023', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'LMA health', Field_API_Name__c = 'LMA_Health__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0024', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Agency 720 contact name', Field_API_Name__c = 'Agency_720_Contact_Name__c', Required__c = false));
        
        RecapFields.add(new Recap_Field__c(Name = '0025', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Agency 720 contact phone', Field_API_Name__c = 'Agency_720_Contact_Phone__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0026', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Agency 720 contact email', Field_API_Name__c = 'Agency_720_Contact_Email__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0027', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'USIM Contact Name', Field_API_Name__c = 'USIM_Contact_Name__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0028', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'USIM Contact Phone', Field_API_Name__c = 'USIM_Contact_Phone__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0029', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'USIM Contact Email', Field_API_Name__c = 'USIM_Contact_Email__c', Required__c = false));
        
        RecapFields.add(new Recap_Field__c(Name = '0030', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'LMA President Name', Field_API_Name__c = 'LMA_President_Name__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0031', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'LMA President Phone', Field_API_Name__c = 'LMA_President_Phone__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0032', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'LMA President Email', Field_API_Name__c = 'LMA_President_Email__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0033', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Model Year Trim1', Field_API_Name__c = 'Model_Year_Trim1__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0034', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Proforma Presented', Field_API_Name__c = 'Proforma_Presented__c', Required__c = false));
        
        RecapFields.add(new Recap_Field__c(Name = '0035', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Proforma Approved', Field_API_Name__c = 'Proforma_Approved__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0036', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Strategy', Field_API_Name__c = 'Strategy__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0037', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Offer Type', Field_API_Name__c = 'Offer_Type__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0038', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Offer Type', Field_API_Name__c = 'Conquest_Makes_Models__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0039', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Audience Demographics', Field_API_Name__c = 'Audience_Demographics__c', Required__c = false));
        
        RecapFields.add(new Recap_Field__c(Name = '0040', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Model Feature Highlights', Field_API_Name__c = 'Model_Feature_Highlights__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0041', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'A720 Creative Summary Attached', Field_API_Name__c = 'A720_Creative_Summary_Attached__c', Required__c = false, LMA_Started__c = 'Started', LMA_Working__c = 'Working', LMA_RdRecapComplete__c = 'RD Recap Complete', LMA_WithLMAteam__c = 'With LMA Team', LMA_RecapComplete__c = 'Closed - Complete', LMA_RecapInComplete__c = 'Closed - Incomplete'));
        RecapFields.add(new Recap_Field__c(Name = '0042', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Generic Mock Up Presented', Field_API_Name__c = 'Generic_Mock_Up_Presented__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0043', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Default National Incentive', Field_API_Name__c = 'Default_National_Incentive__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0044', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Regional Incentive', Field_API_Name__c = 'Regional_Incentive__c', Required__c = false));
        
        RecapFields.add(new Recap_Field__c(Name = '0045', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Creative Mockup Needed', Field_API_Name__c = 'Creative_Mockup_Needed__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0046', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Special Instructions', Field_API_Name__c = 'Special_Instructions__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0047', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Community Event', Field_API_Name__c = 'Community_Event__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0048', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'LMA Logo Attached', Field_API_Name__c = 'LMA_Logo_Attached__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0049', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Monthly Budget Amount', Field_API_Name__c = 'Monthly_Budget_Amount__c', Required__c = false));
        
        RecapFields.add(new Recap_Field__c(Name = '0050', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Total Budget Amount', Field_API_Name__c = 'Total_Budget_Amount__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0051', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Proforma Attached', Field_API_Name__c = 'Proforma_Attached__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0052', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'RFP Received', Field_API_Name__c = 'RFP_Received__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0053', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Contract Start Date', Field_API_Name__c = 'Contract_Start_Date__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0054', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Contract End Date', Field_API_Name__c = 'Contract_End_Date__c', Required__c = false));
        
        RecapFields.add(new Recap_Field__c(Name = '0055', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Total Contract Month', Field_API_Name__c = 'Total_Contract_Months__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0056', sObject__c = 'Recap__c', Section__c = 'Order Information', Label__c = 'Dealer Group Name', Field_API_Name__c = 'Dealer_Group_Name2__c', Required__c = true, Lookup_sObject_Type__c = 'Account', Lookup_sObject__c ='Account__r'));
        RecapFields.add(new Recap_Field__c(Name = '0057', sObject__c = 'Recap__c', Section__c = 'Order Information', Label__c = 'Brand', Field_API_Name__c = 'Brand__c', Required__c = false));
        RecapFields.add(new Recap_Field__c(Name = '0058', sObject__c = 'Recap_Product__c', Section__c = 'Order Information', Label__c = 'Recap in LMA Strategists Name', Field_API_Name__c = 'LMA_Strategist__c', Required__c = false)); // , Lookup_sObject_Type__c = 'User', Lookup_sObject__c ='LMA_Strategists__r'));  
        insert RecapFields;
        return RecapFields;
    }
}