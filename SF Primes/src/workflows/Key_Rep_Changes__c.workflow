<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Upd_Key_Rep_Changes_Previous_DOS</fullName>
        <description>Update previous KEY DOS name</description>
        <field>Previous_Key_DOS__c</field>
        <formula>Account__r.Key_DOS__r.FirstName + &apos; &apos; +  Account__r.Key_DOS__r.LastName</formula>
        <name>Upd - Key Rep Changes - Previous DOS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Key_Rep_Changes_Previous_Rep</fullName>
        <description>Update previous key rep name</description>
        <field>Previous_Key_Rep__c</field>
        <formula>Account__r.Key_Rep__r.FirstName + &apos; &apos; +  Account__r.Key_Rep__r.LastName</formula>
        <name>Upd - Key Rep Changes - Previous Rep</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Key_Rep_Changes_Region</fullName>
        <description>Update Region</description>
        <field>Region__c</field>
        <formula>TEXT(Account__r.Region__c)</formula>
        <name>Upd - Key Rep Changes - Region</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Upd - Key Rep Changes - Previous RepDOSRegion</fullName>
        <actions>
            <name>Upd_Key_Rep_Changes_Previous_DOS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Upd_Key_Rep_Changes_Previous_Rep</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Upd_Key_Rep_Changes_Region</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>On insert new reocrd on KEY Rep Changes, store previous Rep, DOS and Region.</description>
        <formula>ISBLANK(Previous_Key_Rep__c) || ISBLANK(Previous_Key_DOS__c) || ISBLANK(Region__c)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
