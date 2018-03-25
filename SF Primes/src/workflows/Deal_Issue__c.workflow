<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>DS_BDC_ClosedDate</fullName>
        <field>Closed_Date__c</field>
        <formula>Now()</formula>
        <name>DS_BDC_ClosedDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_BDC_ClosedDate_Null</fullName>
        <field>Closed_Date__c</field>
        <name>DS_BDC_ClosedDate_Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DealIssue_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>DealIssue_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>DS_BDC_UPD_ClosedDate</fullName>
        <actions>
            <name>DS_BDC_ClosedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deal_Issue__c.Closed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Created to update Closed date with current date/time when ever Closed in checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_BDC_UPD_ClosedDate_Null</fullName>
        <actions>
            <name>DS_BDC_ClosedDate_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deal_Issue__c.Closed__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Created to update closed date to null when closed is unchecked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DealIssue_Set_Migration_ID</fullName>
        <actions>
            <name>DealIssue_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
