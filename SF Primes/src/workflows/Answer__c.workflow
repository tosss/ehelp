<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>IMP_DiscoveryAnswer_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>IMP_DiscoveryAnswer_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Any_Answer_Field</fullName>
        <field>Any_Answer__c</field>
        <literalValue>1</literalValue>
        <name>Update Any Answer Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>IMP_DiscoveryAnswer_Set_Migration_ID</fullName>
        <actions>
            <name>IMP_DiscoveryAnswer_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IMP_Discovery_Answer_hasAnswer</fullName>
        <actions>
            <name>Update_Any_Answer_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 or 9 OR 10</booleanFilter>
        <criteriaItems>
            <field>Answer__c.Date_Answer__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Answer__c.Currency_Answer__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Answer__c.Checkbox_Answer__c</field>
            <operation>notEqual</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Answer__c.Number_Answer__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Answer__c.YesNo_Answer__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Answer__c.URL_Answer__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Answer__c.Picklist_Answer__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Answer__c.MultiSelect_Picklist_Answer__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Answer__c.Text_Answer__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Answer__c.Phone_Answer__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update any_answer__c to true when a user answered a question</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
