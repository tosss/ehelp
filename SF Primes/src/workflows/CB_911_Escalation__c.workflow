<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CB_IFS911_Send_to_IFS</fullName>
        <description>CB_IFS911_ Send_to_IFS</description>
        <protected>false</protected>
        <recipients>
            <recipient>erika.myrick@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jenn.atkins@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kevin.haller@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paulette.howard@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tracey.wait@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFS_Launch_Templates/Alert_911_Escalation_Notification_to_IFS</template>
    </alerts>
    <alerts>
        <fullName>CB_IFS911_Send_to_Sales</fullName>
        <description>CB_IFS911_ Send_to_Sales</description>
        <protected>false</protected>
        <recipients>
            <recipient>Director of Digital Sales</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFS_Launch_Templates/Alert_911_Escalation_Notification</template>
    </alerts>
    <alerts>
        <fullName>CB_SvcIFS_Alert_911_Approved</fullName>
        <description>CB_SvcIFS_Alert_911 Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Requested_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert_Your_911_Request_Was_Approved</template>
    </alerts>
    <alerts>
        <fullName>CB_SvcIFS_Alert_911_Denied</fullName>
        <description>CB_SvcIFS_Alert_911_Denied</description>
        <protected>false</protected>
        <recipients>
            <field>Requested_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert_Your_911_Request_Was_Denied</template>
    </alerts>
    <alerts>
        <fullName>CB_Svc_Alert_911_Amended</fullName>
        <description>CB Svc Alert 911 Amended</description>
        <protected>false</protected>
        <recipients>
            <recipient>erika.myrick@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jenn.atkins@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kevin.haller@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paulette.howard@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tracey.wait@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Services_Internal_Notifications/Alert_Your_911_Request_Was_Amended</template>
    </alerts>
    <fieldUpdates>
        <fullName>CB_SvcIFS_911_Not_Completed</fullName>
        <description>This will uncheck the IsClosed check box when someone moves a 911 Escalation out of a Closed status.</description>
        <field>IsClosed__c</field>
        <literalValue>0</literalValue>
        <name>CB_SvcIFS_911_Not_Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_SvcIFS_Assign_Booking_OM_Q</fullName>
        <description>Assigns the Booking OM Queue</description>
        <field>OwnerId</field>
        <lookupValue>IFSBookingOM</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CB_SvcIFS_Assign_Booking_OM_Q</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_SvcIFS_Assign_IFS_911_Approve_Q</fullName>
        <field>OwnerId</field>
        <lookupValue>IFS_911_Approver</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CB_SvcIFS_Assign_IFS_911_Approve_Q</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_SvcIFS_IsClosed_Checked</fullName>
        <description>Check the IsClosed check box on the 911 request object.</description>
        <field>IsClosed__c</field>
        <literalValue>1</literalValue>
        <name>CB_SvcIFS_IsClosed_Checked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>X911Escalation_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>911Escalation_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>911Escalation_Set_Migration_ID</fullName>
        <actions>
            <name>X911Escalation_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB Svc Alert 911 Amended</fullName>
        <actions>
            <name>CB_Svc_Alert_911_Amended</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Alert</description>
        <formula>$RecordType.Name = &quot;Order Escalation&quot; &amp;&amp;  ISPickVal(Status__c, &apos;Amended&apos;) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcIFS_Alert_911_Approved</fullName>
        <actions>
            <name>CB_SvcIFS_Alert_911_Approved</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>CB_911_Escalation__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>For all RT: Sends an alert to the person who requested the 911 when the request is Approved.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcIFS_Alert_911_Denied</fullName>
        <actions>
            <name>CB_SvcIFS_Alert_911_Denied</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CB_911_Escalation__c.Status__c</field>
            <operation>equals</operation>
            <value>Denied</value>
        </criteriaItems>
        <criteriaItems>
            <field>CB_911_Escalation__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Order Escalation</value>
        </criteriaItems>
        <description>For all RT: Sends an alert to the person who requested the 911 when the request is Denied.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcIFS_Assign_911_Approver_Queue</fullName>
        <actions>
            <name>CB_IFS911_Send_to_IFS</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CB_IFS911_Send_to_Sales</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CB_SvcIFS_Assign_IFS_911_Approve_Q</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CB_911_Escalation__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Order Escalation</value>
        </criteriaItems>
        <description>Assigns the IFS - 911 Approver queue when a record is created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcIFS_Assign_Alert_Booking_OM_Q</fullName>
        <actions>
            <name>CB_SvcIFS_Alert_911_Approved</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CB_SvcIFS_Assign_Booking_OM_Q</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CB_911_Escalation__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>CB_911_Escalation__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Order Escalation</value>
        </criteriaItems>
        <description>Assigns the Booking OM queue when the status is set to Approved.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcIFS_UPD_911_Completed</fullName>
        <actions>
            <name>CB_SvcIFS_IsClosed_Checked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All RT: Checks the IsClosed check box when the Status moves from an open status to closed.</description>
        <formula>AND(IsClosed__c = FALSE,   $RecordType.Name = &quot;Order Escalation&quot;,  OR(ISPICKVAL(Status__c ,&quot;Denied&quot;),  ISPICKVAL(Status__c,&quot;Completed&quot;), ISPICKVAL(Status__c,&quot;Duplicate&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CB_SvcIFS_UPD_911_No_Longer_Completed</fullName>
        <actions>
            <name>CB_SvcIFS_911_Not_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All RT: When someone moves the request out of the completed stage, this makes sure the IsClosed check box is unchecked.</description>
        <formula>AND(IsClosed__c = TRUE, $RecordType.Name = &quot;Order Escalation&quot;,  NOT(ISPICKVAL( Status__c ,&quot;Denied&quot;)),   NOT(ISPICKVAL(Status__c,&quot;Completed&quot;)),  NOT(ISPICKVAL(Status__c,&quot;Duplicate&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
