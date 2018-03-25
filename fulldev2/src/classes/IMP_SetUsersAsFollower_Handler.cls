/*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas       
Description: Handler for IMP_SetUsersAsFollower trigger that sets
             user's as followers of the project and subproject if still not following
Test Class:  IMP_SetUsersAsFollowerHandler_Test
History:
09/30/14     Kimiko Roberto     Created
11/05/14     Samuel Oberes      Refactored: 1) merged setUsersAsFollower and updateSubProjectFollower 2) removed redundant code
05/13/15     Samuel Oberes      Refactored: instead of 2, calls to IMP_Project_Utility.retrieveEntitySubscription were merged to 1 to lessen SOQL query count
------------------------------------------------------------*/
public class IMP_SetUsersAsFollower_Handler {
    
    //public static void setUsersAsFollower(List<SubProject__c> subProjectList, Map<Id, SubProject__c> oldSubProject, Set<Id> prjIds, Boolean blnIsInsertContext, Boolean blnIsUpdateContext) {
        
    //    //get followers of subproject from the passed subproject ids; this will be used to retrieve the subproject's followers

    //    //List<EntitySubscription> checkFollowerList = IMP_Project_Utility.retrieveEntitySubscription(null, null, subProject);
    //    //List<EntitySubscription> checkFollowerList = [SELECT Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentId IN: subProject];

    //    //List<EntitySubscription> checkFollowerProjectList = IMP_Project_Utility.retrieveEntitySubscription(null, prjIds, null);
    //    //List<EntitySubscription> checkFollowerProjectList = [SELECT Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentId IN: prjIds];

    //    Set<EntitySubscription> newFollowersSet = new Set<EntitySubscription>();
    //    //String followers = '';
    //    //String followersPrj = '';
        
    //    //for(EntitySubscription follower : checkFollowerList){
    //    //    if(!checkFollowerList.isEmpty()){
    //    //        followers = followers + follower.SubscriberId;
    //    //    }
            
    //    //}
    //    //for(EntitySubscription followerP : checkFollowerProjectList){
    //    //    if(!checkFollowerProjectList.isEmpty()){
    //    //        followersPrj = followersPrj + followerP.SubscriberId;
    //    //    }
            
    //    //}
        
    //    Set<Id> projectAndSubprojectIdsSet = new Set<Id>();
    //    Set<String> projectAndSubprojectFollowersSet = new Set<String>();

    //    projectAndSubprojectIdsSet.addAll(new Map<Id, SubProject__c>(subProjectList).keySet());
    //    projectAndSubprojectIdsSet.addAll(prjIds);

    //    List<EntitySubscription> subscriptions = IMP_Project_Utility.retrieveEntitySubscription(null, projectAndSubprojectIdsSet, null);
    //    for (EntitySubscription es : subscriptions)
    //    {
    //        projectAndSubprojectFollowersSet.add(es.ParentId + '|' + es.SubscriberId);
    //    }

    //    //iterate from passed subprject list; if there are users set to the Project Manager, Training Implementation Client Mgr and HW Specialist PFW they will be set as the Subproject and Project's follower
    //    // only if they are not still following it
    //    Map<String, IMP_RolesToFields__c> rtf = IMP_RolesToFields__c.getAll();
    //    Set<String> subProjectFields = Schema.SObjectType.SubProject__c.fields.getMap().keySet();

    //    String subprojectFieldName;
    //    SubProject__c oldSP;
    //    for(SubProject__c sp : subProjectList) {
    //        if(blnIsUpdateContext) {
    //            oldSP = oldSubProject.get(sp.Id);
    //        }
    //        for(String key : rtf.keySet()) {
    //            // check if the field name, which is set in the custom setting, is existing in the current list of fields of the subproject.
    //            subprojectFieldName = IMP_RolesToFields__c.getInstance(key).SubprojectFieldName__c;
    //            if(subProjectFields.contains(subprojectFieldName.toLowerCase())) {
    //                // if the field (either Project Manager, Training Implementation Client Mgr, HW Specialist PFW, or other future fields) is not null, try adding it as a follower
    //                // Whether DML context is either INSERT or UPDATE, check if field is not null. Then, check if the DML context is UPDATE. If YES, 
    //                //  return the result of the comparison of the new against the old field's value. If NO, just return a literal TRUE so that the AND operator will not evaluate to FALSE.
    //                if((Id)sp.get(subprojectFieldName) != null && ( blnIsUpdateContext ? ((Id)sp.get(subprojectFieldName) != (Id)oldSP.get(subprojectFieldName)) : true ) ) {
    //                    if(blnIsInsertContext || !projectAndSubprojectFollowersSet.contains( sp.Id + '|' + (Id)sp.get(subprojectFieldName)) ) {
    //                        EntitySubscription newFollower = new EntitySubscription(ParentId = sp.Id, SubscriberId = (Id)sp.get(subprojectFieldName));
    //                        if(!newFollowersSet.contains(newFollower)){
    //                            newFollowersSet.add(newFollower);
    //                        } 
    //                    }
    //                    if(!projectAndSubprojectFollowersSet.contains( sp.Project__c + '|' + (Id)sp.get(subprojectFieldName)) ) {
    //                        EntitySubscription newFollower2 = new EntitySubscription(ParentId = sp.Project__c, SubscriberId = (Id)sp.get(subprojectFieldName));
    //                        if(!newFollowersSet.contains(newFollower2)){
    //                            newFollowersSet.add(newFollower2);
    //                        }
    //                    }
    //                }

    //            } else {
    //                System.debug('DBG: Subproject field name \"' + subprojectFieldName + '\" does not exist in the list of existing Subproject fields.');
    //            }
    //        }
    //    }
    //    if(!newFollowersSet.isEmpty()){
    //        insert new List<EntitySubscription>(newFollowersSet);
    //    }
    //}
}