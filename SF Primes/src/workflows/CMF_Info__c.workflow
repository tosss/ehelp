<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CMF_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>Ship_CMF__c</formula>
        <name>CMF_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_LSR_ConditionalARStatementInstallDate</fullName>
        <field>Conditional_A_R_Statement_Install_Date__c</field>
        <formula>Today()</formula>
        <name>DS_LSR_ConditionalARStatementInstallDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_LSR_ServiceEdgeClientInstallDate</fullName>
        <field>Service_Edge_Client_Install_Date__c</field>
        <formula>Today()</formula>
        <name>DS_LSR_ServiceEdgeClientInstallDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_LSR_UPD_eSignatureClientInstallDate</fullName>
        <field>eSignature_Client_Install_Date__c</field>
        <formula>Today()</formula>
        <name>DS_LSR_UPD_eSignatureClientInstallDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CMF_Set_Migration_ID</fullName>
        <actions>
            <name>CMF_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>DS_LSR_UPD_ConditionalA%2FRStatementInstallDate</fullName>
        <actions>
            <name>DS_LSR_ConditionalARStatementInstallDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CMF_Info__c.Conditional_A_R_Statement__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates Conditional A/R Statement Install Date to current date when Conditional A/R Statement is checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_LSR_UPD_ServiceEdgeClientInstallDate</fullName>
        <actions>
            <name>DS_LSR_ServiceEdgeClientInstallDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CMF_Info__c.Service_Edge_Client__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates Service Edge Client Install Date to current date when Service Edge Client is checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_LSR_UPD_eSignatureClientInstallDate</fullName>
        <actions>
            <name>DS_LSR_UPD_eSignatureClientInstallDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CMF_Info__c.eSignature_Client__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates eSignature Client Install Date to current date when eSignature Client is checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
