<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>IMP_ProjectLog_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>IMP_ProjectLog_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Manager_Id_Of_Project_Manager</fullName>
        <field>Manager_Id_Of_Project_Manager__c</field>
        <formula>CASE( Record_Type_Name__c , 
&quot;Action Item&quot;, Sub_Project_Action_Items__r.Manager_Id_Of_Project_Manager__c , 
&quot;Change Request&quot;, Sub_Project_Change_Request__r.Manager_Id_Of_Project_Manager__c, 
&quot;Issue&quot;, Sub_Project_Issue__r.Manager_Id_Of_Project_Manager__c, 
&quot;Lesson Learned&quot;, Sub_Project_Lessons_Learned__r.Manager_Id_Of_Project_Manager__c, 
&quot;Risk&quot;, Sub_Project_Risk__r.Manager_Id_Of_Project_Manager__c, 
&quot;&quot;)</formula>
        <name>Populate Manager Id Of Project Manager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_SubProject_Manager_Id</fullName>
        <field>SubProject_Manager_Id__c</field>
        <formula>CASE( Record_Type_Name__c , 
&quot;Action Item&quot;, Sub_Project_Action_Items__r.Project_Manager__c, 
&quot;Change Request&quot;, Sub_Project_Change_Request__r.Project_Manager__c, 
&quot;Issue&quot;, Sub_Project_Issue__r.Project_Manager__c, 
&quot;Lesson Learned&quot;, Sub_Project_Lessons_Learned__r.Project_Manager__c, 
&quot;Risk&quot;, Sub_Project_Risk__r.Project_Manager__c, 
&quot;&quot;)</formula>
        <name>Populate SubProject Manager Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>IMP_ProjectLog_Set_Migration_ID</fullName>
        <actions>
            <name>IMP_ProjectLog_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate Manager Id Fields</fullName>
        <actions>
            <name>Populate_Manager_Id_Of_Project_Manager</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_SubProject_Manager_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate SubProject Manager Id and ManagerId Of Project Manager of Project_Task__c object</description>
        <formula>AND(  OR(   RecordType.Name = &quot;Action Item&quot;,   RecordType.Name = &quot;Change Request&quot;,   RecordType.Name = &quot;Issue&quot;,   RecordType.Name = &quot;Lesson Learned&quot;,   RecordType.Name = &quot;Risk&quot;  ),  OR(   NOT(ISBLANK(Sub_Project_Action_Items__c)),   NOT(ISBLANK(Sub_Project_Change_Request__c)),   NOT(ISBLANK(Sub_Project_Issue__c)),   NOT(ISBLANK(Sub_Project_Lessons_Learned__c)),   NOT(ISBLANK(Sub_Project_Risk__c))  ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
