<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EmployeeTextMessage</fullName>
        <description>Employee Text Message</description>
        <protected>false</protected>
        <recipients>
            <field>Ph_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ADP_Dealer_Services/Employee_Text_Message</template>
    </alerts>
    <fieldUpdates>
        <fullName>EmpInfoAutoSetPhoneEmail</fullName>
        <description>Employee Information screen, set the phone email for all reps that have phone vendor and mobile defined</description>
        <field>Ph_Email__c</field>
        <formula>CASE( Ph_Vendor__c , 
&quot;Verizon&quot;, SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(Mobile__c, &quot; &quot;, &quot;&quot;)  
, &quot;-&quot;, &quot;&quot;)  , &quot;)&quot;, &quot;&quot;)  , &quot;(&quot;, &quot;&quot;)   &amp; &quot;@vtext.com&quot;, 
&quot;Sprint&quot;, SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(Mobile__c, &quot; &quot;, &quot;&quot;)  
, &quot;-&quot;, &quot;&quot;)  , &quot;)&quot;, &quot;&quot;)  , &quot;(&quot;, &quot;&quot;)  &amp; &quot;@messaging.sprintpcs.com&quot;, 
&quot;Bell Canada&quot;, SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(Mobile__c, &quot; &quot;, &quot;&quot;)  
, &quot;-&quot;, &quot;&quot;)  , &quot;)&quot;, &quot;&quot;)  , &quot;(&quot;, &quot;&quot;)  &amp; &quot;@txt.bell.ca&quot;, 
&quot;AT&amp;T&quot;, SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(Mobile__c, &quot; &quot;, &quot;&quot;)  
, &quot;-&quot;, &quot;&quot;)  , &quot;)&quot;, &quot;&quot;)  , &quot;(&quot;, &quot;&quot;)  &amp; &quot;@txt.att.net&quot;, 
&quot;U.S. Cellular&quot;, SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(Mobile__c, &quot; &quot;, &quot;&quot;)  
, &quot;-&quot;, &quot;&quot;)  , &quot;)&quot;, &quot;&quot;)  , &quot;(&quot;, &quot;&quot;)  &amp; &quot;@email.uscc.net&quot;, 
&quot;&quot;)</formula>
        <name>Emp Info - Auto Set Phone Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EmpInfoClearSendCurrentMessage</fullName>
        <description>Emp Info - Clear Send Current Message Flag after text message is sent</description>
        <field>Send_Current_Message__c</field>
        <literalValue>0</literalValue>
        <name>Emp Info - Clear Send Current Message</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Employee_License_Status_InUse</fullName>
        <description>Update License Status = &apos;In Use&apos; when user account activated.</description>
        <field>License_Status_Del__c</field>
        <literalValue>In Use</literalValue>
        <name>Upd - Employee - License Status-InUse</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Employee_License_Status_Released</fullName>
        <description>Update License Status = &apos;Released&apos; when user account in-activated and &apos;Keep User Always Active&apos; = False</description>
        <field>License_Status_Del__c</field>
        <literalValue>Released</literalValue>
        <name>Upd - Employee - License Status-Released</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Employee_Status_Active</fullName>
        <description>Update Employee Status to &apos;Active&apos; when User account activated.</description>
        <field>Status_Del__c</field>
        <literalValue>Active</literalValue>
        <name>Upd - Employee - Status-Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Employee_Status_Inactive</fullName>
        <description>Update Employee Status to &apos;Inactive&apos; when User account in-activated and &apos;Keep User Always Active&apos; = False</description>
        <field>Status_Del__c</field>
        <literalValue>Inactive</literalValue>
        <name>Upd - Employee - Status-Inactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Email - Emp Info - Send Text Message</fullName>
        <actions>
            <name>EmployeeTextMessage</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>EmpInfoClearSendCurrentMessage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Email - Emp Info - Send Text Message to employee</description>
        <formula>AND(   LEN(Ph_Email__c) &gt; 5,   Send_Current_Message__c = True,   LEN(Text_Message_Subject__c) &gt; 2, NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))    )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Employee - Status-License Status - Active</fullName>
        <actions>
            <name>Upd_Employee_License_Status_InUse</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Upd_Employee_Status_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update Employee Status = &apos;Active&apos; and License Status = &apos;In Use&apos; when user activated.</description>
        <formula>AND(User__r.IsActive = TRUE, OR(ISPICKVAL(Status_Del__c, &quot;Inactive&quot;), ISPICKVAL(Status_Del__c, &quot;&quot;), ISPICKVAL(License_Status_Del__c, &quot;Released&quot;), ISPICKVAL(License_Status_Del__c, &quot;&quot;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Employee - Status-License Status - Inactive</fullName>
        <actions>
            <name>Upd_Employee_License_Status_Released</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Upd_Employee_Status_Inactive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update Employee Status = &apos;Inactive&apos; and License Status = &apos;Released&apos; when user in-activated.</description>
        <formula>AND(User__r.IsActive = FALSE, User__r.Inactive_Due_to_Inactivity__c = FALSE,  OR(ISPICKVAL(Status_Del__c, &quot;Active&quot;), ISPICKVAL(Status_Del__c, &quot;&quot;)), ISPICKVAL(License_Status_Del__c, &quot;In Use&quot;),  ISPICKVAL(License_Status_Del__c, &quot;&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Employee Info - Phone Email Set</fullName>
        <actions>
            <name>EmpInfoAutoSetPhoneEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Employee Info - Set Phone Email if Phone Vendor and Mobile are set</description>
        <formula>AND(  LEN(CASE( Ph_Vendor__c, &quot;Verizon&quot;, &quot;Verizon&quot;, &quot;Sprint&quot;, &quot;Sprint&quot;, &quot;Bell Canada&quot;, &quot;Bell Canada&quot;, &quot;AT&amp;T&quot;, &quot;AT&amp;T&quot;, &quot;U.S. Cellular&quot;,  &quot;U.S. Cellular&quot;, &quot; &quot;)) &gt; 0,  LEN(  Mobile__c ) &gt; 0  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
