<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_AA_SEO_SEO_Dealer_3rd_Party_Checked</fullName>
        <description>Alert AA, SEO - SEO Dealer/3rd Party Checked</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Advocate__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SEO_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_AA_SEO_SEO_3rd_Party_Dealer_Checked</template>
    </alerts>
    <alerts>
        <fullName>Alert_AA_SEO_SEO_Dealer_3rd_Party_Unchecked</fullName>
        <description>Alert AA, SEO - SEO Dealer/3rd Party Unchecked</description>
        <protected>false</protected>
        <recipients>
            <recipient>kelly.reynolds@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Account_Advocate__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SEO_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_AA_SEO_SEO_3rd_Party_Dealer_Unchecked</template>
    </alerts>
    <alerts>
        <fullName>Alert_Account_Team_when_Advocate_is_Added_or_Changed</fullName>
        <description>Alert Account Team when Advocate is Added or Changed</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Executive__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Online_Marketing_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>OwnerMktg_Specialist_lookup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SEO_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_Account_Team_when_Advocate_is_added_or_changed</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Account_Team_when_DAA_OMS_is_updated</fullName>
        <description>Alert to Account Team when DAA (OMS) is updated</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Advocate__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Account_Executive__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>OwnerMktg_Specialist_lookup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SEO_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_Account_Team_when_DAA_OMS_is_added_or_changed</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Account_Team_when_EMS_is_updated</fullName>
        <description>Alert to Account Team when EMS is updated</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Advocate__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Account_Executive__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Online_Marketing_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SEO_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_Account_Team_when_EMS_is_added_or_changed</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Account_Team_when_SEO_is_Updated</fullName>
        <description>Alert to Account Team when SEO is Updated</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Advocate__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Account_Executive__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Online_Marketing_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>OwnerMktg_Specialist_lookup__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_Account_Team_when_SEO_is_added_or_changed</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_NewCustomerOrderNotifications_when_PowerSEO_Cancels</fullName>
        <ccEmails>newcustomerordernotifications@cobalt.com</ccEmails>
        <description>Alert to NewCustomerOrderNotifications when PowerSEO Cancels</description>
        <protected>false</protected>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Services_Internal_Notifications/Alert_to_NewCustomerOrderNotifications_when_PowerSEO_Cancels</template>
    </alerts>
    <alerts>
        <fullName>Alert_when_DA_Helplist_is_checked</fullName>
        <description>Alert when DA Helplist is checked</description>
        <protected>false</protected>
        <recipients>
            <recipient>melissa.satterwhite@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Account_Advocate__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Online_Marketing_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/DA_Helplist_Notification</template>
    </alerts>
    <alerts>
        <fullName>Alert_when_PowerSEO_Help_List_is_checked</fullName>
        <description>Alert when PowerSEO Help List is checked</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Advocate__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SEO_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/PowerSEO_Help_List_Notification</template>
    </alerts>
    <alerts>
        <fullName>WebID_Primary_Flag_Change</fullName>
        <description>WebID Primary Flag Change</description>
        <protected>false</protected>
        <recipients>
            <recipient>nancy.durant@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Templates_for_Sales04t40000000/WebId_Primary_Website_Flag_Change</template>
    </alerts>
    <fieldUpdates>
        <fullName>CB_Svc_RepMan_Help_List_Date</fullName>
        <field>RepMan_Help_List_Date__c</field>
        <formula>Now()</formula>
        <name>CB_Svc_RepMan_Help_List_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Hot_List_Reason</fullName>
        <description>Removes hot list reason when the hot list check box is removed.</description>
        <field>Hot_List_Reason__c</field>
        <name>Clear Hot List Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DMS_Last_Modified_Date_Field_Update</fullName>
        <description>Changes the DMS Data Last Modified Date to today’s date</description>
        <field>DMS_Data_Last_Modified_Date__c</field>
        <formula>NOW()</formula>
        <name>DMS Last Modified Date Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_OEM_Text_Field</fullName>
        <description>Update OEM field</description>
        <field>OEM_Hidden__c</field>
        <formula>CASE( LEFT( Name , FIND( &quot;-&quot;,Name)-1 ) , 
&quot;gmps&quot;, &quot;GM&quot;, 
&quot;hyun&quot;, &quot;Hyundai&quot;, 
&quot;acura&quot;, &quot;Acura&quot;, 
&quot;audi&quot;, &quot;Audi&quot;, 
&quot;hond&quot;, &quot;Honda&quot;, 
&quot;hummer&quot;, &quot;HUMMER&quot;, 
&quot;hyundai&quot;, &quot;Hyundai&quot;, 
&quot;infiniti&quot;, &quot;Infiniti&quot;, 
&quot;kia&quot;, &quot;Kia&quot;, 
&quot;k1ia&quot;, &quot;Kia&quot;, 
&quot;jaguar&quot;, &quot;Jaguar&quot;, 
&quot;jeep&quot;, &quot;Jeep&quot;, 
&quot;lex&quot;, &quot;Lexus&quot;, 
&quot;lincoln&quot;, &quot;Ford&quot;, 
&quot;mazda&quot;, &quot;Mazda&quot;, 
&quot;mitsu&quot;, &quot;Mitsubishi&quot;, 
&quot;motp&quot;, &quot;Non Endorsed&quot;, 
&quot;asm&quot;, &quot;Non Endorsed&quot;, 
&quot;saturn&quot;, &quot;Saturn&quot;, 
&quot;scion&quot;, &quot;Scion&quot;, 
&quot;subaru&quot;, &quot;Subaru&quot;, 
&quot;suzuki&quot;, &quot;Suzuki&quot;, 
&quot;thrifty&quot;, &quot;Thrifty&quot;, 
&quot;toyd&quot;, &quot;Toyota&quot;, 
&quot;volvo&quot;, &quot;Volvo&quot;, 
&quot;vw&quot;, &quot;VW&quot;, 
&quot;nissan&quot;, &quot;Nissan&quot;, 
&quot;b1mw&quot;, &quot;BMW&quot;, 
&quot;chevy&quot;, &quot;GM&quot;, 
&quot;chrysler&quot;, &quot;Chrysler&quot;, 
&quot;dodge&quot;, &quot;Dodge&quot;, 
&quot;landrover&quot;, &quot;Landrover&quot;, 
&quot;ford&quot;, &quot;Ford&quot;, 
&quot;porsche&quot;, &quot;Porsche&quot;, 
&quot;saab&quot;, &quot;Saab&quot;, 
&quot;b2mw&quot;, &quot;BMW&quot;, 
&quot;hum&quot;, &quot;HUMMER&quot;, 
&quot;c1hr&quot;, &quot;Chrysler&quot;, 
&quot;gmcl&quot;, &quot;GM Canada&quot;, 
&quot;mini&quot;, &quot;MINI&quot;, 
&quot;holden&quot;, &quot;Holden&quot;,
&quot;holdennz&quot;, &quot;Holden NZ&quot;, 
&quot;gmlma&quot;, &quot;GMLMA&quot;,
&quot;Other&quot;)</formula>
        <name>Upd - OEM Text Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_DA_Help_List_Description</fullName>
        <field>DA_Help_List_Description__c</field>
        <name>Update DA Help List Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_DA_Help_List_Reason</fullName>
        <field>DA_Help_List_Reason__c</field>
        <name>Update DA Help List Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_PowerSEO_Help_List_Description</fullName>
        <field>PowerSEO_Help_List_Description__c</field>
        <name>Update PowerSEO Help List Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_PowerSEO_Help_List_Reason</fullName>
        <field>PowerSEO_Help_List_Reason__c</field>
        <name>Update PowerSEO Help List Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_RepMan_Helplist_Date</fullName>
        <field>RepMan_Help_List_Date__c</field>
        <name>Update RepMan Helplist Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_RepMan_Helplist_Description</fullName>
        <description>Clears the RepMan helplist description field when RepMan helplist is unchecked.</description>
        <field>RepMan_Help_List_Description__c</field>
        <name>Update RepMan Helplist Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_RepMan_Helplist_Reason</fullName>
        <description>Clears the RepMan helplist reason field when RepMan helplist is unchecked.</description>
        <field>RepMan_Help_List_Reason__c</field>
        <name>Update RepMan Helplist Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WebID_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>If(NOT(ISBLANK(External_ID__c)),External_ID__c,IF(ISBLANK(Locale__c),Name,Name+&quot;|&quot;+Locale__c))</formula>
        <name>WebID_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>X5_Star_Review_Last_Update</fullName>
        <field>X5_Star_Review_Last_Update__c</field>
        <formula>TODAY()</formula>
        <name>5 Star Review Last Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>X5_Star_Video_Last_Update</fullName>
        <field>X5_Star_Video_Last_Update__c</field>
        <formula>TODAY()</formula>
        <name>5 Star Video Last Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Alert AA%2FSEO %E2%80%93 SEO 3rd Party%2FDealer Checked</fullName>
        <actions>
            <name>Alert_AA_SEO_SEO_Dealer_3rd_Party_Checked</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>WebID__c.SEO_Opt_Out__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When the SEO - 3rd Party/Dealer box is checked by a manager, an alert will go out to the Advocate and SEO on the account team to let them know the dealer has opted out of optimization.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert AA%2FSEO %E2%80%93 Update %E2%80%93 SEO 3rd Party%2FDealer - Unchecked</fullName>
        <actions>
            <name>Alert_AA_SEO_SEO_Dealer_3rd_Party_Unchecked</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When the SEO - 3rd Party/Dealer box is checked by a manager, an alert will go out to the Advocate and SEO on the account team to let them know the dealer has opted back into optimization.</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),      SEO_Opt_Out__c =FALSE,      PRIORVALUE(SEO_Opt_Out__c)=TRUE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Alert to Account Team when AA is updated</fullName>
        <actions>
            <name>Alert_Account_Team_when_Advocate_is_Added_or_Changed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND ( ISCHANGED( Account_Advocate__c ), (NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Alert to Account Team when DAA %28OMS%29 is updated</fullName>
        <actions>
            <name>Alert_to_Account_Team_when_DAA_OMS_is_updated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND ( ISCHANGED( Online_Marketing_Specialist__c   ), (NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Alert to Account Team when EMS is updated</fullName>
        <actions>
            <name>Alert_to_Account_Team_when_EMS_is_updated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND ( ISCHANGED(  OwnerMktg_Specialist_lookup__c ), (NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Alert to Account Team when SEO is updated</fullName>
        <actions>
            <name>Alert_to_Account_Team_when_SEO_is_Updated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND ( ISCHANGED(  SEO_Specialist__c   ), (NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Alert to NewCustomerOrderNotifications when PowerSEO Cancels</fullName>
        <actions>
            <name>Alert_to_NewCustomerOrderNotifications_when_PowerSEO_Cancels</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notification when PowerSEO cancels so a ProCare SEO Specialist can be assigned, instead of a PowerSEO Specialist.</description>
        <formula>And( PRIORVALUE( PowerSEO_Product__c) &gt; 0, PowerSEO_Product__c = 0)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB - Upd - OEM Text Field</fullName>
        <actions>
            <name>Upd_OEM_Text_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update OEM Text field - OEm formula field will use this field to display OEM.</description>
        <formula>OR(ISNEW(),  ISCHANGED( Name ),  ISBLANK( OEM__c ) ) &amp;&amp; (NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CBLT_Helplist_Alert</fullName>
        <actions>
            <name>Alert_when_DA_Helplist_is_checked</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WebID__c.DA_Help_List__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sends an email notification when the DA Helplist box is checked.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CBLT_PSEO_Helplist_Alert</fullName>
        <actions>
            <name>Alert_when_PowerSEO_Help_List_is_checked</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WebID__c.PowerSEO_Help_List__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sends an email notification when the PowerSEO Helplist box is checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_ClearDAHelpListReason</fullName>
        <actions>
            <name>Update_DA_Help_List_Description</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_DA_Help_List_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule clears the DA Help List Reason and DA Help List description when the DA Help list box is unchecked.</description>
        <formula>And( DA_Help_List__c = False, NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_ClearPowerSEOHelpList</fullName>
        <actions>
            <name>Update_PowerSEO_Help_List_Description</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_PowerSEO_Help_List_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule clears the PowerSEO Help List Reason and PowerSEO Help List Description fields when the PowerSEO Help List box is unchecked.</description>
        <formula>AND( 	PowerSEO_Help_List__c = FALSE, 	NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) 	)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_ClearRepManHelpListReason</fullName>
        <actions>
            <name>Update_RepMan_Helplist_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_RepMan_Helplist_Description</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_RepMan_Helplist_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule clears the RepMan Help List Reason and RepMan Help List description when the RepMan Help list box is unchecked.</description>
        <formula>And(  RepMan_Help_List__c = False,  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_Svc_Update_RepMan_Help_List_Date</fullName>
        <actions>
            <name>CB_Svc_RepMan_Help_List_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All RT w/ fields – when the RepMan Help List checkbox is set to true, the date is captured in the RepMan Help List Date field.</description>
        <formula>AND(NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)), RepMan_Help_List__c = TRUE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DMS Last Modified Date</fullName>
        <actions>
            <name>DMS_Last_Modified_Date_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Will update DMS Last Modified Date field when either the DMS (Primary), DMS (Secondary), Username or Password fields are changed.</description>
        <formula>AND(  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  OR( ISCHANGED( DMS__c ) ,  ISCHANGED( DMS_Secondary__c ) ,  ISCHANGED( Password__c ) ,  ISCHANGED( User_Name__c )  ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Field Update - 5 Star Review Last Update Date</fullName>
        <actions>
            <name>X5_Star_Review_Last_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow will update the 5 Star Review Last Update field anytime one of the 5 Star Review fields are changed.</description>
        <formula>AND(         NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),           OR ( ISCHANGED( X5_Star_Reviews__c ) ,  ISCHANGED( X5_Star_Reviews1__c ) ,  ISCHANGED( X5_Star_Reviews2__c )  ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Field Update - 5 Star Video Last Update Date</fullName>
        <actions>
            <name>X5_Star_Video_Last_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow will update the 5 Star Video Last Update field anytime one of the 5 Star Video Review fields are updated.</description>
        <formula>AND(  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),    OR ( ISCHANGED(  X5_Star_Video_Link__c  ) ,  ISCHANGED(  X5_Star_Video_Text__c  )     ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Hot List Sync</fullName>
        <actions>
            <name>Clear_Hot_List_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WebID__c.Hot_List__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>This workflow will clear the Hot list reason selection and email health notes in regards to hot list to keep everything in sync.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WebID_Set_Migration_ID</fullName>
        <actions>
            <name>WebID_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WebId Primary Website Flag Change</fullName>
        <actions>
            <name>WebID_Primary_Flag_Change</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notification to Sales Ops anytime that the Primary flag on a Web Id is changed.</description>
        <formula>PRIORVALUE( Primary__c ) &lt;&gt;Primary__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
