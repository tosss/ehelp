<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_UAT_Issue_created</fullName>
        <description>New UAT Issue created</description>
        <protected>false</protected>
        <recipients>
            <recipient>cindy.limjoco@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_UAT_Issue_Notification</template>
    </alerts>
    <alerts>
        <fullName>UAT_Issue_status_has_been_updated_to_Rejected_or_Resolved</fullName>
        <description>UAT Issue status has been updated to &apos;Rejected&apos; or &apos;Resolved&apos;</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/UAT_Issue_Status_Updated_to_Rejected_or_Resolved</template>
    </alerts>
    <rules>
        <fullName>Email New UAT Issue</fullName>
        <actions>
            <name>New_UAT_Issue_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>UAT_Issue__c.Description__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>An Email regarding a new UAT issue created will be sent to Administrators</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Status Updated to Rejected or Resolved</fullName>
        <actions>
            <name>UAT_Issue_status_has_been_updated_to_Rejected_or_Resolved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>UAT_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>Resolved</value>
        </criteriaItems>
        <criteriaItems>
            <field>UAT_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <description>Sends an Email notification to the owner whether the status of the issue is updated to &apos;Rejected&apos; or &apos;Resolved&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
