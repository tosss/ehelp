<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Contact_Status_Change_Notification</fullName>
        <description>Contact Status Change Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Forecasting - Digital Solutions Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AA_Templates/Contact_Data_Change_Notifies_Contact_Owner</template>
    </alerts>
    <alerts>
        <fullName>EMP_HRInvoluntaryTermEmail</fullName>
        <ccEmails>HelpMeIT@CDK.com</ccEmails>
        <description>EMP_HRInvoluntaryTermEmail</description>
        <protected>false</protected>
        <recipients>
            <recipient>craig.brantner@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dave.hanson@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lyle.warszewik@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>peter.vonbusch@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rose.gilligan@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Corp_HR/HR_Involuntary_Termination_HTML</template>
    </alerts>
    <fieldUpdates>
        <fullName>CB_Contact_UPD_No_Longer_There</fullName>
        <description>If the No Longer There checkbox was checked and has been unchecked, remove &quot;- Left&quot; from the contact name.</description>
        <field>Email</field>
        <formula>Substitute( Email, &quot;-left&quot;, &quot;&quot;)</formula>
        <name>CB_Contact_UPD_No_Longer_There_Rmv_Left</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Contact_UPD_No_Longer_There_Add_Left</fullName>
        <description>If the Contact is marked as INACTIVE or No Longer There add  &quot;- Left&quot; to the contact name.</description>
        <field>Email</field>
        <formula>Email + &quot;-left&quot;</formula>
        <name>CB_Contact_UPD_No_Longer_There_Add_Left</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>CASESAFEID(Id)</formula>
        <name>Contact_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>NoLongerThereCheckbox</fullName>
        <field>LastName</field>
        <formula>If(Contains(LastName, &quot;- LEFT&quot;), LastName, LastName &amp; &quot; - LEFT&quot;)</formula>
        <name>No Longer There - Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RemoveLeftfromLastName</fullName>
        <field>LastName</field>
        <formula>Substitute( LastName, &quot;- LEFT&quot;, &quot;&quot;)</formula>
        <name>Remove &quot;- LEFT&quot; from LastName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Contact_s_Designated_DSM</fullName>
        <field>Account_Designated_DSM_EMail__c</field>
        <formula>Account.Designated_DSM__r.Email</formula>
        <name>Set Contact&apos;s Designated DSM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Contact_No_Longer_There_EML_UPD</fullName>
        <field>Email</field>
        <formula>IF(NOT(ISBLANK(Email)), Email + &quot;.left&quot;, Email)</formula>
        <name>Upd - Contact - No Longer There-EML UPD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Contact_No_Longer_There_Uncheck</fullName>
        <field>Email</field>
        <formula>Substitute( Email, &quot;.left&quot;, &quot;&quot;)</formula>
        <name>Upd - Contact - No Longer There- Uncheck</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Contact Status Change Notifies Account Team</fullName>
        <actions>
            <name>Contact_Status_Change_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifies Account Team when contact status changes</description>
        <formula>ISCHANGED( Status__c ) &amp;&amp;  OR(NOT(BEGINS($User.Username,$Setup.GlobalSettings__c.Admin_Integration_Username__c)), NOT(BEGINS($User.Username,$Setup.GlobalSettings__c.DMG_Contact_ByPass_Username__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contact_Set_Migration_ID</fullName>
        <actions>
            <name>Contact_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EMP_HRInvoluntaryTermEmail</fullName>
        <actions>
            <name>EMP_HRInvoluntaryTermEmail</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Associates_Last_Termination_Date_Time__c ) &amp;&amp; NOT( ISBLANK(Associates_Last_Termination_Date_Time__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Designated DSM when Account Changes</fullName>
        <actions>
            <name>Set_Contact_s_Designated_DSM</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AccountId  &lt;&gt; &apos;&apos; &amp;&amp; OR(NOT(BEGINS($User.Username,$Setup.GlobalSettings__c.Admin_Integration_Username__c)), NOT(BEGINS($User.Username,$Setup.GlobalSettings__c.DMG_Contact_ByPass_Username__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Contact - No Longer There - Checkbox</fullName>
        <actions>
            <name>NoLongerThereCheckbox</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Upd_Contact_No_Longer_There_EML_UPD</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the No Longer There checkbox is checked then &quot;- LEFT&quot;  needs to be added to the contact name.</description>
        <formula>OR( AND( ISCHANGED( No_Longer_There__c ), No_Longer_There__c = True),  AND( ISCHANGED(Status__c ), CASE(Status__c, &quot;Inactive&quot;, &quot;Inactive&quot;, &quot;&quot;) = &quot;Inactive&quot;))  &amp;&amp; NOT(BEGINS(Account_Name_Text__c, &quot;CDK Global&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Contact - No Longer There - Checkbox Unchecked</fullName>
        <actions>
            <name>RemoveLeftfromLastName</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Upd_Contact_No_Longer_There_Uncheck</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the No Longer There checkbox was checked and has been unchecked, remove &quot;- LEFT&quot;  from the contact name.</description>
        <formula>OR( AND(ISCHANGED(No_Longer_There__c), No_Longer_There__c = False),  AND(ISCHANGED(Status__c), CASE(Status__c, &quot;Active&quot;, &quot;Active&quot;, &quot;&quot;) = &quot;Active&quot;))  &amp;&amp; NOT(BEGINS(Account_Name_Text__c, &quot;CDK Global&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
