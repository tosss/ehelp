<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Check_Business_Unit_Changed_for_SProject</fullName>
        <field>Business_Unit_Changed__c</field>
        <literalValue>1</literalValue>
        <name>Check Business Unit Changed for SProject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IMP_SubProject_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>IMP_SubProject_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unchk_Business_Unit_Changed_for_SProject</fullName>
        <field>Business_Unit_Changed__c</field>
        <literalValue>0</literalValue>
        <name>Unchk Business Unit Changed for SProject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Project_Assigned_to_PM_PS_Field</fullName>
        <description>Update of the field whenever a PM is assigned to a subproject and isn&apos;t the integration user</description>
        <field>Project_Assigned_to_PM_PS__c</field>
        <formula>Today()</formula>
        <name>Update Project Assigned to PM/PS Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_of_PMC_Assigned_Field</fullName>
        <description>Update of the Date PMC assigned field based on the PMC picklist value</description>
        <field>Date_PMC_Assigned__c</field>
        <formula>Today()</formula>
        <name>Update of PMC Assigned Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>IMP_Business_Unit_Changed_SubProject</fullName>
        <actions>
            <name>Check_Business_Unit_Changed_for_SProject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Business_Unit_Changed__c to true if the Business Unit field changes</description>
        <formula>!ISNULL(TEXT( SubProject_Region__c )) &amp;&amp; !ISBLANK(TEXT(SubProject_Region__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IMP_No_Business_Unit_SubProject</fullName>
        <actions>
            <name>Unchk_Business_Unit_Changed_for_SProject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Business_Unit_Changed__c to false if the Business Unit field changes</description>
        <formula>ISCHANGED( SubProject_Region__c ) &amp;&amp; ISPICKVAL( SubProject_Region__c , &apos;&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IMP_SubProject_Set_Migration_ID</fullName>
        <actions>
            <name>IMP_SubProject_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Imp Set PMC Date</fullName>
        <actions>
            <name>Update_of_PMC_Assigned_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SubProject__c.Project_Management_Center__c</field>
            <operation>notEqual</operation>
            <value>Region</value>
        </criteriaItems>
        <description>Update of the Date PMC Assigned field.  Triggered when the PMC field is changed to the qualifying values</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Imp Update Project Assigned to PM%2FPS Field</fullName>
        <actions>
            <name>Update_Project_Assigned_to_PM_PS_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow will set the key date for when the subproject is assigned to a PM for management</description>
        <formula>AND(NOT(ISBLANK(Project_Manager__c)),Project_Manager__r.FirstName &lt;&gt; &quot;Implementation&quot;, ISCHANGED(Project_Manager__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Imp Update Project Assigned to PM%2FPS Field on Create</fullName>
        <actions>
            <name>Update_Project_Assigned_to_PM_PS_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow will set the key date for when the subproject is assigned to a PM for management</description>
        <formula>AND(NOT(ISBLANK(Project_Manager__c)),Project_Manager__r.FirstName &lt;&gt; &quot;Implementation&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
