<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Closed_Won_Opportunity_Notification</fullName>
        <description>Closed Won Opportunity Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>matthew.condon@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>reeves.ronser@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Templates_for_Sales04t40000000/Notify_for_Closed_Won_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>DS_SLS_UnhooktoDash_Checked</fullName>
        <description>DS_SLS_UnhooktoDash_Checked</description>
        <protected>false</protected>
        <recipients>
            <recipient>jim.quinlan@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>scott.keller@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Baseline_Channel_Sales_Templates/Unhook_to_Dash_Template</template>
    </alerts>
    <alerts>
        <fullName>DS_SLS_UnhooktoDash_Checked_HoffmanSales</fullName>
        <description>DS_SLS_UnhooktoDash_Checked_HoffmanSales</description>
        <protected>false</protected>
        <recipients>
            <recipient>jim.quinlan@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lisa.senger@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Baseline_Channel_Sales_Templates/Unhook_to_Dash_Template</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_Opportiunity_Created_By_DAAs</fullName>
        <description>Email - Alert Opportiunity Created By DAAs</description>
        <protected>false</protected>
        <recipients>
            <field>OppMgrEmail__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Digital_Sales_Ops_Templates/Opportunity_Created_BY_DAAs</template>
    </alerts>
    <alerts>
        <fullName>Email_TSM_Opportunity_is_Closed_Won</fullName>
        <ccEmails>NRM@adp.com</ccEmails>
        <ccEmails>Patti.Spelman@adp.com</ccEmails>
        <description>Email - TSM Opportunity is Closed-Won</description>
        <protected>false</protected>
        <recipients>
            <recipient>Forecasting - Telephony Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Baseline_Channel_Sales_Templates/Email_Opp_TSM_Opportunity_is_Closed_Won</template>
    </alerts>
    <alerts>
        <fullName>ISR_Closed_Opp_Update_Warning</fullName>
        <description>ISR Closed Opp Update Warning</description>
        <protected>false</protected>
        <recipients>
            <recipient>amy.huseth@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ADP_Dealer_Services/ISR_Closed_Opp_Update_Warning</template>
    </alerts>
    <alerts>
        <fullName>Ifanopportunityisreassignedtoabaselinereptherepshouldreceiveanemailnotifica</fullName>
        <description>If an opportunity is reassigned to a baseline rep the rep should receive an email notification</description>
        <protected>false</protected>
        <recipients>
            <field>OppMgrEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ADP_Opportunity_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ADP_Dealer_Services/OppOwnerChange</template>
    </alerts>
    <alerts>
        <fullName>NotifyBaselineRepthatISROpportunityClosed</fullName>
        <description>Notify Baseline Rep that ISR Opportunity Closed</description>
        <protected>false</protected>
        <recipients>
            <recipient>Forecasting - Baseline Rep</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <field>ADP_Opportunity_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ADP_Dealer_Services/Notify_Baseline_of_ISR_Deal_Closure</template>
    </alerts>
    <alerts>
        <fullName>Recap_Reminder_for_Migration_Team_B</fullName>
        <description>Recap Reminder for Migration Team B</description>
        <protected>false</protected>
        <recipients>
            <recipient>cameron.wong@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BZ_Migration_Templates/Paperwork_Completed_Recap_Needed</template>
    </alerts>
    <alerts>
        <fullName>Recap_Reminder_for_Migration_Team_C</fullName>
        <description>Recap Reminder for Migration Team C</description>
        <protected>false</protected>
        <recipients>
            <recipient>cameron.wong@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BZ_Migration_Templates/Paperwork_Completed_Recap_Needed</template>
    </alerts>
    <alerts>
        <fullName>Recap_Reminder_for_Migration_Team_D</fullName>
        <description>Recap Reminder for Migration Team D</description>
        <protected>false</protected>
        <recipients>
            <recipient>cameron.wong@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BZ_Migration_Templates/Paperwork_Completed_Recap_Needed</template>
    </alerts>
    <fieldUpdates>
        <fullName>Add_1_for_Business_Hurts</fullName>
        <description>Adds to the data quality score if the business hurts field is filled out.</description>
        <field>Data_Quality_Count__c</field>
        <formula>IF( ISBLANK( What_are_the_business_hurts__c ) ,  Data_Quality_Count__c, Data_Quality_Count__c +1 )</formula>
        <name>NOTUSED Add 1 for Business Hurts</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Add_1_for_Has_Activity</fullName>
        <description>Adds 1 point to the score if the Has Activity field is populated</description>
        <field>Data_Quality_Count__c</field>
        <formula>IF( ISBLANK(  Has_Activity__c ) , Data_Quality_Count__c, Data_Quality_Count__c +1 )</formula>
        <name>NOTUSED Add 1 for Has Activity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Add_1_for_Next_Steps</fullName>
        <field>Data_Quality_Count__c</field>
        <formula>IF( ISBLANK(  NextStep  ) , Data_Quality_Count__c, Data_Quality_Count__c +1 )</formula>
        <name>NOTUSED Add 1 for Next Steps</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Add_1_for_Oppty_Influencers</fullName>
        <field>Data_Quality_Count__c</field>
        <formula>IF( Num_of_Influencer__c &gt;0, Data_Quality_Count__c +1,Data_Quality_Count__c)</formula>
        <name>NOTUSED Add 1 for Oppty Influencers</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Add_1_for_Products</fullName>
        <description>Add 1 to score if products are populated</description>
        <field>Data_Quality_Count__c</field>
        <formula>IF( Product_QC_Count__c &gt;0,  Data_Quality_Count__c +1, Data_Quality_Count__c )</formula>
        <name>NOTUSED Add 1 for Products</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Add_1_for_Stage</fullName>
        <field>Data_Quality_Count__c</field>
        <formula>IF(   ISPICKVAL(StageName, &apos;Working&apos;), Data_Quality_Count__c +1,

IF(ISPICKVAL(StageName, &apos;Closed Won&apos;), Data_Quality_Count__c +1
,Data_Quality_Count__c)
)</formula>
        <name>NOTUSED Add 1 for Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Add_2_for_Has_Activity</fullName>
        <field>Data_Quality_Count__c</field>
        <formula>IF( ISBLANK( Has_Activity__c ) , Data_Quality_Count__c, Data_Quality_Count__c +2 )</formula>
        <name>NOTUSED Add 2 for Has Activity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Add_2_for_Oppty_Influencers</fullName>
        <field>Data_Quality_Count__c</field>
        <formula>IF( Num_of_Influencer__c &gt;0, Data_Quality_Count__c +2,Data_Quality_Count__c)</formula>
        <name>NOTUSED Add 2 for Oppty Influencers</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Opp_Data_Quality_Score_Enrollment_Con</fullName>
        <description>Updated Data Quality Score on Opp for Enrollment Opp Types</description>
        <field>Data_Quality_Count__c</field>
        <formula>IF( Product_QC_Count__c &gt;0, 1, 0) +
IF( ISBLANK( Has_Activity__c ) , 0, 1) +
IF( Num_of_Influencer__c &gt;0, 2, 0) +
IF( ISPICKVAL(StageName, &apos;Working&apos;), 1, IF(ISPICKVAL(StageName, &apos;Closed Won&apos;), 1, 0))</formula>
        <name>CB_Opp_Data_Quality_Score_Enrollment_Con</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Opp_Data_Quality_Score_Pipeline_Conso</fullName>
        <description>Updated Data Quality Score on Opp for Pipeline Opp Types</description>
        <field>Data_Quality_Count__c</field>
        <formula>IF( ISBLANK( What_are_the_business_hurts__c ), 0, 1) +
IF( ISBLANK( Has_Activity__c ), 0, 1) +
IF( ISBLANK( NextStep ), 0, 1) +
IF( Num_of_Influencer__c &gt;0, 1, 0) +
IF( Product_QC_Count__c &gt;0, 1, 0)</formula>
        <name>CB_Opp_Data_Quality_Score_Pipeline_Conso</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_InsideSales_SFDC_Field</fullName>
        <field>SFDC__c</field>
        <formula>Account.Name</formula>
        <name>DS_InsideSales_SFDC Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_Sls_Opp_Name_Update</fullName>
        <field>Name</field>
        <formula>ADP_Opportunity_Owner__r.LastName   + &quot; - &quot; + IS_Product__r.Name</formula>
        <name>DS_Sls_Opp_Name_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Data_Quality_Score_Calculation</fullName>
        <description>Sets Data Quality to zero</description>
        <field>Data_Quality_Count__c</field>
        <formula>0</formula>
        <name>Reset Data Quality Score</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Increment_Push_Counter</fullName>
        <field>Winning_Competitor__c</field>
        <literalValue>ABC Competitor</literalValue>
        <name>Increment Push Counter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Increment_Push_Counter_Field</fullName>
        <description>Increment the Push Counter by 1</description>
        <field>Push_Counter__c</field>
        <formula>IF( 
ISNULL( Push_Counter__c ), 
1, 
Push_Counter__c + 1 
)</formula>
        <name>Increment Push Counter Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opp_OwnrMgr_Email_Set</fullName>
        <description>get Opp Owner Email from &quot;Opp Owner Mgr&quot; and put in this email field so it can be used in an email workflow</description>
        <field>OppMgrEmail__c</field>
        <formula>IF(CONTAINS( UPPER(ADP_Opportunity_Owner__r.UserRole.Name), &quot;REP&quot;), OppMgr__c, 
 IF(CONTAINS( UPPER(ADP_Opportunity_Owner__r.UserRole.Name), &quot;DSM&quot;), OppMgr__c, &quot;&quot;))</formula>
        <name>Opp - OwnrMgr_Email Set</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Owner_2_Admin</fullName>
        <description>UPD - Opportunity Owner 2 Admin since not set in trigger as failing</description>
        <field>OwnerId</field>
        <lookupValue>integration_user@adp.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Opportunity Owner 2 Admin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>CASESAFEID(Id) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>Opportunity_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Digital_Advertising_QC</fullName>
        <field>Digital_Advertising_QC__c</field>
        <formula>RSF_Digital_Advertising_QC__c</formula>
        <name>Set Digital Advertising QC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Digital_Marketing_QC</fullName>
        <field>Digital_Marketing_QC__c</field>
        <formula>BLANKVALUE(RSF_Digital_Marketing_QC__c, 0) + BLANKVALUE(RSF_Digital_Advertising_QC__c, 0)</formula>
        <name>Set Digital Marketing QC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Opp_NS_Document_Attached_to_False</fullName>
        <field>NS_Document_Attached__c</field>
        <literalValue>0</literalValue>
        <name>Upd - Opp NS Document Attached to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Opp_NS_Document_Attached_to_True</fullName>
        <field>NS_Document_Attached__c</field>
        <literalValue>1</literalValue>
        <name>Upd - Opp NS Document Attached to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Closed Won Notification</fullName>
        <actions>
            <name>Closed_Won_Opportunity_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Pipeline</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Notifies Jae Kim when an opportunity is closed-won so he can confirm the sales order for closed deals.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_InsideSales_SFDC Field</fullName>
        <actions>
            <name>DS_InsideSales_SFDC_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This WF updates the SFDC field for improved Global Search results</description>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DS_SLS_EML_UnhooktoDash_Checked</fullName>
        <actions>
            <name>DS_SLS_UnhooktoDash_Checked</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.DS_SLS_Unhook_to_Dash__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Region__c</field>
            <operation>notEqual</operation>
            <value>Hoffman Sales</value>
        </criteriaItems>
        <description>Send email to Scott Keller and Jim Quinlan when Unhook to Dash is checked for Account Region not equal to Hoffman Sales</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_SLS_EML_UnhooktoDash_Checked_HoffmanSales</fullName>
        <actions>
            <name>DS_SLS_UnhooktoDash_Checked_HoffmanSales</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.DS_SLS_Unhook_to_Dash__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Region__c</field>
            <operation>equals</operation>
            <value>Hoffman Sales</value>
        </criteriaItems>
        <description>Send email to Lisa Senger and Jim Quinlan when Unhook to Dash is checked for Account Region Hoffman Sales</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_Sls_Opp_Name_Update</fullName>
        <actions>
            <name>DS_Sls_Opp_Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>WF to update Opportunity Name on DS ISR  (5 - Inside Sales Opportunity)created opportunities with the ISR Last Name and the IS Product type.</description>
        <formula>AND( RecordTypeId = &quot;012400000000xbZ&quot;, OR(ADP_Opportunity_Owner__r.ProfileId = &quot;00e40000000rPTw&quot;, (ADP_Opportunity_Owner__r.ProfileId = &quot;00e40000000rQff&quot; &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp;  NOT(BEGINS(ADP_Opportunity_Owner__r.Title, &quot;CDP&quot;)) &amp;&amp; NOT(BEGINS(ADP_Opportunity_Owner__r.Title, &quot;PV ISR&quot;)))), CASE(StageName, &quot;Closed - Won&quot;, &quot;Closed - Won&quot;, &quot; &quot;) &lt;&gt; &quot;Closed - Won&quot;, CASE(StageName, &quot;Closed - Lost&quot;, &quot;Closed - Lost&quot;, &quot; &quot;) &lt;&gt; &quot;Closed - Lost&quot;, CASE(StageName, &quot;Inactive/Cancelled&quot;, &quot;Inactive/Cancelled&quot;, &quot; &quot;) &lt;&gt; &quot;Inactive/Cancelled&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Data Quality Score Calculation - Enrollment Record Type</fullName>
        <actions>
            <name>Add_1_for_Has_Activity</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Add_1_for_Products</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Add_1_for_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Add_2_for_Oppty_Influencers</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CB_Opp_Data_Quality_Score_Enrollment_Con</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Data_Quality_Score_Calculation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Enrollment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Updates the Data Quality Score field based on field values.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Data Quality Score Calculation - Pipeline Record Type</fullName>
        <actions>
            <name>CB_Opp_Data_Quality_Score_Pipeline_Conso</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Data Quality Score field based on field values.</description>
        <formula>AND (RecordTypeId = &quot;01240000000ICUP&quot;, NOT( ISBLANK( Name )), NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email - ISR Closed Opp Update Warning</fullName>
        <actions>
            <name>ISR_Closed_Opp_Update_Warning</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>ISR Closed-Won Opp updated warning to IS Supv/IS Mgr</description>
        <formula>OR( ((ISCHANGED(ISR_QC__c) || ISCHANGED(CloseDate)) &amp;&amp; CASE(StageName, &quot;Closed - Won&quot;, &quot;Closed - Won&quot;, &quot; &quot;) = &quot;Closed - Won&quot; &amp;&amp; CASE(PRIORVALUE(StageName), &quot;Closed - Won&quot;, &quot;Closed - Won&quot;, &quot; &quot;) = &quot;Closed - Won&quot;), ((ISCHANGED(StageName) &amp;&amp; CASE(StageName, &quot;Closed - Won&quot;, &quot;Closed - Won&quot;, &quot; &quot;) &lt;&gt; &quot;Closed - Won&quot; &amp;&amp; CASE(PRIORVALUE(StageName), &quot;Closed - Won&quot;, &quot;Closed - Won&quot;, &quot; &quot;) = &quot;Closed - Won&quot;))   ) &amp;&amp; BEGINS(ADP_Opportunity_Owner__r.Title, &quot;ISR&quot;) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email - Notify Baseline Rep of ISR deal closed</fullName>
        <actions>
            <name>NotifyBaselineRepthatISROpportunityClosed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>If the opportunity is of the inside sales type, the baseline rep listed on the sales team and the opportunity owner are emailed a notification.</description>
        <formula>AND( ADP_Opportunity_Owner__r.UserRoleId &lt;&gt; &quot;00E40000000oFd3&quot;, RecordTypeId = &quot;012400000000xbZ&quot;, CASE(StageName, &quot;Closed - Won&quot;, &quot;Closed - Won&quot;, &quot; &quot;) = &quot;Closed - Won&quot;, NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email - Opp - TSM Opp Closed</fullName>
        <actions>
            <name>Email_TSM_Opportunity_is_Closed_Won</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When an opportunity with the opportunity type of Baseline Multi-Channel”, “Inside Sales”, or “Network Solutions” has one of the following occur:
a.  it’s status is set to “Closed-Won” and “N/S Document Attached” is set to “true”.</description>
        <formula>OR(ISCHANGED(StageName), ISCHANGED(NS_Document_Attached__c), ISCHANGED(Value_Scorecard_Upload_Date__c), ISCHANGED(Device_Worksheet_Upload_Date__c)) &amp;&amp; IF(ISPICKVAL(StageName, &quot;Closed - Won&quot;), True, False) &amp;&amp; IF(OR(NOT(ISBLANK(Value_Scorecard_Upload_Date__c)), NOT(ISBLANK(Device_Worksheet_Upload_Date__c))), True, False) &amp;&amp; OR(RecordTypeId = &quot;012400000000xbU&quot;, RecordTypeId = &quot;012400000000xbZ&quot;, RecordTypeId  = &quot;012400000000ymP&quot;) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email - Opp Owner Change</fullName>
        <actions>
            <name>Ifanopportunityisreassignedtoabaselinereptherepshouldreceiveanemailnotifica</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>If an opportunity is reassigned to a baseline rep the rep should receive an email notification</description>
        <formula>AND(OR(ISCHANGED( ADP_Opportunity_Owner__c ), AND( ISNEW() , ADP_Opportunity_Owner__c &lt;&gt; CreatedById ) ), NOT(CONTAINS( UPPER(ADP_Opportunity_Owner__r.Profile.Name), &apos;ADMIN&apos;)),  CASE(Account.Region__c , &quot;NIADA&quot;, &quot;NIADA&quot;, &quot; &quot;) &lt;&gt; &apos;NIADA&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email - Opportunity Created By DAAs</fullName>
        <actions>
            <name>Email_Alert_Opportiunity_Created_By_DAAs</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Now with Digital Advertising Analysts (DAAs) creating upsell Opportunities, the Managers of the DSMs, (the DOSs) want to be notified when this type of Opporutnity is created.</description>
        <formula>AND( RecordTypeId = &quot;01240000000ICUP&quot;,  ISPICKVAL(Internal_Lead_Source__c, &quot;Digital Ad Spend Specialist&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity_Set_Migration_ID</fullName>
        <actions>
            <name>Opportunity_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Push Counter</fullName>
        <actions>
            <name>Increment_Push_Counter_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Increment the Push Counter field by 1</description>
        <formula>IF(  CloseDate &gt; PRIORVALUE( CloseDate ),  IF (MONTH(CloseDate) &lt;&gt; MONTH(PRIORVALUE( CloseDate )) ,  TRUE,  FALSE),  FALSE) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Recap Reminder Team A</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>BZ Migration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Migration_Team__c</field>
            <operation>equals</operation>
            <value>A</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Recap_Completed__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recap Reminder Team B</fullName>
        <actions>
            <name>Recap_Reminder_for_Migration_Team_B</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>BZ Migration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Migration_Team__c</field>
            <operation>equals</operation>
            <value>B</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Recap_Completed__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recap Reminder Team C</fullName>
        <actions>
            <name>Recap_Reminder_for_Migration_Team_C</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>BZ Migration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Migration_Team__c</field>
            <operation>equals</operation>
            <value>C</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Recap_Completed__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recap Reminder Team D</fullName>
        <actions>
            <name>Recap_Reminder_for_Migration_Team_D</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>BZ Migration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Migration_Team__c</field>
            <operation>equals</operation>
            <value>D</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Recap_Completed__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Digital Advertising QC_DEL</fullName>
        <actions>
            <name>Set_Digital_Advertising_QC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Set Digital Advertising QC - If Digital Solutions Opp</description>
        <formula>((Digital_Advertising_QC__c == null || Digital_Advertising_QC__c &lt;&gt; RSF_Digital_Advertising_QC__c) &amp;&amp; NOT (ISBLANK(RSF_Digital_Advertising_QC__c )) &amp;&amp; RSF_Digital_Advertising_QC__c &gt;= 0)  &amp;&amp; ( $RecordType.Id = &quot;01240000000ICUP&quot; || $RecordType.Id = &quot;01240000000ICUO&quot; || $RecordType.Id = &quot;01240000000ICUN&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Digital Marketing QC</fullName>
        <actions>
            <name>Set_Digital_Marketing_QC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Digital Marketing QC - If Digital Solutions Opp</description>
        <formula>(ISNULL(Digital_Marketing_QC__c) ||  BLANKVALUE(Digital_Marketing_QC__c, 0)  &lt;&gt; (BLANKVALUE(RSF_Digital_Marketing_QC__c, 0) + BLANKVALUE(RSF_Digital_Advertising_QC__c, 0))) &amp;&amp;   ((NOT (ISBLANK(RSF_Digital_Marketing_QC__c )) &amp;&amp; BLANKVALUE(RSF_Digital_Marketing_QC__c, 0) &gt;= 0) || (NOT (ISBLANK(RSF_Digital_Advertising_QC__c )) &amp;&amp; BLANKVALUE(RSF_Digital_Advertising_QC__c, 0) &gt;= 0))  &amp;&amp; (  CASESAFEID($RecordType.Id) = &quot;01240000000ICUNAA4&quot; || CASESAFEID($RecordType.Id) = &quot;01240000000ICUOAA4&quot; || CASESAFEID($RecordType.Id) = &quot;01240000000ICUPAA4&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Task - Next Follow up Date</fullName>
        <actions>
            <name>OpportunityFollowUp</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed – Lost,Inactive/Cancelled</value>
        </criteriaItems>
        <description>A task will be sent out to the opportunity owner 30 days after it was closed or no decision has been made.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Opp - NS Document Attached - False</fullName>
        <actions>
            <name>Upd_Opp_NS_Document_Attached_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( ISBLANK( Value_Scorecard_Upload_Date__c ), ISBLANK( Device_Worksheet_Upload_Date__c ), NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Opp - NS Document Attached - True</fullName>
        <actions>
            <name>Upd_Opp_NS_Document_Attached_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the user enters a date in either the “Value Scorecard (Upload Date)” field OR the “Device Worksheet (Upload Date)” field – set the “N/S Document Attached” checkbox to be true.</description>
        <formula>OR( NOT(ISBLANK( Value_Scorecard_Upload_Date__c )), NOT(ISBLANK(  Device_Worksheet_Upload_Date__c ))) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Opp Owner 2 Admin</fullName>
        <actions>
            <name>Opportunity_Owner_2_Admin</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Upd - Opp Owner 2 Admin...since need to comment out of trigger due to failure on key rep converting lead for account they own.</description>
        <formula>OwnerId &lt;&gt; &apos;00540000000zU2KAAU&apos;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Opp Owner Mgr Email Set</fullName>
        <actions>
            <name>Opp_OwnrMgr_Email_Set</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Copy Opp Owner&apos;s Mgr&apos;s email from OppMgr field to OppMgr_Email field</description>
        <formula>OR(ISCHANGED( ADP_Opportunity_Owner__c ), ISNEW() )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>OpportunityFollowUp</fullName>
        <assignedToType>owner</assignedToType>
        <description>This is a reminder to follow up with the Opportunity that is listed under the Related To column on the Task section on the homepage.  It Stage value of Decision/Cancelled or Closed Lost was previously selected.</description>
        <dueDateOffset>30</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Opportunity Follow Up</subject>
    </tasks>
</Workflow>
