/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Consolidated SubProjectSite triggers
Test Class:
History
10/20/14    Michael Lasala      Created
12/24/14    Samuel Oberes       Commented existing BEFORE INSERT and UPDATE context codes and replaced it with new logic, focused on populating Account and Dealer group. 
                                Added handlers for adding and deleting subproject external related entity records in the AFTER INSERT, UPDATE, and DELETE context
12/30/14    Samuel Oberes       Refactored: Encapsulated scattered codes inside IMP_SubProjectSite_Handler.rejectDuplicateSites method for reusability
12/30/14    Samuel Oberes       Refactored: Abstracted codes from rejectDuplicateSites which resulted to new method named populateAccountAndDealerGroup
01/05/15    Samuel Oberes       renamed method from insertNewRecord to insertOrUpdateRecord
01/21/15    Samuel Oberes       Consolidated AFTER-INSERT and AFTER-UPDATE
                                renamed method from insertOrUpdateRecord to insertOrUpdateCMFEntityRecord
                                renamed method from deleteRecord to deleteCMFEntityRecord
02/05/15    Samuel Oberes       Added codes to properly populate the new SPS CMF_Numbers__c field in the BEFORE INSERT and BEFORE UPDATE context
                                replaced insertOrUpdateCMFEntityRecord with insertCMFEntityRecord and updateCMFEntityRecord in the AFTER INSERT/UPDATE context
02/06/15    Samuel Oberes       Added IMP_SubProjectSite_Handler.forcePopulateCMF method in the BEFORE UPDATE context
05/28/15    Venkata Shrivol     Added IMP_DeleteWorkbookOnDeleteSite_Handler method to delete related Site-Workbooks and answers whenever
								a SubProjectSite is deleted. 
------------------------------------------------------------*/
trigger IMP_SubProjectSite on SubProjectSite__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if (Trigger.isBefore) {
        
        if(Trigger.isInsert){

            //Set<Id> subProjectIds = new Set<Id>();
            //List<SubProjectSite__c> sitesToUpdate = new List<SubProjectSite__c>();
            
            //for(SubProjectSite__c sps: Trigger.New){

            //    //DEPRECATED CODE & APPROACH
            //    ////pass the subproject site to be created and validate it through
            //    ////comparing the SubProject's dealer group top level account and the site's top level account,
            //    ////checking to see if the Site has already been added to the Subproject, and checking values of subproject's dealer group and project type
            //    //IMP_ConfirmSiteinDealerGroup_Handler.validateInsertedSite(sps);

            //    if(sps.SubProject__c != null){
            //        sitesToUpdate.add(sps);
                    
            //        //Add SubProject Id to set to be used for query in handler
            //        subProjectIds.add(sps.SubProject__c);
            //    }
            //}
            
            ////Process records
            //if(!sitesToUpdate.isEmpty()){
            //    //Update Project value on SubProject Site based on SubProject's Project
            //    IMP_Project_Utility.updateProjectField(sitesToUpdate, null, null, null, subProjectIds);
            //}

            // -------------------------------------------------------------
            // Initialization phase
            Set<Id> subProjectIds = new Set<Id>();
            List<SubProjectSite__c> sitesToUpdate = new List<SubProjectSite__c>();
            Set<String> shipCmfsSet = new Set<String>();
            List<SubProjectSite__c> newSites = new List<SubProjectSite__c>();

            for (SubProjectSite__c newSite : Trigger.New) {
                if (String.isBlank(newSite.CMF_Numbers__c)) {
                    newSite.CMF_Numbers__c = newSite.Ship_CMF__c;
                }
                
                sitesToUpdate.add(newSite);
                subProjectIds.add(newSite.SubProject__c);

                if (newSite.Ship_CMF__c != null) {
                    shipCmfsSet.add(newSite.Ship_CMF__c);
                    newSites.add(newSite);
                }
            }

            // -------------------------------------------------------------
            // Update Project value of all SubProject Sites based on SubProject's Project
            if (!sitesToUpdate.isEmpty()){
                IMP_Project_Utility.updateProjectField(sitesToUpdate, null, null, null, subProjectIds);
            }

            // -------------------------------------------------------------
            // Populate the account and dealer group field of the subproject site only if the ship cmf is not null
            IMP_SubProjectSite_Handler.populateAccountAndDealerGroup(shipCmfsSet, newSites);

            // -------------------------------------------------------------
            // Get the subproject id and account id of those subprojects with non-null ship cmf. This will be used in checking for duplicate subproject site entries.
            Set<Id> subProjectIdsSet = new Set<Id>();
            Set<Id> accountIdsSet = new Set<Id>();
            for (SubProjectSite__c site : newSites) {
                subProjectIdsSet.add(site.SubProject__c);
                accountIdsSet.add(site.Account__c);
            }
            SubProjectSite__c randomSite = (newSites.size() == 0 ? null : newSites[0]);
            IMP_SubProjectSite_Handler.rejectDuplicateSites(subProjectIdsSet, accountIdsSet, randomSite);
            
        } else if(Trigger.isUpdate){
            
            //DEPRECATED CODE & APPROACH
            //for(SubProjectSite__c site : Trigger.New){
            //    //pass the subproject site to be updated and validate it through
            //    //comparing the SubProject's dealer group top level account and the site's top level account,
            //    //checking to see if the Site has already been added to the Subproject, and checking values of subproject's dealer group and project type
            //    SubProjectSite__c old = Trigger.Oldmap.get(site.Id);
            //    if(site.Account__c != null && site.Account__c != old.Account__c){
            //        IMP_ConfirmSiteinDealerGroup_Handler.validateInsertedSite(site);
            //    }
            //}

            // -------------------------------------------------------------
            // Initialization phase
            Set<String> shipCmfsSet = new Set<String>();
            List<SubProjectSite__c> newSites = new List<SubProjectSite__c>();

            String oldShipCmf;
            String newShipCmf;
            Set<String> uniqueCmfNumbersSet;
            for (SubProjectSite__c newSite : Trigger.New) {
                oldShipCmf = Trigger.oldMap.get(newSite.Id).Ship_CMF__c;
                newShipCmf = newSite.Ship_CMF__c;

                // Get only the details of sites whose ship cmf changed, and the resulting ship cmf is not null.
                if ((newShipCmf != null) && 
                    (oldShipCmf != newShipCmf)) {

                    uniqueCmfNumbersSet = new Set<String>(IMP_Project_Utility.parseDelimitedString(newSite.CMF_Numbers__c, ';', true));
                    if (uniqueCmfNumbersSet.contains(oldShipCmf)) {
                        uniqueCmfNumbersSet.remove(oldShipCmf);
                    }
                    if (!uniqueCmfNumbersSet.contains(newShipCmf)) {
                        uniqueCmfNumbersSet.add(newShipCmf);
                    }
                    newSite.CMF_Numbers__c = IMP_Project_Utility.buildProjectTypeString(new List<String>(uniqueCmfNumbersSet));

                    shipCmfsSet.add(newShipCmf);
                    newSites.add(newSite);
                }
            }

            // -------------------------------------------------------------
            // Populate the account and dealer group field of the subproject site only if the ship cmf is not null
            IMP_SubProjectSite_Handler.populateAccountAndDealerGroup(shipCmfsSet, newSites);

            // -------------------------------------------------------------
            // Get the subproject id and account id of those subprojects with non-null ship cmf. This will be used in checking for duplicate subproject site entries.
            Set<Id> subProjectIdsSet = new Set<Id>();
            Set<Id> accountIdsSet = new Set<Id>();
            for (SubProjectSite__c site : newSites) {
                subProjectIdsSet.add(site.SubProject__c);
                accountIdsSet.add(site.Account__c);
            }
            SubProjectSite__c randomSite = (newSites.size() == 0 ? null : newSites[0]);
            IMP_SubProjectSite_Handler.rejectDuplicateSites(subProjectIdsSet, accountIdsSet, randomSite);

            // -------------------------------------------------------------
            // if a user selects a different CMF Name via the lookup that is associated with a different Account, CMF_Numbers field gets overwritten with just the Ship_CMF__c value now stamped
            IMP_SubProjectSite_Handler.forcePopulateCMF(Trigger.oldMap, Trigger.New);
                
            
        } else if(Trigger.isDelete)
        {
    		IMP_DeleteWorkbookOnDeleteSite_Handler.deleteWorkbookOnDeleteSites(Trigger.oldMap.keySet());
        }
        
    } else if (Trigger.isAfter) {
        
        if(Trigger.isInsert){
            
            IMP_SubProjectExtRelatedEntity_Handler.insertCMFEntityRecord(Trigger.newMap);

        } else if(Trigger.isUpdate){

            IMP_SubProjectExtRelatedEntity_Handler.updateCMFEntityRecord(Trigger.oldMap, Trigger.newMap);

        } else if(Trigger.isDelete){
            
            IMP_SubProjectExtRelatedEntity_Handler.deleteCMFEntityRecord(Trigger.oldMap);

        } else if(Trigger.isUndelete){
            
        }
        
    }
}