trigger DS_ContactBeforeDelete on Contact (before delete) {

		for(integer i=0; i< trigger.old.size(); i++){
			if(trigger.old[i].Authorized_Contract_Signer__c == true){
					trigger.old[i].addError('ERROR: Contacts designated as Authorized Contract Signers can not be deleted!');
			}
		}
}