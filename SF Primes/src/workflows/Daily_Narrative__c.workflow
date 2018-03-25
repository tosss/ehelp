<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>IMP_Update_10_hour_reason</fullName>
        <description>Field update to set the 10 hour reason to N/A so the user doesn&apos;t have to select value when the checkbox is false.</description>
        <field>Why_did_you_work_more_than_10_hours__c</field>
        <literalValue>N/A</literalValue>
        <name>IMP Update 10 hour reason to N/A</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>IMP Update 10 hour reason to N%2FA</fullName>
        <actions>
            <name>IMP_Update_10_hour_reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Daily_Narrative__c.Worked_more_than_10_hours__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Workflow to set the reason to N/A when the 10 hour worked checkbox is &quot;false&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
