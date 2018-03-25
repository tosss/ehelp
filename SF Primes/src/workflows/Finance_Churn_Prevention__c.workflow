<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Equifax_RI_Set_Last_Modified_User</fullName>
        <field>Equifax_RI_Last_Modified_User__c</field>
        <formula>$User.FirstName &amp; &apos; &apos; &amp;  $User.LastName</formula>
        <name>FCP - Equifax RI Set Last Modified User</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Equifax_RI_Set_Modified_UserDate</fullName>
        <field>Equifax_RI_Modified_UserDate__c</field>
        <formula>$User.FirstName &amp; &apos; &apos; &amp;  $User.LastName &amp; &apos; &apos; &amp;  TEXT( NOW() )</formula>
        <name>FCP - Equifax RI Set Modified UserDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Equifax_SUP_Set_Last_Modified_User</fullName>
        <field>Equifax_SUP_Last_Modified_User__c</field>
        <formula>$User.FirstName &amp; &apos; &apos; &amp;  $User.LastName</formula>
        <name>FCP - Equifax SUP Set Last Modified User</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Equifax_SUP_Set_Modified_UserDate</fullName>
        <field>Equifax_SUP_Modified_UserDate__c</field>
        <formula>$User.FirstName &amp; &apos; &apos; &amp;  $User.LastName &amp; &apos; &apos; &amp;  TEXT( NOW() )</formula>
        <name>FCP - Equifax SUP Set Modified UserDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Equifax_Set_Last_Modified_RI</fullName>
        <field>Equifax_RI_Last_Modified__c</field>
        <formula>NOW()</formula>
        <name>FCP - Equifax Set Last Modified RI</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Equifax_Set_Last_Modified_SUP</fullName>
        <field>Equifax_SUP_Last_Modified__c</field>
        <formula>NOW()</formula>
        <name>FCP - Equifax Set Last Modified SUP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Experian_RI_Set_Modified_User</fullName>
        <field>Equifax_RI_Last_Modified_User__c</field>
        <formula>$User.FirstName &amp; &apos; &apos; &amp;  $User.LastName</formula>
        <name>FCP - Experian RI Set Modified User</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Experian_RI_Set_Modified_UserDate</fullName>
        <field>Experian_RI_Modified_UserDate__c</field>
        <formula>$User.FirstName &amp; &apos; &apos; &amp;  $User.LastName &amp; &apos; &apos; &amp;  TEXT( NOW() )</formula>
        <name>FCP - Experian RI Set Modified UserDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Experian_SUP_Set_Last_Modified_User</fullName>
        <field>Experian_SUP_Last_Modified_User__c</field>
        <formula>$User.FirstName &amp; &apos; &apos; &amp;  $User.LastName</formula>
        <name>FCP-Experian SUP Set Last Modified User</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Experian_SUP_Set_Modified_UserDate</fullName>
        <field>Experian_SUP_Modified_UserDate__c</field>
        <formula>$User.FirstName &amp; &apos; &apos; &amp;  $User.LastName &amp; &apos; &apos; &amp; TEXT(NOW())</formula>
        <name>FCP-Experian SUP Set Modified UserDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Experian_Set_Last_Modified_RI</fullName>
        <field>Experian_RI_Last_Modified__c</field>
        <formula>NOW()</formula>
        <name>FCP - Experian Set Last Modified RI</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Experian_Set_Last_Modified_SUP</fullName>
        <field>Experian_SUP_Last_Modified__c</field>
        <formula>NOW()</formula>
        <name>FCP - Experian Set Last Modified SUP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Trans_Union_RI_Set_Last_Modified_Date</fullName>
        <field>Trans_Union_SUP_Last_Modified__c</field>
        <formula>Now()</formula>
        <name>FCP-Trans Union RI Set Last Modified Dt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Trans_Union_RI_Set_Last_Modified_User</fullName>
        <field>Trans_Union_RI_Last_Modified_User__c</field>
        <formula>$User.FirstName &amp; &apos; &apos; &amp;  $User.LastName</formula>
        <name>FCP-Trans Union RI Set Last Mod User</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Trans_Union_RI_Set_Modified_UserDate</fullName>
        <field>Trans_Union_RI_Modified_UserDate__c</field>
        <formula>$User.FirstName &amp; &apos; &apos; &amp;  $User.LastName &amp; &apos; &apos; &amp; TEXT(NOW())</formula>
        <name>FCP-Trans Union RI Set Modified UserDt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Trans_Union_SUP_Set_Last_Modified_User</fullName>
        <field>Trans_Union_SUP_Last_Modified_User__c</field>
        <formula>$User.FirstName &amp; &apos; &apos; &amp;  $User.LastName</formula>
        <name>FCP-Trans Union SUP Set Last Mod User</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Trans_Union_SUP_Set_Modified_UserDate</fullName>
        <field>Trans_Union_SUP_Modified_UserDate__c</field>
        <formula>$User.FirstName &amp; &apos; &apos; &amp;  $User.LastName &amp; &apos; &apos; &amp; TEXT(NOW())</formula>
        <name>FCP-Trans Union SUP Set Modified UserDt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Trans_Union_Set_Last_Modified_SUP</fullName>
        <field>Trans_Union_SUP_Last_Modified__c</field>
        <name>FCP-Trans Union Set Last Modified SUP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UPD_FCP_Status</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Completed_Job</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>FCP-UPD FCP Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Task - FCP Create Task</fullName>
        <active>false</active>
        <description>Rule to create a Task to call a dealer in the insertion of a new record to Finance Churn Prevention Object</description>
        <formula>NOT(ISNULL(Id)) &amp;&amp;  NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)) &amp;&amp; NOT(ISNULL( Model_Job_Number__c ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UPD FCP Set Record Type</fullName>
        <actions>
            <name>UPD_FCP_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Finance_Churn_Prevention__c.Job_Status__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <description>If the Job Status is set to Complete, make the page read only.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Equifax Set Last Modified RI</fullName>
        <actions>
            <name>Equifax_RI_Set_Last_Modified_User</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Equifax_RI_Set_Modified_UserDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Equifax_Set_Last_Modified_RI</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Workflow to set Last Modified Date for Equifax Bureau for Remote Installer</description>
        <formula>Equifax_RI_Save_Amount__c  &lt;&gt;  PRIORVALUE( Equifax_RI_Save_Amount__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Equifax Set Last Modified SUP</fullName>
        <actions>
            <name>Equifax_SUP_Set_Last_Modified_User</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Equifax_SUP_Set_Modified_UserDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Equifax_Set_Last_Modified_SUP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Workflow to set Last Modified Date for Equifax Bureau for Supervisor</description>
        <formula>Equifax_SUP_Save_Amount__c     &lt;&gt;  PRIORVALUE( Equifax_SUP_Save_Amount__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Experian Set Last Modified RI</fullName>
        <actions>
            <name>Experian_RI_Set_Modified_User</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Experian_RI_Set_Modified_UserDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Experian_Set_Last_Modified_RI</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Workflow to set Last Modified Date for Experian Bureau for Remote Installer</description>
        <formula>Experian_RI_Save_Amount__c  &lt;&gt;  PRIORVALUE( Experian_RI_Save_Amount__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Experian Set Last Modified SUP</fullName>
        <actions>
            <name>Experian_SUP_Set_Last_Modified_User</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Experian_SUP_Set_Modified_UserDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Experian_Set_Last_Modified_SUP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Workflow to set Last Modified Date for Experian Bureau for Supervisor</description>
        <formula>Experian_SUP_Save_Amount__c      &lt;&gt;  PRIORVALUE( Equifax_SUP_Save_Amount__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Trans Union Set Last Modified RI</fullName>
        <actions>
            <name>Trans_Union_RI_Set_Last_Modified_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Trans_Union_RI_Set_Last_Modified_User</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Trans_Union_RI_Set_Modified_UserDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Workflow to set Modfied User and Date when modified by RI User.</description>
        <formula>Trans_Union_RI_Save_Amount__c   &lt;&gt;  PRIORVALUE( Trans_Union_RI_Save_Amount__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Trans Union Set Last Modified SUP</fullName>
        <actions>
            <name>Trans_Union_SUP_Set_Last_Modified_User</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Trans_Union_SUP_Set_Modified_UserDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Trans_Union_Set_Last_Modified_SUP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Workflow to set Last Modified Date for Trans Union Bureau for Supervisor</description>
        <formula>Trans_Union_SUP_Save_Amount__c    &lt;&gt;  PRIORVALUE( Trans_Union_SUP_Save_Amount__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
