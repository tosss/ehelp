@isTest
public class ALL_User_Builder {
    private User record;
    private Id profileId;
    private String alias;
    private String email;
    private String emailEncodingKey;
    private String lastName;
    private String languageLocaleKey;
    private String localeSidKey;
    private String timeZoneSidKey;
    private String userName;

    public ALL_User_Builder(Id profileId) {
        this.profileId = profileId;
        this.alias = 'sample';
        this.email = 'sampleuser@testorg.com';
        this.emailEncodingKey = 'UTF-8';
        this.lastName = 'Testing';
        this.languageLocaleKey = 'en_US';
        this.localeSidKey = 'en_US';
        this.timeZoneSidKey = 'America/Los_Angeles';
        this.userName = 'sampleuser@testorg.com';
    }

    public ALL_User_Builder alias(String alias){
        this.alias = alias;
        return this;
    }

    public ALL_User_Builder email(String email){
        this.email = email;
        return this;
    }

    public ALL_User_Builder emailEncodingKey(String emailEncodingKey){
        this.emailEncodingKey = emailEncodingKey;
        return this;
    }

    public ALL_User_Builder lastName(String lastName){
        this.lastName = lastName;
        return this;
    }

    public ALL_User_Builder languageLocaleKey(String languageLocaleKey){
        this.languageLocaleKey = languageLocaleKey;
        return this;
    }

    public ALL_User_Builder localeSidKey(String localeSidKey){
        this.localeSidKey = localeSidKey;
        return this;
    }

    public ALL_User_Builder timeZoneSidKey(String timeZoneSidKey){
        this.timeZoneSidKey = timeZoneSidKey;
        return this;
    }

    public ALL_User_Builder userName(String userName){
        this.userName = userName;
        return this;
    }

    public ALL_User_Builder build(){
        record = new User();
        record.ProfileId = profileId;
        record.Alias = alias;
        record.Email = email;
        record.EmailEncodingKey = emailEncodingKey;
        record.LastName = lastName;
        record.LanguageLocaleKey = languageLocaleKey;
        record.LocaleSidKey = localeSidKey;
        record.TimeZoneSidKey = timeZoneSidKey;
        record.UserName = userName;
        return this;
    }

    public ALL_User_Builder save(){
        build();
        insert record;
        return this;
    }

    public User getRecord(){
        return record;
    }
}