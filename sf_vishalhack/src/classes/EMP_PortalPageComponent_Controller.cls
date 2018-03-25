//2016-07-26- anirudh.singh@cdk.com- Corrected the identation.
//2016-07-26- anirudh.singh@cdk.com- Replaced the SOQL Query for custom setting EMP_VFPageName__c by methods.
public with sharing class EMP_PortalPageComponent_Controller
{
    //http://salesforce.stackexchange.com/questions/1474/how-to-get-fieldset-fields-in-apex-dynamically-fieldset-name-is-not-static
    
    public page_component__c PageComp{get; set;}
    public String sRecordTypeName{get; set;}
    public map<String,String> mapRecordTypeWiseFieldSetName{get; set;}
    public list<EMP_VFPageName__c> PageName_Types{get; set;}
    public List<SelectOption> options; 
    public List<Schema.FieldSetMember> lstFields{get; set;}
    public String selectedPage{get; set;}
    public Boolean showContent{get; set;}
    private String ObjectName;
    
    public EMP_PortalPageComponent_Controller(ApexPages.StandardController controller)
    {
        system.debug('Start EMP_PortalPageComponent_Controller---->');
        
        Controller.addFields(new list<string>{'VFPageName__c'});
        objectName='page_component__c';
        PageComp=(page_component__c)controller.getRecord();
        
        if(PageComp.RecordTypeId!=null)
        {
            for(RecordType rt: [Select Id, Name, DeveloperName From RecordType Where Id=:PageComp.RecordTypeId limit 1])
            {
                sRecordTypeName=rt.DeveloperName;
            }
            
            if(sRecordTypeName =='Content' || sRecordTypeName =='Carousel')
            {
                showContent=true;
            }
            
            lstFields=fetchFieldSetDetails(sRecordTypeName);
            
            if(PageComp.Id!=null)
            {
                PageComp=database.query(buildSOQL(ObjectName, PageComp, lstFields));
            }
        }
        
        system.debug('End EMP_PortalPageComponent_Controller---->');
    }
    
    public List<Schema.FieldSetMember> fetchFieldSetDetails(String fieldSetName)
    {      
        Map<String, Schema.SObjectType> GlobalDescribeMap=Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj=GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj=SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj=DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields();
    }
    
    private static String buildSOQL(String ObjectName, Page_Component__c PageComp, list<Schema.FieldSetMember> FieldsToQuery)
    {
        String query='Select Id';
        for(Schema.FieldSetMember fld: FieldsToQuery)
        {
            query+=', '+fld.getFieldPath();
        }
        query+=' From '+ObjectName+' Where Id='+'\''+PageComp.Id+'\''+' limit 1';
          
        return query;
    }
    
    public List<SelectOption> getOptions()
    {
        PageName_Types=new list<EMP_VFPageName__c>(); 
        options=new List<SelectOption>();
        
        //2016-07-26- anirudh.singh@cdk.com- Replaced the SOQL Query sorted in DESC Order with the below two lines.
        PageName_Types=EMP_VFPageName__c.getAll().values();
        PageName_Types.sort();
        
        if(PageName_Types.size()>0)
        {
            for(EMP_VFPageName__c entry: PageName_Types)
            {
                options.add(new SelectOption(entry.Page_API_Name__c, entry.Page_Name__c));
            }
        }
        else
        {
            options.add(new SelectOption('', '--None--'));
        }
        return options;
        
    }
    
    public PageReference save()
    {
        upsert PageComp ID;
        
        PageReference pageRef=new PageReference('/'+PageComp.ID);
        return pageRef;
    }
}