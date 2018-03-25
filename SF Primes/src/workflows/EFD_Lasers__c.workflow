<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>DS_LSR_InstallerDate</fullName>
        <field>Installed_Date__c</field>
        <formula>Today()</formula>
        <name>DS_LSR_InstallerDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_LSR_InstallerName</fullName>
        <field>Installer_Name__c</field>
        <formula>CreatedBy.FirstName &amp;&quot; &quot;&amp; CreatedBy.LastName</formula>
        <name>DS_LSR_InstallerName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>DS_LSR_UPD_InstallerName%2FDate</fullName>
        <actions>
            <name>DS_LSR_InstallerDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>DS_LSR_InstallerName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Installer Name to creator of the record and Installed date to current</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
