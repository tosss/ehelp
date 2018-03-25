<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>TRV_Resource_Name_First_Name_Last_Name</fullName>
        <description>Resource Name is updated with combination of User&apos;s First Name and Last Name.</description>
        <field>Name</field>
        <formula>TRV_Resource__r.FirstName + &apos; &apos; + TRV_Resource__r.LastName</formula>
        <name>TRV Resource Name_First Name Last Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TRV_Resource_Status_Terminated</fullName>
        <description>Resource Status field is updated as &apos;Terminated&apos;.</description>
        <field>TRV_Status__c</field>
        <literalValue>Terminated</literalValue>
        <name>TRV Resource Status_Terminated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>TRV_FLD_ResourceName</fullName>
        <actions>
            <name>TRV_Resource_Name_First_Name_Last_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>TRV_Resource__c.TRV_Resource__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Resource Name will be updated on record creation and whenever User is changed on Resource.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TRV_FLD_ResourceStatus</fullName>
        <active>true</active>
        <criteriaItems>
            <field>TRV_Resource__c.TRV_Termination_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>TRV_Resource__c.TRV_Termination_Date__c</field>
            <operation>greaterThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>Resource Status is updated to Terminated when Termination Date is greater than Today.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>TRV_Resource_Status_Terminated</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>TRV_Resource__c.TRV_Termination_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>TRV_FLD_ResourceStatusLessThanToday</fullName>
        <actions>
            <name>TRV_Resource_Status_Terminated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>TRV_Resource__c.TRV_Termination_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>TRV_Resource__c.TRV_Termination_Date__c</field>
            <operation>lessOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>Resource Status is updated to Terminated when Termination Date is less than or equal to Today.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
