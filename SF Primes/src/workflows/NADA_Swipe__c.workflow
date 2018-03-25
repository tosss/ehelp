<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_NADA_Service_Issue_to_Tom_Keller</fullName>
        <ccEmails>dave.hanson@adp.com</ccEmails>
        <description>Alert to NADA Service Issue to Tom Keller</description>
        <protected>false</protected>
        <recipients>
            <recipient>tom.kelter@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Automation_Templates/Email_NADA_Service_Issue_To_Tom_Keller</template>
    </alerts>
    <alerts>
        <fullName>Email_Notifying_Marjana_about_NADA_Device_Not_Entered_in_NADA_Devices</fullName>
        <description>Email Notifying Marjana about NADA Device Not Entered in NADA Devices</description>
        <protected>false</protected>
        <recipients>
            <recipient>_jeanine.strama@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dave.hanson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>irfan.siddiqui@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>marjana.shogren@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Automation_Templates/DS_Nadaswipe_Device_wo_DeviceLookup</template>
    </alerts>
    <rules>
        <fullName>Email - NADA Swipe - Service Issue</fullName>
        <actions>
            <name>Alert_NADA_Service_Issue_to_Tom_Keller</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>sent e-mail to Tom.kelter@adp.com for Service Issue. Answer 7 has &apos;%service issue%&apos; in value on NADA Swipe.</description>
        <formula>AND( NOT( ISBLANK(Linked_Account__c )), NOT( ISBLANK( Linked_Contact__c )), CONTAINS( LOWER(Answer_7__c), &quot;service issue&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email_NADASwipe_without_Found_Device</fullName>
        <actions>
            <name>Email_Notifying_Marjana_about_NADA_Device_Not_Entered_in_NADA_Devices</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>NADA Swipe record with a device id, but lookup did not find it...send email to DH, MS</description>
        <formula>NOT( ISBLANK(Apparatus_Id__c )) &amp;&amp;  ISBLANK( NADA_Scan_Device__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
