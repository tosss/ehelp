@isTest
public class ISVC_Task_Builder {
    private Task record;
    private Id whatId;
    private Id whoId;
    private Id ownerId;
    private String subject;

    public ISVC_Task_Builder() {
        whatId = null;
        whoId = null;
        ownerId = UserInfo.getUserId();
        subject = 'Test task';
    }

    public ISVC_Task_Builder whatId(Id whatId){
        this.whatId = whatId;
        return this;
    }

    public ISVC_Task_Builder whoId(Id whoId){
        this.whoId = whoId;
        return this;
    }

    public ISVC_Task_Builder ownerId(Id ownerId){
        this.ownerId = ownerId;
        return this;
    }

    public ISVC_Task_Builder subject(String subject){
        this.subject = subject;
        return this;
    }

    public ISVC_Task_Builder build(){
        record = new Task();
        record.WhatId = whatId;
        record.WhoId = whoId;
        record.OwnerId = ownerId;
        record.Subject = subject;
        return this;
    }

    public ISVC_Task_Builder save(){
        build();
        insert record;
        return this;
    }

    public Task getRecord(){
        return record;
    }
}