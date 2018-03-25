trigger keepStatusAndNoLongerThereInSync on Contact (before update) {
	
	
	ContactUpdateTriggerUpdates.onUpdateCheckStatusAndUpdateRelatedValues(trigger.oldMap, trigger.new) ;
	
}