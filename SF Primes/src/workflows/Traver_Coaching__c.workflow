<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>TRV_Email_to_Resource_Assignment_Notification</fullName>
        <description>TRV Email to Resource - Assignment Notification</description>
        <protected>false</protected>
        <recipients>
            <field>TRV_Resource_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>TRV_EmailTemplate/Assignment_Notification_To_Resource</template>
    </alerts>
    <fieldUpdates>
        <fullName>DS_Traver_PartyID_TC</fullName>
        <field>PartyID__c</field>
        <formula>Traver_Project__r.Account__r.PartyID__c</formula>
        <name>DS_Traver_PartyID_TC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TRV_Multi_Country_Paperwork_False</fullName>
        <description>Updates the Multi-Country Paperwork field on B4B Coaching.</description>
        <field>TRV_Multi_Country_Paperwork__c</field>
        <literalValue>0</literalValue>
        <name>TRV Multi-Country Paperwork_False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>DS_Traver_UPD_PartyID_TC</fullName>
        <actions>
            <name>DS_Traver_PartyID_TC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates PatryId on creation of new record</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>TRV_EML_to _Resource_when_Coaching_is_Assigned</fullName>
        <actions>
            <name>TRV_Email_to_Resource_Assignment_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends an Email to Resource whenever a new B4B Coaching is created or whenever Resource is changed.</description>
        <formula>ISCHANGED( TRV_Completed_By__c ) || ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TRV_FLD_Multi-CountryPaperwork</fullName>
        <actions>
            <name>TRV_Multi_Country_Paperwork_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Multi-Country Paperwork will be updated to False whenever Resource is changed.</description>
        <formula>ISCHANGED(TRV_Completed_By__c ) &amp;&amp;  TRV_Multi_Country_Paperwork__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
