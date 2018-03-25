trigger DS_ContactSetPrimary on Contact (after update, after insert) {
	if (Trigger.isUpdate){
    	for(integer i=0;i< Trigger.new.size(); i++){
    	    if (trigger.new[i].Primary_Contact__c != trigger.old[i].Primary_Contact__c){
    	        if (trigger.new[i].Primary_Contact__c == true){
    	        	List<Contact> updatedContacts = new List<Contact>();
    	            for (Contact c : [select c.Primary_Contact__c, c.Accountid, c.Id from Contact c where c.Accountid = :Trigger.new[i].AccountId and c.Id != :Trigger.new[i].Id]){
    	                c.Primary_Contact__c = false;
    	                updatedContacts.add(c); 
    	            }
    	            update updatedContacts;
    	        }
   	     	}
   	 	}
	}
	if (Trigger.isInsert){
		for(integer i=0;i< Trigger.new.size(); i++){
			if (trigger.new[i].Primary_Contact__c == true){
				List<Contact> insertedContacts = new List<Contact>();
				for (Contact c : [select c.Primary_Contact__c,c.Accountid,c.Id from Contact c where c.Accountid = :Trigger.new[i].AccountId and c.Id != :Trigger.new[i].Id]){
					c.Primary_Contact__c = false;	
					insertedContacts.add(c);
				}
				update insertedContacts;
			}	
		}
	}
}