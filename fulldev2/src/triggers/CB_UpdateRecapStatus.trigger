/*****************************************************************************************************
 Description: This trigger fires on Recap__c object. This object is related to Recap_product__c and 
 Recap_webid__c objects. When Certain fields on these objects are updated, the trigger assists in 
 changing the 'status' field in the Recap__c object to appropriate value depending on the fields 
 updated in the three above mentioned objects.
*******************************************************************************************************/

trigger CB_UpdateRecapStatus on Recap__c (before Insert, before Update) 
{
	// query all of the recordtypes into a map, get recordtype name (record does not necessarily have it)
	RecordType GlobalRecordType = [Select Id, Name, sObjectType From RecordType Where sObjectType='Recap__c' And Name like '%global%' limit 1];
	
	List<Recap__c> RecapsToProcess = new List<Recap__c>();
    System.debug('GlobalRecordType---'+GlobalRecordType);
    if(GlobalRecordType != null)
    {
	    for(Recap__c Recap : Trigger.New) { 
	    	if(Recap.RecordTypeId == GlobalRecordType.Id) { RecapsToProcess.add(Recap); } 
		}
        System.debug('RecapsToProcess---'+RecapsToProcess);
    }
    
    // update Accounts on Recap Products, if the Recap Account has changed
    // 2014-02-19 MK - this causes a DML recursion error that cannot be fixed using a variable; commented out
    //CB_Recap.UpdateAccountsOnRecapProducts(Trigger.NewMap, Trigger.OldMap);
    
    // call the class method to process the Recap status fields
    CB_Recap.RecapBeforeInsertTriggerHandler(RecapsToProcess);
}