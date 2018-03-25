<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CB_DA_EML_A1_A2_Strategy_Change_Request_Created</fullName>
        <description>CB DA EML A1 &amp; A2 Strategy Change Request Created</description>
        <protected>false</protected>
        <recipients>
            <field>LMA_Analyst_2_EMail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>LMA_Analyst_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Service_Templates/Alert_A1_and_A2_AMA_Account_Plan_Strategy_Change_Request_is_Created</template>
    </alerts>
    <fieldUpdates>
        <fullName>AMAAPStrategyChangeRequest_Set_Migration</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>AMAAPStrategyChangeRequest_Set_Migration</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Svc_UPD_LMA_Analyst_2_Email</fullName>
        <description>Update the Analyst 2 email form the account plan email</description>
        <field>LMA_Analyst_2_EMail__c</field>
        <formula>Account_Plan__r.LMA_Analyst2_Email__c</formula>
        <name>CB Svc UPD LMA Analyst 2 Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_Svc_UPD_LMA_Analyst_Email</fullName>
        <description>Update the LMA Analyst Email from AMA Account Plan</description>
        <field>LMA_Analyst_Email__c</field>
        <formula>Account_Plan__r.LMA_Analyst_Email__c</formula>
        <name>CB Svc UPD LMA Analyst Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AMAAPStrategyChangeRequest_Set_Migration_ID</fullName>
        <actions>
            <name>AMAAPStrategyChangeRequest_Set_Migration</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB DA EML A1 %26 A2 Strategy Change Request Created</fullName>
        <actions>
            <name>CB_DA_EML_A1_A2_Strategy_Change_Request_Created</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CB_Svc_UPD_LMA_Analyst_2_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CB_Svc_UPD_LMA_Analyst_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the AMA Account Plan AMAAP Strategy Change Request is created Email the LMA Analyst 1 and  2</description>
        <formula>NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
