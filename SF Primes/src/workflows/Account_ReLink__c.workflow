<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Account_Re_Link_Notification_Email</fullName>
        <ccEmails>ServicesOpsAnalystTeam@cdk.com</ccEmails>
        <description>Account Re-Link Notification Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>SA_Content_Admins_Minus_Dave_and_Patti</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>Service_Admins</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>matt.keefe@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>william.thresher@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Automation_Templates/Account_Re_Link_Notification_Template</template>
    </alerts>
    <rules>
        <fullName>Account Re-Link Notification</fullName>
        <actions>
            <name>Account_Re_Link_Notification_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>Cobalt_Account_Number__c != null &amp;&amp; Party_ID__c != null</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
