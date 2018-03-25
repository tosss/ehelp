<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_AA_of_SEO_Maintenance</fullName>
        <description>Alert - AA of SEO Maintenance</description>
        <protected>false</protected>
        <recipients>
            <field>Advocate_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_AA_WebID_in_SEO_Maintenance_Mode</template>
    </alerts>
    <alerts>
        <fullName>Alert_DA_Help_List_is_Checked</fullName>
        <description>Alert DA Help List is Checked</description>
        <protected>false</protected>
        <recipients>
            <field>Advocate_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>OMS_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>melissa.satterwhite@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/DA_Help_List_Notification_Account_Plan</template>
    </alerts>
    <alerts>
        <fullName>Alert_PowerSEO_Help_List_is_Checked</fullName>
        <description>Alert PowerSEO Help List is Checked</description>
        <protected>false</protected>
        <recipients>
            <field>Advocate_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SEO_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/PowerSEO_Help_List_Notification_Account_Plan</template>
    </alerts>
    <alerts>
        <fullName>CB_SVC_Alert_LMA_Strategist</fullName>
        <description>CB SVC Alert LMA Strategist</description>
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
        <template>IFS_Launch_Templates/CB_SVC_Alert_AMA_Account_Plan_Strategist</template>
    </alerts>
    <fieldUpdates>
        <fullName>AccountPlan_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>AccountPlan_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Svc_Citation_Flow_Date</fullName>
        <field>Citation_Flow_Date__c</field>
        <formula>Now()</formula>
        <name>CB Svc Citation Flow Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Svc_Date_Mo_1_Req_Steps</fullName>
        <field>Month_1_Required_Steps_Date__c</field>
        <formula>Today()</formula>
        <name>CB Svc Date Mo 1 Req Steps</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Svc_Trust_Flow_Date</fullName>
        <field>Trust_Flow_Date__c</field>
        <formula>Now()</formula>
        <name>CB Svc Trust Flow Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Svc_UPD_SDC_Last_Updated</fullName>
        <description>When the following fields are changed: Temperature, Current Health, Next Steps, KPI Changes or Enhancement Requests update the field to Today&apos;s date.</description>
        <field>SDC_Last_Updated__c</field>
        <formula>Today()</formula>
        <name>CB Svc UPD SDC Last Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Svc_UPD_SEO_Maintenance_Only</fullName>
        <description>When the Account Plan&apos;s Product Status is changed to &apos;Onboarding&apos; set the SEO Maintenance-Only checkbox to unchecked.</description>
        <field>SEO_Maintenance_Only__c</field>
        <literalValue>0</literalValue>
        <name>CB_Svc_UPD_ SEO Maintenance Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Svc_UPD_Temperature</fullName>
        <field>Temperature__c</field>
        <name>CB Svc UPD Temperature</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Upd_AP_SEO_Flag_Change_Date</fullName>
        <field>SEO_Flag_Change_Date__c</field>
        <formula>TODAY()</formula>
        <name>CB_Upd - AP SEO Flag Change Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Upd_AP_SEO_Flag_Change_User</fullName>
        <field>SEO_Flag_Change_User__c</field>
        <formula>$User.FirstName &amp; &apos; &apos; &amp; $User.LastName</formula>
        <name>CB_Upd - AP SEO Flag Change User</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_DA_Help_List_Date</fullName>
        <field>DA_Help_List_Date__c</field>
        <name>Delete DA Help List Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_DA_Help_List_Description</fullName>
        <field>DA_Help_List_Description__c</field>
        <name>Delete DA Help List Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_DA_Help_List_Reason</fullName>
        <field>DA_Help_List_Reason__c</field>
        <name>Delete DA Help List Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Hot_List_Date</fullName>
        <field>Hot_List_Date__c</field>
        <name>Delete Hot List Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Hot_List_Reason</fullName>
        <field>Hot_List_Reason__c</field>
        <name>Delete Hot List Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_PowerSEO_Help_List_Date</fullName>
        <field>PowerSEO_Help_List_Date__c</field>
        <name>Delete PowerSEO Help List Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_PowerSEO_Help_List_Description</fullName>
        <field>PowerSEO_Help_List_Description__c</field>
        <name>Delete PowerSEO Help List Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_PowerSEO_Help_List_Reason</fullName>
        <field>PowerSEO_Help_List_Reason__c</field>
        <name>Delete PowerSEO Help List Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_RepMan_Help_List_Date</fullName>
        <field>RepMan_Help_List_Date__c</field>
        <name>Delete RepMan Help List Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_RepMan_Help_List_Description</fullName>
        <field>RepMan_Help_List_Description__c</field>
        <name>Delete RepMan Help List Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_RepMan_Help_List_Reason</fullName>
        <field>RepMan_Help_List_Reason__c</field>
        <name>Delete RepMan Help List Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Social_Help_List_Date</fullName>
        <field>Social_Help_List_Date__c</field>
        <name>Delete Social Help List Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Social_Help_List_Description</fullName>
        <field>Social_Help_List_Description__c</field>
        <name>Delete Social Help List Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Social_Help_List_Reason</fullName>
        <field>Social_Help_List_Reason__c</field>
        <name>Delete Social Help List Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_5_Star_Reviews_Last_Updated</fullName>
        <field>X5_Star_Reviews_Last_Updated__c</field>
        <formula>NOW()</formula>
        <name>Update 5 Star Reviews Last Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_AA_Data_Quality_Count</fullName>
        <field>AA_Data_Quality_Count__c</field>
        <formula>IF( LEN(TRIM( Discovery__c ))=0, 0, 1) + 
IF( ISBLANK( Dealer_Hurt__c ), 0, 1) + 
IF( ISBLANK( TEXT(Dealership_Health__c)), 0, 1) + 
 
IF( 
OR( 
ISBLANK( Next_Action_Due__c ) 
,Next_Action_Due__c &lt; TODAY() 
), 0, 1) + 
 
IF( 
OR( 
NOT(ISBLANK( Sales_Process__c )) 
,NOT(ISBLANK( Perceived_Reputation__c )) 
,NOT(ISBLANK( Fixed_Operations_Details__c )) 
,NOT(ISBLANK( Location__c )) 
) 
, 1, 0)</formula>
        <name>Update AA Data Quality Count</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Account_Notes_Last_Modified</fullName>
        <field>Account_Notes_Last_Updated__c</field>
        <formula>NOW()</formula>
        <name>Update Account Notes Last Modified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Account_Notes_Last_Modified_By</fullName>
        <field>Account_Notes_Last_Updated_By__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName</formula>
        <name>Update Account Notes Last Modified By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Coaching_Notes_Last_Modified</fullName>
        <field>Coaching_Notes_Last_Modified_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Coaching Notes Last Modified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Coaching_Notes_Last_Modified_By</fullName>
        <field>Coaching_Notes_Last_Modified_By__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName</formula>
        <name>Update Coaching Notes Last Modified By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_DAA_Data_Last_Updated</fullName>
        <field>DAA_Data_Last_Updated__c</field>
        <formula>NOW()</formula>
        <name>Update DAA Data Last Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_DA_Help_List_Date</fullName>
        <field>DA_Help_List_Date__c</field>
        <formula>NOW()</formula>
        <name>Update DA Help List Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Discovery_Last_Updated</fullName>
        <field>Discovery_Last_Updated__c</field>
        <formula>NOW()</formula>
        <name>Update Discovery Last Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Discovery_Last_Updated1</fullName>
        <field>Discovery_Last_Updated__c</field>
        <formula>NOW()</formula>
        <name>Update Discovery Last Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Discovery_Last_Updated_By</fullName>
        <field>Discovery_Last_Updated_By__c</field>
        <formula>$User.Alias</formula>
        <name>Update Discovery Last Updated By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Discovery_Last_Updated_By2</fullName>
        <field>Discovery_Last_Updated_By__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName</formula>
        <name>Update Discovery Last Updated By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_External_Id_WebId</fullName>
        <field>External_Id_WebId__c</field>
        <formula>WebID__r.Name</formula>
        <name>Update External Id WebId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Hot_List_Date</fullName>
        <field>Hot_List_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Hot List Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Month_1_Req_Steps_Date_Null</fullName>
        <field>Month_1_Required_Steps_Date__c</field>
        <name>Update - Month 1 Req Steps Date Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Month_2_Req_Steps_Date</fullName>
        <field>Month_2_Required_Steps_Date__c</field>
        <formula>Today()</formula>
        <name>Update - Month 2 Req Steps Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Month_2_Req_Steps_Date_Null</fullName>
        <field>Month_2_Required_Steps_Date__c</field>
        <name>Update - Month 2 Req Steps Date Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Month_3_Opt_Steps_Date</fullName>
        <field>Month_3_Optional_Steps_Date__c</field>
        <formula>Today()</formula>
        <name>Update - Month 3 Opt Steps Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Month_3_Opt_Steps_Date_Null</fullName>
        <field>Month_3_Optional_Steps_Date__c</field>
        <name>Update - Month 3 Opt Steps Date Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Month_3_Req_Steps_Date</fullName>
        <field>Month_3_Required_Steps_Date__c</field>
        <formula>Today()</formula>
        <name>Update - Month 3 Req Steps Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Month_3_Req_Steps_Date_Null</fullName>
        <field>Month_3_Required_Steps_Date__c</field>
        <name>Update - Month 3 Req Steps Date Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Month_4_Req_Steps_Date</fullName>
        <field>Month_4_Required_Steps_Date__c</field>
        <formula>Today()</formula>
        <name>Update - Month 4 Req Steps Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Month_4_Req_Steps_Date_Null</fullName>
        <field>Month_4_Required_Steps_Date__c</field>
        <name>Update - Month 4 Req Steps Date Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Month_5_Opt_Steps_Date</fullName>
        <field>Month_5_Optional_Steps_Date__c</field>
        <formula>Today()</formula>
        <name>Update - Month 5 Opt Steps Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Month_5_Opt_Steps_Date_Null</fullName>
        <field>Month_5_Optional_Steps_Date__c</field>
        <name>Update - Month 5 OptSteps Date Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Month_5_Req_Steps_Date</fullName>
        <field>Month_5_Required_Steps_Date__c</field>
        <formula>Today()</formula>
        <name>Update - Month 5 Req Steps Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Month_5_Req_Steps_Date_Null</fullName>
        <field>Month_5_Required_Steps_Date__c</field>
        <name>Update - Month 5 Req Steps Date Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Month_6_Req_Steps_Date</fullName>
        <field>Month_6_Required_Steps_Date__c</field>
        <formula>Today()</formula>
        <name>Update - Month 6 Req Steps Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Month_6_Req_Steps_Date_Null</fullName>
        <field>Month_6_Required_Steps_Date__c</field>
        <name>Update - Month 6 Req Steps Date Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_PowerSEO_Help_List_Date</fullName>
        <field>PowerSEO_Help_List_Date__c</field>
        <formula>NOW()</formula>
        <name>Update PowerSEO Help List Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_RepMan_Help_List_Date</fullName>
        <field>RepMan_Help_List_Date__c</field>
        <formula>NOW()</formula>
        <name>Update RepMan Help List Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Social_Help_List_Date</fullName>
        <field>Social_Help_List_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Social Help List Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AccountPlan_Set_Migration_ID</fullName>
        <actions>
            <name>AccountPlan_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Alert %26 Update - DA Help List Added</fullName>
        <actions>
            <name>Alert_DA_Help_List_is_Checked</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_DA_Help_List_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All RT w/ fields – when the DA Help List checkbox is set to true, the date is captured in the DA Help List Date field.  Also send out email notification.</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),      DA_Help_List__c = TRUE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert %26 Update - PowerSEO Help List Added</fullName>
        <actions>
            <name>Alert_PowerSEO_Help_List_is_Checked</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_PowerSEO_Help_List_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All RT w/ fields – when the PowerSEO Help List checkbox is set to true, the date is captured in the PowerSEO Help List Date field. Email notification is also sent.</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),      PowerSEO_Help_List__c = TRUE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB SVC Alert Strategist AMA Account Plan setup CTNs</fullName>
        <actions>
            <name>CB_SVC_Alert_LMA_Strategist</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>For AMA Account Plans alert LMA Strategist to setup CTNs</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c))&amp;&amp; $RecordType.Name = &quot;AMA Account Plan&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB SVC UPD Temperature</fullName>
        <actions>
            <name>CB_Svc_UPD_Temperature</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>1/18/2016 - Deactivate as per RQ-06119.

Clear temperature rating only if 90 days have passed without the temp rating field being changed</description>
        <formula>$RecordType.Name = &quot;AA Account Plan&quot; &amp;&amp;  NOT(ISCHANGED(Temperature__c)||  ISCHANGED(Current_Health__c)||  ISCHANGED(Next_Steps__c)||  ISCHANGED(KPI_Changes__c)||  ISCHANGED(Enhancement_Requests__c)  ) &amp;&amp;  (TODAY() &gt;= 90+(SDC_Last_Updated__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB Svc UPD SDC Last Updated</fullName>
        <actions>
            <name>CB_Svc_UPD_SDC_Last_Updated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When Temperature, Current Health, Next Steps, KPI Changes or Enhancement Requests is changed update this field to today&apos;s date.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp;  OR(ISNEW()&amp;&amp;  ($RecordType.Name = &quot;AA Account Plan&quot; ||  $RecordType.Name = &quot;PIC Account Plan&quot;) &amp;&amp;  (NOT(ISPICKVAL(Temperature__c,&quot;&quot;))||  NOT(ISBLANK(Current_Health__c))||  NOT(ISBLANK(Next_Steps__c))||  NOT(ISBLANK(KPI_Changes__c))||  NOT(ISBLANK(Enhancement_Requests__c))  ),($RecordType.Name = &quot;AA Account Plan&quot; ||  $RecordType.Name = &quot;PIC Account Plan&quot;) &amp;&amp;  (ISCHANGED(Temperature__c)||  ISCHANGED(Current_Health__c)||  ISCHANGED(Next_Steps__c)||  ISCHANGED(KPI_Changes__c)||  ISCHANGED(Enhancement_Requests__c)  ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_AA_DataQualScore</fullName>
        <actions>
            <name>Update_AA_Data_Quality_Count</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the AA Data Quality Count</description>
        <formula>OR  (  ISCHANGED( Dealer_Hurt__c )  ,IsCHANGED( Discovery__c )  ,ISCHANGED( Sales_Process__c )  ,ISCHANGED( Next_Action_Due__c )  ,ISCHANGED( Perceived_Reputation__c )  ,ISCHANGED( Fixed_Operations_Details__c )  ,ISCHANGED( Location__c )  ,ISCHANGED( Dealership_Health__c )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_Alert_AA_SEOMaintenanceOnly</fullName>
        <actions>
            <name>Alert_AA_of_SEO_Maintenance</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Alerts the Advocate when the SEO Specialist puts their account plan into SEO Maintenance Only mode.</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  $RecordType.Name = &quot;SEO Account Plan&quot;,  OR  (  INCLUDES(Product__c,&apos;ProCare SEO&apos;),  INCLUDES(Product__c,&apos;Reactive SEO&apos;)  ),  ISCHANGED( SEO_Maintenance_Only__c ),  SEO_Maintenance_Only__c = TRUE  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_Svc_Populate External Id WebId</fullName>
        <actions>
            <name>Update_External_Id_WebId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Plan__c.External_Id_WebId__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_Svc_UPD_ SEO Maintenance Only</fullName>
        <actions>
            <name>CB_Svc_UPD_SEO_Maintenance_Only</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Account Plan&apos;s Product Status is changed to &apos;Onboarding&apos; then the SEO Maintenance-Only checkbox is automatically unchecked. or, when the Product is neither ProCare SEO nor NULL, the SEO Maintenance-Only checkbox is automatically unchecked</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  $RecordType.Name = &quot;SEO Account Plan&quot;,  SEO_Maintenance_Only__c =TRUE,  OR( ISPICKVAL(Account_Status__c,&quot;Onboarding&quot;),  AND(NOT(INCLUDES( Product__c ,&quot;ProCare SEO&quot;)),  NOT(INCLUDES( Product__c ,&quot;Reactive SEO&quot;))),  AND(ISCHANGED(Primary__c), Primary__c = TRUE)  )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_Update_SEO_Flag_Last_Updated</fullName>
        <actions>
            <name>CB_Upd_AP_SEO_Flag_Change_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CB_Upd_AP_SEO_Flag_Change_User</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the SEO Flag Last Updated Date and User fields when the SEO Flag field is changed from its prior value.</description>
        <formula>AND (  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  PRIORVALUE(SEO_Flag__c)&lt;&gt;SEO_Flag__c  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update %E2%80%93 Account Notes Last Updated</fullName>
        <actions>
            <name>Update_Account_Notes_Last_Modified</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Account_Notes_Last_Modified_By</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Account Notes Last Updated and Account Notes Last Updated by fields when the Account Notes field is changed from its prior value.</description>
        <formula>AND (     NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),     PRIORVALUE(Account_Notes__c)&lt;&gt;Account_Notes__c    )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update %E2%80%93 Coaching Notes Last Updated</fullName>
        <actions>
            <name>Update_Coaching_Notes_Last_Modified</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Coaching_Notes_Last_Modified_By</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Coaching Notes Last Updated and Coaching Notes Last Updated by fields when the Coaching Notes field is changed from its prior value.</description>
        <formula>AND (  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  PRIORVALUE(Coaching_Notes__c)&lt;&gt;Coaching_Notes__c  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update %E2%80%93 Discovery Last Updated</fullName>
        <actions>
            <name>Update_Discovery_Last_Updated1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Discovery_Last_Updated_By2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All RT – Updates the Discovery Last Updated and Discovery Last Updated by fields when the Discovery field is changed from its prior value.</description>
        <formula>AND (     NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),     PRIORVALUE(Discovery__c)&lt;&gt;Discovery__c    )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - 5 Star Review Last Updated</fullName>
        <actions>
            <name>Update_5_Star_Reviews_Last_Updated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All Account Plans with 5 Star Review fields – When any of the 5 Star Review fields are modified, the 5 Star Review Last Updated field is updated.</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),      OR(ISCHANGED( X5_Star_Reviews1__c),        ISCHANGED( X5_Star_Reviews2__c),        ISCHANGED( X5_Star_Reviews3__c )       )     )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Citation Flow Date</fullName>
        <actions>
            <name>CB_Svc_Citation_Flow_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Citation Flow Date field when the Citation Flow field changes</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c))&amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;  ISCHANGED(CB_SVC_Citation_Flow__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - DA Help List Removed</fullName>
        <actions>
            <name>Delete_DA_Help_List_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_DA_Help_List_Description</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_DA_Help_List_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All RT w/ field displayed – Once the DA Help List checkbox is unchecked, this workflow clears the values in the DA Help List Date, DA Help List Description, and DA Help List Reason fields.  Manager comments will remain.</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),     PRIORVALUE( DA_Help_List__c ) = TRUE,     DA_Help_List__c = FALSE     )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - DAA Data Last Updated</fullName>
        <actions>
            <name>Update_DAA_Data_Last_Updated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All RT w/ Dealer Logo, OMS Taglines, OMS Geography, DMA or Radius targeted details, or Ad Review (x3) fields – feeds the modification date to the DAA Data Last Updated field.</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),    OR(ISCHANGED( Ad_Review1__c ),       ISCHANGED(Ad_Review2__c),       ISCHANGED(Ad_Review3__c),       ISCHANGED( Dealer_Logo__c),       ISCHANGED( DAA_Taglines__c ),       ISCHANGED( DAA_Geography__c ),       ISCHANGED( DMA_or_Radius_Targeted_Details__c)       )     )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Hot List Added</fullName>
        <actions>
            <name>Update_Hot_List_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All RT w/ fields – when the Email Marketing Hot List checkbox is set to true, the date is captured in the Hot List Date field.</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),        Hot_List__c  = TRUE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update - Hot List Removed</fullName>
        <actions>
            <name>Delete_Hot_List_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_Hot_List_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All RT w/ field – when the Hot List field is unchecked, this clears the Hot List Reason field.</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),     PRIORVALUE( Hot_List__c ) = TRUE,     Hot_List__c  = FALSE     )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Month 1 Req Steps Date</fullName>
        <actions>
            <name>CB_Svc_Date_Mo_1_Req_Steps</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Onboarding Month Step field is checked then change the corresponding date field to today&apos;s date.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;  Month_1_Required_Steps__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Month 1 Req Steps Date Null</fullName>
        <actions>
            <name>Update_Month_1_Req_Steps_Date_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Onboarding Month Step field is unchecked clear the corresponding date field.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;  Month_1_Required_Steps__c = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Month 2 Req Steps Date</fullName>
        <actions>
            <name>Update_Month_2_Req_Steps_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Onboarding Month Step field is checked then change the corresponding date field to today&apos;s date.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;   Month_2_Required_Steps__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Month 2 Req Steps Date Null</fullName>
        <actions>
            <name>Update_Month_2_Req_Steps_Date_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Onboarding Month Step field is unchecked clear the corresponding date field.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;  Month_2_Required_Steps__c = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Month 3 Opt Steps Date</fullName>
        <actions>
            <name>Update_Month_3_Opt_Steps_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Onboarding Month Step field is checked then change the corresponding date field to today&apos;s date.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;   Month_3_Optional_Steps__c  = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Month 3 Opt Steps Date Null</fullName>
        <actions>
            <name>Update_Month_3_Opt_Steps_Date_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Onboarding Month Step field is unchecked clear the corresponding date field.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;  Month_3_Optional_Steps__c = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Month 3 Req Steps Date</fullName>
        <actions>
            <name>Update_Month_3_Req_Steps_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Onboarding Month Step field is checked then change the corresponding date field to today&apos;s date.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;   Month_3_Required_Steps__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Month 3 Req Steps Date Null</fullName>
        <actions>
            <name>Update_Month_3_Req_Steps_Date_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Onboarding Month Step field is unchecked clear the corresponding date field.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;  Month_3_Required_Steps__c = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Month 4 Req Steps Date</fullName>
        <actions>
            <name>Update_Month_4_Req_Steps_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Onboarding Month Step field is checked then change the corresponding date field to today&apos;s date.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;   Month_4_Required_Steps__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Month 4 Req Steps Date Null</fullName>
        <actions>
            <name>Update_Month_4_Req_Steps_Date_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Onboarding Month Step field is unchecked clear the corresponding date field.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;  Month_4_Required_Steps__c = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Month 5 Opt Steps Date</fullName>
        <actions>
            <name>Update_Month_5_Opt_Steps_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Onboarding Month Step field is checked then change the corresponding date field to today&apos;s date.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;  Month_5_Optional_Steps__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Month 5 Opt Steps Date Null</fullName>
        <actions>
            <name>Update_Month_5_Opt_Steps_Date_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Onboarding Month Step field is unchecked clear the corresponding date field.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;  Month_5_Optional_Steps__c  = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Month 5 Req Steps Date</fullName>
        <actions>
            <name>Update_Month_5_Req_Steps_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Onboarding Month Step field is checked then change the corresponding date field to today&apos;s date.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;   Month_5_Required_Steps__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Month 5 Req Steps Date Null</fullName>
        <actions>
            <name>Update_Month_5_Req_Steps_Date_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Onboarding Month Step field is unchecked clear the corresponding date field.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;  Month_5_Required_Steps__c = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Month 6 Req Steps Date</fullName>
        <actions>
            <name>Update_Month_6_Req_Steps_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Onboarding Month Step field is checked then change the corresponding date field to today&apos;s date.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;  Month_6_Required_Steps__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Month 6 Req Steps Date Null</fullName>
        <actions>
            <name>Update_Month_6_Req_Steps_Date_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Onboarding Month Step field is unchecked clear the corresponding date field.</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)) &amp;&amp; $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp;  Month_6_Required_Steps__c = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - PowerSEO Help List Removed</fullName>
        <actions>
            <name>Delete_PowerSEO_Help_List_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_PowerSEO_Help_List_Description</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_PowerSEO_Help_List_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All RT w/ field displayed – Once the PowerSEO Help List checkbox is unchecked, this workflow clears the values in the PowerSEO Help List Date, PowerSEO Help List Description, and PowerSEO Help List Reason fields.  Manager comments will remain.</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),     PRIORVALUE(  PowerSEO_Help_List__c ) = TRUE,     PowerSEO_Help_List__c = FALSE     )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - RepMan Help List Added</fullName>
        <actions>
            <name>Update_RepMan_Help_List_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>All RT w/ fields – when the RepMan Help List checkbox is set to true, the date is captured in the RepMan Help List Date field.</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),       RepMan_Help_List__c  = TRUE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update - RepMan Help List Removed</fullName>
        <actions>
            <name>Delete_RepMan_Help_List_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_RepMan_Help_List_Description</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_RepMan_Help_List_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All RT w/ field displayed – Once the Social Help List checkbox is unchecked, this workflow clears the values in the Social Help List Date, Social Help List Description, and Social Help List Reason fields.  Manager comments will remain.</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),     PRIORVALUE(RepMan_Help_List__c) = TRUE,     RepMan_Help_List__c = FALSE     )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Social Help List Added</fullName>
        <actions>
            <name>Update_Social_Help_List_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All RT w/ fields – when the Social Help List checkbox is set to true, the date is captured in the Social Help List Date field.</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),       Social_Help_List__c  = TRUE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update - Social Help List Removed</fullName>
        <actions>
            <name>Delete_Social_Help_List_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_Social_Help_List_Description</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_Social_Help_List_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All RT w/ field displayed – Once the Social Help List checkbox is unchecked, this workflow clears the values in the Social Help List Date, Social Help List Description, and Social Help List Reason fields.  Manager comments will remain.</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),     PRIORVALUE(Social_Help_List__c) = TRUE,     Social_Help_List__c = FALSE     )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update - Trust Flow Date</fullName>
        <actions>
            <name>CB_Svc_Trust_Flow_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Trust Flow Date field when the Trust Flow field changes</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c))&amp;&amp;  $RecordType.Name = &quot;PowerSEO Account Plan&quot; &amp;&amp; ISCHANGED(Trust_Flow__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
