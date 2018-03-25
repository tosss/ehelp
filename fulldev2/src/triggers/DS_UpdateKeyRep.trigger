/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   To handle Key_Rep__c and Region__c Changes
Created on:    17 July 2015.
Code Coverage: 95%
------------------------------------------------------------
History
17 July 2015    Vishal Bandari      RQ-04982: Added code block to update Key_Rep__c change on Forms_Collection__c
------------------------------------------------------------*/
trigger DS_UpdateKeyRep on Account (before update, before insert, after update)
{    
    //See ALL_Account trigger
}