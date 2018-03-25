//	Created: 2015-06-01 from Request R-960 (combine old triggers into single)
//	Developers:	Addanki, Lakshmi
//				Chava, Maheshwar
//				Cook, Brian 
//				Kalicut, Ram
//				Khan, Mutahhar
//				Li, Guolong 
//				Mishra, Akash 
//				Simhadri, Smitha
//				Thurow, Bill
//				
//	
@IsTest
public with sharing class DS_SystemAtDealership_Test {
    //how many records to be created for multiple
    //record testing
    //
    private static integer recordCount = 3;        				
    
    //
    //to show debug values set this to true
    //
    private static boolean generateDebugStatements = false;
    //
    //run all tests?
    //
    private static boolean runAll = true;
    //
    //or run specific tests?
    //
    private static boolean insPosSingle = false;
    private static boolean beforeInsPos = false;
    private static boolean insCRMSingle = false;
    private static boolean multInsPos = false;
    private static boolean insCRMMult = false;
    private static boolean multUpdPos = false;
    private static boolean beforeMultUpdPos = false;
    private static boolean compId = false;
    private static boolean dateFormat = false;
    private static boolean comboInsTest = false;
    private static boolean comboUpdTest = false;
    //
    private static boolean updateNeg = false;
    private static boolean insNeg = false;
    private static boolean bulkUpdateNeg = false;
    private static boolean compIDNeg = false;
    //
    //
    //
    //run tests for not implemented trigger functions
    //
    private static boolean notImplemented = false;    
    //
    @testSetup static void initialDataSetup() {
        Account act = DS_TestObjects.NewAccount();
        insert act;
        
        Systems__c sysDMS = DS_TestObjects.NewDMSSystem();
        insert sysDMS;
        
        Systems__c sysCRM = DS_TestObjects.NewCRMSystem();
        insert sysCRM;
    }
    //
    //
    //***********************************************************************************
    //
    //positive testing
    //
    private static testMethod void insertPositiveSingle(){
        if(runAll || insPosSingle) {
            setHeader('insertPositiveSingle');
            try {
                createSadRecords(1);   
                system.assert(true,'insertPositiveSingle');
            } catch(Exception x){
                showDebug('insert of SAD record failed with message:  ' + x.getMessage());
                system.assert(false);
            }
        }
    }
    static testMethod void beforeInsertPositive()
    {
        if(runAll || beforeInsPos){
            setHeader('beforeInsertPositive');
            System_at_Dealership__c dms = DS_TestObjects.NewDMSSystemAtDealership();
            Systems__c sys = getDMSSys();
            if(sys.SLXVendor_ID__c == null){
                sys.SLXVendor_ID__c = 'testingid1';
            }
            dms.SLX_Vendor_ID__c = sys.SLXVendor_ID__c;
            
            system.assertNotEquals(dms, null);
            
            list<System_at_Dealership__c> sad = new list<System_at_Dealership__c>();
            sad.add(dms);
            
            DS_SystemAtDealership_Handler.BeforeInsert(sad);
            
            showDebug(sad);
            
            system.assert(true,'beforeInsertPositive');
        }
    }
    public static testMethod void testCRMInsert(){
        try{
            if(runAll || insCRMSingle) {
                setHeader('testCRMInsert');
                createCRMSad(1);
                
                system.assert(true,'testCRMInsert');
            }
        } catch(Exception x){
            showDebug(x.getMessage());
        }
    }
    public static testMethod void testCRMMultiple(){
        if(runAll || insCRMMult) {
            setHeader('testCRMMultiple');
            list<System_at_Dealership__c> newCRMlist = createMultCRMSad(recordCount);
            insert newCRMlist;
            
            system.assert(true,'testCRMMultiple');               
        }
    }
    public static testMethod void testMultipleInsert(){
        if(runAll || multInsPos){
            setHeader('testMultipleInsert');
            list<System_at_Dealership__c> newList = createMultipleSadRecords(recordCount);       
            
            insert newList;
            DS_SystemAtDealership_Handler.updateDeleteExistingSaDs(newList,newList);
            
            system.assert(true,'TestMultipleInsert');
        }
    }
    public static testMethod void testMultipleUpdate(){
        if(runAll || multUpdPos){
            setHeader('testMultipleUpdate');
            list<System_at_Dealership__c> newList = createMultipleSadRecords(recordCount);
            insert newList;
            
            for(integer i = 0; i < recordCount; i++){
                System_at_Dealership__c sad = newList.get(i);
                sad.Install_Date__c = date.today().addDays(-i * i);
            }
            
            update NewList;
            
            system.assert(true,'TestMultipleUpdate');
        }
    }
    static testMethod void beforeUpdateTest()
    {
        if(runAll || beforeMultUpdPos) {
            try{
                setHeader('beforeUpdateTest');
                System_at_Dealership__c dms = DS_TestObjects.NewDMSSystemAtDealership_Inserted();
                system.assertNotEquals(dms, null);
                
                dms.System_Type__c = 'Previous DMS';
                
                map<Id,sObject> om = new map<Id, sObject>();
                om.put(dms.Id, dms);
                
                list<System_at_Dealership__c> sads = new list<System_at_Dealership__c>();
                sads.add(dms);
                
                update dms;
                
                Account act = getAccount();
                Systems__c sys = getDMSSys();
                
                System_at_Dealership__c s1 = new System_at_Dealership__c();
                s1.Account__c = act.Id;
                s1.Vendor__c = sys.Id;
                s1.Install_Date__c = Date.today().addDays(-1);
                s1.System_Type__c = sys.Type__c;
                s1.SLX_Vendor_ID__c = sys.SLXVendor_ID__c;
                s1.SLX_Sys_ID__c = sys.SLXSystem_ID__c;
                
                System_at_Dealership__c s2 = new System_at_Dealership__c();
                s2.Account__c = act.Id;
                s2.Vendor__c = sys.Id;
                s2.Install_Date__c = Date.today().addDays(-2);
                s2.System_Type__c = sys.Type__c;
                s2.SLX_Vendor_ID__c = sys.SLXVendor_ID__c;
                s2.SLX_Sys_ID__c = sys.SLXSystem_ID__c;
                
                insert s1;
                insert s2;
                
                system.assert(true,'beforeUpdateTest');
            } catch(Exception x){
                showDebug(x.getMessage());
            }
        }
    } 
    public static testMethod void comboTypeInsert(){
        if(runAll || comboInsTest) {
            try{
                setHeader('comboTypeInsert');
                list<System_at_Dealership__c> sad = new list<System_at_Dealership__c>();
                
                for(System_at_Dealership__c sd : createMultipleSadRecords(recordCount)){
                    sad.add(sd);
                }
                for(System_at_Dealership__c sdCRM : createMultCRMSad(recordCount)){
                    sad.add(sdCRM);
                }           
                
                insert sad;
                
                system.assert(true,'comboTypeInsert');
            } catch(Exception x){
                showDebug(x.getMessage());
            }
        }
    }
    public static testMethod void comboTypeUpdate(){
        if(runAll || comboUpdTest){
            setHeader('comboTypeUpdate');
            list<System_at_Dealership__c> sad = new list<System_at_Dealership__c>();
            
            for(System_at_Dealership__c sd : createMultipleSadRecords(recordCount)){
                sad.add(sd);
            }
            for(System_at_Dealership__c sd : createMultCRMSad(recordCount)){
                sad.add(sd);
            }         
            
            insert sad;
            
            for(System_at_Dealership__c uSys : sad){
                uSys.Install_Date__c = uSys.Install_Date__c - 1;
            }           
            
            update sad;
            
            system.assert(true,'comboTypeUpdate');
        }
    }
    public static testMethod void compileCompIdTest()
    {
        if(runAll || compId) {
            setHeader('compileCompIdTest');
            string acctId = 'Acct1';
            string insDatestring = '2015/05/25';
            string slxVendorId = 'Vendor1';
            string slxSystemId = 'Sys1';
            string sysType = 'DMS';
            string strCompositeId = DS_SystemAtDealership_Handler.CompileCompId(acctId,insDatestring, slxVendorId, slxSystemId, sysType);
            
            showDebug(strCompositeId);
            
            system.assertEquals(strCompositeId, 'Acct12015/05/25Vendor1Sys1DMS');
        }
    }
    public static testMethod void compileCompIdNullSysIdTest()
    {
        if(runAll || compId) {
            setHeader('compileCompIdNullSysIdTest');
            string acctId = 'Acct1';
            string insDatestring = '2015/05/25';
            string slxVendorId = 'Vendor1';
            string slxSystemId = null;
            string sysType = 'DMS';
            string strCompositeId = DS_SystemAtDealership_Handler.CompileCompId(acctId,insDatestring, slxVendorId, slxSystemId, sysType);
            
            system.assertEquals(strCompositeId, 'Acct12015/05/25Vendor1            DMS');
        }
    }    
    public static testmethod void checkdate(){
        if(runAll || dateFormat){
            setHeader('checkdate');
            try
            {
                string tmpdt = DS_SystemAtDealership_Handler.GetDate(Date.today());
                string y = tmpdt.substring(0,4);
                string m = tmpdt.substring(4,6);
                string d = tmpdt.substring(6,8);
                date dt = date.parse(m + '/' + d + '/' + y);
                
                if(integer.valueof(y) < 1970 || integer.valueOf(y) > 2100) {
                    showDebug('Year value = ' + y + '. Value must be between 1980 and 2099.');
                    system.assert(false);
                }
                if(tmpdt.length() == 8) {
                    system.assert(true);
                } else {
                    system.assert(false);
                }
                
                tmpdt = DS_SystemAtDealership_Handler.GetDate(null);
                if(tmpdt == '        ') {
                    system.assert(true);
                } else {
                    system.assert(false);
                }
                
                dt = date.parse('01/01/2012');
                tmpdt = DS_SystemAtDealership_Handler.GetDate(dt);
                if(tmpdt.length() == 8) {
                    system.assert(true);
                } else {
                    system.assert(false);
                }     
                
                dt = date.parse('10/10/2012');
                tmpdt = DS_SystemAtDealership_Handler.GetDate(dt);
                if(tmpdt.length() == 8) {
                    system.assert(true);
                } else {
                    system.assert(false);
                }                  
            }
            catch(system.Exception x){
                system.assert(false);
            }       
        }
    }    
    //
    //
    //
    //***********************************************************************************
    //
    //negative testing
    //update SAD with null System Type
    //
    public static testMethod void negSADInsert(){
        if(runAll || insNeg){
            setHeader('negSADInsert');
            try{
                System_at_Dealership__c sad = new System_at_Dealership__c();
                Systems__c sys = getDMSSys();
                
                sad.Vendor__c = sys.Id;
                sad.Install_Date__c = Date.today().addDays(-1);
                sad.System_Type__c = sys.Type__c;
                sad.SLX_Vendor_ID__c = sys.SLXVendor_ID__c;
                sad.SLX_Sys_ID__c = sys.SLXSystem_ID__c;   
                
                insert sad;
            }catch(Exception x){
                system.assert(true);
            }
        }            
    }
    public static testmethod void negSADUpdate(){
        if(runAll || updateNeg)
        {
            setHeader('NegSADUpdate');
            //
            //get from testSetup
            //
            Account act = DS_TestObjects.NewAccount(); 
            act.Name = 'SSLA Account4';
            insert act;    
            
            //
            //get from testSetup
            //
            Systems__c sys = new Systems__c(Name='SSLA System4');
            sys.SLXSystem_ID__c = 'SSLASYSTEM4';
            sys.SLXVendor_ID__c = 'SSLASYSTEM4';
            sys.Type__c = 'Phone';
            insert sys;
            
            System_at_Dealership__c newsad = new System_at_Dealership__c();
            newSad.Account__c = act.Id;
            newSad.Vendor__c = sys.Id;
            newSad.Install_Date__c = date.today();
            newSad.System_Type__c =  sys.Type__c;
            newSad.SLX_Vendor_ID__c = sys.SLXVendor_ID__c;
            newSad.SLX_Sys_ID__c = sys.SLXSystem_ID__c;             
            insert newSad;
            
            newSad.System_Type__c = null;
            try{
                update newSad; 
                system.assert(false,'update sad');
            }
            catch(Exception e){     
                if(e.getMessage() == 'Cannot change System Type') {
                    system.assert(true,'negSADUpdate caught expected error');
                }
            }
            showDebug('NegSADUpdate: Update Successful');
            
            System_at_Dealership__C updatedSAD = [
                select	Id, System_Type__c 
                from	System_at_Dealership__C 
                where	id = :newSad.Id
            ];
            
            system.assertNotEquals(updatedSAD.System_Type__c,null);
        }
    }      
    public static testMethod void bulkUpdNeg(){
        if(runAll || bulkUpdateNeg){
            setHeader('bulkUpdNeg');
            try{
                list<System_at_Dealership__c> recs = createMultipleSadRecords(recordCount);
                insert recs;
                
                for(System_at_Dealership__c rec : recs) {
                    rec.Account__c = null;
                }
                update recs;
                system.assert(false);
            }catch(Exception x){
                system.assert(true,'bulkUpdNeg');
            }
        }
    }
    //
    //
    //
    //***********************************************************************************
    //    
    //trigger events not implemented
    //
    public static testMethod void beforeDelete(){
        boolean b = generateDebugStatements;
        generateDebugStatements = false;
        if(runAll || notImplemented){
            setHeader('beforeDelete');
            try{
                createSadRecords(1);
                System_at_Dealership__c sad = [select Id, SLX_Sys_ID__c from System_at_Dealership__c where SLX_Sys_ID__c = 'TEST01234567' limit 1];
                delete sad;    
                system.assert(true,'beforeDelete');
            } catch(Exception x){
                showDebug('beforeDelete failed with message:  ' + x.getMessage());
                system.assert(false);
            }
        }
        generateDebugStatements = b;
    }
    public static testMethod void afterInsert(){
        if(runAll || notImplemented){
            setHeader('afterInsert');
            try{
                createSadRecords(1);
                System_at_Dealership__c sad = [select Id,Name,SLX_Sys_ID__c from System_at_Dealership__c where SLX_Sys_ID__c = 'TEST01234567' limit 1];
                system.assert(true,'afterInsert');
            }catch(Exception x){
                showDebug('failure --> ' + x.getMessage());
                system.assert(false);
            }
        }
    }
    public static testMethod void afterUpdate(){
        if(runAll || notImplemented){
            setHeader('afterUpdate');
            try{
                createSadRecords(1);
                System_at_Dealership__c sad = [select Id,Name,SLX_Sys_ID__c from System_at_Dealership__c where SLX_Sys_ID__c = 'TEST01234567' limit 1]; //SLX_Vendor_ID__c = 'testingid' limit 1];
                sad.Install_Date__c = date.today();
                update sad;
                system.assert(true,'afterUpdate');
            }catch(Exception x){
                showDebug('failure --> ' + x.getMessage());
                system.assert(false);
            }            
        }
    }
    public static testMethod void afterDelete(){
        boolean b = generateDebugStatements;
        generateDebugStatements = false;        
        if(runAll || notImplemented){
            setHeader('afterDelete');
            try{
                createSadRecords(1);
                list<System_at_Dealership__c> sad = [select Id,SLX_Sys_ID__c,SLX_Vendor_ID__c from System_at_Dealership__c where SLX_Sys_ID__c = 'TEST01234567' limit 1]; //SLX_Vendor_ID__c = 'testingid' limit 1];
                showDebug('line 477: ');
                showDebug(sad);
                delete sad;    
                system.assert(true,'afterDelete');
            } catch(Exception x){
                showDebug('afterDelete failed with message:  ' + x.getMessage());
                system.assert(false,x.getMessage());
            }
        }
        generateDebugStatements = b;
    }
    public static testMethod void afterUndelete(){
        if(runAll || notImplemented){
            setHeader('afterUndelete');
            try {
                createSadRecords(1);
                System_at_Dealership__c sad = [select Id,SLX_Sys_ID__c from System_at_Dealership__c where SLX_Sys_ID__c = 'TEST01234567' limit 1]; //SLX_Vendor_ID__c = 'testingid' limit 1];
                delete sad;  
                undelete sad;   
                system.assert(true,'afterDelete');
            } catch(Exception x) {
                showDebug('afterUndelete failed with message: ' + x.getMessage());
                system.assert(false);
            }            
        }
    } 
    //
    //
    //
    //***********************************************************************************
    //
    //generate test data
    //
    private static Account getAccount(){
        list<Account> actList = [select Id from Account where Name = 'Test Account'];
        Account act;
        if(actList.size() == 0){
            system.assert(false,'no test account');
        } else {
            act = actList[0];
        }
        
        return act;
    }
    private static Systems__c getDMSSys(){
        list<Systems__c> sysList = [select Id,Type__c,SLXVendor_ID__c,SLXSystem_ID__c from Systems__c where Name = 'Test DMS System' and Type__c = 'DMS'];
        Systems__c sys;
        if(sysList.size() == 0) {
            system.assert(false,'no test system');
        } else {
            sys = sysList[0];
        }
        
        return sys;
    }
    private static Systems__c getCRMSys(){
        list<Systems__c> sysList = [select Id,Type__c,SLXVendor_ID__c,SLXSystem_ID__c from Systems__c where Name = 'Test CRM System' and Type__c = 'CRM'];
        Systems__c sys;
        if(sysList.size() == 0) {
            system.assert(false,'no test system');
        } else {
            sys = sysList[0];
        }        
        return sys;
    }
    private static void createSadRecords(integer cnt){
        setHeader('createSadRecords(' + cnt + ')');
        
        Account act = [select Id from Account where Name = 'Test Account' limit 1];
        Systems__c sys = [select Id,Type__c,SLXVendor_ID__c,SLXSystem_ID__c from Systems__c where Name = 'Test DMS System' and Type__c = 'DMS' limit 1];
        //Systems__c sys;
        //if(sysList.size() == 0) {
        //    system.assert(false,'no test system');
        //} else {
        //    sys = sysList[0];
        //}
        
        System_at_Dealership__c sad = new System_at_Dealership__c();
        list<System_at_Dealership__c> newList = new list<System_at_Dealership__c>();
        
        try{
            for(integer i = 0; i < cnt; i++){
                sad = new System_at_Dealership__c();
                showDebug('creating SAD #' + i);
                
                sad.Account__c = act.Id;
                sad.Vendor__c = sys.Id;
                sad.Install_Date__c = Date.today().addDays(-i); 
                sad.System_Type__c = sys.Type__c;
                sad.SLX_Vendor_ID__c = sys.SLXVendor_ID__c;
                sad.SLX_Sys_ID__c = 'TEST01234567';//sys.SLXSystem_ID__c;
                showDebug(sad);
                newList.add(sad);
            }
            insert sad;  
        } catch(Exception x){
            showDebug(sad);
            showDebug(x.getMessage());
            system.assert(false,'createSadRecords(' + cnt + ')');
        }
    }
    private static list<System_at_Dealership__c> createMultipleSadRecords(integer cnt){
        setHeader('createMultipleSadRecords(' + cnt + ')');
        
        Account act = [select Id from Account where Name = 'Test Account'][0];
        list<Systems__c> sysList = [select Id,Type__c,SLXVendor_ID__c,SLXSystem_ID__c from Systems__c where Name = 'Test DMS System' and Type__c = 'DMS'];
        Systems__c sys;
        if(sysList.size() == 0) {
            system.assert(false,'no test system');
        } else {
            sys = sysList[0];
        }
        
        System_at_Dealership__c sad = new System_at_Dealership__c();
        list<System_at_Dealership__c> newList = new list<System_at_Dealership__c>();
        try{
            for(integer i = 0; i < cnt; i++){
                sad = new System_at_Dealership__c();
                showDebug('creating SAD #' + i);
                if(sys.SLXVendor_ID__c == null){
                    system.assert(false,'createMultipleSadRecords --> sys.SLXVendor_ID__c is null');
                }
                
                sad.Account__c = act.Id;
                sad.Vendor__c = sys.Id;
                sad.Install_Date__c = Date.today().addDays(-i);
                sad.System_Type__c = sys.Type__c;
                sad.SLX_Vendor_ID__c = sys.SLXVendor_ID__c;
                sad.SLX_Sys_ID__c = sys.SLXSystem_ID__c;
                showDebug(sad);
                newList.add(sad);
            }
        } catch(Exception x){
            showDebug(sad);
            showDebug(x.getMessage());
            system.assert(false,'createMultipleSadRecords(' + cnt + ')');
        }
        return newList;
    }
    private static void createCRMSad(integer i){
        setHeader('createCRMSad');
        
        Account act = [select Id from Account where Name = 'Test Account'][0];
        Systems__c sys = [select Id,Type__c,SLXVendor_ID__c,SLXSystem_ID__c from Systems__c where Name = 'Test CRM System' and Type__c = 'CRM'][0];
        
        System_at_Dealership__c sad = new System_at_Dealership__c();
        
        try{
            
            sad.Account__c = act.Id;
            sad.Vendor__c = sys.Id;
            sad.Install_Date__c = Date.today().addDays(-i);
            sad.System_Type__c = sys.Type__c;
            sad.SLX_Vendor_ID__c = sys.SLXVendor_ID__c;
            sad.SLX_Sys_ID__c = sys.SLXSystem_ID__c;  
            
            insert sad;
            
        }catch(Exception x){
            showDebug(x.getMessage());
            system.assert(false,'createCRMSad');
        }
    }
    private static list<System_at_Dealership__c> createMultCRMSad(integer cnt){
        setHeader('createMultCRMSad');
        
        Account act = [select Id from Account where Name = 'Test Account'][0];
        list<Systems__c> sysList = [select Id,Type__c,SLXVendor_ID__c,SLXSystem_ID__c from Systems__c where Name = 'Test CRM System' and Type__c = 'CRM'];
        Systems__c sys;
        if(sysList.size() == 0) {
            system.assert(false,'no test system');
        } else {
            sys = sysList[0];
        }
        
        System_at_Dealership__c sad = new System_at_Dealership__c();
        list<System_at_Dealership__c> newList = new list<System_at_Dealership__c>();
        try{
            for(integer i = 0; i < cnt; i++){
                sad = new System_at_Dealership__c();
                showDebug('creating SAD #' + i);
                if(sys.SLXVendor_ID__c == null){
                    system.assert(false,'createMultipleCRMRecords --> sys.SLXVendor_ID__c is null');
                }
                
                sad.Account__c = act.Id;
                sad.Vendor__c = sys.Id;
                sad.Install_Date__c = Date.today().addDays(-i);
                sad.System_Type__c = sys.Type__c;
                sad.SLX_Vendor_ID__c = sys.SLXVendor_ID__c;
                sad.SLX_Sys_ID__c = sys.SLXSystem_ID__c;
                showDebug(sad);
                newList.add(sad);
            }
        } catch(Exception x){
            showDebug(sad);
            showDebug(x.getMessage());
            system.assert(false,'createMultipleSadRecords(' + cnt + ')');
        }
        return newList;        
    }
    //
    //
    //
    //***********************************************************************************
    //
    //misc and helper functions
    //
    //
    private static void showDebug(object obj){
        if(generateDebugStatements){
            system.debug(obj);
        }
    }
    private static void setHeader(string txt){
        if(generateDebugStatements){
            system.debug('****************************************');
            system.debug('** ' + txt);            
            system.debug('****************************************');
        }
    }    
}