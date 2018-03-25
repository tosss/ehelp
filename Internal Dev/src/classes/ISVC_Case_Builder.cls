@isTest
public class ISVC_Case_Builder {
    private Case record;
    private Id recordTypeId;
    private Id parentId;
    private Id accountId;
    private Id contactId;
    private Id ownerId;
    private String subject;
    private String status;
    private String category;
    private String subCategory;
    private String impact;
    private String severity;
    private String subCaseType;
    private Date terminationEffectiveDate;
    private Date terminationLastWorkDate;
    private String description;

    public ISVC_Case_Builder() {
        recordTypeId = ALL_RecordTypes_Utility.getRequestRecordTypeId();
        parentId = null;
        accountId = null;
        contactId = null;
        ownerId = UserInfo.getUserId();
        subject = 'Test case';
        category = null;
        subCategory = null;
        impact = 'A Single Person';
        severity = 'Low';
    }

    public ISVC_Case_Builder recordTypeId(Id recordTypeId){
        this.recordTypeId = recordTypeId;
        return this;
    }

    public ISVC_Case_Builder parentId(Id parentId){
        this.parentId = parentId;
        return this;
    }

    public ISVC_Case_Builder accountId(Id accountId){
        this.accountId = accountId;
        return this;
    }

    public ISVC_Case_Builder contactId(Id contactId){
        this.contactId = contactId;
        return this;
    }

    public ISVC_Case_Builder ownerId(Id ownerId){
        this.ownerId = ownerId;
        return this;
    }

    public ISVC_Case_Builder subject(String subject){
        this.subject = subject;
        return this;
    }

    public ISVC_Case_Builder status(String status){
        this.status = status;
        return this;
    }

    public ISVC_Case_Builder category(String category){
        this.category = category;
        return this;
    }

    public ISVC_Case_Builder subCategory(String subCategory){
        this.subCategory = subCategory;
        return this;
    }

    public ISVC_Case_Builder impact(String impact){
        this.impact = impact;
        return this;
    }

    public ISVC_Case_Builder severity(String severity){
        this.severity = severity;
        return this;
    }

    public ISVC_Case_Builder subCaseType(String subCaseType){
        this.subCaseType = subCaseType;
        return this;
    }
    
    public ISVC_Case_Builder terminationEffectiveDate(Date terminationEffectiveDate) {
    		this.terminationEffectiveDate = terminationEffectiveDate;
    		return this;
    }
    
    public ISVC_Case_Builder terminationLastWorkDate(Date terminationLastWorkDate) {
    		this.terminationLastWorkDate = terminationLastWorkDate;
    		return this;
    }
    
    public ISVC_Case_Builder description(String description) {
    		this.description = description;
    		return this;
    }

    public ISVC_Case_Builder build(){
        record = new Case();
        record.RecordTypeId = recordTypeId;
        record.ParentId = parentId;
        record.AccountId = accountId;
        record.ContactId = contactId;
        record.OwnerId = ownerId;
        record.Subject = subject;
        record.Status = status;
        record.Category__c = category;
        record.Sub_Category__c = subCategory;
        record.Impact__c = impact;
        record.Severity__c = severity;
        record.Sub_Case_Type__c = subCaseType;
        record.Effective_Date__c = terminationEffectiveDate;
        record.Last_Work_Date__c = terminationLastWorkDate;
        record.description = description;
        return this;
    }

    public ISVC_Case_Builder save(){
        build();
        insert record;
        return this;
    }

    public Case getRecord(){
        return record;
    }
}