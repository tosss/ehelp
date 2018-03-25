<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Product_QC_Quota_Credit_Type_Update</fullName>
        <field>Quota_Credit_Type_Text__c</field>
        <formula>Quota_Credit_Type__c</formula>
        <name>Product QC - Quota Credit Type Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Quota Credit Type Text - Update with Quota Credit Type</fullName>
        <actions>
            <name>Product_QC_Quota_Credit_Type_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product_QC__c.Quota_Credit_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Update with Quota Credit Type</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
