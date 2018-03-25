<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Imp_Notify_of_Request_assignment</fullName>
        <description>Imp Notify of Request assignment</description>
        <protected>false</protected>
        <recipients>
            <field>Requestor_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Implementation_Templates/Request_Assigned</template>
    </alerts>
    <alerts>
        <fullName>Imp_alert_ICRT_Ready_to_test</fullName>
        <description>Imp alert ICRT Ready to test</description>
        <protected>false</protected>
        <recipients>
            <field>Requestor_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Implementation_Templates/Request_Ready_for_test</template>
    </alerts>
    <alerts>
        <fullName>Imp_alert_ICRT_complete</fullName>
        <description>Imp alert ICRT complete</description>
        <protected>false</protected>
        <recipients>
            <field>Requestor_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Implementation_Templates/Request_Complete</template>
    </alerts>
    <alerts>
        <fullName>Imp_alert_that_the_issue_cr_has_been_submitted</fullName>
        <description>Imp alert that the issue/cr has been submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Imp_User_Support</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Implementation_Templates/Request_submitted</template>
    </alerts>
    <fieldUpdates>
        <fullName>Imp_Queue_update</fullName>
        <description>Update to the queue for the tracking request</description>
        <field>OwnerId</field>
        <lookupValue>Imp_Issue_CR_Support</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Imp Queue update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Imp Request on queue</fullName>
        <actions>
            <name>Imp_alert_that_the_issue_cr_has_been_submitted</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Imp_Queue_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Imp_User_Issue_and_CR_Tracking__c.Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>workflow to move the tracking item to the queue and notify members that there is a new item submitted.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Imp Requester ICRT Complete</fullName>
        <actions>
            <name>Imp_alert_ICRT_complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Imp_User_Issue_and_CR_Tracking__c.Status__c</field>
            <operation>equals</operation>
            <value>Canceled,Complete</value>
        </criteriaItems>
        <description>Notification to the requester that the request is complete or canceled with updated information</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Imp Requester ICRT ready to test</fullName>
        <actions>
            <name>Imp_alert_ICRT_Ready_to_test</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Imp_User_Issue_and_CR_Tracking__c.Status__c</field>
            <operation>equals</operation>
            <value>Ready for Acceptance Test</value>
        </criteriaItems>
        <description>Notification to the requester that their ICRT is ready to be tested</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Imp requester ICRT assigned</fullName>
        <actions>
            <name>Imp_Notify_of_Request_assignment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Imp_User_Issue_and_CR_Tracking__c.Status__c</field>
            <operation>equals</operation>
            <value>Assigned</value>
        </criteriaItems>
        <description>email notification to notify requester of tracking item that it is assigned.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
