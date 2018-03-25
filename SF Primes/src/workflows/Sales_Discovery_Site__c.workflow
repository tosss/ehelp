<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Sales_Discovery_Site_Walk_Trip_Report_completed</fullName>
        <ccEmails>mutahhar.khan@cdk.com</ccEmails>
        <description>Sales Discovery Site Walk Trip Report completed</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_DOS__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Sales_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Discovery_Email_Templates/SD_Site_Walk_Trip_Report_completed</template>
    </alerts>
    <alerts>
        <fullName>Sales_Discovery_Technician_assigned_alert</fullName>
        <ccEmails>mutahhar.khan@cdk.com</ccEmails>
        <description>Sales Discovery Technician assigned alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Discovery_Email_Templates/SD_Site_Walk_Technician_assigned</template>
    </alerts>
</Workflow>
