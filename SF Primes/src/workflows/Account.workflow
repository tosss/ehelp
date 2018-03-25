<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Account_Owner_Change_Notification</fullName>
        <description>Account Owner Change Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>nancy.durant@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Templates_for_Sales04t40000000/Workflow_Email_Account_Owner_Change</template>
    </alerts>
    <alerts>
        <fullName>Account_Owner_Change_Notification_to_AA</fullName>
        <description>Account Owner Change Notification to AA</description>
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
        <template>AA_Templates/Workflow_Email_Account_Owner_Change_AA</template>
    </alerts>
    <alerts>
        <fullName>Account_Region_Not_match_User_Region</fullName>
        <ccEmails>ds.salesops@cdk.com</ccEmails>
        <description>Account Region Not match User Region</description>
        <protected>false</protected>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ADP_Dealer_Services/Account_Region_Not_match_User_Region</template>
    </alerts>
    <alerts>
        <fullName>Account_Segment_Not_match_User_Segment</fullName>
        <description>Account Segment Not match User Segment</description>
        <protected>false</protected>
        <recipients>
            <recipient>DataLibrarians</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ADP_Dealer_Services/Account_Segment_Not_match_User_Segment</template>
    </alerts>
    <alerts>
        <fullName>Accountiseditedandithasinactivesitetype</fullName>
        <description>Account is edited and it has inactive site type</description>
        <protected>false</protected>
        <recipients>
            <recipient>DataLibrarians</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>dave.hanson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>irfan.siddiqui@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ADP_Dealer_Services/AccountswithInactiveSiteType</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_Key_Rep_Changes_for_Update_Party_to_DS_SalesOps</fullName>
        <ccEmails>ds.Salesops@cdk.com</ccEmails>
        <description>Alert to Key Rep Changes for Update Party to DS_SalesOps</description>
        <protected>false</protected>
        <recipients>
            <recipient>irfan.siddiqui@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Automation_Templates/New_Key_Rep_Changes_Notification_New_Party</template>
    </alerts>
    <alerts>
        <fullName>AnemailissenteverytimetheAccountingProductstobesoldfieldischanged</fullName>
        <description>NOTUSED An email is sent every time the Accounting Products to be sold field is changed.</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ADP_Dealer_Services/ProductChangesontheAccountAccountingProductstobeSold</template>
    </alerts>
    <alerts>
        <fullName>AnemailissenteverytimetheFrontendProductstobesoldfieldischanged</fullName>
        <description>NOTUSED An email is sent every time the Front-end Products to be sold field is changed.</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ADP_Dealer_Services/ProductChangesontheAccountFrontendProductstobeSold</template>
    </alerts>
    <alerts>
        <fullName>AnemailissenteverytimethePartsProductstobesoldfieldischanged</fullName>
        <description>NOTUSED An email is sent every time the Parts Products to be sold field is changed.</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ADP_Dealer_Services/ProductChangesontheAccountPartsProductstobeSold</template>
    </alerts>
    <alerts>
        <fullName>AnemailissenteverytimetheServiceProductstobesoldfieldischanged</fullName>
        <description>NOTUSED An email is sent every time the Service Products to be sold field is changed.</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ADP_Dealer_Services/ProductChangesontheAccountServiceProductstobeSold</template>
    </alerts>
    <alerts>
        <fullName>CB_Stop_Gap_New_DS_Party_Addition_Temp</fullName>
        <description>CB Stop-Gap New DS Party Addition-Temp</description>
        <protected>false</protected>
        <recipients>
            <recipient>cameron.wong@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ADP_Dealer_Services/CB_New_DS_Party_Addition</template>
    </alerts>
    <alerts>
        <fullName>CB_Stop_Gap_New_DS_Party_Update_Temp</fullName>
        <description>CB Stop-Gap New DS Party Update-Temp</description>
        <protected>false</protected>
        <recipients>
            <recipient>cameron.wong@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ADP_Dealer_Services/CB_New_DS_Party_Update</template>
    </alerts>
    <alerts>
        <fullName>CS_ES_LMA_RFP_RD_Email</fullName>
        <description>CS_ES_LMA RFP RD and AMA Region Alias Email</description>
        <protected>false</protected>
        <recipients>
            <field>CB_ES_AMA_Regional_Alias_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>LMA_Regional_Director1__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/LMA_RFP_Submission_Response</template>
    </alerts>
    <alerts>
        <fullName>Do_Not_Sell_Alert</fullName>
        <description>Do Not Sell Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Director of Digital Sales</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Enterprise Sales Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Inside Sales Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>Designated_DSM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AA_Templates/Do_Not_Sell_Alert</template>
    </alerts>
    <alerts>
        <fullName>IftheAccountNameischangedtheBaselineRepandtheDOSshouldbenotified</fullName>
        <description>If the Account Name is changed the Baseline Rep and the DOS should be notified</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>Key_DOS__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ADP_Dealer_Services/AccountNameUpdate</template>
    </alerts>
    <alerts>
        <fullName>Notify_for_Account_Strategy_Completion</fullName>
        <description>Notify for Account Strategy Completion</description>
        <protected>false</protected>
        <recipients>
            <field>Designated_DSM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Templates_for_Sales04t40000000/Notify_for_Account_Strategy_Completion</template>
    </alerts>
    <alerts>
        <fullName>OutOfBusinessAccounts</fullName>
        <description>Out-Of-Business Accounts</description>
        <protected>false</protected>
        <recipients>
            <recipient>jeannie.jamieson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>melody.anderson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ADP_Dealer_Services/Out_Of_Business_Account</template>
    </alerts>
    <alerts>
        <fullName>Out_Of_Business_PFW_Accounts</fullName>
        <ccEmails>chris.oliver@adp.com</ccEmails>
        <description>Out-Of-Business - PFW (Accounts Chris Oliver No longer here - delete)</description>
        <protected>false</protected>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ADP_Dealer_Services/Out_Of_Business_Account</template>
    </alerts>
    <alerts>
        <fullName>changemadetogendeptproductstobeSoldfield</fullName>
        <description>NOTUSED change made to gen dept products to be Sold field</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ADP_Dealer_Services/ProductChangesontheAccountGenProductstobeSold</template>
    </alerts>
    <fieldUpdates>
        <fullName>Account_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>IF (NOT(ISBLANK(PartyID__c)), PartyID__c, CASESAFEID(Id))</formula>
        <name>Account_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_ES_AMA_Regional_Alias</fullName>
        <field>CB_ES_AMA_Regional_Alias_Email__c</field>
        <formula>AMA_Regional_Alias__c</formula>
        <name>CB_ES_AMA_Regional_Alias</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_SVC_DGVP_Contract_URL_Last_Updated</fullName>
        <description>Updates the field DGVP Contract URL Last Updated when the field Dealer Group Volume Pricing Contract URL is changed on the Account object.</description>
        <field>CB_SVC_DGVP_URL_Last_Updated__c</field>
        <formula>NOW()</formula>
        <name>DGVP Contract URL Last Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_SVC_DGVP_Contract_URL_Last_Updated_By</fullName>
        <description>Updates the field DGVP Contract URL Last Updated By when the field Dealer Group Volume Pricing Contract URL is changed on the Account object.</description>
        <field>CB_SVC_DGVP_URL_Last_Updated_By__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName</formula>
        <name>DGVP Contract URL Last Updated By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Duplicate_Date</fullName>
        <field>Duplicate_Date__c</field>
        <name>Clear Duplicate Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_OOB_Date</fullName>
        <field>Out_of_Business_Date__c</field>
        <name>Clear OOB Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Duplicate_Date</fullName>
        <field>Duplicate_Date__c</field>
        <formula>NOW()</formula>
        <name>Set Duplicate Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_OOB_Date</fullName>
        <description>Set OOB Date</description>
        <field>Out_of_Business_Date__c</field>
        <formula>NOW()</formula>
        <name>Set OOB Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Account_Bus_License_Last_Updated</fullName>
        <description>Upd - Account Business License Last Updated</description>
        <field>Business_License_Last_Updated__c</field>
        <formula>NOW()</formula>
        <name>Upd - Account Bus License Last Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Account_Legal_Entity_Last_Updated</fullName>
        <description>Upd - Account Legal Entity Last Updated</description>
        <field>Legal_Entity_Last_Updated__c</field>
        <formula>Now()</formula>
        <name>Upd - Account Legal Entity Last Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Single_Point_Checked</fullName>
        <field>Single_Point__c</field>
        <literalValue>1</literalValue>
        <name>Upd - Single Point - Checked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Single_Point_Unchecked</fullName>
        <field>Single_Point__c</field>
        <literalValue>0</literalValue>
        <name>Upd - Single Point - Unchecked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MDA_Last_Modified_By</fullName>
        <field>MDA_Last_Updated_By__c</field>
        <formula>$User.Alias</formula>
        <name>Update – MDA Last Modified By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_MDA_Last_Modified_Date</fullName>
        <field>MDA_Last_Updated__c</field>
        <formula>NOW()</formula>
        <name>Update – MDA Last Modified Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_VIP_Since_to_Blank</fullName>
        <description>When the VIP is unchecked set the VIP Since date to blank</description>
        <field>VIP_Since__c</field>
        <name>Update VIP Since to Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_VIP_Since_to_Today</fullName>
        <description>When the VIP field is checked update the VIP Since field to Today</description>
        <field>VIP_Since__c</field>
        <formula>Today()</formula>
        <name>Update VIP Since to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account Owner Change</fullName>
        <actions>
            <name>Account_Owner_Change_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Account Owner Change notifies Sales Mgmt</description>
        <formula>(ISCHANGED( Designated_DSM__c ) &amp;&amp; LastModifiedBy.ProfileId = &quot;00e400000013Y5j&quot;) &amp;&amp; NOT(BEGINS ($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Account Owner Change Notify AA</fullName>
        <actions>
            <name>Account_Owner_Change_Notification_to_AA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Account Owner Change notification for Account Advocate</description>
        <formula>And ( ISCHANGED(  Designated_DSM__c ), (NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Account_Set_Migration_ID</fullName>
        <actions>
            <name>Account_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB_ES_AMA_Regional_Alias</fullName>
        <actions>
            <name>CB_ES_AMA_Regional_Alias</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.AMA_Regional_Alias__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_ES_LMARFP_Created_Email_Alert</fullName>
        <actions>
            <name>CS_ES_LMA_RFP_RD_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.LMA_RFP_Created__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Email Alert to the AMA Regional Alias and LMA RD Email when the LMA_RFP_Created__c box is cheked by Process builder CB_ES_LMA Created Notification</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CB_SVC_DGVP_CONTRACT_URL_LAST_UPDATED</fullName>
        <actions>
            <name>CB_SVC_DGVP_Contract_URL_Last_Updated</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CB_SVC_DGVP_Contract_URL_Last_Updated_By</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Description: Update the DGVP Contract URL Last Updated and DGVP Contract URL Last Updated By fields when the field Dealer Group Volume Pricing Contract URL is changed on the Account object.</description>
        <formula>AND (  NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c)), $Profile.Name&lt;&gt;&quot;Cobalt Service Data Exporting&quot;, PRIORVALUE(CB_SVC_DG_VOLUME_PRICING_CONTRACT_URL__c)&lt;&gt;CB_SVC_DG_VOLUME_PRICING_CONTRACT_URL__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email - Account Name Update</fullName>
        <actions>
            <name>IftheAccountNameischangedtheBaselineRepandtheDOSshouldbenotified</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>If the Account Name is changed the Baseline Rep and the DOS should be notified</description>
        <formula>ISCHANGED( Name )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email - Account Region %3C%3E User Region</fullName>
        <actions>
            <name>Account_Region_Not_match_User_Region</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email-Account Region &lt;&gt; User Region</description>
        <formula>AND ( ISCHANGED( Key_Rep__c ), Out_of_Business__c &lt;&gt; TRUE, Duplicate__c &lt;&gt; TRUE, NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)), CASE(Region__c, &quot;Hoffman Sales&quot;, &quot;Hoffman Sales&quot;, &quot;ARG&quot;, &quot;ARG&quot;, &quot;CANADA&quot;, &quot;CANADA&quot;, &quot;Central&quot;, &quot;Central&quot;, &quot;Southwest&quot;, &quot;Southwest&quot;, &quot;WEST&quot;, &quot;WEST&quot;, &quot;SOUTH&quot;, &quot;SOUTH&quot;,&quot;NORTH&quot;, &quot;NORTH&quot;, &quot;TRUCK&quot;, &quot;TRUCK&quot;, &quot;NATIONAL&quot;, &quot;NATIONAL&quot;,&quot;ENTERPRISE&quot;, &quot;ENTERPRISE&quot;, &quot;PFW&quot;, &quot;PFW&quot;, &quot;Independent Truck Dealers&quot;, &quot;Independent Truck Dealers&quot;, &quot; &quot;) &lt;&gt; CASE(Key_Rep__r.Region__c, &quot;Hoffman Sales&quot;, &quot;Hoffman Sales&quot;, &quot;ARG&quot;, &quot;ARG&quot;, &quot;CANADA&quot;, &quot;CANADA&quot;, &quot;Central&quot;, &quot;Central&quot;, &quot;Southwest&quot;, &quot;Southwest&quot;, &quot;WEST&quot;, &quot;WEST&quot;, &quot;SOUTH&quot;, &quot;SOUTH&quot;,&quot;NORTH&quot;, &quot;NORTH&quot;, &quot;TRUCK&quot;, &quot;TRUCK&quot;, &quot;NATIONAL&quot;, &quot;NATIONAL&quot;,&quot;ENTERPRISE&quot;, &quot;ENTERPRISE&quot;, &quot;PFW&quot;, &quot;PFW&quot;, &quot;Independent Truck Dealers&quot;, &quot;Independent Truck Dealers&quot;, &quot; &quot;), CASE(Key_Rep__r.Segment_Code__c, &quot;MULTIPLE&quot;, &quot;MULTIPLE&quot;, &quot; &quot;) &lt;&gt; &quot;MULTIPLE&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email - Account Segment %3C%3E User Segment</fullName>
        <actions>
            <name>Account_Segment_Not_match_User_Segment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email-Account Segment &lt;&gt; User Segment</description>
        <formula>AND ( OR( ISCHANGED( Key_Rep__c ),  ISCHANGED( Segment_Code__c )), Out_of_Business__c &lt;&gt; TRUE,  Duplicate__c &lt;&gt; TRUE, NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)), CASE(Segment_Code__c, &quot;NAAT&quot;, &quot;NAAT&quot;, &quot;PFW&quot;, &quot;PFW&quot;, &quot;AUTG&quot;, &quot;AUTG&quot;, &quot; &quot;) &lt;&gt; CASE(Key_Rep__r.Segment_Code__c, &quot;NAAT&quot;, &quot;NAAT&quot;, &quot;PFW&quot;, &quot;PFW&quot;, &quot;AUTG&quot;, &quot;AUTG&quot;, &quot; &quot;), CASE(Key_Rep__r.Segment_Code__c, &quot;MULTIPLE&quot;, &quot;MULTIPLE&quot;, &quot; &quot;) &lt;&gt; &quot;MULTIPLE&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email - Account with Inactive Site Type</fullName>
        <actions>
            <name>Accountiseditedandithasinactivesitetype</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>If an account has a site type that is no longer active and the account is edited, email Data Librarian to change the site type</description>
        <formula>AND (NOT (ISBLANK( Site_Type__c )), Site_Type__r.Active__c = False,NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email - CB Stop-Gap New Party Addition-Temp</fullName>
        <actions>
            <name>CB_Stop_Gap_New_DS_Party_Addition_Temp</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>needed as &apos;stop-gap&apos; until CCF can be modified to send these emails.</description>
        <formula>AND(NOT(ISBLANK(PartyID__c)), CASE(Segment_Code__c, &quot;NAAT&quot;, &quot;NAAT&quot;, &quot; &quot;) = &quot;NAAT&quot;, CASE( Site_Type__r.Name, &quot;Auto&quot;, &quot;Auto&quot;, &quot;Corporation&quot;, &quot;Corporation&quot;, &quot;District&quot;, &quot;District&quot;, &quot;Group&quot;, &quot;Group&quot;, &quot;OEM&quot;, &quot;OEM&quot;, &quot;Under Construction&quot;, &quot;Under Construction&quot;, &quot;Used Vehicle&quot;, &quot;Used Vehicle&quot;, &quot; &quot;) = CASE( Site_Type__r.Name, &quot;Auto&quot;, &quot;Auto&quot;, &quot;Corporation&quot;, &quot;Corporation&quot;, &quot;District&quot;, &quot;District&quot;, &quot;Group&quot;, &quot;Group&quot;, &quot;OEM&quot;, &quot;OEM&quot;, &quot;Under Construction&quot;, &quot;Under Construction&quot;, &quot;Used Vehicle&quot;, &quot;Used Vehicle&quot;, &quot; &quot;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email - CB Stop-Gap New Party Update-Temp</fullName>
        <actions>
            <name>CB_Stop_Gap_New_DS_Party_Update_Temp</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>needed for &apos;stop-gap&apos; until CCF can be modified to send these emails.</description>
        <formula>AND(NOT(ISBLANK(Account_Number__c)), NOT(ISBLANK(PartyID__c)), OR(ISCHANGED(Name), ISCHANGED( BillingStreet ), ISCHANGED( BillingCity ), ISCHANGED( BillingState ), ISCHANGED( BillingPostalCode ), ISCHANGED(Phone), ISCHANGED(Fax), ISCHANGED(Site_Type__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email - Key Rep Changes - Unassigned Key Rep</fullName>
        <actions>
            <name>Alert_to_Key_Rep_Changes_for_Update_Party_to_DS_SalesOps</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When an Account Owner is changed to &apos;Unassigned Key-Rep&apos; send an email to ds.SalesOps@cdkcom.  Since accounts not created with unassigned rep just using this WF (3/13).  Also not need filter skipping integrationuser chgs...since Int User for new parties.</description>
        <formula>AND(NOT(ISNEW()), OwnerId = &apos;0054000000231OB&apos;,  ISCHANGED(OwnerId) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email - Out of Business - NAAT Accounts</fullName>
        <actions>
            <name>OutOfBusinessAccounts</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>for NAAT Accounts -- Email to Jeannie Jamieson and Melody Anderson.</description>
        <formula>AND( Out_of_Business__c = TRUE, CASE( Segment_Code__c , &quot;NAAT&quot;, &quot;NAAT&quot;, &quot; &quot;) = &quot;NAAT&quot;, NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email - Out of Business - PFW Accounts</fullName>
        <actions>
            <name>Out_Of_Business_PFW_Accounts</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>for PFW Accounts only -- email to Chris Oliver...no longer at cdk inactivate 10/15/15</description>
        <formula>AND( Out_of_Business__c = TRUE,  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)), CASE(Segment_Code__c, &quot;PFW&quot;, &quot;PFW&quot;, &quot; &quot;) = &quot;PFW&quot; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Alert - Do not sell</fullName>
        <actions>
            <name>Do_Not_Sell_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Do_Not_Sell__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>Sends an email alert to the sales team when Finance checks the &apos;Do Not Sell&apos; box</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify for Account Strategy Completion</fullName>
        <active>false</active>
        <booleanFilter>(1 OR 2 OR 3 OR 4 OR 5) And 6</booleanFilter>
        <criteriaItems>
            <field>Account.Cobalt_Strategy__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.COF_Summary__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Description</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Collector__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OwnerId</field>
            <operation>notEqual</operation>
            <value>Cast Iron Integration</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Account - Single Point - Checked</fullName>
        <actions>
            <name>Upd_Single_Point_Checked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If a Corporation, Group or District is removed from the Account (so there is no Corporation, Group or District specified on the account), then flip the field to be checked.</description>
        <formula>AND( OR(ISCHANGED( Corporation__c ), ISCHANGED( Group__c ), ISCHANGED( District__c )), ISBLANK(Corporation__c), ISBLANK(Group__c), ISBLANK(District__c), Site_Type__r.Corporation_Flag__c = False, Site_Type__r.Group_Flag__c = False, Site_Type__r.District_Flag__c = False, Single_Point__c = False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Account - Single Point - Unchecked</fullName>
        <actions>
            <name>Upd_Single_Point_Unchecked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If a Corporation, Group, or District is set on the Account, the Single Point checkbox should be flipped to unchecked.</description>
        <formula>AND( OR(ISCHANGED( Corporation__c ), ISCHANGED( Group__c ), ISCHANGED( District__c )), (NOT(ISBLANK(Corporation__c)) || NOT(ISBLANK(Group__c)) || NOT(ISBLANK(District__c))), Site_Type__r.Corporation_Flag__c = False, Site_Type__r.Group_Flag__c = False, Site_Type__r.District_Flag__c = False, Single_Point__c = True)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Account Business License Last Updated</fullName>
        <actions>
            <name>Upd_Account_Bus_License_Last_Updated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Business License Last Updated</description>
        <formula>OR( ISCHANGED(Business_License_Name__c) , ISCHANGED(Business_License_Address__c), ISCHANGED(Business_License_City__c), ISCHANGED(Business_License_State__c), ISCHANGED(Business_License_Postal__c), ISCHANGED( Business_License_Phone__c ), ISCHANGED( Business_License_Contact__c) , ISCHANGED( Business_License_Expiration_Date__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Account Legal Entity Last Updated</fullName>
        <actions>
            <name>Upd_Account_Legal_Entity_Last_Updated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Upd - Account Legal Entity Last Updated</description>
        <formula>OR( ISCHANGED(Legal_Entity_Name__c) , ISCHANGED(Legal_Entity_Address__c), ISCHANGED(Legal_Entity_City__c), ISCHANGED(Legal_Entity_State__c), ISCHANGED(Legal_Entity_Postal__c), ISCHANGED( Legal_Entity_Phone__c )) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Clear Duplicate Date</fullName>
        <actions>
            <name>Clear_Duplicate_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear Duplicate Date when Duplicate__c flag is un-checked.</description>
        <formula>AND(Duplicate__c = FALSE, NOT(ISBLANK( Duplicate_Date__c )))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Clear OOB Date</fullName>
        <actions>
            <name>Clear_OOB_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Remove Date if OOB set to FALSE</description>
        <formula>AND( Out_of_Business__c = FALSE, NOT(ISBLANK(  Out_of_Business_Date__c )))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Set Duplicate Date</fullName>
        <actions>
            <name>Set_Duplicate_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Duplicate Date when Duplicate__c flag checked.</description>
        <formula>AND(Duplicate__c = TRUE,  ISBLANK( Duplicate_Date__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Set OOB Date</fullName>
        <actions>
            <name>Set_OOB_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set OOB Date when OOB Flag is set to TRUE</description>
        <formula>AND( Out_of_Business__c = TRUE, ISBLANK(  Out_of_Business_Date__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Upd MDA Mod Fields %E2%80%93 MDA Info Change</fullName>
        <actions>
            <name>Update_MDA_Last_Modified_By</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_MDA_Last_Modified_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Any Record Types with the Digital MDA fields displayed:  Will update the Last Modified Date and Last Modified By fields based on who changes the MDA Link and MDA fields.</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp;  NOT(BEGINS($User.Username,&quot;castiron.integration@adp.com&quot;))&amp;&amp; (    ISCHANGED( MDA_NEW__c )||    ISCHANGED( MDA_Link__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update VIP Since to Blank</fullName>
        <actions>
            <name>Update_VIP_Since_to_Blank</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the VIP is unchecked set the VIP Since date to blank</description>
        <formula>And ( VIP__c =False, (NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update VIP Since to Today</fullName>
        <actions>
            <name>Update_VIP_Since_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the VIP field is checked set the VIP Since date to today</description>
        <formula>And ( VIP__c =True, (NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
