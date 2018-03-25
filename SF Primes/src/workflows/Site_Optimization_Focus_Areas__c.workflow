<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Focus_Area_Name</fullName>
        <field>Name</field>
        <formula>Text(Category__c )</formula>
        <name>Update Focus Area Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CB_Upd_FocusAreaName</fullName>
        <actions>
            <name>Update_Focus_Area_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>And(  $RecordType.Name = &quot;DAP Focus Areas&quot;, NOT(BEGINS($User.Username,&quot;integration_user@adp.com&quot;)),  OR( ISCHANGED( Category__c ),  DateValue(CreatedDate) = today() ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
