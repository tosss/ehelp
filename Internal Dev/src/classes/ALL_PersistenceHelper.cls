// GLOBIT-5239: Create termination case based on the employee termination record in SuccessFactor
//
// 2017-1-20 stephen.li@cdk.com Created
public with sharing class ALL_PersistenceHelper {
    
    /**
     * This method attempts to insert a list of SObject into the database, any
     * errors are captured in the Integration_Error__c object. Potentially, this
     * method can use 2 DML statements, one for inserting the list of SObject,
     * and another one for inserting the list of Integration_Error__c objects.
     * 
     * @param objList - List of SObject you would like to insert into the db.
     * @param parentObjList - List of SObject you would like the error to be attached to.
     * @return The same list of SObject you provided in the input parameter. If
     * the object has been successfully inserted, it's Id field will be populated
     * with a valid SFDC Id, otherwise, the Id field will be null.
     */
    public static List<SObject> insertObjs(List<SObject> objList, List<SObject> parentObjList) {
        List<Integration_Error__c> intErrList = new List<Integration_Error__c>();
        Integer i = 0;
        for (Database.SaveResult sr : Database.insert(objList, false)) {
            if (!sr.isSuccess()) {
                Integration_Error__c e = new Integration_Error__c(Error__c = getErrorMessage(sr));
                if (parentObjList != null) {
                		SObject parent = parentObjList.get(i);
	                if (parent != null) {
	                		if (parent instanceof Account) {
		                    e.Account__c = parent.Id;
		                } else if (parent instanceof Case) {
		                    e.Case__c = parent.Id;
		                } else if (parent instanceof Asset) {
		                    e.Asset__c = parent.Id;
		                }
	                }
                }
                intErrList.add(e);
            }
            i++;
        }
        if (intErrList.size() > 0) {
            Database.insert(intErrList, false);
        }
        return objList;
    }
    
    private static String getErrorMessage(Database.SaveResult sr) {
    		String msg = 'The following error has occured during an insert: \n';
        for (Database.Error err : sr.getErrors()) {
            msg += err.getStatusCode() + ': ' + err.getMessage() + '; Fields that affected this error: ' + err.getFields() + '\n'; 
        }
        // The reason we are substringing the msg is to make sure the field is big enough to 
        // hold the entire string. 131072 is the max number of charaters for a long text field.
        if (msg.length() > 131072) {
        		msg = msg.substring(0, 131072);
        }
        return msg;
    }
}