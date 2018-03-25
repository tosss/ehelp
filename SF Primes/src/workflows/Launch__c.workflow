<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_AA_Assigned_to_Launch</fullName>
        <description>Alert - AA Assigned to Launch</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Advocate__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_AA_Assigned_to_Launch</template>
    </alerts>
    <alerts>
        <fullName>Alert_AA_Needs_to_be_Assigned</fullName>
        <ccEmails>newcustomerordernotifications@cobalt.com</ccEmails>
        <description>Alert - AA Needs to be Assigned</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Ready_for_AA_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Alert_DA_Assigned_to_Launch</fullName>
        <description>Alert - DA Assigned to Launch</description>
        <protected>false</protected>
        <recipients>
            <field>Online_Marketing_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_DA_Assigned_to_Launch</template>
    </alerts>
    <alerts>
        <fullName>Alert_DataOps_Entered_Ticket</fullName>
        <description>Alert - DataOps Entered Ticket</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Secondary_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Integralink_Ticket_Entered</template>
    </alerts>
    <alerts>
        <fullName>Alert_Data_Ops_that_14_days_have_passed_since_DI</fullName>
        <ccEmails>onstationdataops@cobaltgroup.com</ccEmails>
        <description>Alert Data Ops that 14 days have passed since DI</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Data_Uploaded_Delayed_14_days</template>
    </alerts>
    <alerts>
        <fullName>Alert_Data_Ops_that_14_days_have_passed_since_DI1</fullName>
        <ccEmails>onstationdataops@cobaltgroup.com</ccEmails>
        <description>Alert Data Ops that 14 days have passed since DI</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Data_Uploaded_Delayed_14_days</template>
    </alerts>
    <alerts>
        <fullName>Alert_Data_Ops_that_7_days_have_passed_since_DI</fullName>
        <ccEmails>onstationdataops@cobaltgroup.com</ccEmails>
        <description>Alert Data Ops that 7 days have passed since DI</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Data_Uploaded_Delayed_7_days</template>
    </alerts>
    <alerts>
        <fullName>Alert_Data_Ops_that_7_days_have_passed_since_DI1</fullName>
        <ccEmails>onstationdataops@cobaltgroup.com</ccEmails>
        <description>Alert Data Ops that 7 days have passed since DI</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Data_Uploaded_Delayed_7_days</template>
    </alerts>
    <alerts>
        <fullName>Alert_Data_Ops_that_DI_has_been_submitted</fullName>
        <ccEmails>onstationdataops@cobaltgroup.com</ccEmails>
        <description>Alert Data Ops that DI has been submitted</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Data_Ops_DI_Submitted_to_Vendor</template>
    </alerts>
    <alerts>
        <fullName>Alert_Data_Ops_that_DI_has_been_submitted2</fullName>
        <ccEmails>onstationdataops@cobaltgroup.com</ccEmails>
        <description>Alert Data Ops that DI has been submitted</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Data_Ops_DI_Submitted_to_Vendor</template>
    </alerts>
    <alerts>
        <fullName>Alert_Design_that_request_is_resubmitted</fullName>
        <ccEmails>ServicesEMSDesignTeam@cobaltgroup.com</ccEmails>
        <description>Alert Design that request is resubmitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>chase.tangney@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>yan.chow@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Design_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Design_Resubmit</template>
    </alerts>
    <alerts>
        <fullName>Alert_EMS_that_Account_is_in_Launch</fullName>
        <description>Alert EMS that Account is in Launch</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Marketing_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Account_Assignment_EMS_Notification</template>
    </alerts>
    <alerts>
        <fullName>Alert_GM_NRM_Pilot_Welcome_Kit_Request</fullName>
        <ccEmails>jhearn@promoshopwa.com</ccEmails>
        <description>Alert: GM NRM Pilot Welcome Kit Request</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Welcome_Kit_email_request_GM_NRM</template>
    </alerts>
    <alerts>
        <fullName>Alert_IO_Attached_for_AMA_Launch</fullName>
        <ccEmails>IFSLMA@cdk.com</ccEmails>
        <description>Alert - IO Attached for AMA Launch</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFS_Launch_Templates/Alert_IO_Attached_for_AMA_Launch</template>
    </alerts>
    <alerts>
        <fullName>Alert_Launch_Ticket_Owner</fullName>
        <description>Alert Launch Ticket Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/WebID_has_not_been_updated</template>
    </alerts>
    <alerts>
        <fullName>Alert_OM_Entered_a_Ticket</fullName>
        <description>Alert - OM Entered a Ticket</description>
        <protected>false</protected>
        <recipients>
            <field>Data_Ops_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Secondary_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Integralink_Ticket_Entered</template>
    </alerts>
    <alerts>
        <fullName>Alert_Ops_DAP_Ready_for_Onboarding</fullName>
        <ccEmails>newcustomerordernotifications@cobalt.com</ccEmails>
        <description>Alert Ops - DAP Ready for Onboarding</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/ONB_DAP_Notification</template>
    </alerts>
    <alerts>
        <fullName>Alert_Ops_GAM_CAM_Onboarding</fullName>
        <ccEmails>newcustomerordernotifications@cobalt.com</ccEmails>
        <description>Alert - Ops GAM/CAM Onboarding</description>
        <protected>false</protected>
        <recipients>
            <recipient>cameron.wong@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_CAM_GAM_Onboarding</template>
    </alerts>
    <alerts>
        <fullName>Alert_Ops_Launch_Ready_for_Onboarding</fullName>
        <ccEmails>newcustomerordernotifications@cobalt.com</ccEmails>
        <description>Alert - Ops Launch Ready for Onboarding</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Ready_for_Onboarding</template>
    </alerts>
    <alerts>
        <fullName>Alert_Ops_ProCare_Ready_for_Onboarding</fullName>
        <ccEmails>newcustomerordernotifications@cobalt.com</ccEmails>
        <description>Alert Ops - ProCare Ready for Onboarding</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/ONB_ProCare_Notification</template>
    </alerts>
    <alerts>
        <fullName>Alert_Ops_RM_SM_Launch_Ready_for_Onboarding</fullName>
        <ccEmails>newcustomerordernotifications@cobalt.com</ccEmails>
        <description>Alert - Ops RM/SM Launch Ready for Onboarding</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/ONB_RM_SM_Launch</template>
    </alerts>
    <alerts>
        <fullName>Alert_Ops_Search_Product_Ready_for_Onboarding</fullName>
        <ccEmails>newcustomerordernotifications@cobalt.com</ccEmails>
        <description>Alert Ops - Search Product Ready for Onboarding</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/ONB_Search_Notification</template>
    </alerts>
    <alerts>
        <fullName>Alert_Ops_to_create_an_onboarding_case</fullName>
        <ccEmails>newcustomerordernotifications@cobalt.com</ccEmails>
        <description>Alert Ops to create an onboarding case.</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/EMS_Onboarding_Notification</template>
    </alerts>
    <alerts>
        <fullName>Alert_Order_Priority_Changed_by_NonOwner</fullName>
        <description>Alert - Order Priority Changed by NonOwner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Secondary_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Launch_Changed_to_911</template>
    </alerts>
    <alerts>
        <fullName>Alert_PSEO_Assigned_to_RM_SM_Launch</fullName>
        <description>Alert - PSEO Assigned to RM/SM Launch</description>
        <protected>false</protected>
        <recipients>
            <field>PowerSEO_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFS_Launch_Templates/Alert_RMSM_Assigned_to_Launch</template>
    </alerts>
    <alerts>
        <fullName>Alert_RM_Assigned_to_RM_SM_Launch</fullName>
        <description>Alert - RM Assigned to RM/SM Launch</description>
        <protected>false</protected>
        <recipients>
            <field>Reputation_Management_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_RMSM_Assigned_to_Launch</template>
    </alerts>
    <alerts>
        <fullName>Alert_Ready_for_Data_Ops</fullName>
        <description>Alert - Ready for Data Ops</description>
        <protected>false</protected>
        <recipients>
            <field>Data_Ops_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Ready_for_Data_Ops</template>
    </alerts>
    <alerts>
        <fullName>Alert_SEO_Accnt_switching_to_PowerSEO</fullName>
        <description>Alert - SEO Accnt switching to PowerSEO</description>
        <protected>false</protected>
        <recipients>
            <field>SEO_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_SEO_Accnt_switching_to_Power</template>
    </alerts>
    <alerts>
        <fullName>Alert_SM_Assigned_to_RM_SM_Launch</fullName>
        <description>Alert - SM Assigned to RM/SM Launch</description>
        <protected>false</protected>
        <recipients>
            <field>Social_Media_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_RMSM_Assigned_to_Launch</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_AA_DAA_DSM_Fight_for_First_Create</fullName>
        <description>Alert to AA, DAA, DSM - Fight for First Create</description>
        <protected>false</protected>
        <recipients>
            <field>Advocate_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CAM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>DSM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>OMS_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Fight_For_First_Launch_Opened</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_AA_DAA_DSM_SEO_Fight_for_First_Close</fullName>
        <description>Alert to AA, DAA, DSM, SEO - Fight for First Close</description>
        <protected>false</protected>
        <recipients>
            <field>Advocate_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CAM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>DSM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>OMS_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>RMS_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SEO_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Fight_For_First_Launch_Completed</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_AA_DSM_Launch_Closed</fullName>
        <description>Alert to AA, DSM - Launch Closed</description>
        <protected>false</protected>
        <recipients>
            <field>Advocate_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CAM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>DSM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>RMS_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Order_Closure_Notification</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_AA_DSM_Website_Launch_Created</fullName>
        <description>Alert to AA, DSM - Website Launch Created</description>
        <protected>false</protected>
        <recipients>
            <field>Advocate_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CAM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>DSM_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Order_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_AA_Services_Launch_Created</fullName>
        <description>Alert to AA - Services Launch Created</description>
        <protected>false</protected>
        <recipients>
            <field>Advocate_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CAM_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_AA_Services_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Activation_OM_Holden_Ready_for_Close</fullName>
        <ccEmails>enrollments@cobalt.com</ccEmails>
        <description>Alert to Activation OM - Holden Ready for Close</description>
        <protected>false</protected>
        <recipients>
            <field>Activation_OM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Holden_Ready_for_Oracle_Close</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Builder_OM_has_resubmitted</fullName>
        <description>Alert to Builder - OM has resubmitted</description>
        <protected>false</protected>
        <recipients>
            <field>Builder__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Build_is_Resubmitted</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Builder_QA_Order_on_Hold</fullName>
        <description>Alert to Builder &amp; QA – Order On Hold</description>
        <protected>false</protected>
        <recipients>
            <field>Builder__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>QA_Builder__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Launch_on_Hold</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Builder_Ready_for_Builder</fullName>
        <description>Alert to Builder - Ready for Builder</description>
        <protected>false</protected>
        <recipients>
            <field>Builder__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Ready_for_Builder</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Builder_Time_for_Proto_Loop</fullName>
        <description>Alert to Builder - Time for Proto Loop</description>
        <protected>false</protected>
        <recipients>
            <field>Builder__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Proto_Loop</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_DA_Launch_Closed</fullName>
        <description>Alert to DA - Launch Closed</description>
        <protected>false</protected>
        <recipients>
            <field>OMS_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Order_Closure_Notification</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_DA_Mgr_Launched_Opened</fullName>
        <ccEmails>ServicesDATier3Onboarding@cdk.com</ccEmails>
        <description>Alert to DA Mgr – Launched Opened</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_DA_Mgr_Launch_Opened</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_DSM_Services_Launch_Created</fullName>
        <description>Alert to CAM/DSM - Services Launch Created</description>
        <protected>false</protected>
        <recipients>
            <recipient>Digital Services CAM</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>DSM_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Order_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Data_Ops_Resubmit</fullName>
        <description>Alert to Data Ops - Resubmit</description>
        <protected>false</protected>
        <recipients>
            <field>Data_Ops_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Data_Ops_Resubmit</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Domains_OM_has_resubmitted</fullName>
        <description>Alert to Domains - OM has resubmitted</description>
        <protected>false</protected>
        <recipients>
            <field>Domain_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Domains_is_Resubmitted</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Inventory_OM_has_resubmitted</fullName>
        <description>Alert to Inventory - OM has resubmitted</description>
        <protected>false</protected>
        <recipients>
            <field>Inventory_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Inventory_is_Resubmitted</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_LMA_Analysts_Ready_for_Media</fullName>
        <description>Alert to LMA Analysts – Ready for Media</description>
        <protected>false</protected>
        <recipients>
            <field>LMA_Analyst2__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/AMA_ready_for_media</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_LMA_Analysts_Ready_for_QA</fullName>
        <description>Alert to LMA Analysts – Ready for QA</description>
        <protected>false</protected>
        <recipients>
            <field>LMA_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/AMA_ready_for_QA</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_LMA_Strategist_QA_Complete</fullName>
        <description>Alert to LMA Strategist – QA Complete</description>
        <protected>false</protected>
        <recipients>
            <field>LMA_Strategist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/AMA_QA_Complete</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Launch_Owner_30_Days_since_order_closed</fullName>
        <description>Alert to Launch Owner - 30 Days since order closed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_30_Days_Past_and_No_Data</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Launch_Owner_Build_Complete1</fullName>
        <description>Alert to Launch Owner - Build Complete</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Secondary_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Build_Complete</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Launch_Owner_Build_ready_for_QA</fullName>
        <description>Alert to OM/Secondary - Build Ready for QA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Secondary_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_OM_Build_Ready_for_QA</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Launch_Owner_Domain_Issue</fullName>
        <description>Alert to Launch Owner - Domain Issue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Secondary_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Domain_Issue_to_OM</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Launch_Owner_Domains_Acquired_Waiting_on_URL</fullName>
        <description>Alert to Launch Owner - Domains Acquired - Waiting on URL</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_OM_Domains_Acquired_Waiting_on_URL</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Launch_Owner_Domains_complete</fullName>
        <description>Alert to Launch Owner - Domains complete</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Domains_Complete</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Launch_Owner_Inventory_complete</fullName>
        <description>Alert to Launch Owner - Inventory complete</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Inventory_Complete</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Launch_Secondary_Owner_Data_Ops_Issue</fullName>
        <description>Alert to Launch/Secondary Owner - Data Ops Issue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Secondary_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_DataOps_Issue_to_OM</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Order_Manager_Bulk_Order_has_resubmitted</fullName>
        <description>Alert to Order Manager - Bulk Order has resubmitted</description>
        <protected>false</protected>
        <recipients>
            <field>Order_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Bulk_Order_is_Resubmitted</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Owner_Inventory_Issue</fullName>
        <description>Alert to Owner - Inventory Issue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Secondary_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Inventory_Issue_to_OM</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Owners_Build_Issue</fullName>
        <description>Alert to Owners – Build Issue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Secondary_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Build_Issue_to_OM</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Owners_Proto_Is_Ready</fullName>
        <description>Alert to Owners - Proto Is Ready</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Secondary_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Proto_Ready</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Owners_QA_Complete</fullName>
        <description>Alert to Owners - QA Complete</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Secondary_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_QA_Complete</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Owners_QA_Issue</fullName>
        <description>Alert to Owners - QA Issue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Secondary_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_QA_Issue_to_OM</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_PSEO_Launch_Closed</fullName>
        <description>Alert to PSEO - Launch Closed</description>
        <protected>false</protected>
        <recipients>
            <field>SEO_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Order_Closure_Notification</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_QAAOM</fullName>
        <description>Alert to QAAOM - OM has resubmitted for QA</description>
        <protected>false</protected>
        <recipients>
            <field>QA_Activation_OM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_QA_is_Resubmitted</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_QAAOM_Ready_for_QA</fullName>
        <description>Alert to QAAOM - Ready for QA</description>
        <protected>false</protected>
        <recipients>
            <field>QA_Activation_OM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_Ready_for_QA</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_QA_Ready_for_QA</fullName>
        <description>Alert to QA - Ready for QA</description>
        <protected>false</protected>
        <recipients>
            <field>QA_Builder__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_OM_Build_Ready_for_QA</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_RMS_RepMan_Downgrade</fullName>
        <description>Alert to RMS - RepMan Downgrade</description>
        <protected>false</protected>
        <recipients>
            <field>RMS_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Alert_GM_RepMan_Downgrade</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_RM_SM_Mgr_Launched_Opened</fullName>
        <description>Alert to RM/SM Mgr – Launched Opened</description>
        <protected>false</protected>
        <recipients>
            <recipient>kelly.reynolds@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mitch.williams@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>robert.allen2@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFS_Launch_Templates/Alert_RM_SM_Launch_Opened</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_SEO_Fight_for_First_Launch</fullName>
        <description>Alert to SEO – Fight for First Launch</description>
        <protected>false</protected>
        <recipients>
            <field>SEO_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_SEO_for_Fight_for_First_Launch</template>
    </alerts>
    <alerts>
        <fullName>CB_SVC_Alert_EMS_onboarding_case</fullName>
        <description>CB_SVC Alert EMS onboarding case</description>
        <protected>false</protected>
        <recipients>
            <recipient>kimberly.dearie@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>stephanie.deahl@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFS_Launch_Templates/Alert_EMS_Onboarding_Notification_to_EMS</template>
    </alerts>
    <alerts>
        <fullName>CB_SVC_Alert_PSEO_Assignment_Launch</fullName>
        <description>CB_SVC_Alert - PSEO Assignment Launch</description>
        <protected>false</protected>
        <recipients>
            <field>PowerSEO_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/CB_SVC_Alert_PSEO_Assignment_Launch</template>
    </alerts>
    <alerts>
        <fullName>CB_SVC_Alert_PSEO_DG_Mgr_Launch_Opened</fullName>
        <ccEmails>PSEOLaunchNotifications@cdk.com</ccEmails>
        <description>CB_SVC_Alert – PSEO Mgr Launch Opened</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/CB_SVC_Alert_PSEO_Mgr_Launch_Opened</template>
    </alerts>
    <alerts>
        <fullName>DI_Submitted_Email_Alert</fullName>
        <description>DI Submitted Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>kimberly.dearie@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Submitted_to_DI_Vendor_Notification</template>
    </alerts>
    <alerts>
        <fullName>Data_Uploaded_Alert</fullName>
        <description>Data Uploaded Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Secondary_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Data_has_been_uploaded_Notification</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_to_New_Customer_Orders_for_HoldenNZ_closed_Launch</fullName>
        <ccEmails>newcustomerordernotifications@cobalt.com</ccEmails>
        <description>Email Alert to New Customer Orders for HoldenNZ closed Launch</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFS_Launch_Templates/ONB_ProCare_Notification</template>
    </alerts>
    <alerts>
        <fullName>Email_Banner_Completed_Alert</fullName>
        <description>Email Banner Completed Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Email_Banner_Completed_Notification</template>
    </alerts>
    <alerts>
        <fullName>Email_Banner_Requested_Alert</fullName>
        <ccEmails>ServicesEMSDesignTeam@cobaltgroup.com</ccEmails>
        <description>Email Banner Requested Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>chase.tangney@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>yan.chow@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Email_Banner_Requested_Notification</template>
    </alerts>
    <alerts>
        <fullName>Email_Banner_Requested_Alert2</fullName>
        <ccEmails>ServicesEMSDesignTeam@cobaltgroup.com</ccEmails>
        <description>Email Banner Requested Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>yan.chow@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Design_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Email_Banner_Requested_Notification</template>
    </alerts>
    <alerts>
        <fullName>Email_to_PromoShop_for_Reputation_Management</fullName>
        <ccEmails>john@sbxgrp.com</ccEmails>
        <description>Email to PromoShop for Reputation Management</description>
        <protected>false</protected>
        <recipients>
            <field>Reputation_Management_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Welcome_Kit_Request_Reputation_Management</template>
    </alerts>
    <alerts>
        <fullName>Welcome_Kit_requested_Alert</fullName>
        <ccEmails>SJanzen@robynpromo.com</ccEmails>
        <description>Welcome Kit requested Alert</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/Welcome_Kit_Requested_Notificaiton</template>
    </alerts>
    <alerts>
        <fullName>eAppend_ready_to_send_Alert</fullName>
        <ccEmails>onstationdataops@cobaltgroup.com</ccEmails>
        <description>eAppend ready to send Alert</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/eAppend_Ready_for_Dealer_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_Status_to_In_progress</fullName>
        <field>Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Change Status to In progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Data_Ops_Assign_Date_to_Now</fullName>
        <field>Data_Ops_Assign_Date__c</field>
        <formula>NOW()</formula>
        <name>Data Ops Assign Date to Now</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Data_Ops_Status_to_With_Data_Op</fullName>
        <field>Data_Ops_Status__c</field>
        <literalValue>With Data Ops</literalValue>
        <name>Data Ops Status to With Data Op</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Data_Ops_Status_to_With_Integralink</fullName>
        <field>Data_Ops_Status__c</field>
        <literalValue>With Integralink</literalValue>
        <name>Data Ops Status to With Integralink</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Design_Completion_Date_to_Now</fullName>
        <field>Design_Completion_Date__c</field>
        <formula>Now()</formula>
        <name>Design Completion Date to Now</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Launch_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>Launch_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_Closed_Date</fullName>
        <description>Removes the closed date if the launch record goes from closed to an open status.</description>
        <field>Closed_Date__c</field>
        <name>Remove Closed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_Do_Not_Send_Onboarding_Checkmark</fullName>
        <field>Do_Not_Send_Onboarding__c</field>
        <literalValue>0</literalValue>
        <name>Remove Do Not Send Onboarding Checkmark</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Closed_Date</fullName>
        <description>Sets now as the closed date when workflow evaluates to true.</description>
        <field>Closed_Date__c</field>
        <formula>NOW()</formula>
        <name>Set Closed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Data_Ops_Complete_Date_to_NULL</fullName>
        <field>Data_Ops_Completion_Date__c</field>
        <name>Set Data Ops Complete Date to NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Data_Ops_Complete_Date_to_Now</fullName>
        <field>Data_Ops_Completion_Date__c</field>
        <formula>Now()</formula>
        <name>Set Data Ops Complete Date to Now</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Design_Assign_Date_to_Now</fullName>
        <field>Design_Assign_Date__c</field>
        <formula>Now()</formula>
        <name>Set Design Assign Date to Now</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Design_Completion_date_to_null</fullName>
        <field>Design_Completion_Date__c</field>
        <name>Set Design Completion date to null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Design_completion_date_to_null2</fullName>
        <field>Design_Completion_Date__c</field>
        <name>Set Design completion date to null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_With_Domains</fullName>
        <field>Domain_Status__c</field>
        <literalValue>With Domains</literalValue>
        <name>Set Status With Domains</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_With_Inventory</fullName>
        <field>Inventory_Status__c</field>
        <literalValue>With Inventory</literalValue>
        <name>Set Status With Inventory</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_With_Design</fullName>
        <field>Design_Status__c</field>
        <literalValue>With Design</literalValue>
        <name>Set Status to With Design</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_With_Design2</fullName>
        <field>Design_Status__c</field>
        <literalValue>With Design</literalValue>
        <name>Set Status to With Design</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>URL_for_Domains_set_to_ready</fullName>
        <field>URL_for_Domains_Status__c</field>
        <literalValue>Ready</literalValue>
        <name>URL for Domains set to ready</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_AA_Assign_Alert_Sent</fullName>
        <description>Checks the Sent AA Assign Alert checkbox to signify that this alert has gone out. Prevents Duplicates.</description>
        <field>Sent_AA_Assign_Alert__c</field>
        <literalValue>1</literalValue>
        <name>Update - AA Assign Alert Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Build_Assign_Date</fullName>
        <field>Build_Assign_Date__c</field>
        <formula>NOw()</formula>
        <name>Update Build Assign Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Build_Complete_Date_Complete</fullName>
        <field>Build_Completion_Date__c</field>
        <formula>Now()</formula>
        <name>Update Build Complete Date - Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Build_Complete_Date_NULL</fullName>
        <field>Build_Completion_Date__c</field>
        <name>Update Build Complete Date - NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Build_Complete_Date_Remove_date</fullName>
        <field>Build_Completion_Date__c</field>
        <name>Update Build Complete Date - Remove date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Build_QA_Assign_Date_Field</fullName>
        <description>Pushes the date someone filled out the QA Builder field to the QA Assign Date field.</description>
        <field>Build_QA_Assign_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Build QA Assign Date Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Build_Status</fullName>
        <field>Build_Status__c</field>
        <literalValue>With Builder</literalValue>
        <name>Update Build Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Build_Status_Ready</fullName>
        <field>Build_Status__c</field>
        <literalValue>Ready for Builder</literalValue>
        <name>Update Build Status - Ready</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Build_Status_Ready2</fullName>
        <field>Build_Status__c</field>
        <literalValue>Ready for Builder</literalValue>
        <name>Update Build Status - Ready</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Build_Status_to_With_QA</fullName>
        <description>When the QA Builder field is filled out and the section isn&apos;t complete, the status will be updated to &quot;With QA.&quot;</description>
        <field>Build_Status__c</field>
        <literalValue>With QA</literalValue>
        <name>Update Build Status to With QA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bulk_Order_Assign_Date</fullName>
        <field>Bulk_Order_Assign_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Bulk Order Assign Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bulk_Order_Complete_Date_Complete</fullName>
        <field>Bulk_Order_Completion_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Bulk Order Complete Date-Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bulk_Order_Complete_Date_NULL</fullName>
        <field>Bulk_Order_Completion_Date__c</field>
        <name>Update Bulk Order Complete Date - NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bulk_Order_Complete_Date_Remove</fullName>
        <field>Bulk_Order_Completion_Date__c</field>
        <name>Update Bulk Order Complete Date - Remove</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bulk_Order_Request_Date</fullName>
        <field>Bulk_Order_Submit_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Bulk Order Request Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bulk_Order_Status</fullName>
        <field>Bulk_Order_Status__c</field>
        <literalValue>With Order Specialist</literalValue>
        <name>Update Bulk Order Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bulk_Order_Status_Ready</fullName>
        <field>Bulk_Order_Status__c</field>
        <literalValue>Ready for Order Specialist</literalValue>
        <name>Update Bulk Order Status - Ready</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Completion_Date_NULL</fullName>
        <field>Data_Ops_Completion_Date__c</field>
        <name>Update Completion Date - NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Data_Opps_Status</fullName>
        <field>Data_Ops_Status__c</field>
        <literalValue>With Data Ops</literalValue>
        <name>Update Data Opps Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Data_Ops_Issue_With_Integralink</fullName>
        <description>Update the Data Ops Status field to reflect &quot;Issue with Integralink.&quot;</description>
        <field>Data_Ops_Status__c</field>
        <literalValue>Issue with Integralink</literalValue>
        <name>Update - Data Ops Issue With Integralink</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Data_Ops_Status_Ready</fullName>
        <field>Data_Ops_Status__c</field>
        <literalValue>Ready for Data Ops</literalValue>
        <name>Update Data Ops Status - Ready</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Data_Ops_With_Integralink</fullName>
        <description>Update the Data Ops Status field to reflect &quot;With Integralink&quot;</description>
        <field>Data_Ops_Status__c</field>
        <literalValue>With Integralink</literalValue>
        <name>Update - Data Ops With Integralink</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Do_Not_Send_Onboarding</fullName>
        <field>Do_Not_Send_Onboarding__c</field>
        <literalValue>1</literalValue>
        <name>Update Do Not Send Onboarding</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Domain_Assign_Date</fullName>
        <field>Domain_Assign_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Domain Assign Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Domain_Complete_Date_Complete</fullName>
        <field>Domain_Completion_Date__c</field>
        <formula>Now()</formula>
        <name>Update Domain Complete Date - Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Domain_Complete_Date_Not_Comp</fullName>
        <field>Domain_Completion_Date__c</field>
        <name>Update Domain Complete Date - Not Comp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Domain_Complete_Date_Not_Comp2</fullName>
        <field>Domain_Completion_Date__c</field>
        <name>Update Domain Complete Date - Not Comp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Domain_Rqst_Date</fullName>
        <field>Domain_Request_Submit_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Domain Rqst Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Domain_Status_Ready</fullName>
        <field>Domain_Status__c</field>
        <literalValue>Ready for Domains</literalValue>
        <name>Update Domain Status - Ready</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Domain_Status_Ready2</fullName>
        <field>Domain_Status__c</field>
        <literalValue>Ready for Domains</literalValue>
        <name>Update Domain Status - Ready</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Inventory_Assign_Date</fullName>
        <field>Inventory_Assign_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Inventory Assign Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Inventory_Complete_Date</fullName>
        <field>Inventory_Completion_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Inventory Complete Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Inventory_Complete_Date_Not_Com</fullName>
        <description>Clear the update field when the Status is changed back to incomplete.</description>
        <field>Inventory_Completion_Date__c</field>
        <formula>Null</formula>
        <name>Update Inventory Complete Date – Not Com</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Inventory_Rqst_Date</fullName>
        <field>Inventory_Request_Submit_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Inventory Rqst Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Inventory_Status_Ready</fullName>
        <field>Inventory_Status__c</field>
        <literalValue>Ready for Inventory</literalValue>
        <name>Update Inventory Status – Ready</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Order_Closed_Waiting_Data_Date</fullName>
        <field>Order_Closed_Waiting_on_Data_Date__c</field>
        <formula>today()</formula>
        <name>Update Order Closed Waiting Data Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Proto_Loop_Count_Increment</fullName>
        <description>Updates by an increment of +1 each time the Build Status is set equal to &quot;Proto Loop.&quot;</description>
        <field>Proto_Loop_Count__c</field>
        <formula>IF(ISNULL( Proto_Loop_Count__c ),1,Proto_Loop_Count__c+1)</formula>
        <name>Update Proto Loop Count Increment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Proto_Ready_Date</fullName>
        <description>Updates the Proto Ready Date with the date/time the Build Status is updated to &quot;Proto Ready.&quot;</description>
        <field>Proto_Ready_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Proto Ready Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_QA_Assign_Date</fullName>
        <field>QA_Assign_Date__c</field>
        <formula>NOW()</formula>
        <name>Update QA Assign Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_QA_Complete_Date_Complete</fullName>
        <field>QA_Completion_Date__c</field>
        <formula>NOW()</formula>
        <name>Update QA Complete Date - Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_QA_Complete_Date_Null</fullName>
        <field>QA_Completion_Date__c</field>
        <name>Update QA Complete Date - Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_QA_Rqst_Date_Now</fullName>
        <field>QA_Request_Submit_Date__c</field>
        <formula>NOW()</formula>
        <name>Update QA Rqst Date - Now</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_QA_Status</fullName>
        <field>QA_Status__c</field>
        <literalValue>With QA</literalValue>
        <name>Update QA Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_QA_Status_Ready_for_QA</fullName>
        <field>QA_Status__c</field>
        <literalValue>Ready for QA</literalValue>
        <name>Update QA Status - Ready for QA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Rqst_Date</fullName>
        <field>Build_Request_Submit_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Rqst Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Send_Onboarding_to_True</fullName>
        <field>Send_Onboarding__c</field>
        <literalValue>1</literalValue>
        <name>Update Send Onboarding to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Send_SEO_Onboarding_to_True</fullName>
        <field>Send_SEO_Onboarding__c</field>
        <literalValue>1</literalValue>
        <name>Update Send SEO Onboarding to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Ship_to_Address</fullName>
        <field>Ship_To_Address__c</field>
        <formula>Account__r.CBLTShipAddress__c</formula>
        <name>Update Ship to Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Ready_for_Data_Ops</fullName>
        <field>Data_Ops_Status__c</field>
        <literalValue>Ready for Data Ops</literalValue>
        <name>Update Status - Ready for Data Ops</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Welcome_Kit_Request</fullName>
        <description>Updates the Welcome Kit Request date field to today.</description>
        <field>Welcome_Kit_Requested__c</field>
        <formula>TODAY()</formula>
        <name>Update Welcome Kit Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_eAppend_Completion_Date</fullName>
        <field>eAppend_Completion_Date__c</field>
        <formula>NOW()</formula>
        <name>Update eAppend Completion Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_eAppend_Sent</fullName>
        <field>eAppend_Sent__c</field>
        <formula>NOW()</formula>
        <name>Update eAppend Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_eAppend_Sent_Date</fullName>
        <field>eAppend_Sent_Date__c</field>
        <formula>NOW()</formula>
        <name>Update eAppend Sent Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AMA Launch Alert %E2%80%93 QA Complete</fullName>
        <actions>
            <name>Alert_to_LMA_Strategist_QA_Complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.LMA_QA_Complete__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>AMA Launch Alert: Email alert to LMA Strategist when QA Complete date is entered</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AMA Launch Alert %E2%80%93 Ready for Media</fullName>
        <actions>
            <name>Alert_to_LMA_Analysts_Ready_for_Media</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Ready_for_Media__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>AMA Launch Alert: Email alert to LMA Analysts when Ready for Media date is entered</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AMA Launch Alert %E2%80%93 Ready for QA</fullName>
        <actions>
            <name>Alert_to_LMA_Analysts_Ready_for_QA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Ready_for_QA__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>AMA Launch Alert: Email alert to LMA Analysts when Ready for QA date is entered</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Account handed to specialist</fullName>
        <actions>
            <name>Alert_Ops_to_create_an_onboarding_case</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Launch__c.Account_Handed_to_Specialist__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Email Marketing Launch</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert %E2%80%93 Fight For First Creation</fullName>
        <actions>
            <name>Alert_to_AA_DAA_DSM_Fight_for_First_Create</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Alert_to_SEO_Fight_for_First_Launch</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Applies to all RT where Launch Promotions/Projects is Fight for First and the record is Open.</description>
        <formula>AND(  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  Promotion_Project__r.Name = &quot;Fight for First&quot;  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert %E2%80%93 Fight for First Closure</fullName>
        <actions>
            <name>Alert_to_AA_DAA_DSM_SEO_Fight_for_First_Close</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Applies to all RT where Launch Promotions/Projects is Fight for First and the record is Closed.</description>
        <formula>AND(  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  Promotion_Project__r.Name = &quot;Fight for First&quot;,  Open_Status__c=&quot;Closed&quot;  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert %E2%80%93 RepMan Downgrade</fullName>
        <actions>
            <name>Alert_to_RMS_RepMan_Downgrade</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>For SMRM w/out Product Type GM Power Reputation Management and Order Type = Downgrade: Sends a notification to the RMS assigned to the webid.</description>
        <formula>AND(          NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),      OR(          NOT(INCLUDES( Product_Type__c , &quot;GM Power Reputation Management&quot;)),         NOT(INCLUDES(Product_Type__c, &quot;Power Reputation Management&quot;))        ),         $RecordType.Name = &quot;SM/RM Launch&quot;,          ISPICKVAL(Order_Type__c ,&quot;Downgrade&quot;),           Open_Status__c =&quot;Closed&quot; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert - All Launch Closure</fullName>
        <actions>
            <name>Alert_to_AA_DSM_Launch_Closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>For all Record Types: Notifies the DSM and AA when a Launch record is closed.</description>
        <formula>AND(  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),   Open_Status__c = &quot;Closed&quot;,  Promotion_Project__r.Name &lt;&gt; &quot;Fight for First&quot; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert - DA Mgr Launch Opened</fullName>
        <actions>
            <name>Alert_to_DA_Mgr_Launched_Opened</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>For DAP/Search Product launch: Notifies DAA Mgmt of launch</description>
        <formula>AND(  NOT(BEGINS($User.Username,&quot;integration_user@cdk.com&quot;)),  OR( $RecordType.Name = &quot;DAP Launch&quot;, $RecordType.Name = &quot;Search Products Launch&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert - Not WS Launch Creation</fullName>
        <active>true</active>
        <description>For all but WS Launch: Notifies the DSM and AA when a Launch record is created.  Only done upon creation to prevent mass blasts when there is a bulkload done prior to enrollment.</description>
        <formula>AND(  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  Promotion_Project__r.Name &lt;&gt; &quot;Fight for First&quot;, NOT(ISPICKVAL(Status__c,&quot;Not Started&quot;)), NOT(ISPICKVAL(Status__c,&quot;Not Enrolled&quot;)), $RecordType.Name &lt;&gt; &quot;Website Launch&quot;, $RecordType.Name &lt;&gt; &quot;AMA Launch&quot; )</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Alert_to_AA_Services_Launch_Created</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Alert_to_DSM_Services_Launch_Created</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Alert - Not WS Launch In Progress</fullName>
        <actions>
            <name>Alert_to_AA_Services_Launch_Created</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Alert_to_DSM_Services_Launch_Created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>For all but WS Launch: Notifies the DSM and AA when a Launch record is created.</description>
        <formula>AND($RecordType.Name &lt;&gt; &quot;AMA Launch&quot;,  NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)),  (ISPICKVAL(Status__c,&quot;Gathering Requirements&quot;)),  $RecordType.Name &lt;&gt; &quot;Website Launch&quot;,  Promotion_Project__r.Name &lt;&gt; &quot;Fight for First&quot;  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert - PSEO Launch Closure to DA</fullName>
        <actions>
            <name>Alert_to_DA_Launch_Closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>For PowerSEO Record Types: Notifies the Digital Advertising Analyst when a Launch record is closed.</description>
        <formula>AND(      NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),       Open_Status__c = &quot;Closed&quot;,      OR(       INCLUDES( Product_Type__c , &quot;Power SEO&quot;),        INCLUDES( Add_Ons__c , &quot;Power SEO&quot;)      ),    Promotion_Project__r.Name &lt;&gt; &quot;Fight for First&quot; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert - RM%2FSM Launch Opened</fullName>
        <actions>
            <name>Alert_to_RM_SM_Mgr_Launched_Opened</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>For RM/SM launch: Notifies Jason Davis and Robert Allen when Launch is created</description>
        <formula>AND(  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  $RecordType.Name = &quot;SM/RM Launch&quot; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Alert - SP SMRM DAP Launch Closure to PSEO</fullName>
        <actions>
            <name>Alert_to_PSEO_Launch_Closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>For Search Product, DAP, and SM/RM Record Types: Notifies the PowerSEO when a Launch record is closed.</description>
        <formula>AND(      NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),       Open_Status__c = &quot;Closed&quot;,      PowerSEO_Product__c =1,    OR(       $RecordType.Name = &quot;Search Products Launch&quot;,       $RecordType.Name = &quot;DAP Launch&quot;,       $RecordType.Name = &quot;SM/RM Launch&quot;        )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert - WS Launch Creation</fullName>
        <active>true</active>
        <description>For Website: Notifies the DSM and AA when a Launch record is created.  Only evaluated when created to prevent mass blasts when there are bulkloads done prior to dealer enrollment.</description>
        <formula>AND(  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  $RecordType.Name = &quot;Website Launch&quot;, NOT(ISPICKVAL(Status__c,&quot;Not Started&quot;)), NOT(ISPICKVAL(Status__c,&quot;Not Enrolled&quot;)), NOT( Promotion_Project__r.Name = &quot;Fight for First&quot;) )</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Alert_to_AA_DSM_Website_Launch_Created</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Alert - WS Launch In Progress</fullName>
        <actions>
            <name>Alert_to_AA_DSM_Website_Launch_Created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>For Website: Notifies the DSM and AA when a Launch record is changed to In Progress.</description>
        <formula>AND(  NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)),  $RecordType.Name = &quot;Website Launch&quot;,  (ISPICKVAL(Status__c,&quot;Gathering Requirements&quot;)),  NOT( Promotion_Project__r.Name = &quot;Fight for First&quot;)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Banner Created Date</fullName>
        <actions>
            <name>Email_Banner_Completed_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Design_Status__c</field>
            <operation>equals</operation>
            <value>Design Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Design Section:  An email is sent to Implementation that a banner has been created and posted to the dealer folder by EMS Design.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Build Alert %E2%80%93 On Hold</fullName>
        <actions>
            <name>Alert_to_Builder_QA_Order_on_Hold</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Status__c</field>
            <operation>equals</operation>
            <value>On Hold</value>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Builder__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Build Section:  Alert Builder that status is on hold.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Build Alert - Build Complete</fullName>
        <actions>
            <name>Alert_to_Launch_Owner_Build_Complete1</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>All w/ Build Section: Alert goes to Launch Owner if they did not set the completion status.</description>
        <formula>IF($User.Id &lt;&gt;  OwnerId  &amp;&amp;  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp; ISPIckVal(Build_Status__c, &quot;Build Complete&quot;) , True, False)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Build Alert - Build Issue to OM</fullName>
        <actions>
            <name>Alert_to_Owners_Build_Issue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Build_Status__c</field>
            <operation>equals</operation>
            <value>Issue Sent to Order Manager</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Build Section:  When Build status is set to &quot;Issue Sent to OM&quot; send alert to OM</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Build Alert - Build Ready for QA Not WS</fullName>
        <actions>
            <name>Alert_to_Launch_Owner_Build_ready_for_QA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Build_Status__c</field>
            <operation>equals</operation>
            <value>Ready for QA</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Website Launch</value>
        </criteriaItems>
        <description>All w/ Build Section except WS:  Build work is completed and ready for QA step.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Build Alert - Build Ready for QA WS</fullName>
        <actions>
            <name>Alert_to_QA_Ready_for_QA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Only WS:  Build work is completed and ready for QA step when QA Builder assigned.</description>
        <formula>AND(        NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),               ISPICKVAL(Build_Status__c, &quot;Ready for QA&quot;),         NOT( $User.Id =QA_Builder__c),         $RecordType.Name = &quot;Website Launch&quot;        )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Build Alert - Proto Loop</fullName>
        <actions>
            <name>Alert_to_Builder_Time_for_Proto_Loop</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Build_Status__c</field>
            <operation>equals</operation>
            <value>Proto Loop</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Build Section:  Alert goes to Builder that proto loop is needed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Build Alert - Proto Ready</fullName>
        <actions>
            <name>Alert_to_Owners_Proto_Is_Ready</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>WS - Sends an alert each time the Build Status is updated to Proto Ready.</description>
        <formula>AND(             $RecordType.Name = &quot;Website Launch&quot;,            ISPICKVAL( Build_Status__c, &quot;Proto Ready&quot;)          )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Build Alert - Ready for Builder</fullName>
        <actions>
            <name>Alert_to_Builder_Ready_for_Builder</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Any w/ Build Section: If Builder is assigned and QA or OM changes status to Ready for Builder, Alert is sent to Builder.</description>
        <formula>AND(        NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),              ISPICKVAL(Build_Status__c,&quot;Ready for Builder&quot;),       Not(ISNULL( Builder__c )),       PRIORVALUE(Build_Open_Status__c)&lt;&gt;&quot;Closed&quot;,       NOT($User.Id  = Builder__c)       )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Build Alert and Update - Resubmit</fullName>
        <actions>
            <name>Alert_to_Builder_OM_has_resubmitted</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Build_Complete_Date_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Build_Status_Ready2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All w/ Build Section:  Build work is still needed, alert to Build Specialist and put record back in queue.</description>
        <formula>IF(AND( OR(  PriorValue( Build_ReSubmit_Date__c )&lt;&gt; Build_ReSubmit_Date__c ,  (Isblank(PriorValue( Build_ReSubmit_Date__c )) &amp;&amp;  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp; Not(isblank(Build_ReSubmit_Date__c )))  ),  ISPickval(Build_Status__c, &quot;Build Complete&quot;) ), true, false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Build Update - Add Complete Date</fullName>
        <actions>
            <name>Update_Build_Complete_Date_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Build_Status__c</field>
            <operation>contains</operation>
            <value>Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Build Section:  Adds date/time to Build Complete date field when status is set to complete.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Build Update - Assign Date Only</fullName>
        <actions>
            <name>Update_Build_Assign_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Build_Assign_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Builder__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Build_Status__c</field>
            <operation>equals</operation>
            <value>Build Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Build Section:  If Builder is assigned at same time as Build Complete then update build assign date but do not change build status to &quot;Build Complete.&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Build Update - Assign Date and Status</fullName>
        <actions>
            <name>Update_Build_Assign_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Build_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Build_Assign_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Builder__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Build_Status__c</field>
            <operation>notEqual</operation>
            <value>Build Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Build Section:  Upon Build Status change to &quot;With Builder&quot; update Build Assign Date field.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Build Update - Proto Loop Count</fullName>
        <actions>
            <name>Update_Proto_Loop_Count_Increment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All w/ Build Section/Proto Loop Count field on the page layout.</description>
        <formula>AND(     NOT(ISPICKVAL(PRIORVALUE(Build_Status__c  ), &quot;Proto Loop&quot;)),     ISPICKVAL(Build_Status__c, &quot;Proto Loop&quot;)       )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Build Update - Proto Ready Date</fullName>
        <actions>
            <name>Update_Proto_Ready_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All w/ Build Section &amp; Proto Date field on Page Layout - Updates the date field the first time the Build Status is set to &quot;Proto Ready.&quot;</description>
        <formula>AND(            ISBLANK(Proto_Ready_Date__c ),            ISPICKVAL( Build_Status__c, &quot;Proto Ready&quot;)          )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Build Update - QA Assign Date Only</fullName>
        <actions>
            <name>Update_Build_QA_Assign_Date_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Build_QA_Assign_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.QA_Builder__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notEqual</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Build_Status__c</field>
            <operation>equals</operation>
            <value>Build Complete</value>
        </criteriaItems>
        <description>Any w/ Build Section - Updates the Build QA Assign Date and leaves the Build Status at Complete when the QA Builder field is assigned and Status is Complete.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Build Update - QA Assign Date and Status</fullName>
        <actions>
            <name>Update_Build_QA_Assign_Date_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Build_Status_to_With_QA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Build_QA_Assign_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.QA_Builder__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Build_Status__c</field>
            <operation>notEqual</operation>
            <value>Build Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notEqual</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Any w/ Build Section - Updates the Build QA Assign Date and move the Build Status to With QA when the QA Builder field is assigned.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Build Update - Remove Complete Date</fullName>
        <actions>
            <name>Update_Build_Complete_Date_Remove_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Build_Status__c</field>
            <operation>notContain</operation>
            <value>Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Build Section:  removes Build completion date if status is set back to any status that does not contain the word &quot;Complete&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Build Update - Send to Build Queue</fullName>
        <actions>
            <name>Update_Build_Complete_Date_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Build_Status_Ready</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Rqst_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Build_Request_Submitted__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Build_Request_Submit_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Build Section:  Sets Build status to &quot;Ready for Builder&quot; when the Build Request Submit date is entered.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Bulk Order Alert and Update - Resubmit</fullName>
        <actions>
            <name>Alert_to_Order_Manager_Bulk_Order_has_resubmitted</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Bulk_Order_Complete_Date_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bulk_Order_Status_Ready</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All w/ Bulk Order Section:  Build work is still needed, alert to Order Manager and put record back in queue.</description>
        <formula>IF(AND( OR(  PriorValue( Bulk_Order_ReSubmit_Date__c )&lt;&gt; Bulk_Order_ReSubmit_Date__c ,  (Isblank(PriorValue( Bulk_Order_ReSubmit_Date__c )) &amp;&amp;  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp; Not(isblank(Bulk_Order_ReSubmit_Date__c )))  ),  ISPickval(Bulk_Order_Status__c, &quot;Bulk Order Complete&quot;) ), true, false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Bulk Order Update - Add Complete Date</fullName>
        <actions>
            <name>Update_Bulk_Order_Complete_Date_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Bulk_Order_Status__c</field>
            <operation>contains</operation>
            <value>Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Bulk Order Section:  Adds date/time to Bulk Order Complete date field when status is set to complete.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Bulk Order Update - Assign Date and Status</fullName>
        <actions>
            <name>Update_Bulk_Order_Assign_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bulk_Order_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Bulk_Order_Assign_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Order_Manager__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Bulk_Order_Status__c</field>
            <operation>notEqual</operation>
            <value>Bulk Order Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Bulk Order Section:  Upon Build Status change to &quot;With Order Specialist&quot; update Bulk Order Assign Date field.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Bulk Order Update - Remove Complete Date</fullName>
        <actions>
            <name>Update_Bulk_Order_Complete_Date_Remove</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Bulk_Order_Status__c</field>
            <operation>notContain</operation>
            <value>Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Bulk Order Section:  removes Bulk Order completion date if status is set back to any status that does not contain the word &quot;Complete&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Bulk Order Update - Send to Bulk Order Queue</fullName>
        <actions>
            <name>Update_Bulk_Order_Complete_Date_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bulk_Order_Request_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bulk_Order_Status_Ready</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Bulk_Order_Request_Submitted__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Bulk_Order_Submit_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Bulk Order Section:  Sets Bulk Order status to &quot;Ready for Order Specialist&quot; when the  Bulk Order Request Submit date is entered.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_Alert_AA_Assignment_ProCare_Launch</fullName>
        <actions>
            <name>Alert_AA_Assigned_to_Launch</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>ebsite or A La Carte Launch w/ ProCare: Sends notification to Advocate once they have been assigned to the Launch.</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp;  ( $RecordType.Name = &quot;Website Launch&quot; ||  $RecordType.Name = &quot;A La Carte Launch&quot; )&amp;&amp;  NOT(ISBLANK( Account_Advocate__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_Alert_DA_Assignment_Launch</fullName>
        <actions>
            <name>Alert_DA_Assigned_to_Launch</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>RM/SM Launch: Sends notification to RM once they have been assigned to the Launch.</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@cdk.com&quot;)) &amp;&amp;  ($RecordType.Name = &quot;DAP Launch&quot; ||  $RecordType.Name = &quot;Search Products Launch&quot;) &amp;&amp; NOT(ISBLANK(Online_Marketing_Specialist__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_Alert_RM_Assignment_RMSM_Launch</fullName>
        <actions>
            <name>Alert_RM_Assigned_to_RM_SM_Launch</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>RM/SM Launch: Sends notification to RM once they have been assigned to the Launch.</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp;  $RecordType.Name = &quot;SM/RM Launch&quot; &amp;&amp;  NOT(ISBLANK(Reputation_Management_Specialist__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_Alert_SM_Assignment_RMSM_Launch</fullName>
        <actions>
            <name>Alert_SM_Assigned_to_RM_SM_Launch</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>RM/SM Launch: Sends notification to SM once they have been assigned to the Launch.</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp;  $RecordType.Name = &quot;SM/RM Launch&quot; &amp;&amp;  NOT(ISBLANK(Social_Media_Specialist__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_Alert %E2%80%93 PSEO Mgr Launch Opened</fullName>
        <actions>
            <name>CB_SVC_Alert_PSEO_DG_Mgr_Launch_Opened</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Alert SEO Mgmt when Launch with PowerSEO and Dealer Group is created</description>
        <formula>AND (  NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)), NOT(ISBLANK(Dealer_Group_Name__c)),  OR(  INCLUDES(Product_Type__c,&quot;POWER SEO&quot;),  INCLUDES(Add_Ons__c,&quot;POWER SEO&quot;) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_Alert - PSEO Assignment Launch</fullName>
        <actions>
            <name>CB_SVC_Alert_PSEO_Assignment_Launch</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Power SEO Launch: Sends notification to PowerSEO Specialist once they have been assigned to the Launch.</description>
        <formula>AND  (  NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)),   OR(  $RecordType.Name = &quot;Website Launch&quot;,  $RecordType.Name = &quot;A La Carte Launch&quot;,  $RecordType.Name = &quot;SM/RM Launch&quot;),   OR(  INCLUDES(Product_Type__c,&quot;Power SEO&quot;),  INCLUDES(Add_Ons__c,&quot;Power SEO&quot;)),   OR(  NOT(ISBLANK(PowerSEO_Specialist__c)),  ISCHANGED(PowerSEO_Specialist__c))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_Alert_PSEO_Assignment_RMSM_Launch</fullName>
        <actions>
            <name>Alert_PSEO_Assigned_to_RM_SM_Launch</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>RM/SM Launch: Sends notification to PowerSEO Specialist once they have been assigned to the RM/SM Launch.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp;  $RecordType.Name = &quot;SM/RM Launch&quot; &amp;&amp;  NOT(ISBLANK(PowerSEO_Specialist__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_Email_Marketing_Launch_Ready_ONB</fullName>
        <actions>
            <name>Alert_Ops_to_create_an_onboarding_case</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CB_SVC_Alert_EMS_onboarding_case</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Send_Onboarding_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Email Marketing Launch - send an alert to Service Ops to create onboarding case</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c))&amp;&amp; $RecordType.Name = &quot;Email Marketing Launch&quot; &amp;&amp; Send_Onboarding__c =FALSE &amp;&amp; Open_Status__c = &quot;Closed&quot; &amp;&amp; (INCLUDES( Product_Type__c , &quot;DAP+Email&quot;) ||  INCLUDES( Product_Type__c , &quot;Email Marketing Sales&quot;) ||  INCLUDES( Product_Type__c , &quot;Email Marketing Service&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_SM%2FRM_Launch_Ready_ONB</fullName>
        <actions>
            <name>Alert_Ops_RM_SM_Launch_Ready_for_Onboarding</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Send_Onboarding_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Social Media and Reputation Management Launch - send an alert to Service Ops to create onboarding case</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c))&amp;&amp;  $RecordType.Name = &quot;SM/RM Launch&quot; &amp;&amp;  Do_Not_Send_Onboarding__c = FALSE &amp;&amp;  Send_Onboarding__c = FALSE &amp;&amp;  ((ISPICKVAL(Status__c, &quot;Order Closed Waiting on Data&quot;) &amp;&amp;  ISBLANK(Order_Closed_Waiting_on_Data_Date__c )) ||  ISPICKVAL(Status__c, &quot;Closed w/ Data&quot;) ||  ISPICKVAL(Status__c, &quot;Closed w/o Data&quot;)) &amp;&amp;  (INCLUDES( Product_Type__c , &quot;GM Social Media Essentials&quot;) ||  INCLUDES( Product_Type__c , &quot;Social Media Essentials&quot;) ||  INCLUDES( Product_Type__c , &quot;GM Power Social Media&quot;) ||  INCLUDES( Product_Type__c , &quot;Power Social Media Management&quot;) ||  INCLUDES( Product_Type__c , &quot;Power Reputation Management&quot;) ||  INCLUDES( Product_Type__c , &quot;GM Power Reputation Management&quot;) ||  INCLUDES( Product_Type__c , &quot;Reputation Management&quot;) ||  INCLUDES( Product_Type__c , &quot;GM Power Social Media&quot;) ||  INCLUDES( Product_Type__c , &quot;Social Media - Essentials&quot;) ||  INCLUDES( Product_Type__c , &quot;Social Media - Power&quot;)||  INCLUDES( Add_Ons__c , &quot;RM DAP 5 Star Ads; &quot;) ||  INCLUDES( Add_Ons__c , &quot;RM DAP 5 Star Video&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_Search_and_DAP_Launches_Ready_for_ONB</fullName>
        <actions>
            <name>Alert_Ops_Search_Product_Ready_for_Onboarding</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Send_Onboarding_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Search and DAP Product Launches: Sends a notification to Service Ops to create an Onboarding case.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c))&amp;&amp;  NOT($Profile.Name=&quot;Cobalt Service Data Exporting&quot;) &amp;&amp;  (  $RecordType.Name = &quot;Search Products Launch&quot; &amp;&amp;  (INCLUDES(Product_Type__c, &quot;Holden NV Advertising&quot;)||  INCLUDES(Product_Type__c, &quot;Power Brand NC&quot;)||  INCLUDES(Product_Type__c, &quot;PowerBrand NC Fixed Ops&quot;)||  INCLUDES(Product_Type__c, &quot;PowerBrand Fixed Ops&quot;)||  INCLUDES(Product_Type__c, &quot;Power Brand&quot;)||  INCLUDES(Product_Type__c, &quot;PowerSearch&quot;)||  INCLUDES(Product_Type__c, &quot;GM CCA Tire Promotion&quot;)||  INCLUDES(Product_Type__c, &quot;ReMarketing&quot;)||  INCLUDES(Product_Type__c, &quot;Special Finance&quot;)||  INCLUDES(Product_Type__c, &quot;Search Essentials&quot;)||  INCLUDES(Product_Type__c, &quot;Display&quot;)||  INCLUDES(Product_Type__c, &quot;Parts&quot;)||  INCLUDES(Product_Type__c, &quot;Service&quot;) ||  INCLUDES(Product_Type__c, &quot;Certified Svc&amp;Pts Search&quot;)) &amp;&amp;   Send_Onboarding__c = FALSE  /* ND: commented out to send onboard on any newly created Search Launch that meets criteria */  /* (ISPICKVAL(Status__c,&quot;Not Started&quot;) || ISPICKVAL(Status__c,&quot;Gathering Requirements&quot;) ) */  )  ||  (  $RecordType.Name = &quot;DAP Launch&quot; &amp;&amp;  (INCLUDES(Product_Type__c, &quot;New Flex&quot;)||  INCLUDES(Product_Type__c, &quot;Used Flex&quot;)||  INCLUDES(Product_Type__c, &quot;Service and Parts Flex&quot;))&amp;&amp;  Send_Onboarding__c = FALSE  /* ND: commented out to send onboard on any newly created DAP Launch that meets criteria */  /* (ISPICKVAL(Status__c,&quot;Not Started&quot;) || ISPICKVAL(Status__c,&quot;Gathering Requirements&quot;) ) */  )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_AMA_Launch_Alert_IO_Attached</fullName>
        <actions>
            <name>Alert_IO_Attached_for_AMA_Launch</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>AMA Launch</value>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.IO_Attached__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Order_Type__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>AMA Launch - Notify IFS when IO Attached date is entered</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_CAMGAM_Ready_for_Onboarding</fullName>
        <actions>
            <name>Alert_Ops_GAM_CAM_Onboarding</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Send_Onboarding_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Where Product Type like Group Account Management: This alert goes to Service Ops to confirm that the GAM/CAM has set up their Onboarding case on the parent most account.</description>
        <formula>Open_Status__c = &quot;Closed&quot; &amp;&amp;  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp;  Do_Not_Send_Onboarding__c = FALSE &amp;&amp;   INCLUDES(Product_Type__c , &quot;Group Account Management&quot;)&amp;&amp; Send_Onboarding__c =FALSE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_DAPBulk_Launch_Ready_for_ONB</fullName>
        <actions>
            <name>Alert_Ops_DAP_Ready_for_Onboarding</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>DAP Launch when Bulkloaded: Sends a notification to Service Ops to create an Onboarding case.</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp; $RecordType.Name = &quot;DAP Launch&quot;&amp;&amp; (ISPICKVAL(PRIORVALUE(Status__c),&quot;Not Enrolled&quot;)|| ISPICKVAL(PRIORVALUE(Status__c),&quot;Not Started&quot;))&amp;&amp; ISPICKVAL(Status__c,&quot;In Progress&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_DAP_Launch_Ready_for_ONB</fullName>
        <actions>
            <name>Alert_Ops_DAP_Ready_for_Onboarding</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>DAP Launch when Status is not &quot;Not Started&quot; or &quot;Not Enrolled&quot;: Sends a notification to Service Ops to create an Onboarding case.</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp; $RecordType.Name = &quot;DAP Launch&quot;&amp;&amp; NOT(ISPICKVAL(Status__c,&quot;Not Enrolled&quot;))&amp;&amp; NOT(ISPICKVAL(Status__c,&quot;Not Started&quot;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_EML_Launch_Ready_for_Onb_GM_NRM</fullName>
        <actions>
            <name>Alert_Ops_Launch_Ready_for_Onboarding</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Only SM and GM Network RepMan product type: Send alert to Svc Ops to create MM and assign specialist.</description>
        <formula>(  Open_Status__c = &quot;Closed&quot; &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp;  (INCLUDES( Product_Type__c , &quot;GM Network RepMan&quot;)) &amp;&amp;  ISBLANK(Order_Closed_Waiting_on_Data_Date__c ) &amp;&amp; ($RecordType.Name = &quot;SM/RM Launch&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_ProCare_Launch_Ready_for_Assignment</fullName>
        <actions>
            <name>Alert_AA_Needs_to_be_Assigned</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_AA_Assign_Alert_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Website or A La Carte Launch w/ ProCare: Sends notification to Service Ops to create assign an Advocate.</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp;  (($RecordType.Name = &quot;Website Launch&quot; &amp;&amp;  (INCLUDES( Add_Ons__c , &quot;ProCare&quot;)||  INCLUDES( Add_Ons__c , &quot;Audience Optimization&quot;)) &amp;&amp;  ( NOT(ISBLANK(Oracle_Order_Number__c))||  Open_Status__c = &quot;Closed&quot;)&amp;&amp;  ISBLANK( Account_Advocate__c)&amp;&amp;  Sent_AA_Assign_Alert__c = FALSE &amp;&amp;  Send_Onboarding__c = FALSE)  ||  ($RecordType.Name = &quot;A La Carte Launch&quot; &amp;&amp;  (INCLUDES( Product_Type__c , &quot;ProCare&quot;)||  INCLUDES( Product_Type__c , &quot;Audience Optimization&quot;)) &amp;&amp;  ( NOT(ISBLANK(Oracle_Order_Number__c))||  Open_Status__c = &quot;Closed&quot; )&amp;&amp;  ISBLANK( Account_Advocate__c)&amp;&amp;  Sent_AA_Assign_Alert__c = FALSE &amp;&amp;  Send_Onboarding__c = FALSE))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_ProCare_Launch_Ready_for_ONB</fullName>
        <actions>
            <name>Alert_Ops_ProCare_Ready_for_Onboarding</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Send_Onboarding_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Website or A La Carte Launch w/ ProCare: Sends notification to Service Ops to create an Onboarding case.</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp;  ( ($RecordType.Name = &quot;Website Launch&quot; &amp;&amp;  (INCLUDES( Add_Ons__c, &quot;ProCare&quot;)||  INCLUDES( Add_Ons__c , &quot;Audience Optimization&quot;)||  INCLUDES( Add_Ons__c , &quot;VW Care&quot;)) &amp;&amp;  Open_Status__c = &quot;Closed&quot;&amp;&amp;  Send_Onboarding__c = FALSE )  ||  ( $RecordType.Name = &quot;A La Carte Launch&quot; &amp;&amp;  (INCLUDES( Product_Type__c , &quot;ProCare&quot;) ||  INCLUDES( Product_Type__c , &quot;Audience Optimization&quot;) ) &amp;&amp;  Open_Status__c = &quot;Closed&quot;&amp;&amp;  Send_Onboarding__c = FALSE ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_SEO_Ready_for_Onboarding</fullName>
        <actions>
            <name>Alert_Ops_Launch_Ready_for_Onboarding</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Send_SEO_Onboarding_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>ALC and Webstie: Send alert to Service Ops to create onboarding case for SEO products at close.</description>
        <formula>AND(Open_Status__c = &quot;Closed&quot;,  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  Send_SEO_Onboarding__c=FALSE,  OR(  AND(  $RecordType.Name = &quot;Website Launch&quot; &amp;&amp;  OR(  INCLUDES(Add_Ons__c, &quot;Power SEO&quot;),  INCLUDES(Add_Ons__c,&quot;SEO Essentials&quot;),  INCLUDES(Product_Type__c , &quot;Audience Management Package&quot;),  INCLUDES(Product_Type__c,&quot;VW Core&quot;)  )  ),  AND(  $RecordType.Name = &quot;A La Carte Launch&quot; &amp;&amp;  OR(  INCLUDES( Product_Type__c , &quot;Power SEO&quot;),  INCLUDES(Product_Type__c ,&quot;SEO Essentials&quot;),  INCLUDES( Product_Type__c , &quot;PowerSEO non-CDK&quot;),  INCLUDES(Product_Type__c ,&quot;Pre-Roll Video&quot;)  )  )  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_Search_Launch_Ready_for_ONB</fullName>
        <actions>
            <name>Alert_Ops_Search_Product_Ready_for_Onboarding</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Send_Onboarding_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Search Products Launch: Sends a notification to Service Ops to create an Onboarding case.</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp;  $RecordType.Name = &quot;Search Products Launch&quot; &amp;&amp;   Open_Status__c = &quot;Closed&quot;&amp;&amp; Send_Onboarding__c  = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_WSPerformance_Launch_Ready_for_ONB</fullName>
        <actions>
            <name>Alert_Ops_Launch_Ready_for_Onboarding</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Send_Onboarding_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>For WS RT: For all New and Upgrade orders to Performance and Downgrade orders to Core.</description>
        <formula>(Open_Status__c = &quot;Closed&quot; &amp;&amp;  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp;  $RecordType.Name = &quot;Website Launch&quot; &amp;&amp;  (  (  INCLUDES(Product_Type__c, &quot;Performance&quot;) &amp;&amp;  (  ISPICKVAL( Order_Type__c, &quot;New&quot;)||  ISPICKVAL(Order_Type__c,&quot;Upgrade&quot;)||  ISPICKVAL(Order_Type__c,&quot;Multi-Brand&quot;)  )  )||  (  (INCLUDES(Product_Type__c,&quot;Core/ProSite&quot;)||  INCLUDES(Product_Type__c,&quot;Base&quot;)  )&amp;&amp;  OEM__c=&quot;GM&quot;&amp;&amp;  NOT(INCLUDES(Product_Type__c, &quot;Performance&quot;))&amp;&amp;  ISPICKVAL(Order_Type__c,&quot;Downgrade&quot;)  )  )  &amp;&amp;  Send_SEO_Onboarding__c=FALSE  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_Svc_EML_New_Customer_Orders_for_Holden_Closed_Launch</fullName>
        <actions>
            <name>Email_Alert_to_New_Customer_Orders_for_HoldenNZ_closed_Launch</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email alert that goes to new customer orders when a Launch Record is closed</description>
        <formula>AND(  ISPICKVAL(Status__c, &quot;Closed&quot;),  CONTAINS(WebID__r.Name, &quot;holdennz&quot;),  INCLUDES(Add_Ons__c , &quot;ProCare&quot;),  $RecordType.Name = &quot;Website Launch&quot;  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Data Ops Alert - Data Uploaded Delayed 7 days</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.DI_Submitted_To_Vendor__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Data_Ops_Open_Status__c</field>
            <operation>notEqual</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Data Ops Section:  Sends an alert to Data Ops that 7 days have passed since DI Form has been submitted.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Alert_Data_Ops_that_7_days_have_passed_since_DI</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Alert_Data_Ops_that_14_days_have_passed_since_DI</name>
                <type>Alert</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Data Ops Update %E2%80%93 Assign Date and Status</fullName>
        <actions>
            <name>Data_Ops_Assign_Date_to_Now</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Data_Ops_Complete_Date_to_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Data_Opps_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Data_Ops_Assign_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Data_Ops_Specialist__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Data_Ops_Open_Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Data_Ops_Status__c</field>
            <operation>notEqual</operation>
            <value>N/A - Existing Email Marketing Customer,Data Ops Complete,N/A - No Data Ops Needed</value>
        </criteriaItems>
        <description>All w/ Data Ops Section:  Upon first assignment update the assign date only if status is changed to completed or N/A at the same time (will not change status to &quot;With Data Ops&quot;).</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DataOps Alert - Data Ops Issue to OM</fullName>
        <actions>
            <name>Alert_to_Launch_Secondary_Owner_Data_Ops_Issue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Data_Ops_Status__c</field>
            <operation>equals</operation>
            <value>Issue Sent to Order Manager</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Data Ops Section:  When data ops status is set to &quot;Issue Sent to OM&quot; send alert to OM</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DataOps Alert - Data Uploaded</fullName>
        <actions>
            <name>Data_Uploaded_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Data_Ops_Open_Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Email Marketing Launch</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Data_Ops_Status__c</field>
            <operation>notContain</operation>
            <value>N/A</value>
        </criteriaItems>
        <description>Only EM:  Data Uploaded alert to Launch Owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DataOps Alert - Ready for Data Ops</fullName>
        <actions>
            <name>Alert_Ready_for_Data_Ops</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>All w/ Data Ops Section: When data ops status is set to &quot;Ready for Data Ops&quot; send alert to Data Ops Specialist.</description>
        <formula>AND(        NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),              ISPICKVAL(Data_Ops_Status__c,&quot;Ready for Data Ops&quot;),       Not(ISBLANK( Data_Ops_Specialist__c )),       PRIORVALUE(Data_Ops_Open_Status__c)&lt;&gt;&quot;Closed&quot;,       NOT( $User.Id = Data_Ops_Specialist__c )       )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DataOps Alert and Update %E2%80%93 DI Submitted to Vendor</fullName>
        <actions>
            <name>Alert_Data_Ops_that_DI_has_been_submitted2</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Data_Ops_With_Integralink</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.DI_Submitted_To_Vendor__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Data Ops Section:  This alerts Data Ops that DI has been submitted to Vendor.  Also updated Data Ops Status to With Integralink.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DataOps Alert and Update - DataOps Entered Integralink Ticket</fullName>
        <actions>
            <name>Alert_DataOps_Entered_Ticket</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Data_Ops_Issue_With_Integralink</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Any with Data Ops Section: If the Data Ops Integralink Ticket # was previously blank, the Data Ops Section is not closed, change status and alert OM.</description>
        <formula>AND(        NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),               ISBLANK(PRIORVALUE(  Data_Ops_Integralink_Ticket__c )),        NOT( ISBLANK (Data_Ops_Integralink_Ticket__c)),        Data_Ops_Open_Status__c=&quot;Open&quot;,        NOT(ISPICKVAL(PRIORVALUE(Data_Ops_Status__c),&quot;Issue with Integralink&quot;))       )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DataOps Alert and Update - OM Entered Integralink Ticket</fullName>
        <actions>
            <name>Alert_OM_Entered_a_Ticket</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Data_Ops_Issue_With_Integralink</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Any with Data Ops Section: If the OM Integralink Ticket # was previously blank, the Data Ops Section is not closed, change status and alert Data ops.</description>
        <formula>AND(        NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),              ISBLANK(PRIORVALUE( OM_Integralink_Ticket__c )),        NOT(ISBLANK(OM_Integralink_Ticket__c)),        Data_Ops_Open_Status__c=&quot;Open&quot;,        NOT(ISPICKVAL(PRIORVALUE(Data_Ops_Status__c),&quot;Issue with Integralink&quot;))       )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DataOps Alert and Update - Order Closed Waiting Data</fullName>
        <actions>
            <name>Update_Order_Closed_Waiting_Data_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Status__c</field>
            <operation>equals</operation>
            <value>Order Closed Waiting on Data</value>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Order_Closed_Waiting_on_Data_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>NRM Launch,SM/RM Launch</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Only SMRM and NRM:  Upon Status change to Order Closed Waiting on Data set date to track when waiting on data starts.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Alert_to_Launch_Owner_30_Days_since_order_closed</name>
                <type>Alert</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>DataOps Alert and Update - Resubmit</fullName>
        <actions>
            <name>Alert_to_Data_Ops_Resubmit</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Completion_Date_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Data_Ops_Status_Ready</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All w/ Data Ops Section:  Data Ops work is still needed, alert to Data Ops Specialist and put record back in queue.</description>
        <formula>IF(AND( OR( PriorValue( Data_Ops_ReSubmit_Date__c )&lt;&gt; Data_Ops_ReSubmit_Date__c , (Isblank(PriorValue( Data_Ops_ReSubmit_Date__c )) &amp;&amp;  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp; Not(isblank(Data_Ops_ReSubmit_Date__c ))) ),  Data_Ops_Open_Status__c = &quot;Closed&quot; ), true, false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DataOps Update - Add Complete Date</fullName>
        <actions>
            <name>Set_Data_Ops_Complete_Date_to_Now</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Data_Ops_Open_Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Data_Ops_Status__c</field>
            <operation>notEqual</operation>
            <value>N/A - Existing Email Marketing Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Data Ops Section:  Adds date/time to Data Ops Complete date field when status is set to complete.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DataOps Update - Assign Date and Update Status</fullName>
        <actions>
            <name>Data_Ops_Assign_Date_to_Now</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Data_Ops_Status_to_With_Data_Op</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Data_Ops_Complete_Date_to_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Data_Ops_Assign_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Data_Ops_Specialist__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Data_Ops_Open_Status__c</field>
            <operation>notEqual</operation>
            <value>Data Ops Complete,N/A - Existing Email Marketing Customer,N/A - No Data Ops Needed,With Data Ops</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Data Ops Section:  Upon Data Ops Status change to &quot;With Data Ops&quot; update Data Ops Assign Date field.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DataOps Update - Remove Complete Date</fullName>
        <actions>
            <name>Set_Data_Ops_Complete_Date_to_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Data_Ops_Open_Status__c</field>
            <operation>notEqual</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Data Ops Section:  Removes Data Ops completion date if status is set back to any status that does not contain the word &quot;Complete&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Design Alert and Update - Resubmit</fullName>
        <actions>
            <name>Alert_Design_that_request_is_resubmitted</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Set_Design_Completion_date_to_null</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Status_to_With_Design</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All w/ Design Section:  Design work is still needed, alert to Design Specialist and put record back in queue.</description>
        <formula>IF(AND( OR(  PriorValue( Banner_Resubmit_Date__c )&lt;&gt; Banner_Resubmit_Date__c ,  (Isblank(PriorValue( Banner_Resubmit_Date__c )) &amp;&amp;  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp; Not(isblank(Banner_Resubmit_Date__c )))  ),   Design_Open_Status__c = &quot;Closed&quot; ), true, false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Design Alert and Update - Set Assign Date Status and Alert</fullName>
        <actions>
            <name>Email_Banner_Requested_Alert2</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Set_Design_Assign_Date_to_Now</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Design_Completion_date_to_null</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Status_to_With_Design2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Banner_Request_Submitted__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Design Section:  An email is sent to EMS Design that a banner has been requested for a new dealer - also Design status set to &quot;with design&quot; and assign date set to Now()</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Design Update - Add Complete Date</fullName>
        <actions>
            <name>Design_Completion_Date_to_Now</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Design_Open_Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Design_Status__c</field>
            <operation>notEqual</operation>
            <value>N/A - Relaunch</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Design Section:  Adds date/time to Design Complete date field when status is set to complete</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Design Update - Remove Complete Date</fullName>
        <actions>
            <name>Set_Design_completion_date_to_null2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Design_Open_Status__c</field>
            <operation>notEqual</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Design Section:  Removes Design completion date if status is set back to any status that does not contain the word &quot;Complete&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Do Not Send Onboarding - Add Checkmark</fullName>
        <actions>
            <name>Update_Do_Not_Send_Onboarding</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Launch__c.Product_Type__c</field>
            <operation>equals</operation>
            <value>GM Primary Reputation Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Product_Type__c</field>
            <operation>equals</operation>
            <value>Essentials Reputation Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Add_Ons__c</field>
            <operation>excludes</operation>
            <value>RM DAP 5 Star Ads</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Do Not Send Onboarding - Remove Checkmark</fullName>
        <actions>
            <name>Remove_Do_Not_Send_Onboarding_Checkmark</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2) OR 3</booleanFilter>
        <criteriaItems>
            <field>Launch__c.Product_Type__c</field>
            <operation>notEqual</operation>
            <value>GM Primary Reputation Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Product_Type__c</field>
            <operation>notEqual</operation>
            <value>Essentials Reputation Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Add_Ons__c</field>
            <operation>includes</operation>
            <value>RM DAP 5 Star Ads</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Domain Alert - Domain Complete</fullName>
        <actions>
            <name>Alert_to_Launch_Owner_Domains_complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>All w/ Domain Section: Alert goes to Launch Owner if they did not set the completion status.</description>
        <formula>IF($User.Id &lt;&gt;  OwnerId  &amp;&amp;  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp; ISPickVal(Domain_Status__c, &quot;Domains Complete&quot;) , True, False)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Domain Alert - Domain Issue to OM</fullName>
        <actions>
            <name>Alert_to_Launch_Owner_Domain_Issue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Domain_Status__c</field>
            <operation>equals</operation>
            <value>Issue Sent to Order Manager</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Domain Section:  When domain status is set to &quot;Issue Sent to OM&quot; send alert to OM</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Domain Alert - Domains Acquired Waiting URL</fullName>
        <actions>
            <name>Alert_to_Launch_Owner_Domains_Acquired_Waiting_on_URL</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Launch__c.Domain_Status__c</field>
            <operation>equals</operation>
            <value>Domains Acquired - Waiting on URL</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Domain Update - Add Complete Date</fullName>
        <actions>
            <name>Update_Domain_Complete_Date_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Domain_Open_Status__c</field>
            <operation>contains</operation>
            <value>closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Domain Section:  Adds date/time to Domain Complete date field when Domain open status contains closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Domain Update - Assign Date Only</fullName>
        <actions>
            <name>Update_Domain_Assign_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Domain_Assign_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Domain_Specialist__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Domain_Status__c</field>
            <operation>equals</operation>
            <value>Domains Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Domain Section:  Upon Domain Specialist assignment if Status is set to complete at the same time update Assign Date only (do not change status to &quot;With Domains&quot;).</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Domain Update - Assign Date and Status</fullName>
        <actions>
            <name>Set_Status_With_Domains</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Domain_Assign_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Domain_Assign_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Domain_Specialist__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Domain_Status__c</field>
            <operation>notEqual</operation>
            <value>Domains Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Domain Section:  Upon Domain Status change to &quot;With Domains&quot; update Domain Assign Date field.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Domain Update - Remove Complete Date</fullName>
        <actions>
            <name>Update_Domain_Complete_Date_Not_Comp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All w/ Domain Section:  removes domain completion date if Domain Open Status equals open.</description>
        <formula>AND( NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)), Domain_Open_Status__c = &quot;Open&quot; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Domain Update - Resubmit Domain Rqst</fullName>
        <actions>
            <name>Alert_to_Domains_OM_has_resubmitted</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Domain_Complete_Date_Not_Comp2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Domain_Status_Ready2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All w/ Domain Section:  More Domain work is needed, removes completion date if it exists and sets status back to Ready which puts it back in queue.</description>
        <formula>IF(AND(  OR( PriorValue( Domain_ReSubmit_Date__c )&lt;&gt; Domain_ReSubmit_Date__c, (Isblank(PriorValue( Domain_ReSubmit_Date__c )) &amp;&amp;  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp; Not(isblank(Domain_ReSubmit_Date__c))) ), ISPickval(Domain_Status__c, &quot;Domains Complete&quot;)   ), true, false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Domain Update - Send to Domain Queue</fullName>
        <actions>
            <name>Update_Domain_Complete_Date_Not_Comp</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Domain_Rqst_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Domain_Status_Ready</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Domain_Request_Submitted__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Domain_Request_Submit_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notEqual</operation>
            <value>NOT(BEGINS($User.Username,integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Domain Section:  Sets domain status to &quot;Ready for Domains&quot; when the domain request submitted field is populated. Also sets the Domain Request Submit Date. This only works first time the field is populated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Domain Update - URL for Domains Ready</fullName>
        <actions>
            <name>URL_for_Domains_set_to_ready</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.URL_for_Domains__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notEqual</operation>
            <value>NOT(BEGINS($User.Username,integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Domain Section:  Sets field to Domains Ready which will put the launch back in the Domains Queue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EMS Manager%3A DI Submitted to Vendor</fullName>
        <actions>
            <name>DI_Submitted_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.DI_Submitted_To_Vendor__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Email Marketing Launch</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Only EM:  This alerts EMS Manager to assign a specialist</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Marketing Specialist Assigned</fullName>
        <actions>
            <name>Alert_EMS_that_Account_is_in_Launch</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>All w/ Em Spec Field:  This will send an alert to the Email Marketing Specialist assigned to the Launch record.</description>
        <formula>AND(  isblank(PRIORVALUE (Email_Marketing_Specialist__c )) ,   NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  not(Isblank(Email_Marketing_Specialist__c ))   )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Inventory Alert - Inventory Complete</fullName>
        <actions>
            <name>Alert_to_Launch_Owner_Inventory_complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>All w/ Inventory Section: Alert goes to Launch Owner if they did not set the completion status.</description>
        <formula>IF($User.Id &lt;&gt;  OwnerId  &amp;&amp;  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp; ISPickVal(Inventory_Status__c, &quot;Inventory Complete&quot;) , True, False)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Inventory Alert - Inventory Issue to OM</fullName>
        <actions>
            <name>Alert_to_Owner_Inventory_Issue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Inventory_Status__c</field>
            <operation>equals</operation>
            <value>Issue Sent to Order Manager</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Inventory Section:  When inventory status is set to &quot;Issue Sent to OM&quot; send alert to OM</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Inventory Update - Add Complete Date</fullName>
        <actions>
            <name>Update_Inventory_Complete_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Inventory_Open_Status__c</field>
            <operation>contains</operation>
            <value>closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Inventory Section:  Adds date/time to Inventory Complete date field when Inventory open status contains closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Inventory Update - Assign Date Only</fullName>
        <actions>
            <name>Update_Inventory_Assign_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Inventory_Assign_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Inventory_Specialist__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Inventory_Status__c</field>
            <operation>equals</operation>
            <value>Inventory Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Inventory Section:  Upon Inventory Specialist assignment if Status is set to complete at the same time update Assign Date only (do not change status to &quot;With Inventory&quot;).</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Inventory Update - Assign Date and Status</fullName>
        <actions>
            <name>Set_Status_With_Inventory</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Inventory_Assign_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Inventory_Assign_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Inventory_Specialist__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Inventory_Status__c</field>
            <operation>notEqual</operation>
            <value>Inventory Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Inventory Section:  Upon Inventory Status change to &quot;With Inventory&quot; update Inventory Assign Date field.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Inventory Update - Remove Complete Date</fullName>
        <actions>
            <name>Update_Inventory_Complete_Date_Not_Com</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All w/ Inventory Section:  removes domain completion date if Inventory Open Status equals open.</description>
        <formula>AND( NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)), Inventory_Open_Status__c = &quot;Open&quot; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Inventory Update - Resubmit Inventory Rqst</fullName>
        <actions>
            <name>Alert_to_Inventory_OM_has_resubmitted</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Inventory_Complete_Date_Not_Com</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Inventory_Status_Ready</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All w/ Inventory Section:  More Inventory work is needed, removes completion date if it exists and sets status back to Ready which puts it back in queue.</description>
        <formula>IF(AND(  OR( PriorValue(Inventory_ReSubmit_Date__c)&lt;&gt; Inventory_ReSubmit_Date__c, (Isblank(PriorValue( Inventory_ReSubmit_Date__c )) &amp;&amp;  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp; Not(isblank(Inventory_ReSubmit_Date__c))) ), ISPickval(Inventory_Status__c, &quot;Inventory Complete&quot;)   ), true, false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Inventory Update - Send to Inventory Queue</fullName>
        <actions>
            <name>Update_Inventory_Complete_Date_Not_Com</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Inventory_Rqst_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Inventory_Status_Ready</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Inventory_Request_Submitted__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.Inventory_Request_Submit_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notEqual</operation>
            <value>NOT(BEGINS($User.Username,integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ Inventory Section:  Sets domain status to &quot;Ready for Inventory&quot; when the inventory request submitted field is populated. Also sets the inventory Request Submit Date. This only works first time the field is populated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Launch Alert %E2%80%93 Holden Order Ready To Close</fullName>
        <actions>
            <name>Alert_to_Activation_OM_Holden_Ready_for_Close</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>All w/ ‘Published Site in WSM’ field - Alerts the Activation OM and a queue when a Holden Order is set to Published in WSM.</description>
        <formula>AND(         NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),          Promotion_Project__r.Name = &quot;Holden&quot;,         NOT(ISBLANK( Published_Site_in_WSM__c ))         )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Launch Alert - Order Priority to 911 Not by Owner</fullName>
        <actions>
            <name>Alert_Order_Priority_Changed_by_NonOwner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>All - sends an alert to the Owner and Secondary Owner when someone other than the pimary/secondary owner updates the Order Priority to 911.</description>
        <formula>AND( NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)), NOT($User.Id = OwnerId ),  NOT($User.Id = Secondary_Owner__c ),  ISPICKVAL( Order_Priority__c , &quot;911&quot;),  LEFT( OwnerId ,3)&lt;&gt;&apos;00G&apos;  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Launch Alert SEO Accnt about to switch to Power</fullName>
        <actions>
            <name>Alert_SEO_Accnt_switching_to_PowerSEO</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Only PSEO: Send alert to the SEO Specialist on the WebId that their account is about to change to PowerSEO.</description>
        <formula>($RecordType.Name = &quot;PowerSEO Launch&quot; &amp;&amp;  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp;  Open_Status__c = &quot;Closed&quot; &amp;&amp;  INCLUDES(Product_Type__c, &quot;Power SEO&quot;)&amp;&amp;  (ISPICKVAL(Order_Type__c,&quot;New&quot;)||  ISPICKVAL(Order_Type__c,&quot;Upgrade&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Launch Create Closed Date</fullName>
        <actions>
            <name>Set_Closed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All:  This work flow populates the closed date for the launch object. If more closed statuses are added then they will need to be added to the Open Status field logic under the Launch object.</description>
        <formula>IF (  AND(  OR( PRIORVALUE( Open_Status__c) &lt;&gt; &quot;Closed&quot;,  PRIORVALUE( Open_Status__c) &lt;&gt; &quot;Cancelled&quot; ),  OR( Open_Status__c = &quot;Closed&quot;, Open_Status__c = &quot;Cancelled&quot; ) , NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))   ), TRUE, FALSE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Launch Remove Closed Date</fullName>
        <actions>
            <name>Remove_Closed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All:  This work flow removes the closed date for the launch object if the status goes from closed to open.</description>
        <formula>IF ( And( Open_Status__c &lt;&gt; &quot;Closed&quot;,  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)), Open_Status__c &lt;&gt; &quot;Cancelled&quot; ), TRUE, FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Launch_Set_Migration_ID</fullName>
        <actions>
            <name>Launch_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify Owner to Update WebId</fullName>
        <actions>
            <name>Update_Order_Closed_Waiting_Data_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Only EM:  If Launch record is not closed 24 hours after status is set to &quot;Oracle Order Closed&quot; then notify Launch record Owner and Manager (Michelle Morton).</description>
        <formula>And(  IsPickval( Status__c , &quot;Oracle Order Closed&quot;),  Open_Status__c  &lt;&gt; &quot;Closed&quot;,     $RecordType.Name = &quot;Email Marketing Launch&quot;, NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))    )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Alert_Launch_Ticket_Owner</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>QA Alert - QA Complete</fullName>
        <actions>
            <name>Alert_to_Owners_QA_Complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>No RT Filter - will only fire on RT with the QA section.  Sends a notification to the Owner/Secondary Owner when the QA Activation OM changes the QA Status to &quot;QA Complete.&quot;</description>
        <formula>IF($User.Id &lt;&gt; OwnerId &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp; ISPIckVal(QA_Status__c, &quot;QA Complete&quot;) , True, False)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>QA Alert - QA Issue to OM</fullName>
        <actions>
            <name>Alert_to_Owners_QA_Issue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.QA_Status__c</field>
            <operation>equals</operation>
            <value>Issue Sent to Order Manager</value>
        </criteriaItems>
        <description>No RT Filter: will only fire on records with QA section.  Sends a notification to Owners when the QA Activation OM sets the QA Status to &quot;Issue Sent to Order Manager.&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>QA Alert - Ready for QA</fullName>
        <actions>
            <name>Alert_to_QAAOM_Ready_for_QA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>No RT Filter: will only fire on records that have the QA section.  Let&apos;s the QA Activation OM know when the Launch is assigned to them again. Covers Issue to OM process.</description>
        <formula>AND(           NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),           ISPICKVAL(QA_Status__c,&quot;Ready for QA&quot;),            Not(ISNULL( QA_Activation_OM__c )),            PRIORVALUE(QA_Open_Status__c)&lt;&gt;&quot;Closed&quot;,            NOT($User.Id = QA_Activation_OM__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>QA Alert and Update - Resubmit</fullName>
        <actions>
            <name>Alert_to_QAAOM</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_QA_Complete_Date_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_QA_Status_Ready_for_QA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>No RT Filter: will only fire if QA section is on the RT.  QA work is still needed, alert to QA Activation OM and puts record back in queue.</description>
        <formula>IF(    AND(              OR(                     PriorValue( QA_Resubmit_Date__c )&lt;&gt; QA_Resubmit_Date__c ,                         (Isblank(PriorValue( QA_Resubmit_Date__c ))                      &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))                      &amp;&amp; Not(isblank(QA_Resubmit_Date__c ))) ),                      ISPickval(QA_Status__c, &quot;QA Complete&quot;) ), true, false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>QA Update - Add Complete Date</fullName>
        <actions>
            <name>Update_QA_Complete_Date_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.QA_Status__c</field>
            <operation>equals</operation>
            <value>QA Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ QA Section:  Adds date/time to QA Completion Date when the status is set to complete.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>QA Update - Assign Date Only</fullName>
        <actions>
            <name>Update_QA_Assign_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.QA_Assign_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.QA_Activation_OM__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.QA_Status__c</field>
            <operation>contains</operation>
            <value>Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ QA Section: If QA Activation OM is assigned at same time as QA Complete then update QA assign date but do not change QA status from &quot;QA Complete.&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>QA Update - Assign Date and Status</fullName>
        <actions>
            <name>Update_QA_Assign_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_QA_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.QA_Assign_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.QA_Activation_OM__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.QA_Status__c</field>
            <operation>notEqual</operation>
            <value>QA Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ QA Section: Upon QA Status change to &quot;With QA&quot; update QA Assign Date field.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>QA Update - Remove Complete Date</fullName>
        <actions>
            <name>Update_QA_Complete_Date_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.QA_Status__c</field>
            <operation>notContain</operation>
            <value>Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ QA Section: removes QA Completion Date if status is set back to any status that does not contain the word &quot;Complete&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>QA Update - Send to QA Queue</fullName>
        <actions>
            <name>Update_QA_Complete_Date_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_QA_Rqst_Date_Now</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_QA_Status_Ready_for_QA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.QA_Request_Submitted__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.QA_Request_Submit_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All w/ QA Section: Sets QA Status to “Ready for QA” when the QA Request Submit date is entered.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Ship to Address Update</fullName>
        <actions>
            <name>Update_Ship_to_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.Open_Status__c</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>All: updates the ship to address field with the data in the digital solutions ship to address field on the account.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Welcome Kit Request Change</fullName>
        <actions>
            <name>Welcome_Kit_requested_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>All w/ Welcome Kit Section:  Sends an alert to Marketing that a Welcome Kit has been requested.</description>
        <formula>And(  Not(ISblank( Welcome_Kit_Requested__c)),  $RecordType.Name = &quot;Email Marketing Launch&quot;,  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  Not( Contains(&quot;Sandbox&quot;,Account__r.Name)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Welcome Kit Request RepMan</fullName>
        <actions>
            <name>Email_to_PromoShop_for_Reputation_Management</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Welcome_Kit_Request</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Only SM/RM: This sends and email to PromoShop external vendor requesting a Welcome Kit for Reputation Management upon first closure of the SM/RM Launch record.</description>
        <formula>And ( $RecordType.Name = &quot;SM/RM Launch&quot;,  OR(          Includes( Product_Type__c , &quot;Reputation Management&quot;),           Includes( Product_Type__c , &quot;GM Power Reputation Management&quot;),           Includes( Product_Type__c , &quot;GM Primary Reputation Management&quot;),          Includes( Product_Type__c , &quot;GM Primary Plus Reputation Management&quot;),          Includes(Product_Type__c, &quot;Essentials Reputation Management&quot;),          Includes(Product_Type__c, &quot;Advanced Reputation Management&quot;),          Includes(Product_Type__c, &quot;Power Reputation Management&quot;)        ), Open_Status__c = &quot;Closed&quot;, Isblank(Welcome_Kit_Requested__c ),  Not( Contains(&quot;Sandbox&quot;,Account__r.Name)) , NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>eAppend Alert - eAppend Ready to Send</fullName>
        <actions>
            <name>eAppend_ready_to_send_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.eAppend_Status__c</field>
            <operation>equals</operation>
            <value>Ready to Send</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notEqual</operation>
            <value>NOT(BEGINS($User.Username,integration_user@adp.com</value>
        </criteriaItems>
        <description>Any w/ eAppend fields:  Sends an alert to Data Ops that eAppend is ready to send.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>eAppend Update - eAppend Completion Date</fullName>
        <actions>
            <name>Update_eAppend_Completion_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.eAppend_Completion_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.eAppend_Status__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notEqual</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>EM Only - Not RT specific, but this is the only page with these fields on the layout.  Updates the eAppend Completion Date field when the eAppend Status is set to &quot;Complete&quot;.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>eAppend Update - eAppend Sent Update</fullName>
        <actions>
            <name>Update_eAppend_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_eAppend_Sent_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch__c.eAppend_Sent__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.eAppend_Sent_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Launch__c.eAppend_Status__c</field>
            <operation>equals</operation>
            <value>Sent</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notEqual</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>EM Only - Not RT specific, but this is the only page with these fields on the layout.  Updates both the eAppend Sent and eAppend Sent Date fields.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
