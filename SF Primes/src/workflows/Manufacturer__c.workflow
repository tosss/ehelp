<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Manufacturer_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>Left(Ora_Manufacturers_Code__c + &apos;-&apos; + IF(ISPICKVAL(Segment_Code__c, &quot;NAAT&quot;), &quot;NAAT&quot;, IF(ISPICKVAL(Segment_Code__c, &quot;PFW&quot;), &quot;PFW&quot;, &quot;&quot;)), 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>Manufacturer_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Manufacturer_Set_Migration_ID</fullName>
        <actions>
            <name>Manufacturer_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
