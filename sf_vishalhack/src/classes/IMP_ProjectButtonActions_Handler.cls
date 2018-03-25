/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Handles the overriding of button actions
History
11/26/14     Samuel Oberes       Created
11/03/14     Venkata Shrivol     Commented out the code for Project_Checklist__c reference 
12/02/16     Venkata Shrivol	 commented the entire class as project object is getting deleted RQ-08305
------------------------------------------------------------*/
public class IMP_ProjectButtonActions_Handler {
    /*public static void removeAssociatedRecords(List<Project__c> listOfOldProjects){

        Set<Id> setOfOldProjectIDs = new Set<Id>();
        for (Project__c p : listOfOldProjects) {
            setOfOldProjectIDs.add(p.Id);
        }

        // generate a siteWBstoDeleteList by querying all records for Site_Workbook__c where matching Project__c
        List<Site_Workbook__c> siteWBstoDeleteList = new List<Site_Workbook__c>();
        // [SELECT Id FROM Site_Workbook__c WHERE Project__c IN :listOfOldProjects];
        siteWBstoDeleteList = IMP_Project_Utility.retrieveSiteWorkbooks(setOfOldProjectIDs);
        
        
        // generate a siteWBCatstoDeleteList by querying all records for Discovery_Workbook_Category__c where matching Site_Workbook__c
        List<Discovery_Workbook_Category__c> siteWBCatstoDeleteList = new List<Discovery_Workbook_Category__c>();
        // [SELECT Id FROM Discovery_Workbook_Category__c WHERE Site_Workbook__c IN :siteWBstoDeleteList];
        siteWBCatstoDeleteList = IMP_Project_Utility.retrieveWorkborkCategoryWithSubquery(siteWBstoDeleteList, null);

        
        // delete siteWBCatstoDeleteList in a try/catch block
        try {
            if (!siteWBCatstoDeleteList.isEmpty()) {
                delete siteWBCatstoDeleteList;
            }
        } catch (DmlException e) {
            System.debug('DBG: DELETION ERROR ON siteWBCatstoDeleteList');
            System.debug('DBG: MESSAGE: ' + e.getMessage());
            System.debug('DBG: STACKTRACE: ' + e.getStackTraceString());
        }

        
        // delete siteWBstoDeleteList in a try/catch block
        try {
            if (!siteWBstoDeleteList.isEmpty()) {
                delete siteWBstoDeleteList;
            }
        } catch (DmlException e) {
            System.debug('DBG: DELETION ERROR ON siteWBstoDeleteList');
            System.debug('DBG: MESSAGE: ' + e.getMessage());
            System.debug('DBG: STACKTRACE: ' + e.getStackTraceString());
        }


        // generate a checklisttoDeleteList by querying all records for Project_Checklist__c where matching Project__c
        //List<Project_Checklist__c> checklisttoDeleteList = new List<Project_Checklist__c>();
        // [SELECT Id FROM Project_Checklist__c WHERE Project__c IN :listOfOldProjects];
        //checklisttoDeleteList = IMP_Project_Utility.retrieveProjectCheckList(setOfOldProjectIDs);


        // delete checklisttoDeleteList in a try/catch block
        /*try {
            if (!checklisttoDeleteList.isEmpty()) {
                delete checklisttoDeleteList;
            }
        } catch (DmlException e) {
            System.debug('DBG: DELETION ERROR ON checklisttoDeleteList');
            System.debug('DBG: MESSAGE: ' + e.getMessage());
            System.debug('DBG: STACKTRACE: ' + e.getStackTraceString());
        }


        // generate a projectlogstoDeleteList by querying all records for Project_Log__c where matching Project__c
        List<Project_Log__c> projectlogstoDeleteList = new List<Project_Log__c>();
        projectlogstoDeleteList.addAll([SELECT Id 
                                          FROM Project_Log__c 
                                         WHERE (Project_Action_Items__c IN :listOfOldProjects) 
                                            OR (Project_Change_Request__c IN :listOfOldProjects)
                                            OR (Project_Issue__c IN :listOfOldProjects)
                                            OR (Project_Lessons_Learned__c IN :listOfOldProjects)
                                            OR (Project_Risk__c IN :listOfOldProjects)]);


        // delete projectlogstoDeleteList in a try/catch block
        try {
            if (!projectlogstoDeleteList.isEmpty()) {
                delete projectlogstoDeleteList;
            }
        } catch (DmlException e) {
            System.debug('DBG: DELETION ERROR ON projectlogstoDeleteList');
            System.debug('DBG: MESSAGE: ' + e.getMessage());
            System.debug('DBG: STACKTRACE: ' + e.getStackTraceString());
        }
    }*/
}