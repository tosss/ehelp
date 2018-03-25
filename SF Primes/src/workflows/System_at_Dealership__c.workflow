<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>IftheSystemsatDealershipforanaccounthasBoxLocationuncheckedANDBoxLocationis</fullName>
        <description>If the Systems at Dealership for an account has “Box Location” unchecked AND “Box Location” is an account listed as inactive, notify the data librarian</description>
        <protected>false</protected>
        <recipients>
            <recipient>DataLibrarians</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ADP_Dealer_Services/InactiveAccountNotification</template>
    </alerts>
    <fieldUpdates>
        <fullName>SysAtDlrClearLeaseExpirationDate</fullName>
        <description>Clear Lease Expiration Date if date is less than 1/1/1970</description>
        <field>Lease_Expiration_Date__c</field>
        <name>Sys At Dlr - Clear Lease Expiration Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SysAtDlrClearSoldDMSInstallDate</fullName>
        <description>Clear Sold DMS Install Date if the Sold DMS Vendor is Null</description>
        <field>Sold_DMS_Estimated_Install_Date__c</field>
        <name>Sys At Dlr - Clear Sold DMS Install Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SystemAtDealer_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>SystemAtDealer_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>System_Software_to_Def_System_Software</fullName>
        <description>Set System Software to Default System Software</description>
        <field>System_Software__c</field>
        <formula>Vendor__r.Default_System_Software__c</formula>
        <name>System Software to Def System Software</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Email - Sys At Dlr - Inactive Box Location</fullName>
        <actions>
            <name>IftheSystemsatDealershipforanaccounthasBoxLocationuncheckedANDBoxLocationis</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>If the Systems at Dealership for an account has “Box Location” unchecked AND “Box Location” is an account listed as inactive (for current DMS  only), notify the data librarian</description>
        <formula>AND(NOT( CONTAINS(CASE(System_Type__c , &quot;CRM&quot;, &quot;CRM&quot;, &quot;DMS&quot;, &quot;DMS&quot;, &quot;Leasing&quot;, &quot;Leasing&quot;, &quot;Phone&quot;, &quot;Phone&quot;, &quot;Previous CRM&quot;, &quot;Previous CRM&quot;, &quot;Previous DMS&quot;, &quot;Previous DMS&quot;, &quot;Previous Leasing&quot;, &quot;Previous Leasing&quot;, &quot;Previous Phone&quot;, &quot;Previous Phone&quot;, &quot;&quot;), &quot;Previous&quot;)),  Box_Onsite__c = False ,  LEN( Box_Location__r.Name ) =0) &amp;&amp; NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SystemAtDealer_Set_Migration_ID</fullName>
        <actions>
            <name>SystemAtDealer_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Sys At Dlr - Clear Lease Exp Date if %3C 1970</fullName>
        <actions>
            <name>SysAtDlrClearLeaseExpirationDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear out Lease Expiration Date if value is less than 1/1/1970</description>
        <formula>AND( NOT( ISNULL(Lease_Expiration_Date__c) ) , YEAR( Lease_Expiration_Date__c)  &lt; 1970)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Sys At Dlr - Clear Sold Install Date %3C 1970</fullName>
        <actions>
            <name>SysAtDlrClearSoldDMSInstallDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Systems at Dealership - If Sold DMS Install Date &lt; 1970 or no Sold DMS Vendor__c, clear Sold DMS Install Date</description>
        <formula>OR(  AND( LEN( Sold_DMS_Vendor__r.Name ) &lt; 1 ,  NOT(ISNULL( Sold_DMS_Estimated_Install_Date__c ))), AND( NOT(LEN(Sold_DMS_Vendor__r.Name ) &lt; 1),  NOT(ISNULL( Sold_DMS_Estimated_Install_Date__c )),    YEAR(Sold_DMS_Estimated_Install_Date__c ) &lt; 1970)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Sys At Dlr - System Software</fullName>
        <actions>
            <name>System_Software_to_Def_System_Software</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>(inactive ccf chgs) Update If Sysyem Type = &apos;DMS&apos; and System_Software__c is null and Default System Software is not null then Set Systems_At_Dealership__c.System_Software__c = SF_SYSTEMS__C.DEFAULT_SYSTEM_SOFTWARE__C


inactivated per request RQ-03184</description>
        <formula>AND( CASE(System_Type__c , &quot;DMS&quot;, &quot;DMS&quot;, &quot;&quot;) = &quot;DMS&quot;,  OR( ISBLANK( System_Software__c) ,  Vendor__r.Default_System_Software__c &lt;&gt; System_Software__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
