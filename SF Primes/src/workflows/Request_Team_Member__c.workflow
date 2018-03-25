<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DS_Request_AddMember</fullName>
        <description>DS_Request_AddMember</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Automation_Templates/Request_Team_Member_Addition</template>
    </alerts>
    <rules>
        <fullName>DS_Request_EML_AddMember</fullName>
        <actions>
            <name>DS_Request_AddMember</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send email to newly added request team member if creator of the new record is not same as request team member</description>
        <formula>User__c&lt;&gt;CreatedById</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
