<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ADPDefaultTeamMbr_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>ADPDefaultTeamMbr_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Team_Mbr_Title_To_User_Title</fullName>
        <description>Update Team Member Title to User Title</description>
        <field>Title__c</field>
        <formula>Team_Member__r.Title</formula>
        <name>Upd Team Mbr Title To User Title</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ADPDefaultTeamMbr_Set_Migration_ID</fullName>
        <actions>
            <name>ADPDefaultTeamMbr_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Upd - ADP Def Team Member Title</fullName>
        <actions>
            <name>Upd_Team_Mbr_Title_To_User_Title</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update ADP Default Team Member Title from User Title</description>
        <formula>AND(NOT(ISBLANK($User.Title)), OR(LEN(Title__c) &lt;= 0, $User.Title &lt;&gt; Title__c )) || NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
