<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_SiteCmfRmsReqId_field</fullName>
        <field>SiteCmfRmsReqId__c</field>
        <formula>SubProjectSite__c + CMF_Info__c +  RMS_Request_Id__c</formula>
        <name>Update SiteCmfRmsReqId field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>IMP_Update_SiteCmfRmsReqId_field</fullName>
        <actions>
            <name>Update_SiteCmfRmsReqId_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CMFtoSubProjectSite__c.RMS_Request_Id__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
