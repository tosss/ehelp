<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Emails_Received_Count</fullName>
        <field>Emails_Received_Count__c</field>
        <formula>IF( ISBLANK(Parent.Emails_Received_Count__c) ,0, (Parent.Emails_Received_Count__c+1))</formula>
        <name>Update Emails Received Count</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Inbound Email Received</fullName>
        <actions>
            <name>Update_Emails_Received_Count</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Rule evaluating an incoming email to count incoming emails on the case object.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
