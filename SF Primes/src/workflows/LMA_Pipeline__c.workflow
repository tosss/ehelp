<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ES_Set_Apr_Last_Updated_Date</fullName>
        <field>Apr_Last_Update__c</field>
        <formula>TODAY()</formula>
        <name>ES Set Apr Last Updated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ES_Set_Aug_Last_Updated_Date</fullName>
        <field>Aug_Last_Update__c</field>
        <formula>TODAY()</formula>
        <name>ES Set Aug Last Updated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ES_Set_Dec_Last_Updated_Date</fullName>
        <field>Dec_Last_Update__c</field>
        <formula>TODAY()</formula>
        <name>ES Set Dec Last Updated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ES_Set_Feb_Last_Updated_Date</fullName>
        <field>Feb_Last_Update__c</field>
        <formula>TODAY()</formula>
        <name>ES Set Feb Last Updated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ES_Set_Jan_Last_Updated_Date</fullName>
        <field>Jan_Last_Update__c</field>
        <formula>TODAY()</formula>
        <name>ES Set Jan Last Updated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ES_Set_Jul_Last_Updated_Date</fullName>
        <field>Jul_Last_Update__c</field>
        <formula>TODAY()</formula>
        <name>ES Set Jul Last Updated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ES_Set_Jun_Last_Updated_Date</fullName>
        <field>Jun_Last_Update__c</field>
        <formula>TODAY()</formula>
        <name>ES Set Jun Last Updated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ES_Set_MarLast_Updated_Date</fullName>
        <field>Mar_Last_Update__c</field>
        <formula>TODAY()</formula>
        <name>ES Set MarLast Updated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ES_Set_May_Last_Updated_Date</fullName>
        <field>May_Last_Update__c</field>
        <formula>TODAY()</formula>
        <name>ES Set May Last Updated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ES_Set_Nov_Last_Updated_Date</fullName>
        <field>Nov_Last_Update__c</field>
        <formula>TODAY()</formula>
        <name>ES Set Nov Last Updated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ES_Set_Oct_Last_Updated_Date</fullName>
        <field>Oct_Last_Update__c</field>
        <formula>TODAY()</formula>
        <name>ES Set Oct Last Updated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ES_Set_Sep_Last_Updated_Date</fullName>
        <field>Sep_Last_Update__c</field>
        <formula>TODAY()</formula>
        <name>ES Set Sep Last Updated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ES_TrackAprValueUpdated</fullName>
        <actions>
            <name>ES_Set_Apr_Last_Updated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(NOT(ISBLANK( Apr__c )) &amp;&amp; ISNEW()) ||   ISCHANGED(Apr__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ES_TrackAugValueUpdated</fullName>
        <actions>
            <name>ES_Set_Aug_Last_Updated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(NOT(ISBLANK( Aug__c )) &amp;&amp; ISNEW()) ||   ISCHANGED(Aug__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ES_TrackDecValueUpdated</fullName>
        <actions>
            <name>ES_Set_Dec_Last_Updated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(NOT(ISBLANK( Dec__c )) &amp;&amp; ISNEW()) ||   ISCHANGED(Dec__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ES_TrackFebValueUpdated</fullName>
        <actions>
            <name>ES_Set_Feb_Last_Updated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(NOT(ISBLANK( Feb__c )) &amp;&amp; ISNEW()) ||   ISCHANGED(Feb__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ES_TrackJanValueUpdated</fullName>
        <actions>
            <name>ES_Set_Jan_Last_Updated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(NOT(ISBLANK(Jan__c)) &amp;&amp; ISNEW()) ||   ISCHANGED(Jan__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ES_TrackJulValueUpdated</fullName>
        <actions>
            <name>ES_Set_Jul_Last_Updated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(NOT(ISBLANK( Jul__c )) &amp;&amp; ISNEW()) ||   ISCHANGED(Jul__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ES_TrackJunValueUpdated</fullName>
        <actions>
            <name>ES_Set_Jun_Last_Updated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(NOT(ISBLANK( Jun__c )) &amp;&amp; ISNEW()) ||   ISCHANGED(Jun__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ES_TrackMarValueUpdated</fullName>
        <actions>
            <name>ES_Set_MarLast_Updated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(NOT(ISBLANK( Mar__c )) &amp;&amp; ISNEW()) ||   ISCHANGED(Mar__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ES_TrackMayValueUpdated</fullName>
        <actions>
            <name>ES_Set_May_Last_Updated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(NOT(ISBLANK( May__c )) &amp;&amp; ISNEW()) ||   ISCHANGED(May__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ES_TrackNovValueUpdated</fullName>
        <actions>
            <name>ES_Set_Nov_Last_Updated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(NOT(ISBLANK( Nov__c )) &amp;&amp; ISNEW()) ||   ISCHANGED(Nov__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ES_TrackOctValueUpdated</fullName>
        <actions>
            <name>ES_Set_Oct_Last_Updated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(NOT(ISBLANK( Oct__c )) &amp;&amp; ISNEW()) ||   ISCHANGED(Oct__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ES_TrackSepValueUpdated</fullName>
        <actions>
            <name>ES_Set_Sep_Last_Updated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(NOT(ISBLANK( Sep__c )) &amp;&amp; ISNEW()) ||   ISCHANGED(Sep__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
