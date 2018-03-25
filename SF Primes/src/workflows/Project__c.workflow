<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Check_Business_Unit_Changed_for_Project</fullName>
        <field>Business_Unit_Changed__c</field>
        <literalValue>1</literalValue>
        <name>Check Business Unit Changed for Project</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IMP_Project_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>CASESAFEID(Id)</formula>
        <name>IMP_Project_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unchck_Business_Unit_Changed_for_Project</fullName>
        <field>Business_Unit_Changed__c</field>
        <literalValue>0</literalValue>
        <name>Unchck Business Unit Changed for Project</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>IMP_Business_Unit_Changed_Project</fullName>
        <actions>
            <name>Check_Business_Unit_Changed_for_Project</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Business_Unit_Changed__c to true if the Business Unit field changes</description>
        <formula>!ISNULL(TEXT( Project_Region__c ))  &amp;&amp; !ISBLANK(TEXT(Project_Region__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IMP_No_Business_Unit_Project</fullName>
        <actions>
            <name>Unchck_Business_Unit_Changed_for_Project</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Business_Unit_Changed__c to false if the Business Unit field changes</description>
        <formula>ISCHANGED(Project_Region__c) &amp;&amp;   ISPICKVAL( Project_Region__c , &apos;&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IMP_Project_Set_Migration_ID</fullName>
        <actions>
            <name>IMP_Project_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
