<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_User_Being_QAd</fullName>
        <field>User_Being_QA_d__c</field>
        <formula>Account_Plan__r.Owner:User.FirstName+&apos; &apos;+ Account_Plan__r.Owner:User.LastName</formula>
        <name>Update User Being QAd</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CB_Populate_QAUser_on_Create</fullName>
        <actions>
            <name>Update_User_Being_QAd</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CBQA__c.Open_Status__c</field>
            <operation>equals</operation>
            <value>Closed,Open</value>
        </criteriaItems>
        <description>Populates the user that is being QA&apos;d when the record is created. This is determined by the Account Plan owner. It only fires once and can be overwritten if I user goes in and makes changes.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
