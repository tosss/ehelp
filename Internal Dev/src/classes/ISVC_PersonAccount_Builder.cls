@isTest
public class ISVC_PersonAccount_Builder {
    private Account record;
    private Id recordTypeId;
    private String firstName;
    private String lastName;
    private String userId;
    private String fedId;
    private String personEmail;
    private Id managerId;
    private Boolean inAD;
    private String country;

    public ISVC_PersonAccount_Builder() {
        recordTypeId = ALL_RecordTypes_Utility.getPersonAccountRecordTypeId();
        firstName = 'Paul';
        lastName = 'White';
        userId = 'companycommunityuser';
        fedId = 'COMPANYCOMMUNITYUSER';
        personEmail = 'companycommunityuser@cdk.com';
        inAD = true;
        country = 'United States';
    }

    public ISVC_PersonAccount_Builder recordTypeId(Id recordTypeId){
        this.recordTypeId = recordTypeId;
        return this;
    }

    public ISVC_PersonAccount_Builder firstName(String firstName){
        this.firstName = firstName;
        return this;
    }

    public ISVC_PersonAccount_Builder lastName(String lastName){
        this.lastName = lastName;
        return this;
    }

    public ISVC_PersonAccount_Builder userId(String userId){
        this.userId = userId;
        return this;
    }

    public ISVC_PersonAccount_Builder fedId(String fedId){
        this.fedId = fedId;
        return this;
    }

    public ISVC_PersonAccount_Builder personEmail(String personEmail){
        this.personEmail = personEmail;
        return this;
    }

    public ISVC_PersonAccount_Builder managerId(String managerId){
        this.managerId = managerId;
        return this;
    }

    public ISVC_PersonAccount_Builder inAD(Boolean inAD){
        this.inAD = inAD;
        return this;
    }

    public ISVC_PersonAccount_Builder country(String country){
        this.country = country;
        return this;
    }

    public ISVC_PersonAccount_Builder build(){
        record = new Account();
        record.RecordTypeId = recordTypeId;
        record.FirstName = firstName;
        record.LastName = lastName;
        record.User_Id__pc = userId;
        record.FedId__c = fedId;
        record.PersonEmail = personEmail;
        record.Manager__pc = managerId;
        record.In_AD__pc = inAD;
        record.Country__pc = country;
        return this;
    }

    public ISVC_PersonAccount_Builder save(){
        build();
        insert record;
        return this;
    }

    public Account getRecord(){
        return record;
    }
}