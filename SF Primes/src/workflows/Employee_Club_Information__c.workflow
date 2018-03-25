<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EmpClubAutoCheckPewterField</fullName>
        <description>If Pewter check box is not checked, check it automatically</description>
        <field>Pewter_Award__c</field>
        <literalValue>1</literalValue>
        <name>Emp Club-Auto Check Pewter Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EmpClubAutoUNCheckPewterField</fullName>
        <description>If pewter aware type is cleared out, uncheck the pewter award checkbox</description>
        <field>Pewter_Award__c</field>
        <literalValue>0</literalValue>
        <name>Emp Club-Auto UNCheck Pewter Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Upd - Emp Club - Auto Uncheck Pewter</fullName>
        <actions>
            <name>EmpClubAutoUNCheckPewterField</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Uncheck Pewter</description>
        <formula>AND(LEN( Pewter_Award_Reason__c) = 0,  Pewter_Award__c = true)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Emp Club - Check Pewter Award</fullName>
        <actions>
            <name>EmpClubAutoCheckPewterField</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Auto Check Pewter Award checkbox if the Pewter Award Type is filled in</description>
        <formula>AND(LEN( Pewter_Award_Reason__c )&gt;0,  Pewter_Award__c = false)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
