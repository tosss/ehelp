<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DS_BDC_NSABrianScholley</fullName>
        <description>DS_BDC_NSABrianScholley</description>
        <protected>false</protected>
        <recipients>
            <recipient>brian.schooley@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BDC_Docs/BDC_Controller_Notification</template>
    </alerts>
    <alerts>
        <fullName>DS_BDC_NSAController</fullName>
        <description>DS_BDC_NSAController</description>
        <protected>false</protected>
        <recipients>
            <field>Controller_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>patti.spelman@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BDC_Docs/BDC_Controller_Notification</template>
    </alerts>
    <alerts>
        <fullName>DS_BDC_NSAController_Reminder</fullName>
        <description>DS_BDC_NSAController_Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>Controller_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>patti.spelman@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BDC_Docs/BDC_Controller_Notification_Reminder</template>
    </alerts>
    <fieldUpdates>
        <fullName>DS_BDC_ControllerDate</fullName>
        <field>Controller_Review_Date_Time__c</field>
        <formula>Now()</formula>
        <name>DS_BDC_ControllerDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_BDC_ControllerDate_Null</fullName>
        <field>Controller_Review_Date_Time__c</field>
        <name>DS_BDC_ControllerDate_Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_BDC_ControllerEmail</fullName>
        <field>Controller_Email__c</field>
        <formula>Deal_State__r.Controller_Email__c</formula>
        <name>DS_BDC_ControllerEmail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_BDC_ControllerName</fullName>
        <field>Controller_Name__c</field>
        <formula>LastModifiedBy.FirstName &amp;&quot; &quot;&amp;LastModifiedBy.LastName</formula>
        <name>DS_BDC_ControllerName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_BDC_ControllerName_Null</fullName>
        <field>Controller_Name__c</field>
        <name>DS_BDC_ControllerName_Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_BDC_NSA_AttachedDate</fullName>
        <field>NSA_Attached_Date__c</field>
        <formula>Now()</formula>
        <name>DS_BDC_NSA_AttachedDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_BDC_NSA_AttachedDate_Null</fullName>
        <field>NSA_Attached_Date__c</field>
        <name>DS_BDC_NSA_AttachedDate_Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DS_BDC_RollCallDate</fullName>
        <field>Roll_Call_Date__c</field>
        <formula>Deal_State__r.Roll_Call_Date__c</formula>
        <name>DS_BDC_RollCallDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SQTNSA_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>SQTNSA_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>DS_BDC_EML_NSABrianScholley</fullName>
        <actions>
            <name>DS_BDC_NSABrianScholley</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SQT_NSA__c.NSA_Attached_By__c</field>
            <operation>contains</operation>
            <value>SCHOOLEY</value>
        </criteriaItems>
        <criteriaItems>
            <field>SQT_NSA__c.Roll_Call_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Send email when NSA (addendum) attached by Brian Schooley</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_BDC_EML_NSAController</fullName>
        <actions>
            <name>DS_BDC_NSAController</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SQT_NSA__c.Roll_Call_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>SQT_NSA__c.Controller_Review_Date_Time__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>SQT_NSA__c.NSA_Attached_By__c</field>
            <operation>notContain</operation>
            <value>SCHOOLEY</value>
        </criteriaItems>
        <description>Send email notification to controller when Roll call date is not null and controller review date is null</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_BDC_EML_NSAController_Reminder</fullName>
        <actions>
            <name>DS_BDC_NSAController_Reminder</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send email notification to controller whenRoll call date is not null and after 15 days of Roll Call date and Controller Review Date/Time is null</description>
        <formula>AND(NOW()-DATETIMEVALUE(Roll_Call_Date__c)&gt; 15,ISBLANK(Controller_Review_Date_Time__c),NOT(CONTAINS(NSA_Attached_By__c,&quot;SCHOOLEY&quot;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_BDC_UPD_ControllerNameDate</fullName>
        <actions>
            <name>DS_BDC_ControllerDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>DS_BDC_ControllerName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Controller date time to current date time and controller name to last updated by when controller NSA review is checked</description>
        <formula>AND(ISCHANGED(Controller_NSA_Review_Completed__c),Controller_NSA_Review_Completed__c=true)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DS_BDC_UPD_ControllerNameDate_Null</fullName>
        <actions>
            <name>DS_BDC_ControllerDate_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>DS_BDC_ControllerName_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Controller date timeand  controller name to null when controller NSA review is unchecked</description>
        <formula>AND(ISCHANGED(Controller_NSA_Review_Completed__c),Controller_NSA_Review_Completed__c=false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DS_BDC_UPD_NSA_AttachedDate</fullName>
        <actions>
            <name>DS_BDC_NSA_AttachedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SQT_NSA__c.NSA_Attached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Created to update NSA Attached date with current date/time when NSA Attached is checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_BDC_UPD_NSA_AttachedDate_Null</fullName>
        <actions>
            <name>DS_BDC_NSA_AttachedDate_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SQT_NSA__c.NSA_Attached__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Created to make NSA Attached null when NSA attached is un checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DS_BDC_UPD_RollCallDate%2FControllerEmail</fullName>
        <actions>
            <name>DS_BDC_ControllerEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>DS_BDC_RollCallDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the roll call date and controller email from deal state to SQT NSA</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SQTNSA_Set_Migration_ID</fullName>
        <actions>
            <name>SQTNSA_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records,</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
