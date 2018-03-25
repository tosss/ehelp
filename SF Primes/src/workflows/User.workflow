<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Upd_Legacy_ProfileID</fullName>
        <field>Legacy_ProfileID__c</field>
        <formula>PRIORVALUE(ProfileId)</formula>
        <name>Upd - Legacy ProfileID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Legacy_RoleID</fullName>
        <field>Legacy_RoleID__c</field>
        <formula>PRIORVALUE( UserRoleId )</formula>
        <name>Upd - Legacy RoleID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>User_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>CASESAFEID(Id)</formula>
        <name>User_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Upd - User - Legacy ProfileID Field</fullName>
        <actions>
            <name>Upd_Legacy_ProfileID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(ProfileId) &amp;&amp;  NOT(ISBLANK(PRIORVALUE(ProfileId))) &amp;&amp;  $User.ProfileId = &apos;00e40000000rAoY&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - User - Legacy RoleID Field</fullName>
        <actions>
            <name>Upd_Legacy_RoleID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Legacy Role field with previous role if role has changed.</description>
        <formula>ISCHANGED( UserRoleId ) &amp;&amp;   NOT(ISBLANK(PRIORVALUE(UserRoleId))) &amp;&amp;  $User.ProfileId = &apos;00e40000000rAoY&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>User_Set_Migration_ID</fullName>
        <actions>
            <name>User_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
