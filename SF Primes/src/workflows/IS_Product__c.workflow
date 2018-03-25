<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ISProduct_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>CASESAFEID(Id) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>ISProduct_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_IS_Product_Name</fullName>
        <description>Update Product name and add Product Group Name abbreviation. 
G1 - (FO) 
G2 - (BP) 
G3 - (F&amp;I) 
G5 - (Canada) 
G6 - (Truck)</description>
        <field>Name</field>
        <formula>IF(ISPICKVAL( ISR_Group__c , &quot;G1&quot;), Name + &apos; - (FO)&apos;, 
 IF(ISPICKVAL( ISR_Group__c , &quot;G2&quot;), Name + &apos; - (BP)&apos;, 
 IF(ISPICKVAL( ISR_Group__c , &quot;G3&quot;), Name + &apos; - (F&amp;I)&apos;, 
 IF(ISPICKVAL( ISR_Group__c , &quot;G5&quot;), Name + &apos; - (Canada)&apos;, 
 IF(ISPICKVAL( ISR_Group__c , &quot;G6&quot;), Name + &apos; - (Truck)&apos;,
Name)))))</formula>
        <name>Upd - IS Product Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ISProduct_Set_Migration_ID</fullName>
        <actions>
            <name>ISProduct_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Upd - IS Product Name with Product Group</fullName>
        <actions>
            <name>Upd_IS_Product_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the IS Product Name field and add Product Group Name.</description>
        <formula>IsActive__c = TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
