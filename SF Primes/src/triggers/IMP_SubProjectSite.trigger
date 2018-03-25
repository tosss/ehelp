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
07/28/15    Samuel Oberes       Renamed insertCMFEntityRecord to insertSpereRecordIdentifier AND updateCMFEntityRecord to updateSpereIdentifier
07/17/15    Rey Austral         Add prevention of reparenting of site based on the condition
07/29/15    Kimiko Roberto      Added IMP_SetSubprojectforRMS_Handler at isBefore|isInsert for RMS transactions
08/08/15    Samuel Oberes       Added logic for rejecting duplicate sites due to re-parenting
10/06/15    Samuel Oberes       Added DUPLICATE ERROR logic
12/11/15    Venkata Shrivol		Added boolean parameter rejectDuplicateSites method for recursive check
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
            IMP_SubProjectSite_Handler.rejectDuplicateSites(subProjectIdsSet, accountIdsSet, randomSite, false);
            
            //assign SubProject Id from rms transactions
            /* Removed
            List<SubProjectSite__c> subProjectSitefromRMSList = new List<SubprojectSite__c>();
            for(SubProjectSite__c sps : trigger.New)
            {
                if((sps.SubProject_Name_from_RMS__c != null && sps.SubProject_Name_from_RMS__c != '') && (sps.SubProject__c == 'a3Le0000000GfVD'))
                {
                    subProjectSitefromRMSList.add(sps);
                }
            }
            
            
            if(subProjectSitefromRMSList != null && !subProjectSitefromRMSList.isEmpty())
            {
                IMP_SetSubprojectforRMS_Handler.assignSubProjectId(subProjectSitefromRMSList);
            }
            */
            
            
        } else if(Trigger.isUpdate)
        {
        	
            
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
            List<SubProjectSite__c> reParentedSites = new List<SubProjectSite__c>();

            String oldShipCmf;
            String newShipCmf;
            Set<String> uniqueCmfNumbersSet;
            
            //get all the subproject from the old and new value and convert to Set of Id
            Set<Id> oldSubprojectIdSet = IMP_Project_Utility.buildIdSet(Trigger.Old, 'SubProject__c');
            Set<Id> newSubprojectIdSet = IMP_Project_Utility.buildIdSet(Trigger.New, 'SubProject__c');
            Set<Id> oldAccoutIdSet = IMP_Project_Utility.buildIdSet(Trigger.Old, 'Account__c');
            //Query the project field from the set of subproject
            Map<Id,SubProject__c> subprojectMap = new Map<Id,SubProject__c>([Select Id,Project__c from SubProject__c 
                                                                                    where Id IN: oldSubprojectIdSet  or Id IN: newSubprojectIdSet ]);
            Set<Id> siteIdsSet = new Set<Id> (Trigger.NewMap.keySet());
            Map<Id,AggregateResult> siteInMilestoneMap =  IMP_Project_Utility.countSiteReferenceInMilestone(siteIdsSet);
            List<AggregateResult> siteInDiscoveryList =  IMP_Project_Utility.countSiteReferenceInDiscovery(oldAccoutIdSet,oldSubprojectIdSet);
            for (SubProjectSite__c newSite : Trigger.New) {
                SubProjectSite__c oldSite = Trigger.oldMap.get(newSite.Id);
                oldShipCmf = oldSite.Ship_CMF__c;
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
                //2015-07-17 Rey Austral
                //Logic to determine if we need to prevent the reparenting of a subproject site
                //we prevent reparenting if the new subproject parent rolls up to a completely different project and
                //we also prevent reparenting if the subproject site is associate with one or more milestone
            
            
                if (oldSite.SubProject__c != newSite.SubProject__c) 
                {
                    //check if the project field of the new subproject is different with the project field of the old subproject
                    
                    String oldProject = subprojectMap.get(oldSite.SubProject__c).Project__c;
                    String newProject = subprojectMap.get(newSite.SubProject__c).Project__c;                    
                    Integer countSiteInMilestone = 0; 
                    if (siteInMilestoneMap.containsKey(newSite.Id))
                    {
                        countSiteInMilestone = (Integer)siteInMilestoneMap.get(newSite.Id).get('numberOfSite');
                    }
                    Boolean isReferenceInDiscovery = IMP_Project_Utility.isSiteReferenceInDiscovery(siteInDiscoveryList,oldSite.Account__c,oldSite.SubProject__c);
                    //if the project field is different prevent the reparenting
                    if (oldProject  != newProject )
                    {
                        newSite.AddError('Cannot reparent subproject site to another subproject that has different project');
                    }
                    //of the site already associated in a milestone prevent reparenting
                    else if (countSiteInMilestone > 0 )
                    {
                        newSite.AddError('Cannot reparent subproject site if it is already associated with 1 or more milestone records');
                    }
                    else if (isReferenceInDiscovery)
                    {
                        newSite.AddError('Cannot reparent subproject site if it is already associated with 1 or more discovery records');
                    }
                    reParentedSites.add(newSite);
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

            // 2015-08-08: added by Sam
            for (SubProjectSite__c site : reParentedSites) {
                subProjectIdsSet.add(site.SubProject__c);
                accountIdsSet.add(site.Account__c);
            }
            SubProjectSite__c randomSite = (newSites.isEmpty() ? (reParentedSites.isEmpty() ? null : reParentedSites[0]) : newSites[0]);
			IMP_SubProjectSite_Handler.rejectDuplicateSites(subProjectIdsSet, accountIdsSet, randomSite, true);
            // -------------------------------------------------------------
            // if a user selects a different CMF Name via the lookup that is associated with a different Account, CMF_Numbers field gets overwritten with just the Ship_CMF__c value now stamped
            IMP_SubProjectSite_Handler.forcePopulateCMF(Trigger.oldMap, Trigger.New);

            
        } else if(Trigger.isDelete){
            IMP_DeleteWorkbookOnDeleteSite_Handler.deleteWorkbookOnDeleteSites(Trigger.oldMap.keySet());  
        }
        
    } else if (Trigger.isAfter) {

        // -----------------------------------------------------------
        // added by Sam 2015-10-06

        Map<Id, Map<String, Set<String>>> cmfOrRmsToExcludeFromInsertionMap = new Map<Id, Map<String, Set<String>>>();

        if (Trigger.isInsert || Trigger.isUpdate)
        {
            Set<String> spereNumbersSet = new Set<String>();
            String field = '';
            Set<Id> subprojectIdsSet = new Set<Id>();

            // loop through all the sites involved in this context
            for (SubProjectSite__c newSite : Trigger.newMap.values()) 
            {
                // loop through all the SPERE fields of the site. 
                // As of time of writing, SPERE fields on site are CMF_Numbers__c and RMS_Request_IDs__c.
                for (String entityType : IMP_EntityTypeHelper__c.getAll().keySet())
                {
                    field = IMP_EntityTypeHelper__c.getInstance(entityType).Entity_Field_Name__c;
                    spereNumbersSet.addAll(IMP_Project_Utility.parseDelimitedString((String)newSite.get(field), ',', true));
                }
                subprojectIdsSet.add(newSite.SubProject__c);
            }

            List<SubProject_External_Related_Entity__c> alreadyExistingSperes = [SELECT Id, Entity_Type__c, Entity_Number__c, SubProject__c 
                                                                                   FROM SubProject_External_Related_Entity__c 
                                                                                  WHERE Entity_Type__c IN :IMP_EntityTypeHelper__c.getAll().keySet() 
                                                                                    AND Entity_Number__c IN :spereNumbersSet
                                                                                    AND SubProject__c IN :subProjectIdsSet];

            // Populate the map > map > set.
            // The first map contains a key which is a subproject id, and the map's value is another map.
            // The second map contains a key which is an entity type, and its value is a set of all the entity numbers that is associated with that entity type.
            // This map is part of the overall logic that will be used in determining whether or not the current entity number should be deemed a duplicate, leading to its insertion/update cancelation.
            for (SubProject_External_Related_Entity__c spere : alreadyExistingSperes)
            {
                if (cmfOrRmsToExcludeFromInsertionMap.keySet().contains(spere.SubProject__c))
                {
                    if (cmfOrRmsToExcludeFromInsertionMap.get(spere.SubProject__c).keySet().contains(spere.Entity_Type__c))
                    {
                        cmfOrRmsToExcludeFromInsertionMap.get(spere.SubProject__c).get(spere.Entity_Type__c).add(spere.Entity_Number__c);
                    }
                    else
                    {
                        cmfOrRmsToExcludeFromInsertionMap.get(spere.SubProject__c).put(spere.Entity_Type__c, new Set<String>{ spere.Entity_Number__c });
                    }
                }
                else
                {
                    cmfOrRmsToExcludeFromInsertionMap.put(spere.SubProject__c, new Map<String, Set<String>>{ spere.Entity_Type__c => new Set<String>{ spere.Entity_Number__c } });
                }
            }
        }

        // -----------------------------------------------------------
        
        // -----------------------------------------------------------

        if(Trigger.isInsert){
            
            IMP_SubProjectExtRelatedEntity_Handler.insertSpereRecordIdentifier(Trigger.newMap, cmfOrRmsToExcludeFromInsertionMap);

        } else if(Trigger.isUpdate){
            
            IMP_SubProjectExtRelatedEntity_Handler.updateSpereIdentifier(Trigger.oldMap, Trigger.newMap, cmfOrRmsToExcludeFromInsertionMap);

        } else if(Trigger.isDelete){
            
            IMP_SubProjectExtRelatedEntity_Handler.deleteCMFEntityRecord(Trigger.oldMap);

        } else if(Trigger.isUndelete){
            
        }
        
    }
}