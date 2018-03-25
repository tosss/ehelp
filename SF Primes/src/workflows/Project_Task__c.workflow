<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>IMP_ProjectTask_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>IMP_ProjectTask_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IMP_Stamp_Planned_End_Date_on_Project_Ta</fullName>
        <description>When a new Project Task record is created, stamp its parent’s Planned End Date value into its own Planned End Date field to inherit the same value at creation (only).</description>
        <field>Planned_End_Date__c</field>
        <formula>Project_Activity_Planned_End_Date__c</formula>
        <name>IMP Stamp Planned End Date on Project Ta</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IMP_Stamp_Planned_Start_Date_on_Project</fullName>
        <description>When a new Project Task record is created, stamp its parent’s Planned Start Date value into its own Planned Start Date field to inherit the same value at creation (only).</description>
        <field>Planned_Start_Date__c</field>
        <formula>Project_Activity_Planned_Start_Date__c</formula>
        <name>IMP Stamp Planned Start Date on Project</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>IMP Stamp Planned End Date on Project Task During Create</fullName>
        <actions>
            <name>IMP_Stamp_Planned_End_Date_on_Project_Ta</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project_Task__c.Project_Activity_Planned_End_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When a new Project Task record is created, stamp its parent’s Planned End Date value into its own Planned End Date field to inherit the same value at creation (only).</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IMP Stamp Planned Start Date on Project Task During Create</fullName>
        <actions>
            <name>IMP_Stamp_Planned_Start_Date_on_Project</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project_Task__c.Project_Activity_Planned_Start_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When a new Project Task record is created, stamp its parent’s Planned Start Date value into its own Planned Start Date field to inherit the same value at creation (only).</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IMP_ProjectTask_Set_Migration_ID</fullName>
        <actions>
            <name>IMP_ProjectTask_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
