/* ****************************************************
** 08//24/2017 vijay.manimaran@cdk.com Created
***************************************************** */
public with sharing class COM_SearchLinks_Controller {

	@AuraEnabled
	public static List<SObject> searchLinks(String searchText){
        Id linkRecordTypeID=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Page_Component__c', 'Link');
		List<List<SObject>> searchList;
		searchList =  [
            FIND :searchText IN ALL FIELDS 
            RETURNING Page_Component__c(Id,Name,Link_Text__c,Link_URL__c,Linked_to_User__c, 
                                        recordTypeId WHERE recordTypeId =: linkRecordTypeID AND Linked_to_User__c ='')
        ];
		return searchList[0];
	}

}