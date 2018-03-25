<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CB_Stop_Gap_New_DS_Manuf_Addition_Temp</fullName>
        <description>CB Stop-Gap New DS Manuf Addition-Temp</description>
        <protected>false</protected>
        <recipients>
            <recipient>cameron.wong@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ADP_Dealer_Services/CB_New_DS_Manuf_Addition</template>
    </alerts>
    <fieldUpdates>
        <fullName>ManufacturerAtDealership_Set_Migration_I</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>ManufacturerAtDealership_Set_Migration_I</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Email - CB Stop-Gap New Manuf Added-Temp</fullName>
        <actions>
            <name>CB_Stop_Gap_New_DS_Manuf_Addition_Temp</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>needed for &apos;stop-gap&apos; until CCF can be modified to send these emails.</description>
        <formula>AND(NOT(ISBLANK(Account__r.Account_Number__c )), NOT(ISBLANK(Account__r.PartyID__c)), CASE(Account__r.Segment_Code__c, &quot;NAAT&quot;, &quot;NAAT&quot;, &quot; &quot;) = &quot;NAAT&quot;, CASE(Account__r.Site_Type__r.Name, &quot;Auto&quot;, &quot;Auto&quot;, &quot;Corporation&quot;, &quot;Corporation&quot;, &quot;District&quot;, &quot;District&quot;, &quot;Group&quot;, &quot;Group&quot;, &quot;OEM&quot;, &quot;OEM&quot;, &quot;Under Construction&quot;, &quot;Under Construction&quot;, &quot;Used Vehicle&quot;, &quot;Used Vehicle&quot;, &quot; &quot;) = CASE( Account__r.Site_Type__r.Name , &quot;Auto&quot;, &quot;Auto&quot;, &quot;Corporation&quot;, &quot;Corporation&quot;, &quot;District&quot;, &quot;District&quot;, &quot;Group&quot;, &quot;Group&quot;, &quot;OEM&quot;, &quot;OEM&quot;, &quot;Under Construction&quot;, &quot;Under Construction&quot;, &quot;Used Vehicle&quot;, &quot;Used Vehicle&quot;, &quot; &quot;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ManufacturerAtDealership_Set_Migration_ID</fullName>
        <actions>
            <name>ManufacturerAtDealership_Set_Migration_I</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
