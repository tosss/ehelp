<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>IMP_SubProjSite_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>IMP_SubProjSite_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IMP_Subproject_update_for_lookup</fullName>
        <field>SubProject_for_Filters__c</field>
        <formula>SubProject__r.Name</formula>
        <name>IMP Subproject update for lookup</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>IMP SubProject Update for lookup filter</fullName>
        <actions>
            <name>IMP_Subproject_update_for_lookup</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SubProject__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Field used to find SubProject sites when creating Trip Reports from the trip report tab</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IMP_SubProjSite_Set_Migration_ID</fullName>
        <actions>
            <name>IMP_SubProjSite_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
