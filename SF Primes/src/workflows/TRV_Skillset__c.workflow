<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>TRV_SkillsetName_LastName_ExpertiseMajor</fullName>
        <description>Skillset Name is updated with combination of Resource Last Name and Expertise Major</description>
        <field>Name</field>
        <formula>IF(TEXT(TRV_Expertise_Major__c)=&apos;&apos;&amp;&amp;ISBLANK(TRV_Resource__c), Name, IF(ISBLANK(TRV_Resource__c), TEXT(TRV_Expertise_Major__c), TRV_Resource__r.TRV_Resource__r.LastName + IF(TEXT(TRV_Expertise_Major__c)=&apos;&apos;, &apos;&apos;, &apos; - &apos;+TEXT(TRV_Expertise_Major__c))))</formula>
        <name>TRV SkillsetName_LastName-ExpertiseMajor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>TRV_FLD_SkillsetName</fullName>
        <actions>
            <name>TRV_SkillsetName_LastName_ExpertiseMajor</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Skillset Name will be updated on record creation and whenever resource is changed on Skillset</description>
        <formula>ISNEW() || ISCHANGED( TRV_Resource__c ) || ISCHANGED( TRV_Expertise_Major__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
