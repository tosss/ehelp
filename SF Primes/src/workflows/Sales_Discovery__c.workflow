<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Site_Walk_Technician_Request_Created</fullName>
        <ccEmails>mutahhar.khan@cdk.com</ccEmails>
        <description>New Site Walk Technician Request Created</description>
        <protected>false</protected>
        <recipients>
            <recipient>jim.beczkiewicz@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>TSM_DOS__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>TSM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Discovery_Email_Templates/SD_Site_Walk_Technician_request</template>
    </alerts>
    <alerts>
        <fullName>Sales_Discovery_Finding_report_completed</fullName>
        <description>Sales Discovery Finding report completed</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Discovery_Email_Templates/SD_Summary_Finding_Report_completed</template>
    </alerts>
    <alerts>
        <fullName>Sales_Discovery_Finding_report_request</fullName>
        <description>Sales Discovery Finding report request</description>
        <protected>false</protected>
        <recipients>
            <recipient>Virtual_Discovery_Specialist</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Discovery_Email_Templates/SD_Summary_Finding_Report_Request</template>
    </alerts>
    <alerts>
        <fullName>Sales_Discovery_Proposed_Solutions_to_be_updated</fullName>
        <ccEmails>mutahhar.khan@cdk.com</ccEmails>
        <description>Sales Discovery: Proposed Solutions to be updated</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Discovery_Email_Templates/SD_Update_Proposed_Solutions_after_acknowledgement</template>
    </alerts>
    <alerts>
        <fullName>Sales_Discovery_Site_Walk_Request_Approval</fullName>
        <description>Sales Discovery:Site Walk Request Approval</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Discovery_Email_Templates/SD_Site_Walk_RequestApproval</template>
    </alerts>
    <alerts>
        <fullName>Sales_Discovery_Site_Walk_Request_rejected</fullName>
        <description>Sales Discovery:Site Walk Request rejected</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Discovery_Email_Templates/SD_Site_Walk_Request_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Sales_Discovery_Solution_Design_creation_request</fullName>
        <ccEmails>mutahhar.khan@cdk.com</ccEmails>
        <description>Sales Discovery: Solution Design creation request</description>
        <protected>false</protected>
        <recipients>
            <recipient>Virtual_Discovery_Specialist</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Discovery_Email_Templates/SD_Reuqest_to_create_Solution_Design</template>
    </alerts>
    <alerts>
        <fullName>Sales_Discovery_Technician_assigned_message</fullName>
        <ccEmails>mutahhar.khan@cdk.com</ccEmails>
        <description>Sales Discovery Technician assigned message</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Discovery_Email_Templates/SD_Site_Walk_Technician_assigned</template>
    </alerts>
    <alerts>
        <fullName>Sales_Discovery_Virtual_Discovery_Request</fullName>
        <description>Sales Discovery: Virtual Discovery Request</description>
        <protected>false</protected>
        <recipients>
            <recipient>Virtual_Discovery_Specialist</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>mutahhar.khan@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Discovery_Email_Templates/SD_Virtual_Discovery_request</template>
    </alerts>
    <alerts>
        <fullName>Sales_Discovery_Virtual_Discovery_Request_completed</fullName>
        <description>Sales Discovery: Virtual Discovery Request completed</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Discovery_Email_Templates/SD_Virtual_Discovery_completed</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_Current_Status_to_site_walk_appv</fullName>
        <field>Status__c</field>
        <literalValue>Site Walk Request Approved</literalValue>
        <name>Change Current Status to site walk appv</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reject_Site_Walk</fullName>
        <description>Reject Site Walk</description>
        <field>Reject_Site_Walk__c</field>
        <literalValue>1</literalValue>
        <name>Reject Site Walk</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_submission_date</fullName>
        <field>Site_Walk_Request_Submitted_Date__c</field>
        <name>Remove submission date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Revert_back_current_status_to_VS_complet</fullName>
        <field>Status__c</field>
        <literalValue>Virtual Sales Discovery Completed</literalValue>
        <name>Revert back current status to VS complet</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Approve_Flag_to_yes</fullName>
        <field>Approve_Site_Walk__c</field>
        <literalValue>1</literalValue>
        <name>Set Approve Flag to yes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Site_walk_Approve_by_DOS_Date</fullName>
        <field>On_Site_Sales_Discovery_Approval_Date__c</field>
        <formula>Now()</formula>
        <name>Set_Site walk Approve by DOS Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Technician_status_to_approved</fullName>
        <field>Technical_Site_Walk_Status__c</field>
        <literalValue>Request Approved</literalValue>
        <name>Set Technician status to approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_ownership_to_site_technician_group</fullName>
        <field>OwnerId</field>
        <lookupValue>Sales_Discovery_Site_Technician</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Set ownership to site technician group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_rejection_date</fullName>
        <field>Site_Walk_Rejection_Date__c</field>
        <formula>NOW()</formula>
        <name>Set rejection date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_the_Submission_for_SIte_Walk</fullName>
        <field>Site_Walk_Request_Submitted__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck the Submission for SIte Walk</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>uncheck_technical_status</fullName>
        <field>Technical_Site_Walk_Status__c</field>
        <name>uncheck technical status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
