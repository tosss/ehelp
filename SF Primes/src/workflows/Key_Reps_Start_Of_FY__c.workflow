<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Upd_LYKR_Account_Name</fullName>
        <field>Account_Name__c</field>
        <formula>Account__r.Name</formula>
        <name>Upd - LYKR - Account Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Upd - LYKR - Account Name</fullName>
        <actions>
            <name>Upd_LYKR_Account_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Udate Acount Name in table Key Reps Start Of FY</description>
        <formula>NOT( ISNULL(Account__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
