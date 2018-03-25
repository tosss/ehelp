<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CB_LMA_Combined_Autopuplater</fullName>
        <field>LMA_Combined_Unique__c</field>
        <formula>LMA_Combined__c</formula>
        <name>CB_LMA_Combined_Autopuplater</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LMARelationships_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>LMARelationships_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CB_LMA_Combined_Autopuplater</fullName>
        <actions>
            <name>CB_LMA_Combined_Autopuplater</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CB_LMA_Relationship__c.LMA_Combined__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This WF rule updates the LMA_Combined_Unique__c field whenever the LMA_Combined__c is populated</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LMARelationships_Set_Migration_ID</fullName>
        <actions>
            <name>LMARelationships_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
