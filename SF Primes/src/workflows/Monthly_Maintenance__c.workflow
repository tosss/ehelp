<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CB_SVC_GM_Factory_Preowned_Alert</fullName>
        <description>Email alert for Advocacy that a strategy for GM Factory Preowned Collection was assigned to them.</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/CB_SVC_GM_Preowned_Strategy_Notification</template>
    </alerts>
    <alerts>
        <fullName>URL_Changed_alert_EMS</fullName>
        <description>URL Changed alert EMS</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/URL_Changed_AA</template>
    </alerts>
    <alerts>
        <fullName>URL_changed_alert_AA</fullName>
        <description>URL changed alert AA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/URL_Changed_AA</template>
    </alerts>
    <alerts>
        <fullName>URL_changed_alert_DAS</fullName>
        <description>URL changed alert DAS</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/URL_Changed_AA</template>
    </alerts>
    <alerts>
        <fullName>URl_Changed_SEO</fullName>
        <description>URl Changed SEO</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/URL_Changed_AA</template>
    </alerts>
    <fieldUpdates>
        <fullName>CB_SvcMM_Upd_ThisMonth_to0</fullName>
        <description>Monthly Maintenance: Set field &apos;This Month&apos; to 0 when month of Action Due Date does NOT = Current Month</description>
        <field>This_Month__c</field>
        <formula>0</formula>
        <name>CB_SvcMM_Upd_ThisMonth_to0</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_SvcMM_Upd_ThisMonth_to1</fullName>
        <description>Monthly Maintenance: Set field &apos;This Month&apos; to 1 when month of Action Due Date = Current Month</description>
        <field>This_Month__c</field>
        <formula>1</formula>
        <name>CB_SvcMM_Upd_ThisMonth_to1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MonthlyMaintenance_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>MonthlyMaintenance_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Monthly_Maintenance_Due_Date</fullName>
        <description>Sets the MM due date based on the month field.</description>
        <field>Due_Date__c</field>
        <formula>CASE( MONTH( Month__c ) ,
2, Month__c +27,
4, Month__c +29,
6, Month__c +29,
9, Month__c +29,
11, Month__c +29,
Month__c + 30)</formula>
        <name>Monthly Maintenance Due Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Bing_Completed</fullName>
        <field>Bing_Map_Activity_Status__c</field>
        <literalValue>Completed</literalValue>
        <name>Set Bing Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Bing_Not_Complete</fullName>
        <field>Bing_Map_Activity_Status__c</field>
        <literalValue>Not Completed</literalValue>
        <name>Set Bing Not Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_City_Completed</fullName>
        <field>City_Search_Activity_Status__c</field>
        <literalValue>Completed</literalValue>
        <name>Set City Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_City_Not_Completed</fullName>
        <field>City_Search_Activity_Status__c</field>
        <literalValue>Not Completed</literalValue>
        <name>Set City Not Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Google_Completed</fullName>
        <field>Google_Places_Activity_Status__c</field>
        <literalValue>Completed</literalValue>
        <name>Set Google Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Google_Not_Completed</fullName>
        <field>Google_Places_Activity_Status__c</field>
        <literalValue>Not Completed</literalValue>
        <name>Set Google Not Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Insider_Completed</fullName>
        <field>Insider_Pages_Activity_Status__c</field>
        <literalValue>Completed</literalValue>
        <name>Set Insider Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Insider_Not_completed</fullName>
        <field>Insider_Pages_Activity_Status__c</field>
        <literalValue>Not Completed</literalValue>
        <name>Set Insider Not completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Yahoo_Completed</fullName>
        <field>Yahoo_Local_Activity_Status__c</field>
        <literalValue>Completed</literalValue>
        <name>Set Yahoo Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Yelp_Completed</fullName>
        <field>Yelp_Activity_Status__c</field>
        <literalValue>Completed</literalValue>
        <name>Set Yelp Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Yelp_Not_Completed</fullName>
        <field>Yelp_Activity_Status__c</field>
        <literalValue>Not Completed</literalValue>
        <name>Set Yelp Not Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_yahoo_Not_Completed</fullName>
        <field>Yahoo_Local_Activity_Status__c</field>
        <literalValue>Not Completed</literalValue>
        <name>Set yahoo Not Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>URL_Changed_AA</fullName>
        <field>Due_Date__c</field>
        <formula>date(2011,6,30)</formula>
        <name>URL Changed AA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_5_Star_Status_to_NA</fullName>
        <field>X5_Star_Review_Status__c</field>
        <literalValue>N/A</literalValue>
        <name>Update 5 Star Status to NA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_5_Star_Status_to_Not_Completed</fullName>
        <field>X5_Star_Review_Status__c</field>
        <literalValue>Not Completed</literalValue>
        <name>Update 5 Star Status to Not Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MM_Status</fullName>
        <description>Updates the MM Status field.</description>
        <field>Status__c</field>
        <literalValue>Completed</literalValue>
        <name>Update MM Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MM_Status_NA</fullName>
        <field>Status__c</field>
        <literalValue>N/A</literalValue>
        <name>Update MM Status NA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MM_Status_NC</fullName>
        <description>updates MM status to In Progress</description>
        <field>Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Update MM Status NC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opt_Plan_last_updated</fullName>
        <field>Opt_Plan_Last_Updated__c</field>
        <formula>Today()</formula>
        <name>Update Opt Plan last updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CB_MM_ThisMonthUpdate_to0</fullName>
        <actions>
            <name>CB_SvcMM_Upd_ThisMonth_to0</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Hidden Field &apos;This Month&apos; should always be 1 if action due is current month, otherwise 0</description>
        <formula>IF(MONTH(Action_Due_Date__c) &lt;&gt; MONTH(TODAY()),TRUE,FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_MM_ThisMonthUpdate_to1</fullName>
        <actions>
            <name>CB_SvcMM_Upd_ThisMonth_to1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Hidden Field &apos;This Month&apos; should always be 1 if action due is current month, otherwise 0</description>
        <formula>IF(MONTH(Action_Due_Date__c) = MONTH(TODAY()),TRUE,FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_NRM_5StarStatusNA</fullName>
        <actions>
            <name>Update_5_Star_Status_to_NA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Monthly_Maintenance__c.Type__c</field>
            <operation>notContain</operation>
            <value>5 Star</value>
        </criteriaItems>
        <criteriaItems>
            <field>Monthly_Maintenance__c.X5_Star_Review_Status__c</field>
            <operation>notEqual</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Sets the 5 Star status to N/A if 5 Star is not in the product mix field unless the status is already set to completed.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_NRM_5StarStatusNotCompleted</fullName>
        <actions>
            <name>Update_5_Star_Status_to_Not_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Monthly_Maintenance__c.Type__c</field>
            <operation>contains</operation>
            <value>5 Star</value>
        </criteriaItems>
        <criteriaItems>
            <field>Monthly_Maintenance__c.X5_Star_Review_Status__c</field>
            <operation>notEqual</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Sets the 5 Star status to Not Completed if 5 Star is in the product mix field unless the status is already set to completed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_OMSMM_UpdateOptPlanDate</fullName>
        <actions>
            <name>Update_Opt_Plan_last_updated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates a Date field with the current date whenever the Optimization Plan field is changed.</description>
        <formula>ISCHANGED( Optimization_Plan__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_OMSMM_UpdateStatusNA</fullName>
        <actions>
            <name>Update_MM_Status_NA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Monthly_Maintenance__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>OMS - Monthly Maintenance</value>
        </criteriaItems>
        <description>Sets the OMS MM record status to N/A when record is first created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_GM_Factory_Preowned</fullName>
        <actions>
            <name>CB_SVC_GM_Factory_Preowned_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify Advocate when a GM Factory Preowned Collection strategy is created on their Account Plan.</description>
        <formula>AND(NOT(BEGINS($User.Username,$Setup.GlobalSettings__c.Admin_Integration_Username__c)), ISPICKVAL(Status__c,&quot;Not Started&quot;), ISPICKVAL(Account_Plan__r.Account_Status__c,&quot;Active&quot;), ISPICKVAL(Action_Type__c, &quot;Focus Area&quot;), Focus_Area__c = &quot;GM Factory Preowned Collection&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EMS Update MM Status</fullName>
        <actions>
            <name>Update_MM_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Monthly_Maintenance__c.Overall_Campaign_Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Monthly_Maintenance__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EMS - Campaign Tracking</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Updates MM status when campaigns status goes to completed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EMS Update MM Status - NC</fullName>
        <actions>
            <name>Update_MM_Status_NC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Monthly_Maintenance__c.Overall_Campaign_Status__c</field>
            <operation>equals</operation>
            <value>Not Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Monthly_Maintenance__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EMS - Campaign Tracking</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Updates MM status when campaigns status goes to Not Completed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Monthly Maintenance Due Date Defaults</fullName>
        <actions>
            <name>Monthly_Maintenance_Due_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) and 3</booleanFilter>
        <criteriaItems>
            <field>Monthly_Maintenance__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>AA - Monthly Maintenance,SEO - Monthly Maintenance,OMS - Monthly Maintenance,DAS - Monthly Maintenance,EMS - Campaign Tracking,Social - Monthly Maintenance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Monthly_Maintenance__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>RMS - Activity Tracking</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Sets AA,OMS, &amp; Social Monthly Maintenance due date based on Month field.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MonthlyMaintenance_Set_Migration_ID</fullName>
        <actions>
            <name>MonthlyMaintenance_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>RMS MM Calc City Complete</fullName>
        <actions>
            <name>Set_City_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets status to completed when there are more than 4 characters in the activity field</description>
        <formula>IF (AND( LEN( City_Search_Activity__c  )&gt;4,  $RecordType.Name = &quot;RMS - Activity Tracking&quot; ) ,TRUE,FALSE)  &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMS MM Calc City NotComplete</fullName>
        <actions>
            <name>Set_City_Not_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Activity Status to not complete if activity has less than 4 chars or is blank.</description>
        <formula>IF (AND( OR(LEN( City_Search_Activity__c  )&lt;=4, ISblank(City_Search_Activity__c) ), $RecordType.Name = &quot;RMS - Activity Tracking&quot; ) ,TRUE,FALSE) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMS MM Calc Insider Complete</fullName>
        <actions>
            <name>Set_Insider_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets status to completed when there are more than 4 characters in the activity field</description>
        <formula>IF (AND( LEN(Insider_Pages_Activity__c)&gt;4,  $RecordType.Name = &quot;RMS - Activity Tracking&quot; ) ,TRUE,FALSE) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMS MM Calc Insider NotComplete</fullName>
        <actions>
            <name>Set_Insider_Not_completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Activity Status to not complete if activity has less than 4 chars or is blank.</description>
        <formula>IF (AND( OR(LEN( Insider_Pages_Activity__c  )&lt;=4, ISblank(Insider_Pages_Activity__c) ), $RecordType.Name = &quot;RMS - Activity Tracking&quot; ) ,TRUE,FALSE) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMS MM Calc Yelp Complete</fullName>
        <actions>
            <name>Set_Yelp_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets status to completed when there are more than 4 characters in the activity field</description>
        <formula>IF (AND( LEN(Yelp_Activity__c)&gt;4,  $RecordType.Name = &quot;RMS - Activity Tracking&quot; ) ,TRUE,FALSE) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMS MM Calc Yelp NotComplete</fullName>
        <actions>
            <name>Set_Yelp_Not_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Activity Status to not complete if activity has less than 4 chars or is blank.</description>
        <formula>IF (AND( OR(LEN( Yelp_Activity__c  )&lt;=4, ISblank(Yelp_Activity__c) ), $RecordType.Name = &quot;RMS - Activity Tracking&quot; ) ,TRUE,FALSE) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMS%2FPowerSEO MM Calc Bing Complete</fullName>
        <actions>
            <name>Set_Bing_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets status to completed when there are more than 4 characters in the activity field</description>
        <formula>IF (AND( LEN(Bing_Map_Activity__c )&gt;4, OR(  $RecordType.Name = &quot;RMS - Activity Tracking&quot;,  $RecordType.Name = &quot;PowerSEO - Monthly Maintenance&quot; ) ) ,TRUE,FALSE)  &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMS%2FPowerSEO MM Calc Bing NotComplete</fullName>
        <actions>
            <name>Set_Bing_Not_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Bing Activity Status to not complete if bing activity has less than 4 chars or is blank.</description>
        <formula>IF (AND( OR(LEN(Bing_Map_Activity__c )&lt;=4, ISblank(Bing_Map_Activity__c) ), OR(  $RecordType.Name = &quot;RMS - Activity Tracking&quot;,  $RecordType.Name = &quot;PowerSEO - Monthly Maintenance&quot; ) ) ,TRUE,FALSE) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMS%2FPowerSEO MM Calc Google Complete</fullName>
        <actions>
            <name>Set_Google_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets status to completed when there are more than 4 characters in the activity field</description>
        <formula>IF (AND( LEN( Google_Places_Activity__c )&gt;4, OR(  $RecordType.Name = &quot;RMS - Activity Tracking&quot;,  $RecordType.Name = &quot;PowerSEO - Monthly Maintenance&quot; ) ) ,TRUE,FALSE)  &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMS%2FPowerSEO MM Calc Google NotComplete</fullName>
        <actions>
            <name>Set_Google_Not_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Activity Status to not complete if activity has less than 4 chars or is blank.</description>
        <formula>IF (AND( OR(LEN( Google_Places_Activity__c  )&lt;=4, ISblank(Google_Places_Activity__c) ), OR(  $RecordType.Name = &quot;RMS - Activity Tracking&quot;,  $RecordType.Name = &quot;PowerSEO - Monthly Maintenance&quot; ) ) ,TRUE,FALSE) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMS%2FPowerSEO MM Calc Yahoo Complete</fullName>
        <actions>
            <name>Set_Yahoo_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets status to completed when there are more than 4 characters in the activity field</description>
        <formula>IF (AND( LEN(Yahoo_Local_Activity__c)&gt;4, OR(  $RecordType.Name = &quot;RMS - Activity Tracking&quot;,  $RecordType.Name = &quot;PowerSEO - Monthly Maintenance&quot; ) ) ,TRUE,FALSE) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMS%2FPowerSEO MM Calc Yahoo NotComplete</fullName>
        <actions>
            <name>Set_yahoo_Not_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Activity Status to not complete if activity has less than 4 chars or is blank.</description>
        <formula>IF (AND( OR(LEN( Yahoo_Local_Activity__c  )&lt;=4, ISblank(Yahoo_Local_Activity__c) ), OR(  $RecordType.Name = &quot;RMS - Activity Tracking&quot;,  $RecordType.Name = &quot;PowerSEO - Monthly Maintenance&quot; ) ) ,TRUE,FALSE) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>URL Changed Notification</fullName>
        <actions>
            <name>URL_changed_alert_AA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Monthly_Maintenance__c.URL_Changed_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When the URL Changed Date field gets filled in.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
