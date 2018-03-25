<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_to_LMA_Analysts_UI_Setup</fullName>
        <description>Alert to LMA Analysts – UI Setup</description>
        <protected>false</protected>
        <recipients>
            <field>LMA_Analyst2__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LMA_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/AMA_UI_Setup_Date</template>
    </alerts>
    <alerts>
        <fullName>Alert_to_LMA_Strategist_Setup_Complete</fullName>
        <description>Alert to LMA Strategist – Setup Complete</description>
        <protected>false</protected>
        <recipients>
            <field>LMA_Strategist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFS_Launch_Templates/AMA_Setup_Complete</template>
    </alerts>
    <fieldUpdates>
        <fullName>LauncProduct_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>LauncProduct_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AMA Launch Product Alert %E2%80%93 Setup Complete Date</fullName>
        <actions>
            <name>Alert_to_LMA_Strategist_Setup_Complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch_Product__c.LMA_Setup_Complete__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>AMA Launch Product Alert: Email alert to LMA Strategist when Setup Complete date entered</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AMA Launch Product Alert %E2%80%93 UI Setup Date</fullName>
        <actions>
            <name>Alert_to_LMA_Analysts_UI_Setup</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Launch_Product__c.Ready_for_UI_Setup__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notContain</operation>
            <value>integration_user@adp.com</value>
        </criteriaItems>
        <description>AMA Launch Product Alert: Email alert to LMA Analysts when UI Setup is ready</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LauncProduct_Set_Migration_ID</fullName>
        <actions>
            <name>LauncProduct_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
