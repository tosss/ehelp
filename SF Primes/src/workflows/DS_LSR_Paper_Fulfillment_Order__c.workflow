<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>DS_FFC_ShippingAddress1</fullName>
        <field>Shipping_Address_1__c</field>
        <formula>CMF_Info__r.DS_FFC_Shipping_Address_1__c</formula>
        <name>DS_FFC_ShippingAddress1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_FFC_ShippingCity</fullName>
        <field>Shipping_City__c</field>
        <formula>CMF_Info__r.DS_FFC_Shipping_City__c</formula>
        <name>DS_FFC_ShippingCity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_FFC_ShippingState</fullName>
        <field>Shipping_State__c</field>
        <formula>CMF_Info__r.DS_FFC_Shipping_State__c</formula>
        <name>DS_FFC_ShippingState</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_FFC_ShippingZip</fullName>
        <field>Shipping_Zip__c</field>
        <formula>CMF_Info__r.DS_FFC_Shipping_Zip__c</formula>
        <name>DS_FFC_ShippingZip</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_FFC_Shipping_Address2</fullName>
        <field>Shipping_Address_2__c</field>
        <formula>CMF_Info__r.DS_FFC_Address_2__c</formula>
        <name>DS_FFC_Shipping Address2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PaperFullfillmentOrder_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>PaperFullfillmentOrder_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>DS_FFC_UPD_ShppingAddressFields</fullName>
        <actions>
            <name>DS_FFC_ShippingAddress1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>DS_FFC_ShippingCity</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>DS_FFC_ShippingState</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>DS_FFC_ShippingZip</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>DS_FFC_Shipping_Address2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Shipping address from CMF info for newly created record</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PaperFullfillmentOrder_Set_Migration_ID</fullName>
        <actions>
            <name>PaperFullfillmentOrder_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
