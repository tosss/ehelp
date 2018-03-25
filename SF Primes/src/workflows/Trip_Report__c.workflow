<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>IMP_Update_Trip_Status_to_closed</fullName>
        <description>Update of the Status field to closed when departure is not null</description>
        <field>Trip_Report_Status__c</field>
        <literalValue>Closed</literalValue>
        <name>IMP Update Trip Status to closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IMP_Update_Trip_Status_to_open</fullName>
        <description>field update from workflow to reset the status to Open after previously closed</description>
        <field>Trip_Report_Status__c</field>
        <literalValue>Open</literalValue>
        <name>IMP Update Trip Status to open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Imp_Update_Dealership_CMF</fullName>
        <description>Update of the Dealership CMF from the associated subproject site</description>
        <field>Dealership_CMF__c</field>
        <formula>Associated_SubProjectSite__r.CMF_Name__r.Ship_CMF__c</formula>
        <name>Imp Update Dealership CMF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>IMP Update Trip to Closed</fullName>
        <actions>
            <name>IMP_Update_Trip_Status_to_closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Trip_Report__c.Departure_Finish_Date_Time__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Rule to update the Trip Report status to closed when they have entered a departure date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Imp ReOpen Trip Report</fullName>
        <actions>
            <name>IMP_Update_Trip_Status_to_open</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Trip_Report__c.Departure_Finish_Date_Time__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Trip_Report__c.Trip_Report_Status__c</field>
            <operation>notEqual</operation>
            <value>Open</value>
        </criteriaItems>
        <description>Workflow to reset the trip report status to &quot;open&quot; from &quot;closed&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Imp Update Dealership CMF</fullName>
        <actions>
            <name>Imp_Update_Dealership_CMF</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow to set the value in the Dealership CMF field when there is a SubProject Site on the Trip report.</description>
        <formula>NOT(ISBLANK(Associated_SubProjectSite__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
