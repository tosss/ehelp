<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Pres_Club_Forecast_Channel_Differs_from_User</fullName>
        <description>Email - Pres Club Forecast Channel Differs from User</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply.salesforce@cdk.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ADP_Dealer_Services/Pres_Club_Forecast_Chnl_Not_Match_User</template>
    </alerts>
    <fieldUpdates>
        <fullName>Pres_Club_Month_Num_Upd</fullName>
        <description>Based on the Month (name) chosen set the (fiscal) month number</description>
        <field>MonthNumber__c</field>
        <formula>CASE(Month__c, &quot;July&quot;, 1, &quot;August&quot;, 2, &quot;September&quot;, 3, &quot;October&quot;, 4, &quot;November&quot;, 5, &quot;December&quot;, 6, &quot;January&quot;, 7, &quot;February&quot;, 8, &quot;March&quot;, 9, &quot;April&quot;, 10, &quot;May&quot;, 11, &quot;June&quot;, 12, 0)</formula>
        <name>Pres Club - Month Num Upd</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Email - Pres Club - Frcst Chnl Diff From User</fullName>
        <actions>
            <name>Email_Pres_Club_Forecast_Channel_Differs_from_User</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email - Pres Club - Frcst Chnl Diff From User</description>
        <formula>AND(  LEN( CASE(Employee_Name__r.User__r.Forecasting_Channel__c, &quot;Hoffman Sales&quot;, &quot;Hoffman Sales&quot;, &quot;ARG&quot;, &quot;ARG&quot;, &quot;Canada&quot;, &quot;Canada&quot;, &quot;Dealix&quot;, &quot;Dealix&quot;, &quot;Central&quot;, &quot;Central&quot;, &quot;Southwest&quot;, &quot;Southwest&quot;, &quot;Digital Solutions-East&quot;, &quot;Digital Solutions-East&quot;, &quot;Digital Solutions-West&quot;, &quot;Digital Solutions-West&quot;, &quot;Enterprise&quot;, &quot;Enterprise&quot;, &quot;Inside Sales&quot;, &quot;Inside Sales&quot;, &quot;National&quot;, &quot;National&quot;, &quot;Network Solutions&quot;, &quot;Network Solutions&quot;, &quot;North&quot;, &quot;North&quot;, &quot;PFW&quot;, &quot;PFW&quot;, &quot;RSP Solutions&quot;, &quot;RSP Solutions&quot;, &quot;South&quot;, &quot;South&quot;, &quot;Truck&quot;, &quot;Truck&quot;, &quot;West&quot;, &quot;West&quot;, &quot;&quot;)) &gt; 0,  LEN(CASE (Forecasting_Channel__c , &quot;Hoffman Sales&quot;, &quot;Hoffman Sales&quot;, &quot;ARG&quot;, &quot;ARG&quot;, &quot;Canada&quot;, &quot;Canada&quot;, &quot;Dealix&quot;, &quot;Dealix&quot;, &quot;Central&quot;, &quot;Central&quot;, &quot;Southwest&quot;, &quot;Southwest&quot;, &quot;Digital Solutions-East&quot;, &quot;Digital Solutions-East&quot;, &quot;Digital Solutions-West&quot;, &quot;Digital Solutions-West&quot;, &quot;Enterprise&quot;, &quot;Enterprise&quot;, &quot;Inside Sales&quot;, &quot;Inside Sales&quot;, &quot;National&quot;, &quot;National&quot;, &quot;Network Solutions&quot;, &quot;Network Solutions&quot;, &quot;North&quot;, &quot;North&quot;, &quot;PFW&quot;, &quot;PFW&quot;, &quot;RSP Solutions&quot;, &quot;RSP Solutions&quot;, &quot;South&quot;, &quot;South&quot;, &quot;Truck&quot;, &quot;Truck&quot;, &quot;West&quot;, &quot;West&quot;, &quot;&quot;)) &gt; 0,  CASE(Employee_Name__r.User__r.Forecasting_Channel__c, &quot;Hoffman Sales&quot;, &quot;Hoffman Sales&quot;, &quot;ARG&quot;, &quot;ARG&quot;, &quot;Canada&quot;, &quot;Canada&quot;, &quot;Dealix&quot;, &quot;Dealix&quot;, &quot;Central&quot;, &quot;Central&quot;, &quot;Southwest&quot;, &quot;Southwest&quot;, &quot;Digital Solutions-East&quot;, &quot;Digital Solutions-East&quot;, &quot;Digital Solutions-West&quot;, &quot;Digital Solutions-West&quot;, &quot;Enterprise&quot;, &quot;Enterprise&quot;, &quot;Inside Sales&quot;, &quot;Inside Sales&quot;, &quot;National&quot;, &quot;National&quot;, &quot;Network Solutions&quot;, &quot;Network Solutions&quot;, &quot;North&quot;, &quot;North&quot;, &quot;PFW&quot;, &quot;PFW&quot;, &quot;RSP Solutions&quot;, &quot;RSP Solutions&quot;, &quot;South&quot;, &quot;South&quot;, &quot;Truck&quot;, &quot;Truck&quot;, &quot;West&quot;, &quot;West&quot;, &quot;&quot;) &lt;&gt; CASE (Forecasting_Channel__c , &quot;Hoffman Sales&quot;, &quot;Hoffman Sales&quot;, &quot;ARG&quot;, &quot;ARG&quot;, &quot;Canada&quot;, &quot;Canada&quot;, &quot;Dealix&quot;, &quot;Dealix&quot;, &quot;Central&quot;, &quot;Central&quot;, &quot;Southwest&quot;, &quot;Southwest&quot;, &quot;Digital Solutions-East&quot;, &quot;Digital Solutions-East&quot;, &quot;Digital Solutions-West&quot;, &quot;Digital Solutions-West&quot;, &quot;Enterprise&quot;, &quot;Enterprise&quot;, &quot;Inside Sales&quot;, &quot;Inside Sales&quot;, &quot;National&quot;, &quot;National&quot;, &quot;Network Solutions&quot;, &quot;Network Solutions&quot;, &quot;North&quot;, &quot;North&quot;, &quot;PFW&quot;, &quot;PFW&quot;, &quot;RSP Solutions&quot;, &quot;RSP Solutions&quot;, &quot;South&quot;, &quot;South&quot;, &quot;Truck&quot;, &quot;Truck&quot;, &quot;West&quot;, &quot;West&quot;, &quot;&quot;),  NOT(CONTAINS(Employee_Name__c , &quot;a0W400000000l7a&quot;)),  NOT(CONTAINS(Employee_Name__c , &quot;a0W400000000l7e&quot;)),  NOT(CONTAINS(Employee_Name__c , &quot;a0W40000000RGgh&quot;)),  NOT(CONTAINS(Employee_Name__c , &quot;a0W400000000lD6&quot;))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Upd - Pres Club Perf - Month Num Set</fullName>
        <actions>
            <name>Pres_Club_Month_Num_Upd</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>President_s_Club_Performance__c.Month__c</field>
            <operation>contains</operation>
            <value>October,January,April,February,August,June,November,July,May,December,March,September</value>
        </criteriaItems>
        <description>Upd - Pres Club Performance - Month Num Set based on Month Name</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
