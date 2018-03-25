<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AA_Case_notification_for_Onboarding_after_9_days</fullName>
        <description>AA Case notification for Onboarding after 9 days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/AA_Case_notification_for_Onboarding_after_9_days</template>
    </alerts>
    <alerts>
        <fullName>Alert_Account_Team_New_GM_DMP_case</fullName>
        <ccEmails>ds.seagmdaleads@adp.com</ccEmails>
        <description>Alert Account Team New GM DMP case</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Director of Digital Sales</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Performance Improvement Consultant</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/GM_Solution_Change_Rqst_Opened</template>
    </alerts>
    <alerts>
        <fullName>Alert_Account_Team_lost_GM_DMP_case</fullName>
        <description>Alert Account Team lost GM DMP case</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Performance Improvement Consultant</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/GM_Solution_Change_Rqst_Closed_Lost</template>
    </alerts>
    <alerts>
        <fullName>Alert_Account_Team_saved_GM_DMP_case</fullName>
        <description>Alert Account Team saved GM DMP case</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Performance Improvement Consultant</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/GM_Solution_Change_Rqst_Closed_Saved</template>
    </alerts>
    <alerts>
        <fullName>Alert_Acct_Team_Nitra_Due_Date</fullName>
        <ccEmails>cthompson@cobaltgroup.com</ccEmails>
        <description>Alert Acct Team - Nitra Due Date</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Digital Services CAM</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Director of Digital Sales</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Email Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>National/Enterprise DSM</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing (DAP)</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Performance Improvement Consultant</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Reputation Management Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Templates/Alert_Nitra_Date_is_Approaching</template>
    </alerts>
    <alerts>
        <fullName>Alert_Ad_Operations_New_Case</fullName>
        <ccEmails>AdOperations@cobalt.com</ccEmails>
        <description>Alert Ad Operations - New Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>daisha.neville@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert_to_Ad_Operations_New_Case_Submitted</template>
    </alerts>
    <alerts>
        <fullName>Alert_Ad_Operations_New_Case_in_Queue</fullName>
        <ccEmails>gmms@cobalt.com</ccEmails>
        <description>Alert Ad Operations - New Case in Queue</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert_to_gmms_cobalt_com_for_Cases_in_Ad_Ops_Queue</template>
    </alerts>
    <alerts>
        <fullName>Alert_Case_Owner_New_Onboarding</fullName>
        <description>Alert Case Owner New Onboarding</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Admin/NewassignmentnotificationSAMPLE</template>
    </alerts>
    <alerts>
        <fullName>Alert_DAS_When_AA_Closes_DAP_OnBoarding_Case</fullName>
        <description>Alert DAS When AA Closes DAP OnBoarding Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/DAS_Notification_of_AA_DAP_Onboarding_Completion</template>
    </alerts>
    <alerts>
        <fullName>Alert_Data_Ops_to_deconstruct</fullName>
        <description>Alert Data Ops to deconstruct</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>christy.silveira@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFS_Templates/IFS_Data_Ops_Deconstruct</template>
    </alerts>
    <alerts>
        <fullName>Alert_Enhancements_Flex_DAP_Budget_Change</fullName>
        <ccEmails>enhancementorders@cobalt.com</ccEmails>
        <description>Alert Enhancements - Flex DAP Budget Change</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Notify_Enhancements_Flex_Budget_Change</template>
    </alerts>
    <alerts>
        <fullName>Alert_GM_Program_Questions</fullName>
        <description>Alert GM Program Questions</description>
        <protected>false</protected>
        <recipients>
            <recipient>christopher.dangelo@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jessiah.johnson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>nicole.montague-walker@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert_Program_Question</template>
    </alerts>
    <alerts>
        <fullName>Alert_Inquiry_Service_reports_and_aps_off_waiting_status</fullName>
        <description>Alert - Inquiry Service reports and aps off waiting status</description>
        <protected>false</protected>
        <recipients>
            <recipient>camela.thompson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>nancy.durant@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Service_Ops_Case_No_Longer_Waiting</template>
    </alerts>
    <alerts>
        <fullName>Alert_Inquiry_Service_reports_and_aps_resume_date_is_here</fullName>
        <description>Alert - Inquiry Service reports and aps resume date is here</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Service_Ops_Case_Resume_date_is_here</template>
    </alerts>
    <alerts>
        <fullName>Alert_NewCustomerOrderNotifications_for_RM_DAP_5_Star_Ads</fullName>
        <ccEmails>newcustomerordernotifications@cobaltgroup.com</ccEmails>
        <description>Alert NewCustomerOrderNotifications for RM DAP 5 Star Ads</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert_to_NewCustomerOrderNotifications_5_Star_Ads_Plus_up</template>
    </alerts>
    <alerts>
        <fullName>Alert_Ops_ProCare_Ready_for_Onboarding</fullName>
        <ccEmails>newcustomerordernotifications@cobalt.com</ccEmails>
        <description>Alert Ops - ProCare Ready for Onboarding</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/ONB_ProCare_Notification_Case</template>
    </alerts>
    <alerts>
        <fullName>Alert_Owner_of_New_OnBoarding_Case</fullName>
        <description>Alert Owner of New OnBoarding Case</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Admin/NewassignmentnotificationSAMPLE</template>
    </alerts>
    <alerts>
        <fullName>Alert_Owner_that_CLMs_or_Report_Review_not_complete_45_days</fullName>
        <description>Alert Owner that CLMs or Report Review not complete 45 days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/EMS_Case_notification_for_Onboarding_45_days</template>
    </alerts>
    <alerts>
        <fullName>Alert_Performance_Solution_Cancellation_Case_Created</fullName>
        <ccEmails>gmrdms@cobaltgroup.com</ccEmails>
        <description>Alert - Performance Solution Cancellation Case Created</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cancellation_Templates/Performance_Solution_Cancellation</template>
    </alerts>
    <alerts>
        <fullName>Alert_SEO_AA_Closed_SEO_Es_ONB_Case</fullName>
        <description>Alert SEO - AA Closed SEO Es ONB Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/SEO_Notification_of_AA_SEO_ES_Onboarding_Completion</template>
    </alerts>
    <alerts>
        <fullName>Alert_SEO_AA_when_SEO_INQ_Case_Complete</fullName>
        <description>Alert SEO - AA when SEO INQ Case Complete</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_SEO_AA_when_SEO_INQ_is_complete</template>
    </alerts>
    <alerts>
        <fullName>Alert_SEO_Redesign_Case_Created</fullName>
        <description>Alert SEO – Redesign Case Created</description>
        <protected>false</protected>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_SEO_Redesign_Case_Created</template>
    </alerts>
    <alerts>
        <fullName>Alert_SEO_SEO_Inquiry_Created</fullName>
        <description>Alert SEO - SEO Inquiry Created</description>
        <protected>false</protected>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert_SEO_when_SEO_Inquiry_Case_is_Created</template>
    </alerts>
    <alerts>
        <fullName>Alert_Service_Accnt_Team_GM_Rings</fullName>
        <description>Alert Service Accnt Team GM Rings</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Email Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/GM_Ring_Opt_Out_Notification</template>
    </alerts>
    <alerts>
        <fullName>Alert_Service_Accnt_Team_GM_Rings_Opt_IN</fullName>
        <description>Alert Service Accnt Team GM Rings -Opt IN</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Email Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_Ad_Ops_for_GM_Opt_in</template>
    </alerts>
    <alerts>
        <fullName>Alert_Service_Ops_App_Rpt_Queue</fullName>
        <ccEmails>ServicesOpsAnalystTeam@cobaltgroup.com</ccEmails>
        <description>Alert Service Ops - App/Rpt Queue</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <recipient>dan.dorgan@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert_to_Service_Ops_New_Reporting_Request</template>
    </alerts>
    <alerts>
        <fullName>Alert_Service_Ops_App_Rpt_Queue2</fullName>
        <description>Alert to PM/Manager Case to Queue</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <recipient>chris.wagster@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ken.anderson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>nancy.durant@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert_to_Service_Ops_New_Reporting_Request</template>
    </alerts>
    <alerts>
        <fullName>Alert_SvcOps_Case_is_Fast_Track</fullName>
        <ccEmails>ServicesOpsAnalystTeam@cobaltgroup.com</ccEmails>
        <description>Alert SvcOps Case is Fast Track</description>
        <protected>false</protected>
        <recipients>
            <recipient>camela.thompson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>nancy.durant@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert_SvcOps_Analyst_Fast_Track</template>
    </alerts>
    <alerts>
        <fullName>Alert_Team_Managers_New_Agency_Design_Case</fullName>
        <description>Alert Team Managers New Agency Design Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>shawn.jeffcoat@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>stacey.overturf@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_Managers_for_Agency_Design_Cases</template>
    </alerts>
    <alerts>
        <fullName>Alert_for_RDMM_for_DAP_cancellation</fullName>
        <ccEmails>gmrdms@cobaltgroup.com</ccEmails>
        <description>Alert for RDMM for DAP cancellation</description>
        <protected>false</protected>
        <recipients>
            <recipient>melissa.satterwhite@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cancellation_Templates/DAP_Cancel</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_AA_DSM_DAA_for_Ad_Spend_Increase_or_Decrease_Close</fullName>
        <description>Alert to AA, DSM, DAA for Ad Spend Increase or Decrease Close</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_AA_DSM_DAA_Ad_Spend_Increase_Decrease</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_AA_DSM_DAA_for_Ad_Spend_Increase_or_Decrease_Open</fullName>
        <description>Alert to AA, DSM, DAA for Ad Spend Increase or Decrease Open</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_AA_DSM_DAA_Ad_Spend_Increase_Decrease</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_AA_DSM_DAA_for_PS_Ad_Spend_Change_Close</fullName>
        <description>Alert to AA, DSM, DAA for PS Ad Spend Change Close</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Digital Services CAM</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert_to_AA_DSM_DAA_Ad_Spend_Change</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Account_Team_Flex_Change</fullName>
        <description>Alert to Account Team Flex Change</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Digital Services CAM</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>National/Enterprise DSM</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Notify_Account_Team_Flex_Budget_to_0</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Account_Team_for_Fight_for_First_Cases</fullName>
        <description>Alert to Account Team for Fight for First Cases</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Email Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>jae.kim@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_Account_Team_for_Fight_for_First</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Account_Team_when_Domain_Case_is_created</fullName>
        <description>Alert to Account Team when Domain Case is created</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Email Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing (DAP)</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_account_team_for_Domain_Cases</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Account_Team_when_Domain_Case_resolved</fullName>
        <description>Alert to Account Team when Domain Case resolved</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Email Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing (DAP)</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_account_team_for_Resolved_Domain_Cases</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Account_Team_when_VW_Vehicle_Command_Center_is_live</fullName>
        <description>Alert to Account Team when VW Vehicle Command Center is live</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_Account_Team_for_VW_Vehicle_Command_Center_Migration</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Ad_Ops_for_Closed_GM_Domain_Cases</fullName>
        <ccEmails>CDK.DealerUpdates@cdk.com</ccEmails>
        <description>Alert to Ad Ops for Closed VW, Hyundai or GM Domains Cases</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_Ad_Ops_for_GM_Domains_Cases</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Ad_Ops_for_GM_Buy_Sell</fullName>
        <ccEmails>CDK.DealerUpdates@cdk.com</ccEmails>
        <description>Alert to Ad Ops for GM Buy/Sell</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_Ad_Ops_for_GM_Buy_Sell</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Ad_Ops_for_GM_Name_Changes</fullName>
        <ccEmails>CDK.DealerUpdates@cdk.com</ccEmails>
        <description>Alert to Ad Ops for GM Name Changes</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_Ad_Ops_for_GM_Name_Changes</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Ad_Ops_for_GM_Opt_In</fullName>
        <ccEmails>CDK.DealerUpdates@cdk.com</ccEmails>
        <description>Alert to Ad Ops for GM Opt In</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_Ad_Ops_for_GM_Opt_in</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Ad_Ops_for_VW_BuySell</fullName>
        <ccEmails>CDK.DealerUpdates@cdk.com</ccEmails>
        <description>Alert to Ad Ops for VW or Hyundai BuySell</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_Ad_Ops_for_VW_Buy_Sell</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Ad_Ops_for_VW_Terminations</fullName>
        <ccEmails>CDK.DealerUpdates@cdk.com</ccEmails>
        <description>Alert to Ad Ops for VW Terminations</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_Ad_Ops_for_VW_Dealer_Termination</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Ad_Ops_for_VW_and_Hyundai_Address_Changes</fullName>
        <ccEmails>CDK.DealerUpdates@cdk.com</ccEmails>
        <description>Alert to Ad Ops for VW and Hyundai Address Changes</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFS_Launch_Templates/Alert_to_Ad_Ops_for_VW_or_Hyundai_Address_Change</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Ad_Ops_for_VW_and_Hyundai_Name_Changes</fullName>
        <ccEmails>CDK.DealerUpdates@cdk.com</ccEmails>
        <description>Alert to Ad Ops for VW and Hyundai Name Changes</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFS_Launch_Templates/Alert_to_Ad_Ops_for_VW_and_Hyundai_Name_Changes</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_DLP_Support_Queue</fullName>
        <description>Alert to DLP Support Queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/DLP_Support_Queue_Notification</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Engagement_Manager_Social_of_Buy_Sell_or_iMR_opt_outs</fullName>
        <ccEmails>adpdirectorylistings@cobalt.com</ccEmails>
        <description>Alert to Engagement Manager, Social of Buy/Sell or iMR opt outs for GM</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_Engagement_Manager_Social</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_GMMS_for_GM_Domains_Cases</fullName>
        <ccEmails>CDK.DealerUpdates@cdk.com</ccEmails>
        <description>Alert to GMMS for GM Domains Cases</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_Ad_Ops_for_GM_Domains_Cases</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_GMMS_for_GM_Terminations</fullName>
        <ccEmails>CDK.DealerUpdates@cdk.com</ccEmails>
        <description>Alert to GMMS for GM Terminations</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFS_Launch_Templates/Alert_to_GMMS_for_GM_Dealer_Termination</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_IFS_Team_for_IFS_OEM_Initiated_Change_cases</fullName>
        <description>Alert to IFS Team for IFS - OEM Initiated Change cases</description>
        <protected>false</protected>
        <recipients>
            <recipient>erika.myrick@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jane.minkel@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kevin.olson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>meredith.carlile@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>trish.chambers@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert_Team_for_IFS_OEM_Initiated_Change_Cases</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Joan_Studley_for_Flex_Budget_Changes</fullName>
        <ccEmails>Joan.Studley@adp.com</ccEmails>
        <description>Alert to Joan Studley for Flex Budget Changes</description>
        <protected>false</protected>
        <recipients>
            <recipient>matthew.condon@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sarah.vidrine@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_Joan_Studley_for_Flex_Budget_Changes</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_NewCustomerOrderNotifications_for_Account_Move</fullName>
        <ccEmails>newcustomerordernotifications@cobalt.com</ccEmails>
        <description>Alert to NewCustomerOrderNotifications for Account Move</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert_to_NewCustomerOrder_Notifications_for_Account_Moves</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_New_Customer_Orders_for_Flex_Budget_Changes</fullName>
        <ccEmails>newcustomerordernotifications@cobalt.com</ccEmails>
        <description>Alert to New Customer Orders for Flex Budget Changes</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_New_Customer_Orders_for_Flex_Budget_Changes</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_SEO_Specialist_Page_Customization_Case_CreatedClosed</fullName>
        <description>Alert to SEO Specialist - Page Customization Case CreatedClosed</description>
        <protected>false</protected>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/PowerSEO_Page_Customization_Alert</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_gmms_cobalt_com_for_GM_Address_Changes</fullName>
        <ccEmails>CDK.DealerUpdates@cdk.com</ccEmails>
        <description>Alert to gmms@cobalt.com for GM Address Changes</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_gmms_cobalt_com_for_GM_Address_Changes</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_vw_team1</fullName>
        <description>Alert to VW Team when Cancellation case created for account w/ Volkswagen listed in the OEM</description>
        <protected>false</protected>
        <recipients>
            <recipient>alex.degurian@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>beau.arsenault@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>david.vanfleet@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dayna.welch@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>griffinje@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kristen.cabello@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cancellation_Templates/Cancellation_Case_has_been_Created</template>
    </alerts>
    <alerts>
        <fullName>BuySell_Created_Notification_to</fullName>
        <ccEmails>creditcollections@cobalt.com</ccEmails>
        <description>BuySell Created - Notification to List-Credit-Collections</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IFS_Templates/BuySell_Case_Created</template>
    </alerts>
    <alerts>
        <fullName>CANADA_French_Satisfaction_Survey_Reminder</fullName>
        <description>CANADA-French Satisfaction Survey - Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_Templates/CDK_Digital_Marketing_Survey_FRENCH_Reminder</template>
    </alerts>
    <alerts>
        <fullName>CB_Alert_to_Nicole_Jones_for_Budget_Change_Close</fullName>
        <description>CB Alert to Nicole Jones for Budget Change Close</description>
        <protected>false</protected>
        <recipients>
            <recipient>nicole.kurtiak@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert_to_Nicole_Jones_for_Budget_Change_Case_Close</template>
    </alerts>
    <alerts>
        <fullName>CB_CSI_French_Survey_Email</fullName>
        <description>CB_CSI_French_Survey_Email</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>digitalmarketingsat@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_Templates/CDK_Digital_Marketing_Survey_FRENCH</template>
    </alerts>
    <alerts>
        <fullName>CB_CSI_GM_et_ALL_7_Days_with_No_Response</fullName>
        <description>CB_CSI_GM_et_ALL - 7 Days with No Response</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_Templates/CDK_Digital_Marketing_Survey_Reminder</template>
    </alerts>
    <alerts>
        <fullName>CB_CSI_GM_et_All_Survey_Email</fullName>
        <description>CB_CSI_GM_et_All_Survey_Email</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>digitalmarketingsat@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_Templates/CDK_Digital_Marketing_Survey</template>
    </alerts>
    <alerts>
        <fullName>CB_CSI_Lexus_Survey_Email</fullName>
        <description>CB_CSI_Lexus_Survey_Email</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>lexusdigitalmarketingsat@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_Templates/Lexus_eCare_Satisfaction_Survey</template>
    </alerts>
    <alerts>
        <fullName>CB_Cncl_Notification_to_VW_DMS_Team_for_DAP_or_ProCare_Cancellation</fullName>
        <description>CB_Cncl_Notification_to_VW_DMS_Team_for_DAP_or_ProCare_Cancellation</description>
        <protected>false</protected>
        <recipients>
            <recipient>_shane.helms@adp.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>alex.degurian@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>angelo.abboud@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>beau.arsenault@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>david.vanfleet@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dayna.welch@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>griffinje@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jacob.casmir@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kristen.cabello@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>patrick.hyde@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>peter.rangar@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cancellation_Templates/Cancellation_Case_has_been_Created</template>
    </alerts>
    <alerts>
        <fullName>CB_Cncl_Notification_to_VW_DMS_Team_for_DAP_or_ProCare_Cancellation_status_Booke</fullName>
        <description>CB_Cncl_Notification_to_VW_DMS_Team_for_DAP_or_ProCare_Cancellation_status_Booked</description>
        <protected>false</protected>
        <recipients>
            <recipient>_shane.helms@adp.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>angelo.abboud@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jim.elliott@adp.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>patrick.hyde@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cancellation_Templates/Cancellation_Case_Status_Changed_to_Booked</template>
    </alerts>
    <alerts>
        <fullName>CB_CustData_Case_Created_Notification</fullName>
        <description>CB_CustData_Case_Created_Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>_amit.dwivedi@adp.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>aj.soysouvanh@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Templates/Case_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>CB_EMLALERT_for_Kia_cancellation</fullName>
        <description>CB_EMLALERT for Kia cancellation</description>
        <protected>false</protected>
        <recipients>
            <recipient>cameron.wong@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>melissa.satterwhite@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sean.manne@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>suzanne.newhouse@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>External_Cancellation_Templates/Cancellation_Case_Creation_Notification1</template>
    </alerts>
    <alerts>
        <fullName>CB_EML_Buy_Sell_Notification</fullName>
        <description>CB_EML_Buy-Sell-Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>debra.baker@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Templates/Case_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>CB_EML_PowerBrandCaseOpened</fullName>
        <description>CB_EML_PowerBrandCaseOpened</description>
        <protected>false</protected>
        <recipients>
            <recipient>Email Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Email_Marketing/Alert_to_EMS_Power_Brand_Case_Opened</template>
    </alerts>
    <alerts>
        <fullName>CB_Email_Transition_DAA_Change</fullName>
        <description>CB Email Transition DAA Change</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Transitioning_From__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Transitioning_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Specialist_Transition_Notification</template>
    </alerts>
    <alerts>
        <fullName>CB_Finance_Case_Closed</fullName>
        <description>CB_Finance_Case_Closed</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Finance/Finance_Case_Closed_Notification</template>
    </alerts>
    <alerts>
        <fullName>CB_IFSCA_BZ_Cancellation_Closed</fullName>
        <description>CB_IFSCA_BZ_Cancellation_Closed</description>
        <protected>false</protected>
        <recipients>
            <recipient>jenifer.jones@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jill.johnson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Templates/Case_Closed_Notification</template>
    </alerts>
    <alerts>
        <fullName>CB_IFSCA_BZ_Cancellation_Created</fullName>
        <ccEmails>SalesOpsBZCancellations@adp.com</ccEmails>
        <description>CB_IFSCA_BZ_Cancellation_Created</description>
        <protected>false</protected>
        <recipients>
            <recipient>jenifer.jones@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jill.johnson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Templates/BZ_Cancellation_Case_Created</template>
    </alerts>
    <alerts>
        <fullName>CB_IFSCA_EML_Snd_to_DS_Buy_Sell</fullName>
        <ccEmails>_Ds_account_update@adp.com</ccEmails>
        <description>CB_IFSCA_EML_Snd_to_DS_Buy_Sell</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Case_Admin/DS_Notification_Email_Buy_Sell</template>
    </alerts>
    <alerts>
        <fullName>CB_IFSCA_EML_Snd_to_DS_New_Dealer</fullName>
        <ccEmails>_Ds_account_update@adp.com</ccEmails>
        <description>CB_IFSCA_EML_Snd_to_DS_New_Dealer</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Case_Admin/DS_Notification_Email_New_Dealer</template>
    </alerts>
    <alerts>
        <fullName>CB_IFSCA_EML_Snd_to_DS_Termination</fullName>
        <ccEmails>_Ds_account_update@adp.com</ccEmails>
        <description>CB_IFSCA_EML_Snd_to_DS_Termination</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Case_Admin/DS_Notification_Email_Termination</template>
    </alerts>
    <alerts>
        <fullName>CB_IFSCA_EML_Snd_to_OMS_DMS_when_PS_Budget_Change_Created</fullName>
        <description>CB_IFSCA_EML_Snd_to_OMS_DMS_when_PS_Budget_Change_Created</description>
        <protected>false</protected>
        <recipients>
            <recipient>Digital Services CAM</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Digital Solutions Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Templates/Case_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>CB_IFSCA_EmailAlert_Account_Move</fullName>
        <ccEmails>newcustomerordernotifications@cobalt.com</ccEmails>
        <description>CB_IFSCA_EmailAlert_Account_Move</description>
        <protected>false</protected>
        <recipients>
            <recipient>cameron.wong@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Corp_IT/Case_Creation_Notification_corpIT</template>
    </alerts>
    <alerts>
        <fullName>CB_IFSCA_GM_Termination_Case_Created</fullName>
        <ccEmails>DAPIssue@cobaltgroup.com</ccEmails>
        <description>CB_IFSCA_GM_Termination_Case_Created</description>
        <protected>false</protected>
        <recipients>
            <recipient>cameron.wong@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cancellation_Templates/Cancellation_Case_has_been_Created</template>
    </alerts>
    <alerts>
        <fullName>CB_IFSEnh_ADP_Lead_Manager</fullName>
        <description>CB_IFSEnh_ADP_Lead_Manager</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFS_Templates/Case_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>CB_Low_Score_Alert</fullName>
        <ccEmails>DigitalMarketingSat@cdk.com</ccEmails>
        <description>CB_Low_Score_Alert</description>
        <protected>false</protected>
        <senderAddress>digitalmarketingsat@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_Templates/CB_CSI_Low_Score_Alert</template>
    </alerts>
    <alerts>
        <fullName>CB_OMS_Alert_NewMinorEditCase</fullName>
        <ccEmails>ServicesDACreativeUpdates@cobalt.com</ccEmails>
        <description>CB_OMS_Alert_NewMinorEditCase</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_OMS_New_Minor_Edit_Case</template>
    </alerts>
    <alerts>
        <fullName>CB_ONBSocial_EML_InitialContact_Not_marked_Completed</fullName>
        <description>CB_ONBSocial_EML_InitialContact_Not_marked_Completed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Onboarding_Social_Case_notification_7_days_without_Initial_Contact_Marked_Cmplt</template>
    </alerts>
    <alerts>
        <fullName>CB_RepMan_Cancellation_Notification</fullName>
        <description>CB_RepMan_Cancellation_Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>cameron.wong@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jason.davis@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jenifer.jones@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cancellation_Templates/Cancellation_Case_has_been_Created</template>
    </alerts>
    <alerts>
        <fullName>CB_SVC_Alert_DAA_when_DAS_is_assigned_to_Onboarding_OMS_case</fullName>
        <description>CB SVC Alert - DAA when DAS is assigned to Onboarding - OMS case</description>
        <protected>false</protected>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFS_Launch_Templates/Alert_DAA_when_Strategist_is_assigned_to_Onboarding_OMS_case</template>
    </alerts>
    <alerts>
        <fullName>CB_SVC_Alert_Service_Ops_Inquiry_Queue_Case</fullName>
        <ccEmails>ServicesOpsAnalystTeam@cdk.com</ccEmails>
        <description>CB_SVC Alert Service Ops Inquiry Queue Case</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/CB_SVC_Alert_Service_Ops_Inquiry_Queue_Case</template>
    </alerts>
    <alerts>
        <fullName>CB_SVC_Alert_for_Support_Tools_Case</fullName>
        <description>CB_SVC_Alert for Support Tools Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>amanda.dodd@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/CB_SVC_Alert_for_Support_Tools_Case</template>
    </alerts>
    <alerts>
        <fullName>CB_SVC_BMW_Mini_Cancellation</fullName>
        <ccEmails>DigitalCancellations@cdk.com</ccEmails>
        <ccEmails>Victor.Martinez@cdk.com</ccEmails>
        <ccEmails>Eduardo.Estrada@cdk.com</ccEmails>
        <ccEmails>Michael.Hoagland@cdk.com</ccEmails>
        <description>CB_SVC_BMW_Mini_Cancellation</description>
        <protected>false</protected>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cancellation_Templates/Cancellation_Case_has_been_Created</template>
    </alerts>
    <alerts>
        <fullName>CB_SVC_EML_Alert_the_Strategist_when_Inquiry_LMA_case_is_created</fullName>
        <description>CB SVC EML - Alert the Strategist when Inquiry - LMA case is created</description>
        <protected>false</protected>
        <recipients>
            <recipient>erik.hulbert@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>justin.cave@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>susan.hamilton@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/CB_SVC_Alert_Strategist_Inquiry_LMA_Opt_In_case</template>
    </alerts>
    <alerts>
        <fullName>CB_SVC_EML_Kia_Cancellation_Lost</fullName>
        <ccEmails>Melissa.Satterwhite@cdk.com</ccEmails>
        <ccEmails>Suzanne.Newhouse@cdk.com</ccEmails>
        <ccEmails>Sean.Manne@cdk.com</ccEmails>
        <description>CB_SVC_EML_Kia_Cancellation_Lost</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cancellation_Templates/Cancellation_is_Moving_Forward</template>
    </alerts>
    <alerts>
        <fullName>CB_SVC_EML_TS_Lead_Escalation</fullName>
        <description>CB_SVC_EML TS Lead Escalation</description>
        <protected>false</protected>
        <recipients>
            <recipient>cameron.standley@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jason.denk@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/CBT_SVC_TS_Lead_Escalation_Notification</template>
    </alerts>
    <alerts>
        <fullName>CB_Sales_Hyundai_Cancellation</fullName>
        <ccEmails>hyundaiactivityalert@cdk.com</ccEmails>
        <description>CB_Sales_Hyundai_Cancellation</description>
        <protected>false</protected>
        <recipients>
            <recipient>melissa.satterwhite@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>suzanne.newhouse@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cancellation_Templates/Hyundai_Case_has_been_Created1</template>
    </alerts>
    <alerts>
        <fullName>CB_Svc_Alert_DSM_Closed_As_Dup</fullName>
        <ccEmails>salesops@cobalt.com</ccEmails>
        <description>CB_Svc_Alert_DSM_Closed_As_Dup</description>
        <protected>false</protected>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_DSM_for_Closed_as_Duplicate</template>
    </alerts>
    <alerts>
        <fullName>CB_Transition_Advocate_Change</fullName>
        <description>CB_Transition_Advocate_Change</description>
        <protected>false</protected>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Transitioning_From__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Transitioning_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Advocate_Transition_Notification</template>
    </alerts>
    <alerts>
        <fullName>Cancellation_Case_Open_NoActivity_5day</fullName>
        <description>Cancellation Case with No Activity</description>
        <protected>false</protected>
        <recipients>
            <recipient>Email Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing (DAP)</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Case Team Member</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cancellation_Templates/Cancellation_has_no_activity</template>
    </alerts>
    <alerts>
        <fullName>Cancellation_Case_Opened</fullName>
        <description>Cancellation Case Opened</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Digital Services CAM</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Director of Digital Sales</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>EDS</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Email Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Inside Sales Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing (DAP)</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Performance Improvement Consultant</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Regional Digital Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Reputation Management Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cancellation_Templates/Cancellation_Case_has_been_Created</template>
    </alerts>
    <alerts>
        <fullName>Cancellation_Case_Opened_GM_DMP</fullName>
        <description>Cancellation Case Opened - GM DMP</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Director of Digital Sales</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>EDS</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Email Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Inside Sales Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing (DAP)</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Performance Improvement Consultant</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Regional Digital Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Reputation Management Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>melissa.satterwhite@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cancellation_Templates/Cancellation_Case_has_been_Created_GM_DMP</template>
    </alerts>
    <alerts>
        <fullName>Cancellation_Lost_Alert</fullName>
        <description>Cancellation Lost Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Digital Services CAM</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Director of Digital Sales</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>EDS</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Email Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Inside Sales Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing (DAP)</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Performance Improvement Consultant</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Regional Digital Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Reputation Management Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Case Team Member</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cancellation_Templates/Cancellation_is_Moving_Forward</template>
    </alerts>
    <alerts>
        <fullName>Cancellation_Saved_Alert</fullName>
        <description>Cancellation Saved Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Digital Services CAM</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Director of Digital Sales</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>EDS</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Email Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Inside Sales Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing (DAP)</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Performance Improvement Consultant</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Regional Digital Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Reputation Management Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Case Team Member</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cancellation_Templates/Cancellation_Has_Been_Saved</template>
    </alerts>
    <alerts>
        <fullName>Case_Creation_Email_Notification_Dealix</fullName>
        <description>Case Creation Email Notification - Dealix</description>
        <protected>false</protected>
        <recipients>
            <recipient>jason.denk@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>matthew.albertson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>matthew.browning@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mike.jones@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert_For_New_Dealix_Case</template>
    </alerts>
    <alerts>
        <fullName>Case_Creation_Email_Notification_GMRep</fullName>
        <description>Case Creation Email Notification - GMRep</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>cameron.standley@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jason.denk@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_AutoNotifications_to_Dealer/Case_Opened_AutoNotification_Template_GM_Rep</template>
    </alerts>
    <alerts>
        <fullName>Case_Creation_Email_Notification_Lexus</fullName>
        <description>Case Creation Email Notification - Lexus</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_AutoNotifications_to_Dealer/Lexus_Case_Creation1</template>
    </alerts>
    <alerts>
        <fullName>Case_Creation_Notification_to_List_DLP_Ad_Operations</fullName>
        <ccEmails>DLPAdOperations@cobaltgroup.com</ccEmails>
        <description>Case Creation Notification to List- DLP Ad Operations</description>
        <protected>false</protected>
        <recipients>
            <recipient>cameron.wong@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Templates/Case_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>Case_Opened_From_Email_AutoNotification_Holden</fullName>
        <description>Case Opened From Email AutoNotification - Holden</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_AutoNotifications_to_Dealer/Holden_Case_Opened_AutoNotification_Template</template>
    </alerts>
    <alerts>
        <fullName>Case_Opened_from_Email_AutoNotification</fullName>
        <description>Case Opened from Email AutoNotification</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_AutoNotifications_to_Dealer/Case_Opened_AutoNotification_Template</template>
    </alerts>
    <alerts>
        <fullName>Case_has_been_in_IFS_Data_Ops_Queue_for_3_days</fullName>
        <ccEmails>onstationdataops@cobaltgroup.com</ccEmails>
        <description>Case has been in IFS Data Ops Queue for 3 days</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Email_Marketing/Alert_to_Owner_IFS_No_touch_in_3_Days</template>
    </alerts>
    <alerts>
        <fullName>Cisco_Alert</fullName>
        <description>Cisco Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>charlein.barni@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>christy.silveira@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cindy.hardiman@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Services_Cisco_Notification</template>
    </alerts>
    <alerts>
        <fullName>Customer_Data_911_Field_Checked</fullName>
        <ccEmails>customerdata@cobaltgroup.com</ccEmails>
        <description>Customer Data 911 Field Checked</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Corp_IT/Customer_Data_911_Field_Checked</template>
    </alerts>
    <alerts>
        <fullName>DAS_Notification_of_AA_DAP_ONB_Complete_OMS_on_call</fullName>
        <description>DAS Notification of AA DAP ONB Complete OMS on call</description>
        <protected>false</protected>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/DAS_Notification_of_AA_DAP_ONB_Complete_OMS_on_call</template>
    </alerts>
    <alerts>
        <fullName>EMLAlert_VW_BuySell_Termination_Notifications</fullName>
        <description>EMLAlert_VW_BuySell_Termination_Notifications</description>
        <protected>false</protected>
        <recipients>
            <recipient>alex.degurian@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>beau.arsenault@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>david.vanfleet@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dayna.welch@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>griffinje@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Corp_IT/Case_Creation_Notification_corpIT</template>
    </alerts>
    <alerts>
        <fullName>EML_CB_Svc_Lexus_Case_Needs_Manger_Review</fullName>
        <description>EML CB Svc Lexus Case Needs Manger Review</description>
        <protected>false</protected>
        <recipients>
            <recipient>dana.cristalli1@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kim.mcclure@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tana.pike@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Case_Admin/CB_Svc_Lexus_Case_Needs_Manger_Review</template>
    </alerts>
    <alerts>
        <fullName>EMS_Design_Case_Opened</fullName>
        <ccEmails>ServicesEMSDesignTeam@cobaltgroup.com</ccEmails>
        <description>EMS Design Case Opened</description>
        <protected>false</protected>
        <recipients>
            <recipient>chase.tangney@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>yan.chow@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Email_Marketing/EMS_Design_Case_has_been_Created</template>
    </alerts>
    <alerts>
        <fullName>Email_Advocate_if_case_is_created_by_someone_that_is_not_the_Advocate</fullName>
        <description>Email Advocate if case is created by someone that is not the Advocate</description>
        <protected>false</protected>
        <recipients>
            <field>Advocate_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Case_Opened_AutoNotification_for_AA</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_Cancellation_Case_Created</fullName>
        <description>Email Alert - Cancellation Case Created</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Case911</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_to_Account_Team_when_Downgrade_Case_is_Created</fullName>
        <description>Email Alert to Account Team when Downgrade Case is Created</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Digital Solutions Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Director of Digital Sales</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>EDS</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Email Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Enterprise Sales Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Inside Sales Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>National/Enterprise DSM</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing (DAP)</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Performance Improvement Consultant</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Regional Digital Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Regional OEM Consultant</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Templates/Case_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>Emails_owner_when_the_Planned_Delivery_Date_happens_to_tell_them_it_s_happened</fullName>
        <description>Emails owner when the Planned Delivery Date happens to tell them it&apos;s happened.</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Service_Ops_Case_Delivery_Date_is_Here</template>
    </alerts>
    <alerts>
        <fullName>FYI_to_non_Advantage_users</fullName>
        <description>FYI to non-Advantage users</description>
        <protected>false</protected>
        <recipients>
            <recipient>alicia.childers@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>carolyn.mull@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>daisha.neville@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dereck.moore@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>randal.hinthorne@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert</template>
    </alerts>
    <alerts>
        <fullName>GM_Canada_Cancellation_Notification</fullName>
        <description>GM Canada Cancellation Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>scott.sabo@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cancellation_Templates/Cancellation_Case_has_been_Created</template>
    </alerts>
    <alerts>
        <fullName>GM_iMR_Opt_Out_Notification_to_Account_Team</fullName>
        <description>GM iMR Opt Out Notification to Account Team</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Digital Solutions Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Director of Digital Sales</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Enterprise Sales Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Inside Sales Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Performance Improvement Consultant</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Regional Digital Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cancellation_Templates/GM_Opt_Out_Case_Created</template>
    </alerts>
    <alerts>
        <fullName>Hyundai_Cancellation_Notification</fullName>
        <ccEmails>hyundaiactivityalert@cobalt.com</ccEmails>
        <description>Hyundai Cancellation Notification</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cancellation_Templates/Cancellation_Case_has_been_Created</template>
    </alerts>
    <alerts>
        <fullName>Hyundai_Case_notifies_Suzanna_Casteneda_and_Joshua_Brosnan</fullName>
        <description>Hyundai Case Notifies for cancel,buy/sell, new</description>
        <protected>false</protected>
        <recipients>
            <recipient>suzanne.newhouse@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Hyundai_Case_has_been_Created</template>
    </alerts>
    <alerts>
        <fullName>Hyundai_Termination_notifies_Suzanna_Casteneda_Enterprise_Sales</fullName>
        <description>Hyundai Termination notifies Suzanna Casteneda, Enterprise Sales</description>
        <protected>false</protected>
        <recipients>
            <recipient>suzanne.newhouse@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cancellation_Templates/Cancellation_Case_has_been_Created</template>
    </alerts>
    <alerts>
        <fullName>IFS_DI_30_Day_No_Activity_Email_Alert_DSM</fullName>
        <description>IFS-DI - 30 Day No Activity - Email Alert - DSM</description>
        <protected>false</protected>
        <recipients>
            <recipient>Digital Solutions Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Templates_for_Sales04t40000000/IFS_DI_30_Day_No_Activity_notification</template>
    </alerts>
    <alerts>
        <fullName>IFS_DI_48_Hour_No_Action_Email_Alert_DSM</fullName>
        <description>IFS-DI - 48 Hour No Action Email Alert - DSM</description>
        <protected>false</protected>
        <recipients>
            <recipient>Digital Solutions Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Templates_for_Sales04t40000000/IFS_DI_Alert_AE_2_Days_after_Create</template>
    </alerts>
    <alerts>
        <fullName>IFS_DI_48_Hour_No_Activity_notification</fullName>
        <description>IFS-DI 48 Hour No Activity notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>michelle.duncan@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFS_Templates/IFS_DI_48_Hour_No_Activity_notification</template>
    </alerts>
    <alerts>
        <fullName>IFS_Data_Ops_Alert_to_Manager</fullName>
        <description>IFS - Data Ops Alert to Manager</description>
        <protected>false</protected>
        <recipients>
            <recipient>cameron.wong@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Email_Marketing/Alert_to_IFS_Manager_from_Data_Ops</template>
    </alerts>
    <alerts>
        <fullName>IFS_Data_Ops_Case_Opened</fullName>
        <ccEmails>onstationdataops@cobaltgroup.com</ccEmails>
        <description>IFS Data Ops Case Opened</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Email_Marketing/IFS_Data_Ops_Case_has_been_Created</template>
    </alerts>
    <alerts>
        <fullName>Inbound_Response_Received</fullName>
        <description>Inbound Response Received</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Admin/Customer_Response_Received</template>
    </alerts>
    <alerts>
        <fullName>Lexus_eCare_Satisfaction_Survey_Reminder</fullName>
        <description>Lexus eCare Satisfaction Survey - Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>lexusdigitalmarketingsat@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_Templates/Lexus_eCare_Satisfaction_Survey_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Manager_Approval_Box_Checked</fullName>
        <description>Manager Approval Box Checked</description>
        <protected>false</protected>
        <recipients>
            <recipient>margaret.clayton@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Automation_Templates/ManagerApprovalTemplate</template>
    </alerts>
    <alerts>
        <fullName>New_Task_Alert_Notification</fullName>
        <description>New Task Alert Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>megan.carlisle@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/New_Task_Alert_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_Account_Team_when_case_is_Resolved</fullName>
        <description>Notification to Account Team when case is Resolved</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Notification_to_Account_Team_for_Resolved_Case</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_Account_Team_when_case_is_in_Proof</fullName>
        <description>Notification to Account Team when case is in Proof</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Notification_to_Account_Team_for_Proof_Case</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_Dealer_Group_when_case_is_Resolved</fullName>
        <description>Notification to Dealer Group when case is Resolved</description>
        <protected>false</protected>
        <recipients>
            <field>Dealer_Group_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_AutoNotifications_to_Dealer/Notification_to_Dealer_Group_for_Resolved_Case</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_Dealer_Group_when_case_is_in_Proof</fullName>
        <description>Notification to Dealer Group when case is in Proof</description>
        <protected>false</protected>
        <recipients>
            <field>Dealer_Group_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_AutoNotifications_to_Dealer/Notification_to_Dealer_Group_for_Resolved_in_Proof</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_Dealer_when_case_is_Resolved</fullName>
        <description>Notification to Dealer when case is Resolved</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_AutoNotifications_to_Dealer/Notification_to_Dealer_for_Resolved_Case</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_Dealer_when_case_is_in_Proof</fullName>
        <description>Notification to Dealer when case is in Proof</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_AutoNotifications_to_Dealer/Notification_to_Dealer_for_Resolved_in_Proof</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_contact_for_grp_when_CT_closes_case</fullName>
        <description>Notification to contact for grp when CT closes case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_AutoNotifications_to_Dealer/Case_Closure_AutoNotification_Template_to_Dealer_Group</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_dealer_when_CT_closes_case</fullName>
        <description>Notification to dealer when CT closes case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_AutoNotifications_to_Dealer/Case_Closure_AutoNotification_Template</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_group_dealer_when_CT_closes_case</fullName>
        <description>Notification to group dealer when CT closes case</description>
        <protected>false</protected>
        <recipients>
            <field>Dealer_Group_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Service_AutoNotifications_to_Dealer/Case_Closure_AutoNotification_Template_to_Dealer_Group</template>
    </alerts>
    <alerts>
        <fullName>Notify_AA_via_email_ONB_case_9_days_after_open_if_no_activity</fullName>
        <description>Notify AA via email ONB case 9 days after open if no activity</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/AA_Case_notification_for_Onboarding_after_9_days</template>
    </alerts>
    <alerts>
        <fullName>Notify_AE_for_Budget_Change</fullName>
        <description>Notify AE for Budget Change</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Digital Solutions Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>OMS_Templates/Notify_AE_for_Budget_Change</template>
    </alerts>
    <alerts>
        <fullName>Notify_Escalation</fullName>
        <description>Notify for Case Escalation</description>
        <protected>false</protected>
        <recipients>
            <recipient>TSRManagers</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Caseescalationnotification</template>
    </alerts>
    <alerts>
        <fullName>Notify_Escalation2hours</fullName>
        <description>Notify for Case Escalation 2 hours</description>
        <protected>false</protected>
        <recipients>
            <recipient>TSRManagers</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>TechnicalSupportDirector</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Caseescalationnotification</template>
    </alerts>
    <alerts>
        <fullName>Notify_OMS_for_Onboarding_case_to_close_in_9_days</fullName>
        <description>Notify OMS  for Onboarding case to close in 9 days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/OMS_Case_notification_for_Onboarding_7_days</template>
    </alerts>
    <alerts>
        <fullName>Notify_Parent_Case_Owner_of_Child_Case_Closed</fullName>
        <description>Notify Parent Case Owner of Child Case Closed</description>
        <protected>false</protected>
        <recipients>
            <field>Parent_Case_Owner__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Child_Case_Closed_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_for_911_Case</fullName>
        <description>Notify for 911 Case - Tier 1</description>
        <protected>false</protected>
        <recipients>
            <recipient>arthur.john@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cameron.standley@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>crystal.robertson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jason.denk@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jon.blake@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>matthew.browning@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tana.pike@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Case911</template>
    </alerts>
    <alerts>
        <fullName>Notify_for_911_Case_Creative</fullName>
        <description>Notify for 911 Case - Creative</description>
        <protected>false</protected>
        <recipients>
            <recipient>robert.mcfarland@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tara.norris@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Creative_Case_911_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_for_911_Case_Tier_1_1_hour_no_activity</fullName>
        <description>Notify for 911 Case - Tier 1 - 1 hour no activity</description>
        <protected>false</protected>
        <recipients>
            <recipient>arthur.john@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cameron.standley@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>crystal.robertson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jason.denk@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jon.blake@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>matthew.browning@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tana.pike@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Case911</template>
    </alerts>
    <alerts>
        <fullName>Notify_for_911_Case_Tier_2_1_Hour_no_activity</fullName>
        <description>Notify for 911 Case - Tier 2 - 1 Hour no activity</description>
        <protected>false</protected>
        <recipients>
            <recipient>arthur.john@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cameron.standley@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>crystal.robertson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jason.denk@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jon.blake@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>matthew.browning@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tana.pike@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Case911</template>
    </alerts>
    <alerts>
        <fullName>Notify_for_911_Case_Tier_2_ETS</fullName>
        <description>Notify for 911 Case - Tier 2 - ETS</description>
        <protected>false</protected>
        <recipients>
            <recipient>arthur.john@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cameron.standley@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>crystal.robertson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jason.denk@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jon.blake@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>matthew.browning@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tana.pike@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Case911</template>
    </alerts>
    <alerts>
        <fullName>Notify_for_911_Cases_Holden_Tier_1_Tier_2</fullName>
        <ccEmails>servicesholdenteam@adp.com</ccEmails>
        <description>Notify for 911 Cases - Holden Tier 1, Tier 2</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Case911</template>
    </alerts>
    <alerts>
        <fullName>Notify_for_911_Cases_Tier_2_Content_1_hour_no_activity</fullName>
        <ccEmails>IFSContentNotification@cobalt.com, DS.IFSContentTeamManagers@adp.com</ccEmails>
        <description>Notify for 911 Cases - Tier 2 - Content - 1 hour no activity</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Case911</template>
    </alerts>
    <alerts>
        <fullName>Notify_for_911_Cases_Tier_2_ETS</fullName>
        <ccEmails>IFSContentNotification@cobalt.com</ccEmails>
        <description>Notify for 911 Cases - Tier 2 - ETS</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Case911</template>
    </alerts>
    <alerts>
        <fullName>Notify_for_Cancellation_Case_with_no_Activity_for_5_days</fullName>
        <description>Notify for Cancellation Case with no Activity for 5 days</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Admin/Case_5_days_no_activity</template>
    </alerts>
    <alerts>
        <fullName>Notify_for_Case_Escalation_after_3_hours</fullName>
        <description>Notify for Case Escalation after 3 hours</description>
        <protected>false</protected>
        <recipients>
            <recipient>TSDirector</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Caseescalationnotification</template>
    </alerts>
    <alerts>
        <fullName>Notify_for_IFS_Enhancement_Case_Creation_Closure</fullName>
        <description>Notify for IFS Enhancement Case Creation Closure</description>
        <protected>false</protected>
        <recipients>
            <recipient>Digital Services CAM</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Notify_for_IFS_Enhancement_Case_Creation_Closure</template>
    </alerts>
    <alerts>
        <fullName>Notify_for_Onboarding_case_to_close_in_10_days</fullName>
        <description>Notify for Onboarding case to close in 10 days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/AA_Case_notification_for_Onboarding_after_9_days</template>
    </alerts>
    <alerts>
        <fullName>Notify_for_Onboarding_case_to_close_in_9_days</fullName>
        <description>Notify for Onboarding case to close in 9 days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/AA_Case_notification_for_Onboarding_after_9_days</template>
    </alerts>
    <alerts>
        <fullName>OMS_alert_ONB_not_closed_after_7_business_days</fullName>
        <description>OMS alert ONB not closed after 7 business days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/OMS_Case_notification_for_Onboarding_7_days</template>
    </alerts>
    <alerts>
        <fullName>PowerSEO_Cancellation_Alert</fullName>
        <description>PowerSEO Cancellation Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>dana.melick@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kelly.reynolds@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cancellation_Templates/Cancellation_Case_has_been_Created</template>
    </alerts>
    <alerts>
        <fullName>Pre_Cancellation_Case_Opened</fullName>
        <description>Pre-Cancellation Case Opened</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Digital Services CAM</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Director of Digital Sales</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>EDS</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Email Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Inside Sales Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing (DAP)</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Owner Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Performance Improvement Consultant</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Regional Digital Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Reputation Management Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>DS_Marketing/Pre_Cancellation_Case_has_been_Created</template>
    </alerts>
    <alerts>
        <fullName>SVCOpsClosedCaseAlert</fullName>
        <description>SVCOpsClosedCaseAlert</description>
        <protected>false</protected>
        <recipients>
            <recipient>ken.anderson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/CB_SVC_SVCOpsClosedCaseAlert</template>
    </alerts>
    <alerts>
        <fullName>Send_Cancel_Form_Alert</fullName>
        <description>Send Cancel Form Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Advocate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Digital Solutions Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>EDS</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Inside Sales Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Online Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Performance Improvement Consultant</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Regional Digital Marketing Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Search Optimization Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Case Team Member</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cancellation_Templates/Cancellation_Form_Received</template>
    </alerts>
    <alerts>
        <fullName>Service_Ops_Website_Scan_Tool_notification</fullName>
        <description>Service Ops – Website Scan Tool notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>jeffrey.peugh@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Service_Ops_Website_Scan_Tool</template>
    </alerts>
    <alerts>
        <fullName>Social_Directory_Listings_Queue</fullName>
        <description>CB_Social_Directory_Listing_Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>jacob.casmir@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lindsey.bass@adp.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Case_Opened_AutoNotification_for_AA</template>
    </alerts>
    <fieldUpdates>
        <fullName>AA_Onboarding_Case_Priority</fullName>
        <description>Sets case priority based on problem detail selection.</description>
        <field>Priority</field>
        <literalValue>10-TEN Calendar Days</literalValue>
        <name>AA Onboarding Case Priority</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AA_Onboarding_ProCare_Priority_Default</fullName>
        <description>Sets priority to 30 days.</description>
        <field>Priority</field>
        <literalValue>30-THIRTY Calendar Days</literalValue>
        <name>AA Onboarding ProCare Priority Default</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_Queue_Ad_Operations</fullName>
        <description>Assigns cases with the Ad Operations record type to the Ad Ops Queue.</description>
        <field>OwnerId</field>
        <lookupValue>AdOpsQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign Queue-Ad Operations</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_Queue_Creative_Services</fullName>
        <description>Assign Inquiry - Creative to Creative Services Queue</description>
        <field>OwnerId</field>
        <lookupValue>Creative_Services</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign Queue-Creative Services</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_Queue_IFSCA</fullName>
        <description>Case type &quot;PS Budget Change&quot; sends notifications to both the assigned OMS &amp; DSM and auto assign the case to the Contract Admin queue.</description>
        <field>OwnerId</field>
        <lookupValue>IFSContractAdminQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign Queue-IFSCA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_Queue_Inquiry_Agency_Design</fullName>
        <field>OwnerId</field>
        <lookupValue>Agency_Design_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign Queue-Inquiry - Agency Design</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_Queue_ServiceOpsInquiry</fullName>
        <field>OwnerId</field>
        <lookupValue>ServiceOpsInternalRequests</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign Queue-ServiceOpsInquiry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_Queue_Tier_1</fullName>
        <description>Assign Cases to Tier 1</description>
        <field>OwnerId</field>
        <lookupValue>Tier1Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign Queue-Tier 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_Retail_Insights</fullName>
        <field>OwnerId</field>
        <lookupValue>RetailInsightsQueue281061</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign Retail Insights</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_SalesOpsRecordtype_TypeLeads</fullName>
        <description>Assign SalesOpsRecordtype_TypeLeads</description>
        <field>OwnerId</field>
        <lookupValue>SalesOpsMarketingLead</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign SalesOpsRecordtype_TypeLeads</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_Accounts_Receivable</fullName>
        <field>OwnerId</field>
        <lookupValue>AccountReceivablesQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to Accounts Receivable</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_Accounts_Receivable_Prod_Code</fullName>
        <description>Update the case owner to Accounts Receivable Queue</description>
        <field>OwnerId</field>
        <lookupValue>AccountReceivablesQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to Accounts Receivable Prod Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_Service_Ops_Support_Admin_Q</fullName>
        <field>OwnerId</field>
        <lookupValue>ServiceOpsInternalRequests</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to Service Ops- Support Admin Q</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AutoUpdate_to_IFS_DI_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>SalesOperationsSpecialistQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>AutoUpdate to SalesOps Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AutoUpdate_to_SalesOpsSpecialist</fullName>
        <description>AutoUpdate to SalesOpsSpecialist</description>
        <field>OwnerId</field>
        <lookupValue>SalesOperationsSpecialistQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>AutoUpdate to SalesOpsSpecialist</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Auto_Assign_Case_to_KM_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>ServicesKnowledgeManagementQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Auto Assign Case to KM Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BZ_Cancellation_Task_Assign</fullName>
        <description>Auto Assign to the IFS Contract Admin queue 5 days after the Date Form Received field is filled out.</description>
        <field>OwnerId</field>
        <lookupValue>IFSContractAdminQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BZ Cancellation Task Assign</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_AssignEnhancementCasetoContractAdmin</fullName>
        <field>OwnerId</field>
        <lookupValue>IFSContractAdminQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CB_AssignEnhancementCasetoContractAdmin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_CSI_Sent_Date_Update</fullName>
        <field>CSI_Sent_Date__c</field>
        <formula>Today()</formula>
        <name>CB_CSI_Sent_Date_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Clear_AuditCheckbox</fullName>
        <description>Uncheck the audit checkbox.</description>
        <field>Audited__c</field>
        <literalValue>0</literalValue>
        <name>CB_Clear_AuditCheckbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Cust_Data_Billing_Address_Request</fullName>
        <description>When a Customer Data Billing address case is created, auto assign to the Account Receivables queue.</description>
        <field>OwnerId</field>
        <lookupValue>AccountReceivablesQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CB_Cust_Data_Billing_Address_Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Cust_Data_Collector_Case</fullName>
        <description>Any case created by a collector is assigned to Account Receivables Queue</description>
        <field>OwnerId</field>
        <lookupValue>CustomerDataQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CB_Cust_Data_Collector_Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_IFSCA_UPD_GM_Termination</fullName>
        <field>OwnerId</field>
        <lookupValue>Tier2ETSQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CB_IFSCA_UPD_GM_Termination</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_SVC_Assign_CVS_Support_Cases_to_Tier2</fullName>
        <field>OwnerId</field>
        <lookupValue>Tier2ETSQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CB_SVC_Assign_CVS_Support_Cases_to_Tier2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_SVC_Assign_Queue_Support_Tools</fullName>
        <description>Queue for Inquiry Service Ops cases with Product Category = Support Tools</description>
        <field>OwnerId</field>
        <lookupValue>CB_SVC_ServicesSupportToolsQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CB_SVC_Assign Queue - Support Tools</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_SVC_EDO_Case_Origin_Services</fullName>
        <description>If Case Program = Enhanced Design Options, Set Case Origin = Services to bypass SLA</description>
        <field>Origin</field>
        <literalValue>Services</literalValue>
        <name>CB_SVC_EDO_Case_Origin_Services</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_SVC_EDO_Case_Origin_Type</fullName>
        <description>If Case Program = Enhanced Design Options, Set Case Origin Type = Other to bypass SLA</description>
        <field>Origin_Type__c</field>
        <literalValue>Other</literalValue>
        <name>CB_SVC_EDO_Case_Origin_Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_SVC_FlexStatusIFSEnh</fullName>
        <description>Set Flex Status Default field = &apos;In Queue&apos; when record = IFS - Enhancements, Type = Budget Change, Product Order Category = Flex DAP/PowerBrand</description>
        <field>Flex_Status__c</field>
        <literalValue>In Queue</literalValue>
        <name>CB_SVC_FlexStatusIFSEnh</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_SVS_Assign_Queue_Tier1_CVS_Integratio</fullName>
        <description>Assigns CVS Integration cases created by the Email2Case to the CVS Integration queue. 12-15-2015 - CW</description>
        <field>OwnerId</field>
        <lookupValue>Tier2ETSQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CB_SVS_Assign_Queue_Tier1_CVSIntegration</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Social_Media_Request_Queue</fullName>
        <description>Create a new queue for &quot;Social Media Requests&quot; that includes Jacob Casmir and Gary Weinberg. If the problem code &quot;Deconstruct&quot; is selected have it auto-assign to their queue.</description>
        <field>OwnerId</field>
        <lookupValue>Social_Media_Requests</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CB Social Media Request Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Svc_UPD_CaseOwner</fullName>
        <field>OwnerId</field>
        <lookupValue>IFS_OEM_Initiated_Change_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CB Svc UPD CaseOwner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_UPD_SvcOps_Assign_Queue</fullName>
        <description>WF that assigns any case with “Website Scan Tool” as the problem category to the “Service Ops – Website Scan Tool” queue.</description>
        <field>OwnerId</field>
        <lookupValue>ServiceOpsWebsiteScanTool</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CB_UPD_SvcOps_Assign_Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_UpdateSEOInstructions</fullName>
        <field>Instructions__c</field>
        <formula>&quot;Now that your site has changed domains you need take the following action: &quot;+BR()
+&quot;1. Find the previous domain name within our Webmaster Tools logins and delete that domain.&quot;+BR()+
&quot;2. Add and Verify the new domain within one of our Webmaster Tools logins.&quot;+ BR()+
&quot;3. Ensure the SEO AP in Salesforce is updated with the Webmaster Tools account it is now listed under.&quot;</formula>
        <name>CB_UpdateSEOInstructions</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSI_Sent_Checkbox_Update</fullName>
        <field>CSI_Sent__c</field>
        <literalValue>1</literalValue>
        <name>CSI Sent Checkbox Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Cancel_Task_Assign</fullName>
        <description>Cancel Task Assign</description>
        <field>OwnerId</field>
        <lookupValue>Cancellations</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Cancel Task Assign</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(CaseNumber, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>Case_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_IFS_Domains_Owner</fullName>
        <field>OwnerId</field>
        <lookupValue>IFSDomainsQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change IFS Domains Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Owner_to_IFS_Data_Ops_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>IFSDataOpsQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to IFS Data Ops Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Customer_Data</fullName>
        <field>OwnerId</field>
        <lookupValue>CustomerDataQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Customer Data</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DAPOnb_ONB_AA_Update_PriorityField</fullName>
        <description>Updates the priority field for Onboarding - AA</description>
        <field>Priority</field>
        <literalValue>10-TEN Calendar Days</literalValue>
        <name>DAPOnb_ONB-AA_Update_PriorityField</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_HR_Set_Owner_To_HRQueue</fullName>
        <description>Set the owner of the case (from Email 2 Case) to be owned by an HR Queue</description>
        <field>OwnerId</field>
        <lookupValue>HR_Tier_2_Canada</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>DS_HR_Set_Owner_To_HRQueue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Dealix_Target_Date</fullName>
        <description>Calculate the target date of Dealix Return</description>
        <field>Dealix_Target_Date__c</field>
        <formula>TODAY()+ 60</formula>
        <name>Dealix Target Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Email_2_Case_Records</fullName>
        <field>OwnerId</field>
        <lookupValue>Tier1LexusQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Owner - Tier 1 - Lexus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>GM_PDC_Opt_Out</fullName>
        <field>OwnerId</field>
        <lookupValue>Cancellations</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>GM_PDC_Opt_Out</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFS_Contract_Admin</fullName>
        <field>OwnerId</field>
        <lookupValue>IFSContractAdminQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>IFS - Contract Admin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFS_Contract_Admin1</fullName>
        <field>OwnerId</field>
        <lookupValue>IFSContractAdminQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>IFS - Contract Admin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFS_Custom_Quote_Request_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>IFSCustomQuoteRequestQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>IFS - Custom Quote Request Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFS_Ehancements</fullName>
        <field>OwnerId</field>
        <lookupValue>IFSEnhancementsQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>IFS - Ehancements</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFS_Ehancements2</fullName>
        <field>OwnerId</field>
        <lookupValue>IFSEnhancementsQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>IFS - Enhancements</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFS_FFF</fullName>
        <description>Fight for First</description>
        <field>OwnerId</field>
        <lookupValue>IFS_FFF</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>IFS - FFF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFS_Inventory</fullName>
        <field>OwnerId</field>
        <lookupValue>IFSInventoryQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>IFS - Inventory</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFS_OEM_Initiated_Change_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>IFS_OEM_Initiated_Change_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>IFS - OEM Initiated Change Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFS_Order_Mgmt</fullName>
        <field>OwnerId</field>
        <lookupValue>IFSOrderManagementQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>IFS - Order Mgmt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Inquiry_Services_Reports_Application</fullName>
        <field>OwnerId</field>
        <lookupValue>ServiceOpsApplicationReporting</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Inquiry - Services Reports &amp; Application</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Owner_to_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>ServiceOpsInternalRequests</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Owner to Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sales_Ops_Inquiry_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>SalesOpsMarketingLead</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Sales Ops Inquiry Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sales_Ops_Specialist_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>SalesOperationsSpecialistQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Sales Ops Specialist Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Social_Media_Requests</fullName>
        <field>OwnerId</field>
        <lookupValue>Social_Media_Requests</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Social Media Requests</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Tier_1_Queue</fullName>
        <description>Assign Cases to Tier 1 Queue</description>
        <field>OwnerId</field>
        <lookupValue>Tier1Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Tier 1 Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Tier_1_Reputation_Management_Queue</fullName>
        <description>Assign Cases to Tier 1 - Reputation Management Queue</description>
        <field>OwnerId</field>
        <lookupValue>Tier_1_Reputation_Management</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Tier 1 - Reputation Management Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Tier_2</fullName>
        <field>OwnerId</field>
        <lookupValue>Tier2ETSQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Tier 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Tier_2_Content</fullName>
        <field>OwnerId</field>
        <lookupValue>Tier2ContentQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Tier 2 Content</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Tier_2_ETS_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Tier2ETSQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Tier 2 - ETS Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Resolved_Email_Sent_Date</fullName>
        <description>Update the date/time a resolved email was sent to a dealer/dealer group contact</description>
        <field>Resolved_Email_Sent_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Case Resolved Email Sent Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Dealer_Group_Contact_Email</fullName>
        <field>Dealer_Group_Contact_Email__c</field>
        <formula>Dealer_Group_Contact__r.Email</formula>
        <name>Update Dealer Group Contact Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Finance_Status_In_Progress</fullName>
        <field>Finance_Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Update – Finance Status In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Flex_Status_In_Prog</fullName>
        <field>Flex_Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Update Flex Status In Prog</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Flex_Status_In_Queue</fullName>
        <field>Flex_Status__c</field>
        <literalValue>In Queue</literalValue>
        <name>Update Flex Status In Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Flex_to_0_Status_In_Prog1</fullName>
        <field>Flex_to_0_Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Update Flex to $0 Status In Prog</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Flex_to_0_Status_In_Queue</fullName>
        <field>Flex_to_0_Status__c</field>
        <literalValue>In Queue</literalValue>
        <name>Update Flex to $0 Status In Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_LOE_field</fullName>
        <field>Level_of_Effort__c</field>
        <literalValue>Not Specified</literalValue>
        <name>Update LOE field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Nitra_Alert_Sent</fullName>
        <field>Nitra_Alert_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Update Nitra Alert Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Owner_to_EMS_Design_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>EMSDesignQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Owner to EMS Design Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Owner_to_LMA_Queue</fullName>
        <description>Assign new Inquiry - LMA case to LMA Queue</description>
        <field>OwnerId</field>
        <lookupValue>LMA_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Owner to LMA Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Queue_Stage_Assigned</fullName>
        <field>Queue_Stage__c</field>
        <literalValue>Assigned</literalValue>
        <name>Update Queue Stage - Assigned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Queue_Stage_On_Hold</fullName>
        <field>Queue_Stage__c</field>
        <literalValue>Waiting</literalValue>
        <name>Update Queue Stage - Waiting</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Queue_Stage_Triage</fullName>
        <field>Queue_Stage__c</field>
        <literalValue>Triage</literalValue>
        <name>Update Queue Stage - Triage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Resume_Date</fullName>
        <field>Estimated_Off_Hold_Date__c</field>
        <name>Update Resume Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Target_Date_Time_Null</fullName>
        <description>This changes the Target Date/Time field to Null.</description>
        <field>Target_Date_Time__c</field>
        <name>Update Target Date/Time - Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_fake_last_mod_date</fullName>
        <description>This is for the GM flex migration project to offset a bulk upload we had to do.</description>
        <field>Logged_Date__c</field>
        <formula>NOW()</formula>
        <name>Update fake last mod date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Would_You_Hire_Associate_Action1</fullName>
        <field>Would_You_Hire_Associate_Flag__c</field>
        <literalValue>1</literalValue>
        <name>Would You Hire Associate Action</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_Advocate_email_field</fullName>
        <field>Advocate_Email__c</field>
        <formula>WebID__r.Account_Advocate__r.Email</formula>
        <name>update Advocate email field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AA Email update to case</fullName>
        <actions>
            <name>update_Advocate_email_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow will add the WebId&apos;s Advocate email to the Advocate Email hidden field then send a notification to that email if the case was created by someone besides the Advocate and the record type is either tier 1, 2-ETS or 2-Content</description>
        <formula>IF(   ($RecordType.Name == &apos;Tier 1&apos; ||  $RecordType.Name == &apos;Tier 2 - Content&apos; ||  $RecordType.Name == &apos;Tier 2 - ETS&apos;)   &amp;&amp;    NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp; CreatedBy.FirstName  &amp;  &apos; &apos; &amp; CreatedBy.LastName &lt;&gt;   WebID__r.Account_Advocate__r.FirstName &amp; &apos; &apos; &amp; WebID__r.Account_Advocate__r.LastName  &amp;&amp;   Ispickval( CSI_Type__c , &quot;&quot;)  , True, false)</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Advocate_if_case_is_created_by_someone_that_is_not_the_Advocate</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AA ONB Notification - No Activity 9 days</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 and 6</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding - AA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DAP_Prep_Call_Status__c</field>
            <operation>equals</operation>
            <value>Not Started</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.MAP_Prep_Call_Status__c</field>
            <operation>equals</operation>
            <value>Not Started</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Initial_Optimization_Plan_Call_Status__c</field>
            <operation>equals</operation>
            <value>Not Started</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Notify AA if Onboarding case no activity 9 days after opening</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>AA_Case_notification_for_Onboarding_after_9_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>9</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AA Onboarding DAP priority defaults</fullName>
        <actions>
            <name>AA_Onboarding_Case_Priority</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding - AA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Detail__c</field>
            <operation>equals</operation>
            <value>DAP,ProCare and DAP</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Sets case priority based on problem detail selection. When DAP or Procare/DAP, priority is 10 days.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AA Onboarding ProCare Priority Default</fullName>
        <actions>
            <name>AA_Onboarding_ProCare_Priority_Default</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding - AA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Detail__c</field>
            <operation>equals</operation>
            <value>ProCare</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notEqual</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Sets case priority based on problem detail selection. When ProCare, Priority is 30 days.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert %E2%80%93 New DAP Onboarding</fullName>
        <actions>
            <name>Alert_to_New_Customer_Orders_for_Flex_Budget_Changes</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Enhancements</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Budget Change</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Flex_Budget_Change_Type__c</field>
            <operation>equals</operation>
            <value>$0 to Budget</value>
        </criteriaItems>
        <description>Onboarding alert for 911 budget changes coming through cases</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert Account Team for Fight for First Cases</fullName>
        <actions>
            <name>Alert_to_Account_Team_for_Fight_for_First_Cases</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Fight for First</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert Ad Ops Queue</fullName>
        <actions>
            <name>Alert_Ad_Operations_New_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Ad Operations</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Sends an alert to Ad Ops Queue when a new case is submitted.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert Case Owner New Onboarding Assigned</fullName>
        <actions>
            <name>Alert_Owner_of_New_OnBoarding_Case</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Alert Case Owner New Onboarding Assigned</description>
        <formula>AND( ISPICKVAL(Product_Category__c, &quot;ProCare&quot;) ,          ISPICKVAL(Problem_Code__c , &quot;Onboarding&quot;) ,           IsClosed = FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert DAS - AA DAP ONB Cmpltd OMS on Call</fullName>
        <actions>
            <name>DAS_Notification_of_AA_DAP_ONB_Complete_OMS_on_call</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding - AA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Product_Category__c</field>
            <operation>equals</operation>
            <value>Online Marketing</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Code__c</field>
            <operation>contains</operation>
            <value>DAP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OMS_on_Call__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed as Duplicate</value>
        </criteriaItems>
        <description>Workflow to trigger email notification to DAS when the AA completes the DAP ONB case and the OMS is on the call.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert DAS - AA DAP ONB Completed</fullName>
        <actions>
            <name>Alert_DAS_When_AA_Closes_DAP_OnBoarding_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding - AA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Product_Category__c</field>
            <operation>equals</operation>
            <value>Online Marketing</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Code__c</field>
            <operation>contains</operation>
            <value>DAP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OMS_on_Call__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed as Duplicate</value>
        </criteriaItems>
        <description>Workflow to trigger email notification to DAS when the AA completes the DAP ONB case</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert DLP Support Queue</fullName>
        <actions>
            <name>Alert_to_DLP_Support_Queue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>DLP Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>notEqual</operation>
            <value>Daisha Neville</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert Manager PowerSEO Cancellation Case Created</fullName>
        <actions>
            <name>PowerSEO_Cancellation_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cancellation</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Products_to_Cancel__c</field>
            <operation>includes</operation>
            <value>PowerSEO</value>
        </criteriaItems>
        <description>When a Cancellation Case is created, an email alert is to go out to managers Chris Cunningham and Dana Melick.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert PowerSEO Page Customization Case</fullName>
        <actions>
            <name>Alert_to_SEO_Specialist_Page_Customization_Case_CreatedClosed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Open,Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Product_Category__c</field>
            <operation>equals</operation>
            <value>Website Manager</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Code__c</field>
            <operation>equals</operation>
            <value>Content Changes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Detail__c</field>
            <operation>equals</operation>
            <value>Page Customization</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert SEO %E2%80%93 Inquiry SEO Case Created</fullName>
        <actions>
            <name>Alert_SEO_SEO_Inquiry_Created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>RT Inquiry - SEO: Alerts the SEO Specialist assigned to the account when an SEO - Inquiry case is created except when it is created by Service Ops or the SEO Specialist.</description>
        <formula>AND( $RecordType.Name = &quot;Inquiry - SEO&quot;, NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)), WebID__r.PowerSEO_Product__c =0, $User.Id &lt;&gt; WebID__r.SEO_Specialist__c, $UserRole.Name &lt;&gt; &quot;Service Ops&quot; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Alert SEO %E2%80%93 Redesign Case Created</fullName>
        <actions>
            <name>Alert_SEO_Redesign_Case_Created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Alert SEO Specialist on Account Team for a Website Redesign Case</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c))  &amp;&amp;  OR(  ($RecordType.Name = &apos;Tier 1&apos;),  ($RecordType.Name = &apos;Tier 2 - Content&apos;)  )  &amp;&amp;   OR(  (ISPICKVAL( Problem_Code__c, &apos;Redesign&apos;)),  (ISPICKVAL( Program__c , &apos;Enhanced Design Options&apos;)),  (ISPICKVAL( Problem_Code__c, &apos;EDO Redesign&apos;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert SEO - AA SEO ES ONB Compltd</fullName>
        <actions>
            <name>Alert_SEO_AA_Closed_SEO_Es_ONB_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4) AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding - AA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Detail__c</field>
            <operation>equals</operation>
            <value>SEO Essentials</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Detail__c</field>
            <operation>equals</operation>
            <value>Performance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SEO_Already_has_Info__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Workflow to trigger email notification to SEO when AA Completed the SEO Essential s ONB case and SEO is not on the call.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert SEO - AA when SEO INQ Case Complete</fullName>
        <actions>
            <name>Alert_SEO_AA_when_SEO_INQ_Case_Complete</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Workflow to trigger email notification to SEO &amp; AA when SEO inquiry case completed by the backend SEO or someone who is not the listed SEO on the account.</description>
        <formula>AND(IsClosed = True,  $RecordType.Name = &quot;Inquiry - SEO&quot;,  CASE(Origin_Type__c, &quot;CSI&quot;, &quot;CSI&quot;, &quot;&quot;) &lt;&gt; &quot;CSI&quot;,  OwnerId &lt;&gt; WebID__r.SEO_Specialist__c, (NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert Service Ops Reporting Queue</fullName>
        <actions>
            <name>Alert_Service_Ops_App_Rpt_Queue</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Service Ops - Application/Reporting</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.LastModifiedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Sends an alert to Service Ops reporting when a new case is submitted.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert to AA%2C DSM%2C DAA Ad Spend Increase or Decrease Close</fullName>
        <actions>
            <name>Alert_to_AA_DSM_DAA_for_Ad_Spend_Increase_or_Decrease_Close</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Specific_Product__c</field>
            <operation>equals</operation>
            <value>Ad Spend Increase,Ad Spend Decrease</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Alert to AA, DSM, DAA whenever a case is closed for Ad Spend Increases or Decreases</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert to AA%2C DSM%2C DAA Ad Spend Increase or Decrease Open</fullName>
        <actions>
            <name>Alert_to_AA_DSM_DAA_for_Ad_Spend_Increase_or_Decrease_Close</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Specific_Product__c</field>
            <operation>equals</operation>
            <value>Ad Spend Increase,Ad Spend Decrease</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Alert to AA, DSM, DAA whenever a case is opened for Ad Spend Increases or Decreases</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert to AA%2C DSM%2C DAA PS Ad Spend Change Close</fullName>
        <actions>
            <name>Alert_to_AA_DSM_DAA_for_PS_Ad_Spend_Change_Close</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>PS Budget Change</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Alert to AA, DSM, DAA whenever a case is closed for PS Ad Spend Changes.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert to Account Team for Domains Cases</fullName>
        <actions>
            <name>Alert_to_Account_Team_when_Domain_Case_is_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Product_Category__c</field>
            <operation>equals</operation>
            <value>Domains</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Alert to Account Team when a case is created with the Product Category of Domains.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Alert to Account Team for Resolved Domains Cases</fullName>
        <actions>
            <name>Alert_to_Account_Team_when_Domain_Case_resolved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Product_Category__c</field>
            <operation>equals</operation>
            <value>Domains</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Alert to Account Team when a case is created with the Product Category of Domains and it&apos;s resolved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert to Ad Ops for GM BuySell</fullName>
        <actions>
            <name>Alert_to_Ad_Ops_for_GM_Buy_Sell</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>GM Complete Buy/Sell</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>notContain</operation>
            <value>Stephanie Berchiolly</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert to Ad Ops for GM Name Changes</fullName>
        <actions>
            <name>Alert_to_Ad_Ops_for_GM_Name_Changes</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Name Change</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>equals</operation>
            <value>GM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>notContain</operation>
            <value>Stephanie Berchiolly</value>
        </criteriaItems>
        <description>Alert to Account Team when a GM Name Change Case is closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert to Ad Ops for GM Opt In</fullName>
        <actions>
            <name>Alert_to_Ad_Ops_for_GM_Opt_In</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>GM Opt In</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>notContain</operation>
            <value>Stephanie Berchiolly</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert to Engagement Manager%2C Social</fullName>
        <actions>
            <name>Alert_to_Engagement_Manager_Social_of_Buy_Sell_or_iMR_opt_outs</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Rule to alert Engagement Manager for Social of Buy/Sells and iMR opt outs for GM webIDs</description>
        <formula>$RecordType.Name = &quot;IFS - Contract Admin&quot; &amp;&amp; BEGINS(WebID__r.Name, &quot;gmps&quot;) &amp;&amp; (ISPICKVAL(Type ,&quot;GM iMR Opt Out&quot;)  ||  ISPICKVAL(Type,&quot;GM Termination&quot;) || ISPICKVAL(Type,&quot;GM Complete Buy/Sell&quot;)  || ISPICKVAL(Type, &quot;Customer Buy/Sell&quot;)  || ISPICKVAL(Type,&quot;Dealer Termination&quot;))&amp;&amp;  ISPICKVAL(Status, &quot;Closed&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert to GMMS for GM Address Change</fullName>
        <actions>
            <name>Alert_to_gmms_cobalt_com_for_GM_Address_Changes</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 and 5</booleanFilter>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Address Change</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>includes</operation>
            <value>GM</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>notContain</operation>
            <value>Stephanie Berchiolly</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>Alert to GMMS for GM Address Change</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert to GMMS for GM Domains Cases</fullName>
        <actions>
            <name>Alert_to_GMMS_for_GM_Domains_Cases</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Alert gmms@cobalt.com when a GM case is closed with the Product Category of Domains</description>
        <formula>BEGINS(WebID__r.Name, &quot;gmps&quot;)  &amp;&amp;  ISPICKVAL( Product_Category__c  ,&quot;Domains&quot;) &amp;&amp;  (ISPICKVAL( Problem_Code__c, &quot;Change Primary Domain&quot;) ||    ISPICKVAL( Problem_Code__c, &quot;Purchase New Domain&quot;)  ||  ISPICKVAL( Problem_Code__c, &quot;Release Domain&quot;)  ||  ISPICKVAL( Problem_Code__c, &quot;Change Domain Records (MX/CName/etc)&quot;)) &amp;&amp; ISPICKVAL ( Status, &quot;Closed&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert to GMMS for GM Terminations</fullName>
        <actions>
            <name>Alert_to_GMMS_for_GM_Terminations</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Dealer Termination</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>includes</operation>
            <value>GM</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>contains</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Alert to GMMS for GM Terminations</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert to IFS Manager Data Ops</fullName>
        <actions>
            <name>IFS_Data_Ops_Alert_to_Manager</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Alert_IFS_Manager__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Sends an alert to Richard McNish when an IFS person checks the box.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert to NewCustomerOrder Notifications for Account Moves</fullName>
        <actions>
            <name>Alert_to_NewCustomerOrderNotifications_for_Account_Move</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Contract Admin</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Account Move</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Customer Data Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Alert to NewCustomerOrderNotifications when Account Move case is assigned to Customer Data</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert to NewCustomerOrderNotifications 5 Star Ads Plus-up</fullName>
        <actions>
            <name>Alert_NewCustomerOrderNotifications_for_RM_DAP_5_Star_Ads</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Specific_Product__c</field>
            <operation>equals</operation>
            <value>RM DAP 5 Star Ads</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Alert to NewCustomerOrderNotifications when RM DAP 5 Star Ads Enhancement Case is Closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert to VW Team for VW Terminations</fullName>
        <actions>
            <name>Alert_to_vw_team1</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Cancellation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>includes</operation>
            <value>Volkswagen</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Alert to VW Team for VW  Terminations</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign - BZ Cancellation Queue</fullName>
        <active>true</active>
        <description>Auto Assign to the IFS Contract Admin queue 5 days after the Date Form Received field is filled out.</description>
        <formula>IF(  ( AND(  ($RecordType.Name == &quot;IFS - Contract Admin&quot;),  (ISPICKVAL(Type, &quot;BZ Cancellations&quot;)),  (NOT(ISBLANK( Date_Form_Received__c ))),  (NOT(  OR(  (OwnerId = &quot;00540000001IOgO&quot; ),  (OwnerId= &quot;00540000001IOgc&quot; ),  (OwnerId= &quot;00540000001i3pF&quot; ),  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  (OwnerId= &quot;00540000001IOpZ&quot; ),  (OwnerId= &quot;00540000001IOqj&quot;)))))),  TRUE,FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>BZ_Cancellation_Task_Assign</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Assign - Cancellation Queue</fullName>
        <active>true</active>
        <description>Auto Assign to the Cancellations queue 5 days after the Date Form Received field is filled out.</description>
        <formula>IF( (AND( $RecordType.Name == &quot;Cancellation&quot;, Not(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  ISPICKVAL(Type, &quot;Cancellation&quot;),  NOT(ISBLANK( Date_Form_Received__c )),  (NOT( OR( (OwnerId = &quot;00540000001IOpZ&quot;),  (OwnerId= &quot;00540000001IOea&quot; ),  (OwnerId= &quot;00540000001pIfP&quot; ),  (OwnerId= &quot;00540000001IOpZ&quot; ),  (OwnerId= &quot;00540000001IOgO&quot; ),  (OwnerId= &quot;00540000001IOgc&quot; ),  (OwnerId= &quot;00540000001i3pF&quot; ),  (OwnerId= &quot;00540000001IOhq&quot;) ))) )),  TRUE, FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Cancel_Task_Assign</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Assign - PDC Type to Cancellations</fullName>
        <active>true</active>
        <description>When a GM PDC Opt Out Type is created, or when a record is edited and did not previously meet the rule criteria Auto Assign to the Cancellations queue 1 day after the Date Form Received field is filled out.</description>
        <formula>AND(  $RecordType.Name == &apos;Cancellation&apos;,  ISPICKVAL(Type, &quot;GM PDC Opt Out&quot;),  NOT(ISBLANK( Date_Form_Received__c )),  NOT( OwnerId =&quot;00540000001IOpZ&quot;),  NOT(OwnerId= &quot;00540000001i3pF&quot; ),  NOT(OwnerId= &quot;00540000001IOea&quot; ),  NOT(OwnerId= &quot;00540000001IOhq&quot;),  NOT(OwnerId= &quot;00540000001IOj1&quot; ),  NOT(OwnerId= &quot;00540000001IOgc&quot;),  NOT(OwnerId= &quot;00540000001IOgO&quot; ),  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>GM_PDC_Opt_Out</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Assign - SalesOps-Type Leads to Sales Ops</fullName>
        <actions>
            <name>Assign_SalesOpsRecordtype_TypeLeads</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Sales Operations</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Leads</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Auto assign Sales Operations Record Types with Type &quot;Leads&quot; to Sales Operations Inquiry Queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue - CS Facing Record Type</fullName>
        <actions>
            <name>FYI_to_non_Advantage_users</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Owner_to_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Facing Reporting Issues/Questions</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Automatically assign case to queue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue - Dealix</fullName>
        <actions>
            <name>Tier_2_ETS_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Tier 2 – Dealix</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Detail__c</field>
            <operation>notEqual</operation>
            <value>Source Change</value>
        </criteriaItems>
        <description>Assign Dealix cases to Tier 2 – ETS Queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue - Dealix - Tier 1</fullName>
        <actions>
            <name>Tier_1_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Tier 2 – Dealix</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Code__c</field>
            <operation>equals</operation>
            <value>Imports,Polling</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Detail__c</field>
            <operation>equals</operation>
            <value>Source Change</value>
        </criteriaItems>
        <description>Assign Dealix cases to Tier 1 Queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue - Knowledge Management</fullName>
        <actions>
            <name>Auto_Assign_Case_to_KM_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Inquiry - Svc Ops</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Product_Category__c</field>
            <operation>equals</operation>
            <value>Knowledge Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>WF Rule Auto Assigns Cases that meet the criteria</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue - Network Rep Man</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Inquiry - Network RepMan</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue- Tier 2 - ETS Queue</fullName>
        <actions>
            <name>Tier_2_ETS_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>Cobalt Corporate IT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>GM Termination</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>If Case creator profile is Cobalt Corporate IT and case type is GM Termination, please set rule to assign case to Tier 2 - ETS Queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-Accounts Receivable</fullName>
        <actions>
            <name>Assign_to_Accounts_Receivable</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Inquiry - Finance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-Ad Operations</fullName>
        <actions>
            <name>Alert_Ad_Operations_New_Case_in_Queue</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Assign_Queue_Ad_Operations</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Ad Operations</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-Creative Services</fullName>
        <actions>
            <name>Assign_Queue_Creative_Services</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Inquiry - Creative</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Assign Inquiry - Creative cases to Creative Services Queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-Customer Data</fullName>
        <actions>
            <name>Customer_Data</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Data - Update Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>notEqual</operation>
            <value>Address Change,Billing Address Changes,Name Change</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-EMS Design</fullName>
        <actions>
            <name>Update_Owner_to_EMS_Design_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>EMS - Design</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Routes EMS Case to EMS queue</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-IFS - Data Ops</fullName>
        <actions>
            <name>Change_Owner_to_IFS_Data_Ops_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Data Ops</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-IFS - OEM Initiated Change Queue</fullName>
        <actions>
            <name>IFS_OEM_Initiated_Change_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Assign IFS - Enhancements case record types with case type GM and Non-GM Franchise to the IFS - OEM Initiated Change Queue, Assign Customer Data - Update Request with Type = Name or Address change to IFS - OEM Initiated Change Queue</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; ($RecordType.Name = &quot;IFS - Enhancements&quot; &amp;&amp;    (ISPICKVAL(Type,&quot;GM Franchise&quot;)||     ISPICKVAL(Type,&quot;Non-GM Franchise&quot;))&amp;&amp;    NOT(ISPICKVAL(Product_Order_Category__c,&quot;AMA&quot;))) ||  ($RecordType.Name = &quot;Customer Data - Update Request&quot; &amp;&amp;    $UserRole.Name = &quot;CorpIT&quot; &amp;&amp;   (ISPICKVAL(Type,&quot;Address Change&quot;)||     ISPICKVAL(Type,&quot;Name Change&quot;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-IFS Builders</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Builders</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-IFS CA Flex to Contract Admin</fullName>
        <actions>
            <name>Alert_to_Account_Team_Flex_Change</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IFS_Contract_Admin</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>IFS_Contract_Admin1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If the case is IFS Contract Admin and the type field= Flex Budget Change then the case could go to Enhancements or Contract Admin based on criteria below.</description>
        <formula>And (  $RecordType.Name = &quot;IFS - Contract Admin&quot; ,  Ispickval(Type, &quot;Flex Budget Change&quot;) ,  Contains( Flex_Change_Routing__c , &quot;Contract&quot;) , NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-IFS Contract Admin</fullName>
        <actions>
            <name>IFS_Contract_Admin</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Contract Admin</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>notEqual</operation>
            <value>Holden Termination,PS Budget Change,Flex Budget Change,GM Termination</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-IFS Contract Admin-Enhancement</fullName>
        <actions>
            <name>CB_AssignEnhancementCasetoContractAdmin</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Enhancements</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>GM Fleet/Commercial</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Product_Order_Category__c</field>
            <operation>equals</operation>
            <value>Delete</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-IFS Domains</fullName>
        <actions>
            <name>Change_IFS_Domains_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Domains</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-IFS Enhancements</fullName>
        <actions>
            <name>IFS_Ehancements</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>(($RecordType.Name = &quot;IFS - Enhancements&quot; &amp;&amp;  (NOT(ISPICKVAL(Type,&quot;GM Franchise&quot;))||  NOT(ISPICKVAL(Type,&quot;Non-GM Franchise&quot;))  ))||  ($RecordType.Name = &quot;IFS - Contract Admin&quot; &amp;&amp;  ISPICKVAL(Type,&quot;PS Budget Change&quot;) &amp;&amp;  NOT(ISPICKVAL(Origin,&quot;CSI&quot;))  ))&amp;&amp;  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))&amp;&amp;  NOT(ISPICKVAL(Product_Order_Category__c,&quot;AMA&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-IFS FFF</fullName>
        <actions>
            <name>IFS_FFF</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Fight for First</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notEqual</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Fight for First</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-IFS Inventory</fullName>
        <actions>
            <name>IFS_Inventory</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Inventory</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-IFS Order Mgmt</fullName>
        <actions>
            <name>IFS_Order_Mgmt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 and 5</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Order Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>CB_BZ Migration Outreach</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>notEqual</operation>
            <value>Fight for First</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-Inquiry - Agency Design</fullName>
        <actions>
            <name>Alert_Team_Managers_New_Agency_Design_Case</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Assign_Queue_Inquiry_Agency_Design</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Assign and Alert Inquiry - Agency Design cases to Agency Design Queue</description>
        <formula>$RecordType.Name = &quot;Inquiry - Agency Design&quot; &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-LMA</fullName>
        <actions>
            <name>Update_Owner_to_LMA_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Inquiry - LMA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Routes Inquiry – LMA case to LMA Queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-Reputation Management</fullName>
        <actions>
            <name>Tier_1_Reputation_Management_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Inquiry - RMS</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notEqual</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Assign Inquiry - RMS case record type to Tier 1 - Reputation Management</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-Retail Insights</fullName>
        <actions>
            <name>Assign_Retail_Insights</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Data - Update Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>WebID Primary Audit Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Routes Customer Data case with Type of WebID Primary Audit Request to Retail Insights queue.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-Sales Operations Specialist Queue</fullName>
        <actions>
            <name>Sales_Ops_Specialist_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Sales Operations</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Website Downgrade,GM Opt In</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-Sales Ops Inquiry</fullName>
        <actions>
            <name>Sales_Ops_Inquiry_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Sales Operations</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>New Dealership Notification</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-ServiceOpsInquiry</fullName>
        <actions>
            <name>IFS_OEM_Initiated_Change_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Data - Update Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>CorpIT</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Address Change,Name Change</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-Tier 2</fullName>
        <actions>
            <name>Tier_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2 AND 3)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Tier 2 - ETS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Queue-Tier 2 Content</fullName>
        <actions>
            <name>Tier_2_Content</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(BEGINS($User.Username,$Setup.GlobalSettings__c.Admin_Integration_Username__c)),  NOT($Profile.Name=&quot;Cobalt Service Data Exporting&quot;),  RecordType.Name = &quot;Tier 2 - Content&quot;,  NOT(ISPICKVAL(Origin,&quot;CSI&quot;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign to Accounts Receivable Prod Code</fullName>
        <actions>
            <name>Assign_to_Accounts_Receivable_Prod_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the case owner to Accounts Receivable Queue</description>
        <formula>$RecordType.Name = &quot;IFS - Enhancements&quot; &amp;&amp;  ISPICKVAL(Product_Order_Category__c,&quot;AMA&quot;) &amp;&amp;  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BB_Srv_Assign Queue-Inquiry - Agency Design</fullName>
        <active>false</active>
        <description>Assign and Alert Inquiry - Agency Design cases to Agency Design Queue</description>
        <formula>$RecordType.Name = &quot;Inquiry - Agency Design&quot; &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BuySell Case Notification</fullName>
        <actions>
            <name>BuySell_Created_Notification_to</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 or 2) and 3</booleanFilter>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Customer Buy/Sell</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>GM Complete Buy/Sell</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB Alert Nicole Jones when a %22budget%22 case is closed</fullName>
        <actions>
            <name>CB_Alert_to_Nicole_Jones_for_Budget_Change_Close</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Enhancements</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Budget Change</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Product_Order_Category__c</field>
            <operation>equals</operation>
            <value>Flex DAP/PowerBrand</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>Notify Nicole Jones when a &quot;IFS - Enhancements&quot; case is closed and has Type &quot;Budget Change&quot; and Product Order Category &quot;Flex DAP/PowerBrand&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB Assign Queue - Social Media Requests</fullName>
        <actions>
            <name>CB_Social_Media_Request_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If the problem code &quot;Deconstruct&quot; is selected have it auto-assign to the queue for &quot;Social Media Requests&quot; that includes Jacob Casmir and Gary Weinberg.</description>
        <formula>AND( RecordTypeId = &quot;01240000000ICTs&quot;, CASE(Problem_Code__c, &quot;Deconstruct&quot;, &quot;Deconstruct&quot; , &quot; &quot;) = &quot;Deconstruct&quot;, NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB CXL - Alert Account Team Nitra Date</fullName>
        <actions>
            <name>Alert_Acct_Team_Nitra_Due_Date</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Nitra_Alert_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@cdk.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cancellation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Nitra_Date_Approaching__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Nitra_Alert_Sent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Products_to_Cancel__c</field>
            <operation>includes</operation>
            <value>Audience Management Package,Website,GM Performance Solution</value>
        </criteriaItems>
        <description>Alert the Account Team 2 days before the Nitra cancellation Date.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB SVC Alert - Strategist Inquiry - LMA</fullName>
        <actions>
            <name>CB_SVC_EML_Alert_the_Strategist_when_Inquiry_LMA_case_is_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>An Inquiry – LMA Opt-In case has been created please alert the Strategist</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c))&amp;&amp;  $RecordType.Name = &quot;Inquiry - LMA&quot; &amp;&amp; ISPICKVAL(Problem_Detail__c, &quot;Opt-In&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB SVC Alert DAA Onboarding - OMS</fullName>
        <actions>
            <name>CB_SVC_Alert_DAA_when_DAS_is_assigned_to_Onboarding_OMS_case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email notification DAA Analyst when an onboarding case is assigned to a DAA Strategist</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c))&amp;&amp;  NOT($Profile.Name=&quot;Cobalt Service Data Exporting&quot;) &amp;&amp;  $RecordType.Name = &quot;Onboarding - OMS&quot; &amp;&amp;  (ISCHANGED (OwnerId ) &amp;&amp;  PriorValue(OwnerId ) = &quot;00G40000001L7eo&quot;) &amp;&amp;  /*OMS Queue*/    (NOT(ISBLANK (WebID__r.Digital_Advertising_Strategist__c ))&amp;&amp;  NOT(ISBLANK ( WebID__r.Online_Marketing_Specialist__c )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB SVC Alert to IFS Enhancement Budget Changes</fullName>
        <actions>
            <name>Alert_to_Account_Team_Flex_Change</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Alert_to_Joan_Studley_for_Flex_Budget_Changes</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Alert to Joan Studley and Account Team for IFS Enhancement Budget Changes</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c))&amp;&amp; $RecordType.Name = &quot;IFS - Enhancements&quot;&amp;&amp; ISPICKVAL(Type, &quot;Budget Change&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB SVC Assign IFS - Custom Quote Request Queue</fullName>
        <actions>
            <name>IFS_Custom_Quote_Request_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Assign Custom Quote Request cases to IFS - Custom Quote Request Queue</description>
        <formula>$RecordType.Name = &quot;IFS - Custom Quote Request&quot; &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB SVC Assign Queue-IFS Enhancements Queue</fullName>
        <actions>
            <name>IFS_Ehancements2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When case record type is IFS - Enhancements route valid case types to the IFS - Enhancements Queue. Valid Types are all, but Budget Change &amp; Product Order Category not equal to AMA, and not GM or Non-GM Franchise.</description>
        <formula>AND($RecordType.Name = &quot;IFS - Enhancements&quot;,  OR(  ISPICKVAL(Type, &quot;Enhancement Products&quot;),  ISPICKVAL(Type, &quot;GM Fleet/Commercial&quot;),  ISPICKVAL(Type, &quot;VW Service Xpress&quot;),  AND(ISPICKVAL(Type, &quot;Budget Change&quot;),  NOT(ISPICKVAL( Product_Order_Category__c , &quot;AMA&quot;)))  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB SVC Email Transition AA Change</fullName>
        <actions>
            <name>CB_Transition_Advocate_Change</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When problem code is AA and a name is populated in the “Transitioning To” field an email notification is sent to the AA and a variety of Account Team recipients.
1. Case Owner
2. Transitioning From
3. Transitioned To</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c))&amp;&amp; $RecordType.Name = &quot;Transition - Account Assignment&quot; &amp;&amp; (Transitioning_To__c &lt;&gt;&quot;&quot;) &amp;&amp; ISPICKVAL( Problem_Code__c, &quot;Account Advocate&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB SVC Email Transition DAA Change</fullName>
        <actions>
            <name>CB_Email_Transition_DAA_Change</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When problem code is DAA and a name is populated in the “Transitioning To” field an email notification is sent to the DAA and a variety of recipients.
1. Case Owner
2. Transitioning From
3. Transitioned To</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c))&amp;&amp; $RecordType.Name = &quot;Transition DAA - Account Assignment&quot; &amp;&amp;    (Transitioning_To__c &lt;&gt;&quot;&quot;) &amp;&amp; ISPICKVAL( Problem_Code__c, &quot;Digital Advertising Analyst&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB Svc Alert IFS - OEM Initiated Change Queue</fullName>
        <actions>
            <name>Alert_to_IFS_Team_for_IFS_OEM_Initiated_Change_cases</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Alert team of OEM initiated cases based on case ownership: IFS - OEM Initiated Changes Queue</description>
        <formula>IsClosed = FALSE &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp; OwnerId  = &quot;00G33000002EbNr&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB Svc EML Manager Review is checked for Lexus Case</fullName>
        <actions>
            <name>EML_CB_Svc_Lexus_Case_Needs_Manger_Review</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When a Lexus case and Manager Review box is checked, send email notification to Dana Cristialli &amp; Kim McClure</description>
        <formula>AND(BEGINS(WebID__r.Name, &quot;lex&quot;), Manager_Review__c = TRUE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_CSI_CANADA-French</fullName>
        <actions>
            <name>CB_CSI_French_Survey_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CB_CSI_Sent_Date_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CSI_Sent_Checkbox_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(Contains(Account.Name,&quot;Sandbox&quot;))&amp;&amp;  CSI_Sent__c = FALSE &amp;&amp;  OR( (CONTAINS( WebID__r.OEM__c, &quot;GM Canada&quot;)),  AND (  (NOT(CONTAINS( WebID__r.OEM__c, &quot;LEXUS&quot;))) &amp;&amp; (Account.ShippingCountry = &apos;CA&apos;) ) )   &amp;&amp;   ISPICKVAL(CSI_Type__c, &quot;&quot;) &amp;&amp; ISPICKVAL(Origin_Type__c, &quot;INB-Customer&quot;) &amp;&amp; NOT(ISPICKVAL(Status, &quot;Closed as Duplicate&quot;))&amp;&amp;  OR((ISPICKVAL(Origin, &quot;Email&quot;)), (ISPICKVAL(Origin, &quot;Phone&quot;)), (ISPICKVAL(Origin, &quot;VMail&quot;)), (ISPICKVAL(Origin, &quot;Email – Lexus&quot;))) &amp;&amp;  OR(  NOT(CONTAINS (Subject, &quot;VIP&quot;)),  NOT(CONTAINS (Subject, &quot;IPP&quot;)),  NOT(CONTAINS (Subject, &quot;LDP&quot;))  ) &amp;&amp; OR(( RecordTypeId = &apos;01240000000ICU7&apos;), ( RecordTypeId = &apos;01240000000ICU6&apos;), ( RecordTypeId = &apos;01240000000ICTa&apos;)) &amp;&amp;  Contact.CSIOptOut__c = false &amp;&amp;  ispickval(Status, &quot;Closed&quot;) &amp;&amp; OR(  (ParentId = &quot;&quot;),  (Ispickval(Parent.Status, &quot;Closed&quot;))  ) &amp;&amp; OR( (Today() - Contact.Most_Recent_CSI_Sent_Date__c &gt; 30 &amp;&amp; NOT(isnull(Contact.Most_Recent_CSI_Sent_Date__c ))),   (isnull(Contact.Most_Recent_CSI_Sent_Date__c)   ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_CSI_CANADA-French - 7 Days with No Response</fullName>
        <active>true</active>
        <formula>CSI_Sent__c = True &amp;&amp;  ResponseDate__c = Null &amp;&amp;    NOT(Contains(WebID__r.OEM__c, &quot;Lexus&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CANADA_French_Satisfaction_Survey_Reminder</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CB_CSI_GM_et_All</fullName>
        <actions>
            <name>CB_CSI_GM_et_All_Survey_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CB_CSI_Sent_Date_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CSI_Sent_Checkbox_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(Contains(Account.Name,&quot;Sandbox&quot;))&amp;&amp;  CSI_Sent__c = FALSE &amp;&amp;  NOT(CONTAINS( WebID__r.OEM__c, &quot;Lexus&quot;)) &amp;&amp;  NOT(Contains(WebID__r.OEM__c, &quot;GM Canada&quot;))  &amp;&amp; NOT(Contains(WebID__r.OEM__c, &quot;Holden NZ&quot;))  &amp;&amp; NOT(Account.CBLTShipCountry__c = &apos;CA&apos;)     &amp;&amp; ISPICKVAL(CSI_Type__c, &quot;&quot;) &amp;&amp; ISPICKVAL(Origin_Type__c, &quot;INB-Customer&quot;) &amp;&amp; NOT(ISPICKVAL(Status, &quot;Closed as Duplicate&quot;))&amp;&amp;  OR((ISPICKVAL(Origin, &quot;Email&quot;)), (ISPICKVAL(Origin, &quot;Phone&quot;)), (ISPICKVAL(Origin, &quot;VMail&quot;)), (ISPICKVAL(Origin, &quot;Email – Lexus&quot;))) &amp;&amp;  OR(  NOT(CONTAINS (Subject, &quot;VIP&quot;)),  NOT(CONTAINS (Subject, &quot;IPP&quot;)),  NOT(CONTAINS (Subject, &quot;LDP&quot;))  ) &amp;&amp; OR(( RecordTypeId = &apos;01240000000ICU7&apos;), ( RecordTypeId = &apos;01240000000ICU6&apos;), ( RecordTypeId = &apos;01240000000ICTa&apos;)) &amp;&amp;  Contact.CSIOptOut__c = False &amp;&amp;  ispickval(Status, &quot;Closed&quot;) &amp;&amp;  OR(  (ParentId = &quot;&quot;),  (Ispickval(Parent.Status, &quot;Closed&quot;))  ) &amp;&amp;  OR( (Today() - Contact.Most_Recent_CSI_Sent_Date__c &gt; 30 &amp;&amp; NOT(isnull(Contact.Most_Recent_CSI_Sent_Date__c ))),   (isnull(Contact.Most_Recent_CSI_Sent_Date__c)   ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_CSI_GM_et_All - 7 Days with No Response</fullName>
        <active>true</active>
        <formula>CSI_Sent__c = True &amp;&amp;  ResponseDate__c = Null &amp;&amp;    NOT(CONTAINS( WebID__r.Name, &quot;lex-&quot;)) &amp;&amp;   NOT(Contains(WebID__r.OEM__c, &quot;GM Canada&quot;))  &amp;&amp;  NOT(Contains(WebID__r.OEM__c, &quot;Holden NZ&quot;))  &amp;&amp;  NOT(Account.CBLTShipCountry__c = &apos;CA&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CB_CSI_GM_et_ALL_7_Days_with_No_Response</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CB_CSI_Lexus</fullName>
        <actions>
            <name>CB_CSI_Lexus_Survey_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CB_CSI_Sent_Date_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CSI_Sent_Checkbox_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(Contains(Account.Name,&quot;Sandbox&quot;))&amp;&amp;  CSI_Sent__c = FALSE &amp;&amp; CONTAINS( WebID__r.Name, &quot;lex-&quot;) &amp;&amp; ISPICKVAL(CSI_Type__c, &quot;&quot;) &amp;&amp; ISPICKVAL(Origin_Type__c, &quot;INB-Customer&quot;) &amp;&amp; NOT(ISPICKVAL(Status, &quot;Closed as Duplicate&quot;))&amp;&amp;  OR((ISPICKVAL(Origin, &quot;Email&quot;)), (ISPICKVAL(Origin, &quot;VMail&quot;)), (ISPICKVAL(Origin, &quot;Phone&quot;)), (ISPICKVAL(Origin, &quot;Email – Lexus&quot;))) &amp;&amp;  OR(  NOT(CONTAINS (Subject, &quot;VIP&quot;)),  NOT(CONTAINS (Subject, &quot;IPP&quot;)),  NOT(CONTAINS (Subject, &quot;LDP&quot;))  )&amp;&amp; OR(( RecordTypeId = &apos;01240000000ICU7&apos;), ( RecordTypeId = &apos;01240000000ICU6&apos;), ( RecordTypeId = &apos;01240000000ICTa&apos;)) &amp;&amp;  Contact.CSIOptOut__c = False &amp;&amp;  Ispickval(Status, &quot;Closed&quot;) &amp;&amp;  OR(  (ISBLANK(ParentId)),  (Ispickval(Parent.Status, &quot;Closed&quot;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Case.ResponseDate__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CB_CSI_Lexus - 7 Days with No Response</fullName>
        <active>true</active>
        <formula>CSI_Sent__c = True &amp;&amp;  ResponseDate__c = Null &amp;&amp;    Contains(WebID__r.OEM__c, &quot;Lexus&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Lexus_eCare_Satisfaction_Survey_Reminder</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CB_Cancellation_EmlNot_HMA_Case_Created</fullName>
        <actions>
            <name>Hyundai_Case_notifies_Suzanna_Casteneda_and_Joshua_Brosnan</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify Suzanne Casteneda  when Hyundai cases are created (Termination, Buy/Sell, or New Dealer Notification)</description>
        <formula>or(CONTAINS( UPPER( WebID__r.Name), &quot;HYUN&quot;) &amp;&amp; ISPICKVAL(  Type,&quot;Dealer Termination&quot;),  (ISPICKVAL(Type,&quot;New Dealership Notification&quot;)) &amp;&amp; (CONTAINS(Description,&quot;Hyundai&quot;)),  (ISPICKVAL(Type,&quot;Customer Buy/Sell&quot;)) &amp;&amp; (CONTAINS(Description,&quot;Hyundai&quot;)))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB_Cncl_EML_Notif_to_VWDMS_DAP_or_Procare_Cancellation</fullName>
        <actions>
            <name>CB_Cncl_Notification_to_VW_DMS_Team_for_DAP_or_ProCare_Cancellation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notification to the VW DMS team when VW DAP or ProCare case is created.</description>
        <formula>$RecordType.Name = &quot;Cancellation&quot; &amp;&amp; CONTAINS( WebID__r.Name, &quot;vw-&quot;) &amp;&amp; NOT(ISPICKVAL(Status, &quot;Booked&quot;)) &amp;&amp; OR( (INCLUDES( Products_to_Cancel__c , &quot;DAP Email&quot;)), (INCLUDES( Products_to_Cancel__c , &quot;ProCare&quot;)), (INCLUDES( Products_to_Cancel__c , &quot;DAP&quot;))) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_Cncl_EML_Notif_to_VWDMS_DAP_or_Procare_Cancellation_when_Status_is_Booked</fullName>
        <actions>
            <name>CB_Cncl_Notification_to_VW_DMS_Team_for_DAP_or_ProCare_Cancellation_status_Booke</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notification to the VW DMS team when VW DAP or ProCare case is in booked status.</description>
        <formula>$RecordType.Name = &quot;Cancellation&quot; &amp;&amp; CONTAINS( WebID__r.Name, &quot;vw-&quot;) &amp;&amp; ISPICKVAL(Status, &quot;Booked&quot;) &amp;&amp;  OR( (INCLUDES( Products_to_Cancel__c , &quot;DAP Email&quot;)), (INCLUDES( Products_to_Cancel__c , &quot;ProCare&quot;)), (INCLUDES( Products_to_Cancel__c , &quot;DAP&quot;))) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_CustData_Case_Created_Notification</fullName>
        <actions>
            <name>CB_CustData_Case_Created_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Customer Data Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Last_Modified_Age__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>This WF generates an email to AJ Soysouvahn and Amit Dwivedi any time a customer data case of any kind is created.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_Cust_Data_Billing_Address_Request</fullName>
        <actions>
            <name>CB_Cust_Data_Billing_Address_Request</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Billing Address Changes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Data - Update Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Title</field>
            <operation>equals</operation>
            <value>Collector</value>
        </criteriaItems>
        <description>When a Customer Data Billing Address change is requested auto assign the case to the Account Receivables queue.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB_Cust_Data_Collector_Case</fullName>
        <actions>
            <name>CB_Cust_Data_Collector_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.Title</field>
            <operation>notEqual</operation>
            <value>Collector</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Data - Update Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Billing Address Changes</value>
        </criteriaItems>
        <description>Any Billing Address Change case not created by a collector is assigned to Customer Data queue</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB_EML_Alert_PowerBrandCase</fullName>
        <actions>
            <name>CB_EML_PowerBrandCaseOpened</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Inquiry - Creative</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Code__c</field>
            <operation>equals</operation>
            <value>Power Brand</value>
        </criteriaItems>
        <description>Alert EMS to Power Brand case creation</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_EML_Buy-Sell-Notification</fullName>
        <actions>
            <name>CB_EML_Buy_Sell_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>contains</operation>
            <value>Buy/Sell</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Email Notification to Debbie Baker upon Buy/Sell case creation</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_Finance_Case_Closed</fullName>
        <actions>
            <name>CB_Finance_Case_Closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Contract Admin,Inquiry - Finance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>equals</operation>
            <value>Maureen Meier,Cameron Wong,Charon MacDonald,Judy Kennedy,Grace Mendoza,Elrene Young,Martha DeMoss,Alyssa Zuniga</value>
        </criteriaItems>
        <description>WF to send an email to Finance</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_GMChngRqst_Lost</fullName>
        <actions>
            <name>Alert_Account_Team_lost_GM_DMP_case</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>GM DMP Solution Change Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed - Lost</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_GMChngRqst_Opened</fullName>
        <actions>
            <name>Alert_Account_Team_New_GM_DMP_case</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>GM DMP Solution Change Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB_GMChngRqst_Saved</fullName>
        <actions>
            <name>Alert_Account_Team_saved_GM_DMP_case</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>GM DMP Solution Change Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed - Saved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_IFSCA_BZ_Cancellation_Closed</fullName>
        <actions>
            <name>CB_IFSCA_BZ_Cancellation_Closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Contract Admin</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>BZ Cancellations</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_IFSCA_BZ_Cancellation_Created</fullName>
        <actions>
            <name>CB_IFSCA_BZ_Cancellation_Created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Contract Admin</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>BZ Cancellations</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB_IFSCA_BudgetEndDate_is_Reached</fullName>
        <active>false</active>
        <description>Date field that if in the future will automatically open a task for the case owner when the date is reached.</description>
        <formula>$RecordType.Name == &quot;IFS - Contract Admin&quot; /* Record type: IFS - Contract Admin */ &amp;&amp; NOT( ISBLANK( Budget_End_Date__c ))   /*012A00000005Ylq*/ &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Budget_End_Date_for_case_is_today1</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Budget_End_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CB_IFSCA_BudgetStartDate_is_Reached</fullName>
        <active>false</active>
        <description>Date field that if in the future will automatically open a task for the case owner when the date is reached.</description>
        <formula>$RecordType.Name == &quot;IFS - Contract Admin&quot;    /* Record type: IFS - Contract Admin */ &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Budget_Start_Date_for_case_is_today1</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Case.Budget_Start_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CB_IFSCA_EML_Snd_to_DS_for_BS_Term_New_Dealer</fullName>
        <actions>
            <name>CB_IFSCA_EML_Snd_to_DS_New_Dealer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>New Dealership Notification</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>equals</operation>
            <value>AJ Soysouvanh,Cameron Wong</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Notification to DS for New Dealer</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_IFSCA_EML_Snd_to_DS_for_Buy_Sell</fullName>
        <actions>
            <name>CB_IFSCA_EML_Snd_to_DS_Buy_Sell</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>GM Complete Buy/Sell,Customer Buy/Sell</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assumption_Approved__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>equals</operation>
            <value>AJ Soysouvanh,Cameron Wong</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Notification to DS for BuySell</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_IFSCA_EML_Snd_to_DS_for_Termination</fullName>
        <actions>
            <name>CB_IFSCA_EML_Snd_to_DS_Termination</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Dealer Termination,GM Termination</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>equals</operation>
            <value>AJ Soysouvanh,Cameron Wong</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notEqual</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Notification to DS for Termination</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_IFSCA_EML_UPD_Budget_Change</fullName>
        <actions>
            <name>CB_IFSCA_EML_Snd_to_OMS_DMS_when_PS_Budget_Change_Created</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Assign_Queue_IFSCA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>PS Budget Change</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <description>Notification and field update when an IFS Contract Admin of type PS Budget Change is created</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_IFSCA_EmailAlert_Account_Move_Closed</fullName>
        <actions>
            <name>CB_IFSCA_EmailAlert_Account_Move</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 and 4</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Contract Admin</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Account Move</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Alert to the users when an IFS Contract Admin Account Move Case Type is closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_IFSCA_GM_Termination_Case_Created</fullName>
        <actions>
            <name>CB_IFSCA_GM_Termination_Case_Created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>GM Termination</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Email notification to DAPIssue@cobaltgroup.com when GM Termination case is created.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_IFSCA_UPDEML_FlexStatus</fullName>
        <actions>
            <name>Alert_Enhancements_Flex_DAP_Budget_Change</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Flex_Status_In_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This workflow updates the flex status field w/ In queue if the flex budget change type is budget to budget or $0 to budget. This will make the case show up in the Enhancements flex change view.</description>
        <formula>And(  contains( Flex_Change_Routing__c , &quot;Enhance&quot;) ,  $RecordType.Name =&quot;IFS - Contract Admin&quot; ,  Ispickval( Type , &quot;Flex Budget Change&quot;) ,  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_IFSCA_UPD_FinanceStatusInProg</fullName>
        <actions>
            <name>Update_Finance_Status_In_Progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>IFS – Contract Admin RT: Update Finance Status to In Progress if the Status wasn’t already set to completed.</description>
        <formula>AND(     NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),     NOT(ISPICKVAL(Finance_Status__c, &quot;Complete&quot;)),     NOT(ISBLANK( Finance_Owner__c ))    )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_IFSCA_UPD_FlexStatusInProg</fullName>
        <actions>
            <name>Update_Flex_Status_In_Prog</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow will change the Flex Status to In progress when the Enhancement Owner field is populated.</description>
        <formula>And(  Not( ISBLANK( Enhancements_Owner__c ) ),  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_IFSCA_UPD_FlexTo0Status</fullName>
        <actions>
            <name>Update_Flex_to_0_Status_In_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This workflow updates the flex to 0 status field w/ In queue if the flex budget change type is budget to $0.  This will make the case show up in the Enhancements flex change view.</description>
        <formula>And(  contains( Flex_Change_Routing__c , &quot;Contract&quot;) ,  $RecordType.Name =&quot;IFS - Contract Admin&quot; ,  Ispickval( Type , &quot;Flex Budget Change&quot;) , NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_IFSCA_UPD_FlexTo0StatusInProg</fullName>
        <actions>
            <name>Update_Flex_to_0_Status_In_Prog1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  $RecordType.Name = &quot;IFS - Contract Admin&quot;,  Ispickval(Type, &quot;Flex Budget Change&quot;),  PRIORVALUE( OwnerId ) = &quot;00G40000001L7eA&quot;,  Left(OwnerId, 3) = &quot;005&quot;,  NOT(Ispickval ( Flex_to_0_Status__c , &quot;Complete&quot;)) ,  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_IFSCA_UPD_GM_Term_Created</fullName>
        <actions>
            <name>CB_IFSCA_UPD_GM_Termination</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Contract Admin</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Holden Termination,GM Termination</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>When Type=GM Termination or Holden Termination case auto assigns to the Tier 2 - ETS Group</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_IFSEnh_ADP_Lead_Manager</fullName>
        <actions>
            <name>CB_IFSEnh_ADP_Lead_Manager</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Specific_Product__c</field>
            <operation>equals</operation>
            <value>ADP Lead Manager</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Email notification sent to the Account Advocate when the ADP Lead Manager case is selected</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_IFSEnh_ProCare_ONB</fullName>
        <actions>
            <name>Alert_Ops_ProCare_Ready_for_Onboarding</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>IFS Enhancement Case with Product Order Category = ProCare: Sends an alert to Service Ops to create an Onboarding case.</description>
        <formula>AND(           NOT(BEGINS($User.Username, &quot;integration_user@adp.com&quot;)),         $RecordType.Name = &quot;IFS - Enhancements&quot;,         ISPICKVAL(Product_Order_Category__c , &quot;ProCare&quot;),          ISPICKVAL(Status, &quot;Closed&quot;)         )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_Low_CSI_Alert</fullName>
        <actions>
            <name>CB_Low_Score_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>(IsPickVal(Was_issue_resolved_to_your_satisfaction__c, &quot;No&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_OMS_Alert_NewMinorEditCase</fullName>
        <actions>
            <name>CB_OMS_Alert_NewMinorEditCase</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND (2 or 3)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Inquiry - Creative</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Project_Scope_Difficulty__c</field>
            <operation>equals</operation>
            <value>1 - Text Changes Only</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Minor Edit</value>
        </criteriaItems>
        <description>Email to DA Creative Update SME&apos;s for Level 1 or Minor Edit change for Inquiry - Creative case type. This WF was Deactivated per Rob McFarland on 9/30/15</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_ONBSoc_NewTask_Consult</fullName>
        <actions>
            <name>New_Task_Alert_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Social_Consult_Needed</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding - Social</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Initial_Optimization_Plan_Call_Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>Sandbox</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Creates a task and alert that a consultant needs to be assigned to work the account.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_ONB_Social_EML_IntlContact</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding - Social</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Initial_Optimization_Plan_Call_Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Notification to Don Moss and owner if 7 days pass without Initial Contact &amp; Recap = Completed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CB_ONBSocial_EML_InitialContact_Not_marked_Completed</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CB_PrgQ_GMAlert</fullName>
        <actions>
            <name>Alert_GM_Program_Questions</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>And(  RecordType.Name = &quot;Program Question&quot;, (begins( WebID__r.Name ,&quot;gmps-&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_PrgQ_NonGMAlert</fullName>
        <active>false</active>
        <formula>And(  RecordType.Name = &quot;Program Question&quot;,  NOT(begins( WebID__r.Name ,&quot;gmps-&quot;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_RepMan_Cancellation_Notification</fullName>
        <actions>
            <name>CB_RepMan_Cancellation_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cancellation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Products_to_Cancel__c</field>
            <operation>includes</operation>
            <value>Reputation Management</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC Alert Service Ops Inquiry Queue Case</fullName>
        <actions>
            <name>CB_SVC_Alert_Service_Ops_Inquiry_Queue_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Alert Service Ops when case comes into Inquiry - Svc Ops queue</description>
        <formula>AND( NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)), $RecordType.Name = &apos;Inquiry - Svc Ops&apos;, ISCHANGED( OwnerId ), OwnerId = &apos;00G40000001L7f8&apos;, OR( ISPICKVAL( Product_Category__c,&apos;Salesforce Critical Alert&apos;), ISPICKVAL( Product_Category__c,&apos;Onboard Failure&apos;), ISPICKVAL( Product_Category__c,&apos;Services 911&apos;) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_Assign Queue - Support Tools</fullName>
        <actions>
            <name>CB_SVC_Alert_for_Support_Tools_Case</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CB_SVC_Assign_Queue_Support_Tools</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>WF Rule Auto Assigns Inquiry Service Ops Cases with Product Category = Support Tools that meet the criteria</description>
        <formula>AND( NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)), ISPICKVAL(Product_Category__c,&quot;Support Tools&quot;), $RecordType.Name = &quot;Inquiry - Svc Ops&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_BMW_Mini_Cancellation</fullName>
        <actions>
            <name>CB_SVC_BMW_Mini_Cancellation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>BMW and Mini Cancellations notifies Victor Martinez, Eduardo Estrada, Michael Hoagland, DSM, DigitalCancellations@cdk.com</description>
        <formula>AND(  NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)),  $RecordType.Name == &quot;Cancellation&quot;,  OR(  BEGINS(WebID__r.Name, &quot;b1mw&quot;),  BEGINS(WebID__r.Name, &quot;b2mw&quot;),  BEGINS(WebID__r.Name, &quot;mini&quot;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_EDO_Case_Origin_Services</fullName>
        <actions>
            <name>CB_SVC_EDO_Case_Origin_Services</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CB_SVC_EDO_Case_Origin_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Force all Program = Enhanced Design Options to Origin = Services</description>
        <formula>AND( OR ($RecordType.Name = &quot;Tier 1&quot;,     $RecordType.Name = &quot;Tier 2 - ETS&quot;,     $RecordType.Name = &quot;Tier 2 - Content&quot;), ISPICKVAL(Program__c,&quot;Enhanced Design Options&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_EML TS Lead Escalation</fullName>
        <actions>
            <name>CB_SVC_EML_TS_Lead_Escalation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Trigger an email alert when a case is assigned to the case queue Tier 1 - Seniors.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp;  Owner:Queue.QueueName = &quot;Tier 1 - Seniors&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_EML_Kia_Cancellation_Lost</fullName>
        <actions>
            <name>CB_SVC_EML_Kia_Cancellation_Lost</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>For Kia Cancel/Lost Alerts: Cancellation Case Record type, Webid starts with K1ia, and the Status is updated to &quot;Cancel - Lost&quot;, email Melissa Satterwhite and Suzanne Newhouse</description>
        <formula>AND ( NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)), $RecordType.Name = &quot;Cancellation&quot;,  ISPICKVAL(Status,&quot;Closed - Lost&quot;),  BEGINS(WebID__r.Name,&quot;k1ia&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_GM_Resolved_Contact_Dealer</fullName>
        <actions>
            <name>Notification_to_Account_Team_when_case_is_Resolved</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notification_to_Dealer_when_case_is_Resolved</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Case_Resolved_Email_Sent_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>GM Resolved Case Email to Dealer Contact</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp;  WebID__r.OEM__c = &quot;GM&quot; &amp;&amp; Do_Not_Email_on_Resolved__c = FALSE &amp;&amp; ISBLANK( Resolved_Email_Sent_Date__c ) &amp;&amp;    (ISPICKVAL(  Origin_Type__c ,&quot;INB-Customer&quot;) ||    ISPICKVAL( Origin_Type__c ,&quot;&quot;)) &amp;&amp;       (ISPICKVAL( Origin, &quot;Phone&quot;) ||      ISPICKVAL(  Origin, &quot;VMail&quot;) ||      ISPICKVAL(  Origin, &quot;Email&quot;) ||      ISPICKVAL(  Origin, &quot;Email - Lexus&quot;) ) &amp;&amp;  (    (     (ISPICKVAL(Status,&quot;Resolved&quot;) ||       ISPICKVAL(Status,&quot;Resolved Pending Verification&quot;)     ) &amp;&amp;     $RecordType.Name =&quot;Tier 2 - Content&quot; &amp;&amp;     ISPICKVAL(Proof_or_Publish__c, &quot;Publish&quot;)    )      ||   (    (ISPICKVAL(Status,&quot;Resolved&quot;) ||      ISPICKVAL(Status,&quot;Resolved Pending Verification&quot;)     ) &amp;&amp;    ($RecordType.Name = &quot;Tier 1&quot; || $RecordType.Name = &quot;Tier 2 - ETS&quot;)  )  ) &amp;&amp;  ISBLANK(Dealer_Group_Contact__c) &amp;&amp;   ( ( NOT(ISBLANK(Dealer_Group_Name__c)) &amp;&amp;  ISBLANK(ParentId) )   ||  ISBLANK(Dealer_Group_Name__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_GM_Resolved_Contact_DealerGroup</fullName>
        <actions>
            <name>Notification_to_Account_Team_when_case_is_Resolved</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notification_to_Dealer_Group_when_case_is_Resolved</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Case_Resolved_Email_Sent_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>GM Resolved Case Email to Dealer Group Contact</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp;  WebID__r.OEM__c = &quot;GM&quot; &amp;&amp; Do_Not_Email_on_Resolved__c = FALSE &amp;&amp; ISBLANK( Resolved_Email_Sent_Date__c ) &amp;&amp;    (ISPICKVAL(  Origin_Type__c ,&quot;INB-Customer&quot;) ||     ISPICKVAL( Origin_Type__c ,&quot;&quot;)) &amp;&amp;       (ISPICKVAL( Origin, &quot;Phone&quot;) ||      ISPICKVAL(  Origin, &quot;VMail&quot;) ||      ISPICKVAL(  Origin, &quot;Email&quot;) ||      ISPICKVAL(  Origin, &quot;Email - Lexus&quot;) ) &amp;&amp;  (   (    (ISPICKVAL(Status,&quot;Resolved&quot;) || ISPICKVAL(Status,&quot;Closed&quot;)) &amp;&amp;    $RecordType.Name =&quot;Tier 2 - Content&quot; &amp;&amp;    ISPICKVAL(Proof_or_Publish__c, &quot;Publish&quot;)   )   ||    (    (ISPICKVAL(Status,&quot;Resolved&quot;) ||      ISPICKVAL(Status,&quot;Resolved Pending Verification&quot;)      ) &amp;&amp;    ($RecordType.Name =&quot;Tier 1&quot; || $RecordType.Name = &quot;Tier 2 – ETS&quot;)   )   )   &amp;&amp;  NOT(ISBLANK(Dealer_Group_Contact__c)) &amp;&amp;  ( ( NOT(ISBLANK(Dealer_Group_Name__c)) &amp;&amp;  ISBLANK(ParentId) )   ||  ISBLANK(Dealer_Group_Name__c)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_GM_Resolved_Proof_Contact_Dealer</fullName>
        <actions>
            <name>Notification_to_Account_Team_when_case_is_in_Proof</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notification_to_Dealer_when_case_is_in_Proof</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Case_Resolved_Email_Sent_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>GM Proof Case Email to Dealer Contact</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp;  WebID__r.OEM__c = &quot;GM&quot; &amp;&amp; Do_Not_Email_on_Resolved__c = FALSE &amp;&amp; ISBLANK( Resolved_Email_Sent_Date__c ) &amp;&amp; $RecordType.Name =&quot;Tier 2 - Content&quot; &amp;&amp; ISPICKVAL(Proof_or_Publish__c, &quot;Proof&quot;) &amp;&amp;  (ISPICKVAL(Status,&quot;Resolved&quot;) ||    ISPICKVAL(Status,&quot;Resolved Pending Verification&quot;) ) &amp;&amp;   (ISPICKVAL(Origin_Type__c ,&quot;INB-Customer&quot;) ||    ISPICKVAL(Origin_Type__c ,&quot;&quot;)  ) &amp;&amp;     (ISPICKVAL(Origin, &quot;Phone&quot;) ||   ISPICKVAL(Origin, &quot;VMail&quot;) ||   ISPICKVAL(Origin, &quot;Email&quot;) ||   ISPICKVAL(Origin, &quot;Email - Lexus&quot;)  ) &amp;&amp;   ISBLANK(Dealer_Group_Contact__c) &amp;&amp;  ( ( NOT(ISBLANK(Dealer_Group_Name__c)) &amp;&amp;  ISBLANK(ParentId) )  || ISBLANK(Dealer_Group_Name__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_GM_Resolved_Proof_Contact_DealerGroup</fullName>
        <actions>
            <name>Notification_to_Account_Team_when_case_is_in_Proof</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notification_to_Dealer_Group_when_case_is_in_Proof</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Case_Resolved_Email_Sent_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>GM Proof Case Email to Dealer Group Contact</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp;  WebID__r.OEM__c = &quot;GM&quot; &amp;&amp; Do_Not_Email_on_Resolved__c = FALSE &amp;&amp; ISBLANK( Resolved_Email_Sent_Date__c ) &amp;&amp; $RecordType.Name =&quot;Tier 2 - Content&quot; &amp;&amp; ISPICKVAL(Proof_or_Publish__c, &quot;Proof&quot;) &amp;&amp; (   ISPICKVAL(Status,&quot;Resolved&quot;) ||     ISPICKVAL(Status,&quot;Resolved Pending Verification&quot;) ) &amp;&amp;   (ISPICKVAL(Origin_Type__c ,&quot;INB-Customer&quot;) ||    ISPICKVAL(Origin_Type__c ,&quot;&quot;)   ) &amp;&amp;    (ISPICKVAL(Origin, &quot;Phone&quot;) ||    ISPICKVAL(Origin, &quot;VMail&quot;) ||    ISPICKVAL(Origin, &quot;Email&quot;) ||    ISPICKVAL(Origin, &quot;Email - Lexus&quot;)    ) &amp;&amp;   NOT(ISBLANK(Dealer_Group_Contact__c)) &amp;&amp;  ( (NOT(ISBLANK(Dealer_Group_Name__c)) &amp;&amp;  ISBLANK(ParentId))  || ISBLANK(Dealer_Group_Name__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_SVCOpsClosedCaseAlert</fullName>
        <actions>
            <name>SVCOpsClosedCaseAlert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify Service Ops Management when case closes</description>
        <formula>AND(  NOT(BEGINS($User.Username,$Setup.GlobalSettings__c.Admin_Integration_Username__c)),  NOT($Profile.Name=&quot;Cobalt Service Data Exporting&quot;),  $RecordType.Name = &quot;Inquiry - Services Reports &amp; Applications&quot;,  NOT(ISPICKVAL(Category__c,&quot;Mass Record Updates&quot;)),  NOT(ISPICKVAL(Category__c,&quot;User Data Change&quot;)),  ISPICKVAL(Status,&quot;Completed - Closed&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_SpecialProjectAssignment</fullName>
        <actions>
            <name>Alert_Case_Owner_New_Onboarding</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify recipient of Special Project case that it has been assigned to them.</description>
        <formula>AND(NOT(BEGINS($User.Username,$Setup.GlobalSettings__c.Admin_Integration_Username__c)),  NOT($Profile.Name=&quot;Cobalt Service Data Exporting&quot;),   RecordType.Name = &quot;Special Project Support&quot;,   ISPICKVAL(Program__c,&quot;GM Factory Preowned Collection&quot;),   Subject = &quot;GM Factory Pre-owned Collection Cancellation&quot;  )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVS_Assign_Queue_Tier1_CVS_Integration</fullName>
        <actions>
            <name>CB_SVS_Assign_Queue_Tier1_CVS_Integratio</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2 AND 3) and 4</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Tier 1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email - CVS Integration,Email - CVS Support</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_Sales_Hyundai_Cancellation</fullName>
        <actions>
            <name>CB_Sales_Hyundai_Cancellation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>(CONTAINS( WebID__r.Name, &quot;hyun&quot;)) &amp;&amp; OR( (includes(Products_to_Cancel__c, &quot;Website&quot;)), (includes(Products_to_Cancel__c, &quot;ProCare&quot;)) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB_Social_Directory_Listing_Notification</fullName>
        <actions>
            <name>Social_Directory_Listings_Queue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Social Directory Listings Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Email notification to the Social Directory Listings Queue members</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SpecProject_GMFlexLastMod</fullName>
        <actions>
            <name>Update_fake_last_mod_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  OR(  ISPickVal(Program__c,&quot;BG iMR2 Flex Migration&quot;),  ISPickVal(Program__c,&quot;Cadillac iMR2 Flex Migration&quot;),  IsPickVal(Program__c,&quot;GM iMR2 Flex Migration&quot;),  IsPickVal(Program__c,&quot;Multi-Brand iMR2 Flex Migration&quot;)  ),  RecordTypeId = &quot;01240000000ICU4&quot;,  IsChanged( LastModifiedDate ),  Not($Profile.Name = &quot;Cobalt Service Ops Admin&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_AlertFastTrack</fullName>
        <actions>
            <name>Alert_SvcOps_Case_is_Fast_Track</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Alerts BA team when a case is stet to fast track queue stage and case is owned by queue.</description>
        <formula>And ( RecordType.DeveloperName = &apos;Inquiry_Services_Reports_Applications&apos;,  Left(OwnerId,3)=&apos;00G&apos;, IsPickVal( Queue_Stage__c ,&quot;Fast Track&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_AssignToQueueAndAlert</fullName>
        <actions>
            <name>Alert_Service_Ops_App_Rpt_Queue2</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Inquiry_Services_Reports_Application</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Changes owner to Service Ops Application/Reporting when record type is created.</description>
        <formula>And(  RecordType.DeveloperName = &apos;Inquiry_Services_Reports_Applications&apos;,  Isblank( Ops_Owner__c ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_CaseOffWaiting</fullName>
        <actions>
            <name>Update_Queue_Stage_Assigned</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Resume_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates field and sends alert to a hard coded person.</description>
        <formula>AND(  RecordType.DeveloperName = &apos;Inquiry_Services_Reports_Applications&apos;,  IsPickVal(PriorValue(Status),&apos;Waiting&apos;),  Not(IsPickVal(Status,&apos;Waiting&apos;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_OwnerToQueueIsTriage</fullName>
        <actions>
            <name>Update_Queue_Stage_Triage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When Inquiry - Services aps and reports owner changes from person to queue then update queue stage to triage.</description>
        <formula>And(  RecordType.DeveloperName = &apos;Inquiry_Services_Reports_Applications&apos;,  Left(PriorValue( OwnerId ),3)=&apos;005&apos;,  Left(OwnerId,3)=&apos;00G&apos;  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_PlannedDeliveryIsPassed</fullName>
        <active>true</active>
        <description>When Inquiry - service aps and reports planned delivery date has passed then alert the person that owns the case.</description>
        <formula>And(  RecordType.DeveloperName = &apos;Inquiry_Services_Reports_Applications&apos;,  Planned_Delivery_Date__c &gt; TODAY(),  Not( IsPickVal( Status, &quot;Completed - Closed&quot;)),  Not( IsPickVal( Status, &quot;Cancelled - Closed&quot;)),  Not( IsPickVal( Status, &quot;Closed as Duplicate&quot;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Emails_owner_when_the_Planned_Delivery_Date_happens_to_tell_them_it_s_happened</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Planned_Delivery_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CB_SvcOps_QueueStageToWaitingWhenWaiting</fullName>
        <actions>
            <name>Update_Queue_Stage_On_Hold</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Inquiry - Services Reports &amp; Applications</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Waiting</value>
        </criteriaItems>
        <description>When Status is set to waiting in an Inquiry - Services Reports &amp; Applications case then Queue Stage is set to &quot;Waiting&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_QueueToOwnerIsAssigned</fullName>
        <actions>
            <name>Update_Queue_Stage_Assigned</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When Inquiry - Service aps and report owner changes from queue to person then update queue stage to assigned.</description>
        <formula>And(  RecordType.DeveloperName = &apos;Inquiry_Services_Reports_Applications&apos;,  Left(PriorValue( OwnerId ),3)=&apos;00G&apos;,  Left(OwnerId,3)=&apos;005&apos;  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcOps_ResumeDateIsHere</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Estimated_Off_Hold_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Inquiry - Services Reports &amp; Applications</value>
        </criteriaItems>
        <description>Alerts case owner that date to resume is today.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Alert_Inquiry_Service_reports_and_aps_resume_date_is_here</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Estimated_Off_Hold_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CB_SvcTier2Con_UpdateAuditOnReopen</fullName>
        <actions>
            <name>CB_Clear_AuditCheckbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Tier 2 - Content Record Type: Reset the Audit checkbox to unchecked after a case is reopened.</description>
        <formula>AND( $RecordType.Name = &apos;Tier 2 - Content&apos;  ,ISPICKVAL( Status, &quot;Reopened&quot;)  ,NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_Svc_Alert_Lexus_Resp_Migration_Closed_as_Dup</fullName>
        <actions>
            <name>CB_Svc_Alert_DSM_Closed_As_Dup</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Special Project Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Program__c</field>
            <operation>startsWith</operation>
            <value>Lexus Responsive Migration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed as Duplicate</value>
        </criteriaItems>
        <description>Will send an email to the Digital Solutions Manager when a SPS Case that starts with Lexus Responsive is Closed as Duplicate</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_Svc_EML_Ad Ops for VW or Hyundai or MINI or Lexus BuySell</fullName>
        <actions>
            <name>Alert_to_Ad_Ops_for_VW_BuySell</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND (5 or 6 or 7 or 8)</booleanFilter>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Customer Buy/Sell</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>notContain</operation>
            <value>Stephanie Berchiolly</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>includes</operation>
            <value>Hyundai</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>includes</operation>
            <value>Volkswagen</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>includes</operation>
            <value>MINI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>includes</operation>
            <value>Lexus</value>
        </criteriaItems>
        <description>Alert to Ad Ops for Hyundai or VW or MINI or Lexus BuySell</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_Svc_EML_Ad Ops for VW or Hyundai or Mini or Lexus Address Change</fullName>
        <actions>
            <name>Alert_to_Ad_Ops_for_VW_and_Hyundai_Address_Changes</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3 OR 4 or 5) AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Address Change</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>includes</operation>
            <value>Volkswagen</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>includes</operation>
            <value>Hyundai</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>includes</operation>
            <value>MINI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>includes</operation>
            <value>Lexus</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>notContain</operation>
            <value>Stephanie Berchiolly</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Alert to Ad Ops for VW or Hyundai or Mini or Lexus Address Change</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_Svc_EML_Ad Ops for VW or Hyundai or Mini or Lexus Terminations</fullName>
        <actions>
            <name>Alert_to_Ad_Ops_for_VW_Terminations</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3 OR 4 or 5) AND 6</booleanFilter>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Dealer Termination</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>includes</operation>
            <value>Volkswagen</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>includes</operation>
            <value>Hyundai</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>includes</operation>
            <value>MINI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>includes</operation>
            <value>Lexus</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Alert to Ad Ops for VW or Hyundai or Mini or Lexus Terminations</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_Svc_EML_to Ad Ops for Hyundai or VW or Mini or Lexus Name Changes</fullName>
        <actions>
            <name>Alert_to_Ad_Ops_for_VW_and_Hyundai_Name_Changes</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Name Change</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>includes</operation>
            <value>Volkswagen,MINI,Hyundai,Lexus</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>notContain</operation>
            <value>Stephanie Berchiolly</value>
        </criteriaItems>
        <description>Alert to Ad Ops for Hyundai or VW or Mini or Lexus Name Changes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_Svc_EML_to Ad Ops for VW or Hyundai or Mini or Lexus Domains Cases</fullName>
        <actions>
            <name>Alert_to_Ad_Ops_for_Closed_GM_Domain_Cases</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Alert to Ad Ops when a VW or Hyundai or Mini or Lexus case is closed with the Product Category of Domains</description>
        <formula>OR(BEGINS(WebID__r.Name, &quot;vw&quot;),  BEGINS(WebID__r.Name, &quot;hyun&quot;),  BEGINS(WebID__r.Name, &quot;hyundai&quot;) , BEGINS(WebID__r.Name,&quot;mini&quot;) , BEGINS(WebID__r.Name,&quot;lexus&quot;)) &amp;&amp;  ISPICKVAL( Product_Category__c ,&quot;Domains&quot;) &amp;&amp;  (ISPICKVAL( Problem_Code__c, &quot;Change Primary Domain&quot;) ||  ISPICKVAL( Problem_Code__c, &quot;Purchase New Domain&quot;) ||  ISPICKVAL( Problem_Code__c, &quot;Release Domain&quot;) ||  ISPICKVAL( Problem_Code__c, &quot;Change Domain Records (MX/CName/etc)&quot;)) &amp;&amp; ISPICKVAL ( Status, &quot;Closed&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvsIFS_FlexStatusDefault</fullName>
        <actions>
            <name>CB_SVC_FlexStatusIFSEnh</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Enhancements</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Budget Change</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Product_Order_Category__c</field>
            <operation>equals</operation>
            <value>Flex DAP/PowerBrand</value>
        </criteriaItems>
        <description>Set Flex Status Default field = &apos;In Queue&apos; when record = IFS - Enhancements, Type = Budget Change, Product Order Category = Flex DAP/PowerBrand</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB_T1T2_GMRing_Alert</fullName>
        <actions>
            <name>Alert_Service_Accnt_Team_GM_Rings</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Program__c</field>
            <operation>equals</operation>
            <value>Opt Out GM Rings,Opt Out GM Total Confidence,Opt Out GM Love it or Return it</value>
        </criteriaItems>
        <description>Sends alert for program contains &quot;Opt Out GM.&quot;  This is for the GM Ring promotion and can and should be deactivated as of 9/4/2012.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_T1T2_GMRing_Alert_OptIN</fullName>
        <actions>
            <name>Alert_Service_Accnt_Team_GM_Rings_Opt_IN</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Program__c</field>
            <operation>equals</operation>
            <value>Opt IN GM Love it or Return it,Opt IN GM Total Confidence,Opt IN GM Rings</value>
        </criteriaItems>
        <description>Sends alert for program contains &quot;Opt IN GM.&quot;  This is for the GM Ring promotion and can and should be deactivated as of 9/4/2012.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_UPD_SvcOps_Assign_Queue</fullName>
        <actions>
            <name>Service_Ops_Website_Scan_Tool_notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CB_UPD_SvcOps_Assign_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Product_Category__c</field>
            <operation>equals</operation>
            <value>Website Scan Tool</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>WF that assigns any case with “Website Scan Tool” as the problem category to the “Service Ops – Website Scan Tool” queue.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB_UpdateSEOInstructions</fullName>
        <actions>
            <name>CB_UpdateSEOInstructions</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@cdk.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Inquiry - SEO</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Domain</value>
        </criteriaItems>
        <description>For the SEO Inquiry record type, update the instructions field when the case pertains to Domains. This is for use in cases that are cloned from Domains cases (parent case not null).</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cancellation Case Created</fullName>
        <actions>
            <name>Cancellation_Case_Opened</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cancellation</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Products_to_Cancel__c</field>
            <operation>excludes</operation>
            <value>GM Performance Solution</value>
        </criteriaItems>
        <description>When a Cancellation Case is created, an email alert is to go out to the account team.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cancellation Case Created - GM DMP</fullName>
        <actions>
            <name>Cancellation_Case_Opened_GM_DMP</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cancellation</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Products_to_Cancel__c</field>
            <operation>includes</operation>
            <value>GM Performance Solution</value>
        </criteriaItems>
        <description>When GM DMP Cancellation Case is created, an email alert is to go out to the account team.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cancellation Form Received Alert</fullName>
        <actions>
            <name>Send_Cancel_Form_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Date_Form_Received__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cancellation</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Sends a notification to the Account Team and Case Team once the Date Form Received field is filled out.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cancellation Lost Email Flow</fullName>
        <actions>
            <name>Cancellation_Lost_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cancellation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed - Lost</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>When a Case is a Cancellation Record Type and the Status is updated to &quot;Cancel - Lost&quot;, email the Account Team and Case Team.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cancellation Saved Email</fullName>
        <actions>
            <name>Cancellation_Saved_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 and 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cancellation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed - Saved</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Workflow sends an email notification to the Case Team and Account Team when the Status is updated to &quot;Cancellation - Saved&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case - Update Dealer Group Contact Email</fullName>
        <actions>
            <name>Update_Dealer_Group_Contact_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All with Dealer Group Contact: updates the email field associated with the Dealer Group Contact entered on the case.</description>
        <formula>AND(  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  NOT(ISBLANK( Dealer_Group_Contact__c )) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Opened from Email AutoNotification</fullName>
        <actions>
            <name>Case_Opened_from_Email_AutoNotification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email generated to customer when their email has been converted into a case.</description>
        <formula>($RecordType.Name = &quot;Tier 1&quot; || $RecordType.Name = &quot;Tier 2 -Content&quot;) &amp;&amp;  ( NOT ( contains( WebID__r.Name, &quot;holden-&quot;))) &amp;&amp; ISPICKVAL ( Origin, &quot;Email&quot;)  &amp;&amp; ISPICKVAL ( Origin_Type__c , &quot;INB-Customer&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Opened from Email AutoNotification-GM Dig Rep</fullName>
        <actions>
            <name>Case_Creation_Email_Notification_GMRep</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Assign_Queue_Tier_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email - GMRep</value>
        </criteriaItems>
        <description>Email generated to GM Digital Rep when their email has been converted into a case.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Opened from Email AutoNotification-Holden</fullName>
        <actions>
            <name>Case_Opened_From_Email_AutoNotification_Holden</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email generated to Holden customer when their email has been converted into a case.</description>
        <formula>($RecordType.Name = &quot;Tier 1&quot;  || $RecordType.Name =  &quot;Tier 2 - Content&quot;) &amp;&amp; BEGINS( WebID__r.Name, &quot;holden&quot;) &amp;&amp; ISPICKVAL ( Origin, &quot;Email&quot;) &amp;&amp; ISPICKVAL ( Origin_Type__c , &quot;INB-Customer&quot;)  &amp;&amp;    NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case_Set_Migration_ID</fullName>
        <actions>
            <name>Case_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Cisco Alert</fullName>
        <actions>
            <name>Cisco_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Inquiry - Svc Ops</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Product_Category__c</field>
            <operation>equals</operation>
            <value>Cisco/Calabrio</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Alert for when a Case is created for Service Ops with Cisco as the Product.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Customer Data 911 Notification</fullName>
        <actions>
            <name>Customer_Data_911_Field_Checked</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Customer_Data_911__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Data - Update Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Customer Followup Email Received</fullName>
        <actions>
            <name>Inbound_Response_Received</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This sends an email to the Case Owner.</description>
        <formula>(IsClosed  = False) &amp;&amp; (Emails_Received_Count__c  &gt; 1) &amp;&amp; ischanged(Emails_Received_Count__c) &amp;&amp; not(Isblank(Owner_Lookup__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DAP Cancellation Case Created</fullName>
        <actions>
            <name>Alert_for_RDMM_for_DAP_cancellation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When a DAP Cancellation Case is created, an email alert is to go out to the Regional Digital Marketing Managers (RDMM&apos;s)</description>
        <formula>$RecordType.Name = &quot;Cancellation&quot; &amp;&amp;    CONTAINS( WebID__r.Name, &quot;gmps-&quot;)  &amp;&amp;  (INCLUDES( Products_to_Cancel__c , &quot;DAP&quot;)  ||  INCLUDES(Products_to_Cancel__c , &quot;DAP Email&quot;)) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DAP_OnBoardingAA_Update_PriorityField</fullName>
        <actions>
            <name>DAPOnb_ONB_AA_Update_PriorityField</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 and (3 or 4 or 5 or 7) and 6 and 8</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding - AA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Product_Category__c</field>
            <operation>equals</operation>
            <value>Online Marketing</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Code__c</field>
            <operation>equals</operation>
            <value>DAP - New Car Subscription</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Code__c</field>
            <operation>equals</operation>
            <value>DAP - Used Car Subscription</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Code__c</field>
            <operation>equals</operation>
            <value>DAP - Service &amp; Parts Subscription</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Code__c</field>
            <operation>equals</operation>
            <value>PowerSearch</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Updates the priority field for cases created contain a product category of &quot;Online Marketing&apos; product code containing &quot;DAP&quot; or &quot;PowerSearch&quot; for Onboarding - AA case types to a priority of 5 Days</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_HR_CasesToCanadaHRQueue</fullName>
        <actions>
            <name>DS_HR_Set_Owner_To_HRQueue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>For now HR_Cases to Canada HR Queue</description>
        <formula>ISPICKVAL(Origin, &quot;Email - HR&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Dealix Case Returns</fullName>
        <actions>
            <name>Dealix_Target_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Tier 2 - Dealix</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Product_Category__c</field>
            <operation>equals</operation>
            <value>Inventory</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Code__c</field>
            <operation>equals</operation>
            <value>Exports</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Problem_Detail__c</field>
            <operation>equals</operation>
            <value>Remove Existing/Cancellation</value>
        </criteriaItems>
        <description>Calculate Target date of returns</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Deconstruct Notification</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Data Ops</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Deconstruct</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Due_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Starts time based workflow to alert case owner that they should deconstruct.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Alert_Data_Ops_to_deconstruct</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Due_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Downgrade Case Assign to Salesops</fullName>
        <actions>
            <name>AutoUpdate_to_SalesOpsSpecialist</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Sales Operations</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Downgrade</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Downgrade case autoassigns to the Sales Operations Specialist</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EMLAlert_VW_BuySell_Termination_Notifications</fullName>
        <actions>
            <name>EMLAlert_VW_BuySell_Termination_Notifications</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email notification for any IFS- Contract Admin: Buy/Sell or Dealer Termination Case types for vw-% webID&apos;s.</description>
        <formula>BEGINS(WebID__r.Name, &quot;vw&quot;) &amp;&amp; OR( ISPICKVAL(  Type , &quot;Customer Buy/Sell&quot;) , ISPICKVAL(  Type , &quot;Dealer Termination&quot;) ) &amp;&amp;  RecordTypeId = &apos;01240000000ICTf&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EMS Design Case Created</fullName>
        <actions>
            <name>EMS_Design_Case_Opened</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>EMS - Design</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>When an EMS Design Case is created, an email alert is to go out to the queue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EMS Onboarding 45 day notification</fullName>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3) AND (4 OR 5) and 6</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding - EMS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Product_Type__c</field>
            <operation>includes</operation>
            <value>Email Marketing Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Product_Type__c</field>
            <operation>includes</operation>
            <value>Email Marketing Service</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Dealer_Reporting_Review__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CLM_Group_3_Complete__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Will send an alert to owner if CLM Group 3 or Dealer Reporting Review has not been documented as completed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Alert_Owner_that_CLMs_or_Report_Review_not_complete_45_days</name>
                <type>Alert</type>
            </actions>
            <timeLength>45</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Email 2 Case Records</fullName>
        <actions>
            <name>Email_2_Case_Records</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>User.LastName</field>
            <operation>equals</operation>
            <value>2Case</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Alert - Cancel Case No Activity</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Cancellation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_for_Cancellation_Case_with_no_Activity_for_5_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.LastModifiedDate</offsetFromField>
            <timeLength>5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Email_SalesOps_Downgrade_Case</fullName>
        <actions>
            <name>Email_Alert_to_Account_Team_when_Downgrade_Case_is_Created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Downgrade</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Notification to Account Team when a Downgrade case is created</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FS-DI 48 Hour No Activity notification</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>IFS - DI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - DI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>If no activity after 48 hours for an IFS-DI case type, notification sent to manager.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>IFS_DI_48_Hour_No_Activity_notification</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>GM Canada Cancellation Notify</fullName>
        <actions>
            <name>GM_Canada_Cancellation_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>GM Canada Cancellations notifies Scott Sabo, Enterprise Sales</description>
        <formula>$RecordType.Name == &quot;Cancellation&quot;  &amp;&amp;  BEGINS(WebID__r.Name, &quot;gmcl&quot;)  &amp;&amp;  INCLUDES(Products_to_Cancel__c,&quot;GM Performance Solution&quot;) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>GM iMR Opt Out Notification</fullName>
        <actions>
            <name>GM_iMR_Opt_Out_Notification_to_Account_Team</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Contract Admin</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>GM iMR Opt Out</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Hyundai Cancellation Notify</fullName>
        <actions>
            <name>Hyundai_Cancellation_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Hyundai Cancellations notifies Suzanna Casteneda, Enterprise Sales</description>
        <formula>$RecordType.Name == &quot;Cancellation&quot; &amp;&amp; BEGINS(WebID__r.Name, &quot;hyun&quot;) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFS Data Ops Case Created</fullName>
        <actions>
            <name>IFS_Data_Ops_Case_Opened</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Data Ops</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>notEqual</operation>
            <value>Deconstruct</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>When a IFS Data Ops Case is created, an email alert is to go out to the queue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFS-DI Alert AE 2 Days and 30 days after Create</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 and 4</booleanFilter>
        <criteriaItems>
            <field>Case.DI_Status__c</field>
            <operation>notEqual</operation>
            <value>Received DI,Received NDA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Re_Enroll__c</field>
            <operation>notEqual</operation>
            <value>Other,Active OS/OM,Active or Recent DI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - DI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>IFS_DI_30_Day_No_Activity_Email_Alert_DSM</name>
                <type>Alert</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>IFS_DI_48_Hour_No_Action_Email_Alert_DSM</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>IFS-DI Case auto assigns to SalesOps queue</fullName>
        <actions>
            <name>AutoUpdate_to_IFS_DI_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - DI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>IFS - DI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>When IFS-DI Case is saved it auto assigns to SalesOps queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFS_CA_Record_Type_DLP_Notification</fullName>
        <actions>
            <name>Case_Creation_Notification_to_List_DLP_Ad_Operations</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND (2 or 3 or 4)</booleanFilter>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>GM Complete Buy/Sell,GM iMR Opt Out,GM Termination</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>equals</operation>
            <value>Cameron Wong</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>equals</operation>
            <value>AJ Soysouvanh</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>equals</operation>
            <value>Johnnie Tankersley</value>
        </criteriaItems>
        <description>Email notification to go to “List- DLP Ad Operations” - whenever an IFS- Contract Admin case is opened by Customer Data for the following types: GM Complete Buy/Sell, GM iMR Opt Out, GM Termination</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFS_Manager_Approval</fullName>
        <actions>
            <name>Manager_Approval_Box_Checked</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( (Manager_Approval__c)=TRUE, NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Kia Cancellation Case Created</fullName>
        <actions>
            <name>CB_EMLALERT_for_Kia_cancellation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When a Kia Cancellation Case is created, an email alert is sent to Matt Lipshutz. Requested by Jill Johnson on R-455</description>
        <formula>$RecordType.Name = &quot;Cancellation&quot; &amp;&amp;     CONTAINS( WebID__r.Name, &quot;k1ia-&quot;)  &amp;&amp;  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lexus - Case Opened from Email AutoNotification</fullName>
        <actions>
            <name>Case_Creation_Email_Notification_Lexus</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email generated to customer when their email has been converted into a case. (Lexus)</description>
        <formula>OR( (ISPICKVAL ( Origin, &quot;Email – Lexus&quot;)), (ISPICKVAL ( Origin, &quot;Email - Lexus&quot;)) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notification to Dealer Group - Contact when CT closes case</fullName>
        <actions>
            <name>Notification_to_contact_for_grp_when_CT_closes_case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 and 9 AND (10 OR (11 AND 12))</booleanFilter>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>Content Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin_Type__c</field>
            <operation>equals</operation>
            <value>INB-Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Dealer_Group_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ParentId</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Dealer_Group_Contact_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Tier 1,Tier 2 - Content,Tier 2 - ETS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Resolved_Email_Sent_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OEM__c</field>
            <operation>notEqual</operation>
            <value>GM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OEM__c</field>
            <operation>equals</operation>
            <value>GM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Email_on_Resolved__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify dealer group contact when CT closes case</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification to Dealer Group when CT closes case</fullName>
        <actions>
            <name>Notification_to_group_dealer_when_CT_closes_case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 and 9 AND (10 OR (11 AND 12))</booleanFilter>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>Content Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin_Type__c</field>
            <operation>equals</operation>
            <value>INB-Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Dealer_Group_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ParentId</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Dealer_Group_Contact_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Tier 1,Tier 2 - Content,Tier 2 - ETS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Resolved_Email_Sent_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OEM__c</field>
            <operation>notEqual</operation>
            <value>GM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OEM__c</field>
            <operation>equals</operation>
            <value>GM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Email_on_Resolved__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify dealer group contact when CT closes case</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification to Dealer when CT closes case</fullName>
        <actions>
            <name>Notification_to_dealer_when_CT_closes_case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 and 6 AND (7 OR (8 AND 9))</booleanFilter>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>Content Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin_Type__c</field>
            <operation>equals</operation>
            <value>INB-Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Dealer_Group_Name__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Resolved_Email_Sent_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OEM__c</field>
            <operation>notEqual</operation>
            <value>GM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OEM__c</field>
            <operation>equals</operation>
            <value>GM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Email_on_Resolved__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify dealer when CT closes case</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify AE for Budget Change</fullName>
        <actions>
            <name>Notify_AE_for_Budget_Change</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>OMS - Budget</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Desired_Budget__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify IFS - Data Ops Case no touch 3 days</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>IFS - Data Ops Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>If case has been in queue for 3 days send notification.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Case_has_been_in_IFS_Data_Ops_Queue_for_3_days</name>
                <type>Alert</type>
            </actions>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Notify Parent Case Owner</fullName>
        <actions>
            <name>Notify_Parent_Case_Owner_of_Child_Case_Closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.ParentId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed as Duplicate,Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Notify Parent Case Owner when child case is closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify for 911 Cases - Creative</fullName>
        <actions>
            <name>Notify_for_911_Case_Creative</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When an Inquiry - Creative record is created or edited w/911 Escalation field, it sends an email notification to Creative Team.</description>
        <formula>AND (  NOT(BEGINS($User.Username, &quot;integration_user@adp.com&quot;)),  TEXT(X911_Escalation__c) &lt;&gt; &quot;&quot;,  NOT(ISPICKVAL(Status,&quot;Closed&quot;)),  NOT(ISPICKVAL(Status,&quot;Closed as Duplicate&quot;)),  $RecordType.Name = &quot;Inquiry - Creative&quot;  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify for 911 Cases - Holden Tier 1%2C Tier 2</fullName>
        <actions>
            <name>Notify_for_911_Cases_Holden_Tier_1_Tier_2</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>0-Critical/911 - Emergency</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Resolved Pending Verification,Resolved,Closed as Duplicate,Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Tier 1,Tier 2 - Content,Tier 2 - ETS</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>equals</operation>
            <value>Holden</value>
        </criteriaItems>
        <description>When a Tier 1 record is created w/ Priority of 911 it sends an email notification to service managers. If no change after 1 hour it sends another notification to the managers.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify for 911 Cases - Tier 1</fullName>
        <actions>
            <name>Notify_for_911_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>0-Critical/911 - Emergency</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Resolved Pending Verification,Resolved,Closed as Duplicate,Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Tier 1 - BMW Queue,Tier 1 - Lexus Queue,Tier 1 - MINI Queue,Tier 1 Queue,Tier 1 - Prospector Queue,Tier 1</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>notEqual</operation>
            <value>Holden</value>
        </criteriaItems>
        <description>When a Tier 1 record is created w/ Priority of 911 it sends an email notification to service managers. If no change after 1 hour it sends another notification to the managers.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_for_911_Case_Tier_1_1_hour_no_activity</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Notify for 911 Cases - Tier 2 - Content</fullName>
        <actions>
            <name>Notify_for_911_Cases_Tier_2_ETS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>0-Critical/911 - Emergency</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Resolved Pending Verification,Resolved,Closed as Duplicate,Working,Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Tier 2 - Content</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>notEqual</operation>
            <value>Holden</value>
        </criteriaItems>
        <description>When a  Tier 2 - Content record is created w/ Priority of 911 it sends an email notification to service managers. If no change after 1 hour it sends another notification to the managers.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_for_911_Cases_Tier_2_Content_1_hour_no_activity</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Notify for 911 Cases - Tier 2 - ETS</fullName>
        <actions>
            <name>Notify_for_911_Case_Tier_2_ETS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>0-Critical/911 - Emergency</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Cancelled - Closed,Resolved Pending Verification,Resolved,Working,Closed,Waiting,Closed as Duplicate,Completed - Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Tier 2 - ETS</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>notEqual</operation>
            <value>Holden</value>
        </criteriaItems>
        <description>When a Tier 2 - ETS record is created w/ Priority of 911 it sends an email notification to service managers. If no change after 1 hour it sends another notification to the managers.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_for_911_Case_Tier_2_1_Hour_no_activity</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Notify for Case Escalation 1 hr</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>0-Critical/911 - Emergency</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Tier 1 - BMW Queue,Tier 1 - Lexus Queue,Tier 1 - MINI Queue,Tier 1 Queue,Tier 1 - Prospector Queue,Tier 2 - Content Queue,Tier 2 - ETS Queue</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Escalation</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Notify for Case Escalation 2 hr</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>0-Critical/911 - Emergency</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Tier 1 - BMW Queue,Tier 1 - Lexus Queue,Tier 1 - MINI Queue,Tier 1 Queue,Tier 1 - Prospector Queue,Tier 2 - Content Queue,Tier 2 - ETS Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>notEqual</operation>
            <value>Holden</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Escalation2hours</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Notify for Case Escalation 3 hr</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>0-Critical/911 - Emergency</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Tier 1 - BMW Queue,Tier 1 - Lexus Queue,Tier 1 - MINI Queue,Tier 1 Queue,Tier 1 - Prospector Queue,Tier 2 - Content Queue,Tier 2 - ETS Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Waiting</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Waiting_on__c</field>
            <operation>equals</operation>
            <value>Customer,Tier 3</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OEM__c</field>
            <operation>notEqual</operation>
            <value>Holden</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_for_Case_Escalation_after_3_hours</name>
                <type>Alert</type>
            </actions>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Notify for IFS Enhancement Case Closure</fullName>
        <actions>
            <name>Notify_for_IFS_Enhancement_Case_Creation_Closure</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Enhancements</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Notification for IFS Enhancement Case Closure</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify for IFS Enhancement Case Creation</fullName>
        <actions>
            <name>Notify_for_IFS_Enhancement_Case_Creation_Closure</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IFS - Enhancements</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>CSI</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Notification for IFS Enhancement Case Creation</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OMS ONB Notification - Open after 7 business days</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding - OMS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed as Duplicate,Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>OMS OnBoarding Notification if case is still open at 7 business days.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_OMS_for_Onboarding_case_to_close_in_9_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>9</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Onboarding within 10 days</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding - SEO</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Resolved Pending Verification,Resolved,Closed as Duplicate,Closed</value>
        </criteriaItems>
        <description>If SEO Onboarding is not closed, notify case owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_for_Onboarding_case_to_close_in_10_days</name>
                <type>Alert</type>
            </actions>
            <timeLength>10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Onboarding within 9 days</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding - SEO</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Resolved Pending Verification,Resolved,Closed as Duplicate,Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>If SEO Onboarding not closed notify Case owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_for_Onboarding_case_to_close_in_9_days</name>
                <type>Alert</type>
            </actions>
            <timeLength>9</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Performance Solution Cancellation Case Created</fullName>
        <actions>
            <name>Alert_Performance_Solution_Cancellation_Case_Created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Products_to_Cancel__c</field>
            <operation>equals</operation>
            <value>GM Performance Solution</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cancellation</value>
        </criteriaItems>
        <description>When a Performance Solution Cancellation Case is created, an email alert is to go out to the Digital Advisor email alias (SEA GM DMA&apos;s)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Pre-Cancellation Case Created</fullName>
        <actions>
            <name>Pre_Cancellation_Case_Opened</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When a Pre-Cancellation Case is created, an email alert is to go out to the account team.</description>
        <formula>$RecordType.Name = &quot;IFS - Contract Admin&quot; &amp;&amp;  ISPICKVAL(Type ,&quot;PreActivation Cancellation&quot;) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Same Calendar Day Close FALSE</fullName>
        <active>false</active>
        <description>This workflow checks to see if the created date &lt;&gt; the closed date of a case.  If it does not this rule will evaluate to false and set the field = &quot;No&quot;</description>
        <formula>AND( Date(Year(Datevalue(CreatedDate)),Month(Datevalue(CreatedDate)),Day(datevalue(CreatedDate))) &lt;&gt; Date(Year(datevalue(ClosedDate)),Month(datevalue(ClosedDate)),day(datevalue(ClosedDate))), NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Same Calendar Day Close TRUE</fullName>
        <active>false</active>
        <description>This workflow checks to see if the created date = the closed date of a case.  If this evaluates as true this will set the Same Calendar Day Close Field to &quot;Yes.&quot;</description>
        <formula>AND ( Date(Year(Datevalue(CreatedDate)),Month(Datevalue(CreatedDate)),Day(datevalue(CreatedDate))) = Date(Year(datevalue(ClosedDate)),Month(datevalue(ClosedDate)),day(datevalue(ClosedDate))), NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set LOE to Unknown</fullName>
        <actions>
            <name>Update_LOE_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Level_of_Effort__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Service Ops - Application/Reporting</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>If case is sent to application/report queue the workflow will set the LOE to unknown.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update T2 911 Case - Clear Target DateTime</fullName>
        <actions>
            <name>Update_Target_Date_Time_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When an existing Tier 2 – Content Case has its Priority updated to 911, make sure the Target Date/Time field is null.</description>
        <formula>AND (  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  NOT(ISPICKVAL(PRIORVALUE( Priority),&apos;0-Critical/911 - Emergency&apos;)),  ISPICKVAL(Priority,&apos;0-Critical/911 - Emergency&apos;),  NOT(ISBLANK(Target_Date_Time__c))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>VW Vehicle Command Center is Live</fullName>
        <actions>
            <name>Alert_to_Account_Team_when_VW_Vehicle_Command_Center_is_live</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Tier 1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Program__c</field>
            <operation>equals</operation>
            <value>VW Vehicle Command Center Migration Project</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>Triggers email to VW dealer and account team when Case for Vehicle Command Center Migration is closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Would You Hire Associate Flag</fullName>
        <actions>
            <name>Would_You_Hire_Associate_Action1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR( ( RecordTypeId = &apos;01240000000ICU7&apos;),  ( RecordTypeId = &apos;01240000000ICU6&apos;),  ( RecordTypeId = &apos;01240000000ICTa&apos;) ) &amp;&amp;    ISPICKVAL(Status,&apos;Closed&apos;) &amp;&amp;   CreatedById=LastModifiedById</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Budget_End_Date_for_case_is_today</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Budget End Date for case is today.</subject>
    </tasks>
    <tasks>
        <fullName>Budget_End_Date_for_case_is_today1</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Budget End Date for case is today</subject>
    </tasks>
    <tasks>
        <fullName>Budget_Start_Date_for_case_is_today</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Budget Start Date for case is today.</subject>
    </tasks>
    <tasks>
        <fullName>Budget_Start_Date_for_case_is_today1</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Budget Start Date for case is today</subject>
    </tasks>
    <tasks>
        <fullName>Social_Consult_Needed</fullName>
        <assignedTo>jim.jensen@cdk.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Please contact this dealership and schedule a consultation appointment.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Social Consult Needed</subject>
    </tasks>
    <tasks>
        <fullName>Social_Consult_Needed2</fullName>
        <assignedTo>christy.silveira@cdk.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Social Consult Needed</subject>
    </tasks>
</Workflow>
