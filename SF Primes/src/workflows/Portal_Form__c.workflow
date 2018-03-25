<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EMP_DMSRSA_IT_Request_Form_Email_Alert</fullName>
        <ccEmails>division.support@cdk.com</ccEmails>
        <description>EMP DMSRSA IT Request Form Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>craig.brantner@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>peter.vonbusch@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rose.gilligan@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/EMP_DMSRSA_ITRequestFormEmail</template>
    </alerts>
    <alerts>
        <fullName>IT_HR_Terminations_Emails_Notification_2_Ehelp</fullName>
        <ccEmails>helpmeit@cdk.com</ccEmails>
        <description>IT HR Terminations Emails Notification 2 Ehelp</description>
        <protected>false</protected>
        <recipients>
            <recipient>dave.hanson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Corp_HR/HR_Involuntary_Termination_Text</template>
    </alerts>
    <rules>
        <fullName>EMP_DMSRSA_ITRequestForms</fullName>
        <actions>
            <name>EMP_DMSRSA_IT_Request_Form_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>(NOT(ISBLANK(DMSRSA_Associate_Name__r.Id)) ||  NOT(ISBLANK(DMSRSA_Contractor_First_Name__c))) &amp;&amp; BEGINS(RecordType.DeveloperName, &apos;DMS&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>HR_PortalForm_TermEnteredEmail</fullName>
        <active>false</active>
        <formula>RecordType.Name = &apos;HR Termination&apos; &amp;&amp; NOT(ISBLANK(DMSRSA_Associate_Name__c)) &amp;&amp; NOT(ISBLANK(HR_Termination_Date__c)) &amp;&amp; CASE(HR_AM_PM__c, &apos;AM&apos;, &apos;AM&apos;, &apos;PM&apos;, &apos;PM&apos;, &apos;&apos;) &lt;&gt; &apos;&apos; &amp;&amp; CASE(HR_AM_PM__c, &apos;00&apos;, &apos;00&apos;, &apos;15&apos;, &apos;15&apos;, &apos;30&apos;, &apos;30&apos;, &apos;45&apos;, &apos;45&apos;, &apos;&apos;) &lt;&gt; &apos;&apos; &amp;&amp; CASE(HR_Termination_Hour__c, &apos;01&apos;, &apos;01&apos;, &apos;02&apos;, &apos;02&apos;, &apos;03&apos;, &apos;03&apos;, &apos;04&apos;, &apos;04&apos;, &apos;05&apos;, &apos;05&apos;, &apos;06&apos;, &apos;06&apos;, &apos;07&apos;, &apos;07&apos;, &apos;08&apos;, &apos;08&apos;, &apos;09&apos;, &apos;09&apos;, &apos;10&apos;, &apos;10&apos;, &apos;11&apos;, &apos;11&apos;, &apos;12&apos;, &apos;12&apos;, &apos;&apos;) &lt;&gt; &apos;&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IT HR Term Email 2 Ehelp</fullName>
        <actions>
            <name>IT_HR_Terminations_Emails_Notification_2_Ehelp</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>RecordType.Name = &apos;HR Termination&apos; &amp;&amp; NOT(ISBLANK(DMSRSA_Associate_Name__c)) &amp;&amp; NOT(ISBLANK(HR_Termination_Date__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
