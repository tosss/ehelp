<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Remianing_Quanitity</fullName>
        <description>Set Remaining Quantity with Total Quantity</description>
        <field>Remaining_Quantity__c</field>
        <formula>Quantity__c</formula>
        <name>Update Remianing Quanitity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Equat the Total Quanity to Remaining Quanty</fullName>
        <actions>
            <name>Update_Remianing_Quanitity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Potluck_Dish__c.Quantity__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
