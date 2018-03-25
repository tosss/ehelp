<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Upd_ISR_Group</fullName>
        <field>ISR_Group__c</field>
        <formula>CASE( ISR__r.ISR_Group__c , &quot;G1&quot;, &quot;G1&quot;, &quot;G2&quot;, &quot;G2&quot;, &quot;G3&quot;, &quot;G3&quot;, &quot;G4&quot;, &quot;G4&quot;, &quot;G5&quot;, &quot;G5&quot;, &quot;G6&quot;, &quot;G6&quot;, &quot; &quot;)</formula>
        <name>Upd - ISR Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Upd - ISR Territory DOSes ISR Group</fullName>
        <actions>
            <name>Upd_ISR_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update ISR Group from User ISR Group</description>
        <formula>OR ( ISBLANK( ISR_Group__c ), CASE($User.ISR_Group__c, &quot;G1&quot;, &quot;G1&quot;, &quot;G2&quot;, &quot;G2&quot;, &quot;G3&quot;, &quot;G3&quot;, &quot;G4&quot;, &quot;G4&quot;, &quot;G5&quot;, &quot;G5&quot;, &quot;G6&quot;, &quot;G6&quot;, &quot; &quot;) &lt;&gt; CASE(ISR_Group__c, &quot;G1&quot;, &quot;G1&quot;, &quot;G2&quot;, &quot;G2&quot;, &quot;G3&quot;, &quot;G3&quot;, &quot;G4&quot;, &quot;G4&quot;, &quot;G5&quot;, &quot;G5&quot;, &quot;G6&quot;, &quot;G6&quot;, &quot; &quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
