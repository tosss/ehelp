public with sharing class EMP_PortalPageComponent_Controller {
    //http://salesforce.stackexchange.com/questions/1474/how-to-get-fieldset-fields-in-apex-dynamically-fieldset-name-is-not-static
    
    public page_component__c PageComp {get;set;}
    public String sRecordTypeName {get;set;}
    public map<String,String> mapRecordTypeWiseFieldSetName {get;set;}
    public list<EMP_VFPageName__c> PageName_Types {get;set;}
    public List<SelectOption> options; 
    public List<Schema.FieldSetMember> lstFields {get;set;}
    public String selectedPage{get;set;}
    public Boolean showContent{get;set;}
    private String ObjectName;
    
    public EMP_PortalPageComponent_Controller(ApexPages.StandardController controller) {
        Controller.addFields(new list<string>{'VFPageName__c'});
        objectName = 'page_component__c';
        PageComp = (page_component__c)controller.getRecord();
        
        System.debug('@VijayDeveloper --> PageComp:' + PageComp);
        
        if(PageComp.RecordTypeId != null){
            for(RecordType rt :[Select Id,Name,DeveloperName From RecordType Where Id =:PageComp.RecordTypeId limit 1]){
                sRecordTypeName = rt.DeveloperName;
            }
            
            System.debug('@VijayDeveloper --> sRecordTypeName:' + sRecordTypeName);
            if(sRecordTypeName =='Content' || sRecordTypeName =='Carousel'){
                showContent=true;
            }
            
            lstFields = fetchFieldSetDetails(sRecordTypeName);
            
            if(PageComp.Id != null) {
                PageComp = database.query(buildSOQL(ObjectName, PageComp, lstFields));
            }
        }
    }
    
    public List<Schema.FieldSetMember> fetchFieldSetDetails(String fieldSetName){      
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields();
    }
    
    private static String buildSOQL(String ObjectName, Page_Component__c PageComp, list<Schema.FieldSetMember> FieldsToQuery) {
        String query = 'Select Id';
        for(Schema.FieldSetMember fld :FieldsToQuery) {
            query += ', ' + fld.getFieldPath();
        }
        query += ' From '+ ObjectName + ' Where Id = '+ '\'' + PageComp.Id + '\'' + ' limit 1';
        
        System.debug('@Developer --> query:' + query);     
        return query;
    }
    
    public List<SelectOption> getOptions() {
        PageName_Types = new list<EMP_VFPageName__c>(); 
        options =new List<SelectOption>();      
        PageName_Types = [
            Select Page_Name__c , Page_API_Name__c
            From EMP_VFPageName__c 
            ORDER BY Page_Name__c DESC 
        ];
        
        if (PageName_Types.size() > 0){
            for(EMP_VFPageName__c entry  : PageName_Types){
                options.add(new SelectOption(entry.Page_API_Name__c, entry.Page_Name__c));
            }
        }else{
            options.add(new SelectOption('','--None--'));
        }
        return options;
        
    }
    
    public PageReference save(){
        upsert PageComp ID;
        
        PageReference pageRef = new PageReference('/'+PageComp.ID);
        return pageRef;
    }
    
    
}