<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DS_BDC_FinalizedDealNSARequest</fullName>
        <description>DS_BDC_FinalizedDealNSARequest</description>
        <protected>false</protected>
        <recipients>
            <field>AVP__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>DOS__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>RGM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BDC_Docs/BDC_Finalized_Deal_NSA_Request</template>
    </alerts>
    <fieldUpdates>
        <fullName>FinalizedDealNSARequest_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>FinalizedDealNSARequest_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>DS_BDC_EML_FinalizedDealNSARequest</fullName>
        <actions>
            <name>DS_BDC_FinalizedDealNSARequest</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created to send email to RGM, DOS amd AVP whenever a new record is created</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>FinalizedDealNSARequest_Set_Migration_ID</fullName>
        <actions>
            <name>FinalizedDealNSARequest_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
