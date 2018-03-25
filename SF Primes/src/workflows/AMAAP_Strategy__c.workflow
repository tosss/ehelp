<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CB_DA_EML_A2_Strategy_Detail_Created</fullName>
        <description>CB DA EML A2 Strategy Detail Created</description>
        <protected>false</protected>
        <recipients>
            <field>LMA_Analyst_2_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Service_Templates/Alert_to_A2_AMA_Account_Plan_Strategy_Detail_Created</template>
    </alerts>
    <alerts>
        <fullName>CB_SVC_Alert_AMAAP_Strategy_Strategist</fullName>
        <description>CB SVC Alert AMAAP Strategy - Strategist</description>
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
        <template>IFS_Launch_Templates/CB_SVC_Alert_AMAAP_Strategy_Strategist</template>
    </alerts>
    <fieldUpdates>
        <fullName>AMAAPStrategy_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>AMAAPStrategy_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Svc_UPD_LMA_Analyst_2_Email</fullName>
        <description>Update the LMA Analyst 2 email from the AMA Account Plan</description>
        <field>LMA_Analyst_2_Email__c</field>
        <formula>Account_Plan__r.LMA_Analyst2_Email__c</formula>
        <name>CB Svc UPD LMA Analyst 2 Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AMAAPStrategy_Set_Migration_ID</fullName>
        <actions>
            <name>AMAAPStrategy_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB DA EML A2 Strategy Detail Created</fullName>
        <actions>
            <name>CB_DA_EML_A2_Strategy_Detail_Created</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CB_Svc_UPD_LMA_Analyst_2_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the AMA Account Plan AMAAP Strategy Detail is created Email the Analyst 2</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB SVC Alert Strategist AMAAP Strategy setup CTNs</fullName>
        <actions>
            <name>CB_SVC_Alert_AMAAP_Strategy_Strategist</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>For AMAP Strategy alert LMA Strategist to assign CTN&apos;s</description>
        <formula>NOT(Begins($User.Username, $Setup.GlobalSettings__c.Admin_Integration_Username__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
