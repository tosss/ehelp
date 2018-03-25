<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Cindy_Bennett_Recap_Assign_Alert</fullName>
        <ccEmails>soswest@cobalt.com</ccEmails>
        <description>Cindy Bennett Recap Assign Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>cindy.l.bennett@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Templates_for_Sales/Recap_Assignment_Notification</template>
    </alerts>
    <alerts>
        <fullName>Marsha_Walker_Recap_Alert</fullName>
        <ccEmails>soswest@cobalt.com</ccEmails>
        <description>Marsha Walker Recap Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>sue.vannort@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Templates_for_Sales/Recap_Assignment_Notification</template>
    </alerts>
    <alerts>
        <fullName>Megan_Magarrell_Recap_Alert</fullName>
        <ccEmails>soseast@cobalt.com</ccEmails>
        <description>Marsha Walker Recap Alert 2</description>
        <protected>false</protected>
        <recipients>
            <recipient>sue.vannort@cdk.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Templates_for_Sales/Recap_Assignment_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assign_Cindy_the_SOS</fullName>
        <description>Assigns SOS based on specific Opportunity Owner list.</description>
        <field>SOS_Name__c</field>
        <lookupValue>cindy.l.bennett@cdk.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Assign Cindy the SOS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_Marsha_the_SOS</fullName>
        <description>Assigns the SOS based on a specific list of Opportunity Owners.</description>
        <field>SOS_Name__c</field>
        <lookupValue>sue.vannort@cdk.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Assign Marsha the SOS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_Megan_the_SOS</fullName>
        <description>Assign&apos;s the user to the SOS field based on specific Opporutnity Owners.</description>
        <field>SOS_Name__c</field>
        <lookupValue>sue.vannort@cdk.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Assign Marsha the SOS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_IFS_Recap_Set_DateSent2IFS</fullName>
        <description>Set &quot;Date Sent To IFS&quot; field</description>
        <field>Date_Sent_to_IFS__c</field>
        <formula>TODAY()</formula>
        <name>CB_IFS_Recap_Set_DateSent2IFS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CB_IFS_Recap_Set_Owner2Queue</fullName>
        <description>Set REcap record owner to be &quot;IFS - Website Recaps&quot;</description>
        <field>OwnerId</field>
        <lookupValue>IFS_Website_Recaps</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CB_IFS_Recap_Set_Owner2Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Recap_Set_Migration_ID</fullName>
        <field>Migration_ID__c</field>
        <formula>LEFT(Name, 95) + &apos;:&apos; + $Setup.CustomSettings__c.SF_Instance_Identifier__c</formula>
        <name>Recap_Set_Migration_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CB_IFS_Recap_Ready_For_IFS</fullName>
        <actions>
            <name>CB_IFS_Recap_Set_DateSent2IFS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CB_IFS_Recap_Set_Owner2Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When Global Recap record has status set to &quot;Ready For IFS&quot;, set the owner to be &quot;IFS - Website Recaps&quot; and set Date Sent To IFS to be today.</description>
        <formula>TRIM( RecordType.Name ) = &quot;Global Recap&quot; &amp;&amp;  ISPICKVAL(Status__c, &quot;Ready For IFS&quot;) &amp;&amp;  (Owner:Queue.QueueName &lt;&gt; &quot;IFS - Website Recaps&quot; ||  ISBLANK(Date_Sent_to_IFS__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recap SOS Assign to Cindy Bennett</fullName>
        <actions>
            <name>Cindy_Bennett_Recap_Assign_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Assign_Cindy_the_SOS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Recap__c.Opportunity_Owner__c</field>
            <operation>equals</operation>
            <value>Pamela Payne,Violet Ward,Gene Lam,Ed Neues,Traci Koch,Annette Kaiser,Courtney Thorpe,Jerry Fraser,Terry Drilich,Mark Perry,Mary Ingram,Brian Larkin,Joshua Herbert,Hieu Pham,Steve Davis</value>
        </criteriaItems>
        <description>Assigns an SOS to the SOS field on the Recap object based on who owns the Opportunity the record is being created from.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recap SOS Assign to Dave Fitzgerald-Marsha Walker</fullName>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Recap__c.Opportunity_Owner__c</field>
            <operation>equals</operation>
            <value>Molly Curry,Tracey Corley,Bryan Deker,Ron Lewis,David Hartley,Nancy Haslett,Tiffany Camia,Keith Perret,Bob FitzGerald,Juan Lopez,John Filipas,Vanessa Schipilliti,Bill Aldrich,Shelley Alexander,Stephen Gibbons,Charlie Bruorton</value>
        </criteriaItems>
        <description>Assigns an SOS to the SOS field on the Recap object based on who owns the Opportunity the record is being created from.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recap SOS Assign to Marsha Walker</fullName>
        <actions>
            <name>Marsha_Walker_Recap_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Assign_Marsha_the_SOS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Recap__c.Opportunity_Owner__c</field>
            <operation>equals</operation>
            <value>Robert Cuff,David Agiriga,Ric Gollhofer,John Mogannam,Christine Grant,Michelle Sneathen,Nicole rasmussen,Cord Ficklin,Gary Weber,Scott Knupfer,Jessica Stone,Erin Oertli,Julia Rochester</value>
        </criteriaItems>
        <description>Assigns an SOS to the SOS field on the Recap object based on who owns the Opportunity the record is being created from.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recap SOS Assign to Marsha Walker 2</fullName>
        <actions>
            <name>Megan_Magarrell_Recap_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Assign_Megan_the_SOS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Recap__c.Opportunity_Owner__c</field>
            <operation>equals</operation>
            <value>Troy Peterson,Christine Carter,Dan reese,Russell Adkisson,Mark Chilnick,Michael Askew,Robert Lusby,Priscilla Jaffee,Matt Tedesco,Melanie Borden,Franco Corvino,Greg Hobson,David Powe,Gary Hannah,Paul McMahon</value>
        </criteriaItems>
        <description>Update 8/4: Per Sue VanNort, changing existing WF that was sending notices to Megan Magarrell has changed to send to Marsha W - CW

Assigns an SOS to the SOS field on the Recap object based on who owns the Opportunity the record is being created from.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recap_Set_Migration_ID</fullName>
        <actions>
            <name>Recap_Set_Migration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>set migration ID for new records if not already set on creation of records</description>
        <formula>ISBLANK(Migration_ID__c) &amp;&amp; NOT(ISBLANK($Setup.CustomSettings__c.SF_Instance_Identifier__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
