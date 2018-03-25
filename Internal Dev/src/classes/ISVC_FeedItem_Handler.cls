// GLOBIT-5610: Internal Support - Re-Contact User Workflow
//
// 2017-11-20 marta.malinowska@cdk.com Created
public class ISVC_FeedItem_Handler implements ALL_TriggerHandler_Interface {

    public static Boolean triggerDisabled = false;
    private List<FeedItem> feedItemsRelatedToCases = new List<FeedItem>();

    public Boolean isDisabled(){
        ALL_TriggerToggle__c triggerToggle = ALL_TriggerToggle__c.getInstance();
        Boolean isTriggerDisabled = triggerToggle.AllTriggersDisabled__c || triggerToggle.FeedItemTriggerDisabled__c || triggerDisabled;
        return isTriggerDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {}

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void beforeDelete(Map<Id, SObject> oldItems) {}

    public void afterInsert(Map<Id, SObject> newItems) {
        Map<Id, FeedItem> newFeedItems = (Map<Id, FeedItem>) newItems;
        Boolean isRelatedToCase;
        for(FeedItem feedItem : newFeedItems.values()){
            isRelatedToCase = feedItem.ParentId.getSobjectType() == Case.getSObjectType();
            if(isRelatedToCase){
                feedItemsRelatedToCases.add(feedItem);
            }
        }
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void afterDelete(Map<Id, SObject> oldItems) {}

    public void afterUndelete(Map<Id, SObject> oldItems) {}

    public void andFinally(){
        if(!feedItemsRelatedToCases.isEmpty()){
            ISVC_ChangeCaseStatus.setStatusToReContactUser(feedItemsRelatedToCases);
        }
    }
}