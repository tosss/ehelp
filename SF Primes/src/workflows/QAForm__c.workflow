<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>QAForm_DA_Sec1Tot</fullName>
        <field>DA_Sec1_Tot__c</field>
        <formula>VALUE(TEXT(DA_DealerLogo__c)) + VALUE(TEXT(DA_DMARadius__c)) + VALUE(TEXT(DA_AdRevUpdt__c)) + VALUE(TEXT( DA_OMS_Tag__c)) + VALUE(TEXT(DA_OMS_Geo__c)) + VALUE(TEXT(DA_AdEmailCk__c)) + VALUE(TEXT(DA_DAS_LastUpdt__c)) + VALUE(TEXT(DA_dealerGoals__c))</formula>
        <name>QAForm-DA-Sec1Tot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QAForm_DA_Sec2Tot</fullName>
        <field>DA_Sec2_Tot__c</field>
        <formula>VALUE(TEXT(DA_DocPresent__c)) + VALUE(TEXT(DA_DocCurNoteStmp__c)) + VALUE(TEXT(DA_SpendLead__c)) + VALUE(TEXT(DA_ActionableOpt__c)) + VALUE(TEXT(DA_DataPtsOpt__c))</formula>
        <name>QAForm-DA-Sec2Tot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QAForm_DA_Sec3Tot</fullName>
        <field>DA_Sec3_Tot__c</field>
        <formula>VALUE(TEXT(DA_TmReptMet__c)) + VALUE(TEXT(DA_TmAA__c)) + VALUE(TEXT(DA_ProdDetNotes__c)) + VALUE(TEXT(DA_Acct_Strategy__c))</formula>
        <name>QAForm-DA-Sec3Tot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QAForm_EMS_Sec1Tot</fullName>
        <field>ems_Sec1_Tot__c</field>
        <formula>VALUE(TEXT( ems_EmailHealth__c)) + VALUE(TEXT( ems_EmailGoalPainPt__c )) + VALUE(TEXT( ems_DealerUpdt__c)) + VALUE(TEXT( ems_ROISent__c)) + VALUE(TEXT( ems_PhoneCon__c))</formula>
        <name>QAForm-EMS-Sec1Tot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QAForm_EMS_Sec2Tot</fullName>
        <field>ems_Sec2_Tot__c</field>
        <formula>VALUE(TEXT( ems_EmailAppDoc__c)) + VALUE(TEXT( ems_CampName__c)) + VALUE(TEXT( ems_EmailIdeasPushed__c)) + VALUE(TEXT( ems_AA_copied__c))</formula>
        <name>QAForm-EMS-Sec2Tot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QAForm_RM_Sec1Tot</fullName>
        <description>Calculate Totals for RepMan Section 1</description>
        <field>rm_Sec1_Tot__c</field>
        <formula>VALUE(TEXT(rm_dsr_SpellGram__c )) + VALUE(TEXT(rm_dsr_RespPub__c)) + VALUE(TEXT(rm_AppMess__c 
)) + VALUE(TEXT(rm_RateMatch__c)) + Value(TEXT(rm_tp_SpellGram__c)) +  Value(TEXT(rm_tpAppMess__c)) + Value(TEXT(rm_tp_RateMatch__c)) + Value(TEXT( rm_tp_TimeResp__c))</formula>
        <name>QAForm-RM-Sec1Tot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QAForm_RM_Sec2Tot</fullName>
        <description>Calculate Totals for RepMan Section 2</description>
        <field>rm_Sec2_Tot__c</field>
        <formula>Value(Text(rm_wo_saopt__c)) + Value(Text( rm_wo_sa_PgResp__c)) + Value(Text(rm_wo_sa_PgImg__c)) + Value(Text( rm_wo_sa_Retail__c))</formula>
        <name>QAForm-RM-Sec2Tot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QAForm_RM_Sec3Tot</fullName>
        <description>Calculate Totals for RepMan Section 3</description>
        <field>rm_Sec3_Tot__c</field>
        <formula>Value (Text( rm_wo_rw_PgResp__c)) + Value(Text( rm_wo_rw_PgImg__c))</formula>
        <name>QAForm-RM-Sec3Tot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QAForm_RM_Sec4Tot</fullName>
        <description>Calculate Totals for RepMan Section 4</description>
        <field>rm_Sec4_Tot__c</field>
        <formula>Value(Text(rm_tpoGoogle__c)) + Value(Text(rm_tpoYelp__c)) + Value(Text(rm_tpoYahoo__c))</formula>
        <name>QAForm-RM-Sec4Tot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QAForm_RM_Sec5Tot</fullName>
        <description>Calculate Totals for RepMan Section 5</description>
        <field>rm_Sec5_Tot__c</field>
        <formula>Value(Text(rm_on_AppBoxCk__c)) + Value(Text( rm_on_AdminLinks__c)) + Value(Text( rm_on_DlrCon__c))</formula>
        <name>QAForm-RM-Sec5Tot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QAForm_RM_Sec6Tot</fullName>
        <description>Calculate Totals for RepMan Section 6</description>
        <field>rm_Sec6_Tot__c</field>
        <formula>Value(Text( rm_dcc_GYset__c)) * 1</formula>
        <name>QAForm-RM-Sec6Tot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QAForm_SM_Sec1Tot</fullName>
        <field>sm_Sec1_Tot__c</field>
        <formula>Value(Text(sm_fb_SpellGram__c)) + 
Value(Text(sm_fb_ConFlowContent__c)) + 
Value(Text(sm_fb_Pageopt__c)) +  
Value(Text(sm_fb_RespNegPost__c)) +  
Value(Text(sm_fb_LinkOtherSites__c))</formula>
        <name>QAForm-SM-Sec1Tot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QAForm_SM_Sec2Tot</fullName>
        <field>sm_Sec2_Tot__c</field>
        <formula>Value(Text(sm_tw_SpellGram__c)) + Value(Text(sm_tw_ConFlowContent__c)) + Value(Text(sm_tw_Pageopt__c)) + Value(Text(sm_tw_linkretail__c))</formula>
        <name>QAForm-SM-Sec2Tot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QAForm_SM_Sec3Tot</fullName>
        <field>sm_Sec3_Tot__c</field>
        <formula>Value(Text(sm_go_Pageopt__c)) + Value(Text(sm_go_SpellGram__c)) + Value(Text(sm_go_LinkOtherSites__c)) + Value(Text( sm_go_Currpostcont__c))</formula>
        <name>QAForm-SM-Sec3Tot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QAForm_SM_Sec4Tot</fullName>
        <field>sm_Sec4_Tot__c</field>
        <formula>Value(Text(sm_yt_Pageopt__c)) + Value(Text(sm_yt_SpellGram__c)) + Value(Text(sm_yt_LinkOtherSites__c)) + Value(Text(sm_yt_Currvidcont__c))</formula>
        <name>QAForm-SM-Sec4Tot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QAForm_SM_Sec5Tot</fullName>
        <field>sm_Sec5_Tot__c</field>
        <formula>Value(Text(sm_wp_SteadyBlogCad__c)) + Value(Text(sm_wp_SpellGram__c)) + Value(Text(sm_wp_Pageopt__c))</formula>
        <name>QAForm-SM-Sec5Tot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>QA Form - DAA Totals Calc</fullName>
        <actions>
            <name>QAForm_DA_Sec1Tot</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>QAForm_DA_Sec2Tot</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>QAForm_DA_Sec3Tot</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QAForm__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>QA - DA</value>
        </criteriaItems>
        <description>QAForm - Section subtotals for DA group</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>QA Form - EMS Totals Calc</fullName>
        <actions>
            <name>QAForm_EMS_Sec1Tot</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>QAForm_EMS_Sec2Tot</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QAForm__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>QA - EMS</value>
        </criteriaItems>
        <description>QAForm - Section subtotals for EMS group</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>QA Form - RepMan Totals Calc</fullName>
        <actions>
            <name>QAForm_RM_Sec1Tot</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>QAForm_RM_Sec2Tot</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>QAForm_RM_Sec3Tot</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>QAForm_RM_Sec4Tot</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>QAForm_RM_Sec5Tot</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>QAForm_RM_Sec6Tot</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QAForm__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>QA - RepMan</value>
        </criteriaItems>
        <description>QAForm - Section subtotals for RepMan group</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>QA Form - Social Media Totals Calc</fullName>
        <actions>
            <name>QAForm_SM_Sec1Tot</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>QAForm_SM_Sec2Tot</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>QAForm_SM_Sec3Tot</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>QAForm_SM_Sec4Tot</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>QAForm_SM_Sec5Tot</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QAForm__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>QA - Social Media</value>
        </criteriaItems>
        <description>QAForm - Section subtotals for Social Media group</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
