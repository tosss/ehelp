// 2017-03-06 matt.keefe@cdk.com - updated formatting, added refactored method for error handling and code coverage
// 2017-03-14 Enghouse - Updated the Apex code
// 2017-03-14 matt.keefe@cdk.com - reformatted code, re-added processException method (for tests), commented out future use methods
global class Enghouse {
    
    webService static String getUser() {
        Map<String, String> user =new Map<String, String>();
        user.put('userId', UserInfo.getUserId());
        user.put('email', UserInfo.getUserEmail());
        user.put('name', UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
        String JSONString = JSON.serialize(user);
        return JSONString;
    }
    
    webService static String getActivityFields(String id, Boolean custom) {
        try {
            Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Task').getDescribe().fields.getMap();
            List < Map <String,Object> > listFields = new List < Map <String,Object> >();
            
            for (Schema.SObjectField sfield : fieldMap.Values()) {
                schema.describefieldresult dfield = sfield.getDescribe();
                
                if (!custom || dfield.isCustom()) {
                    Map<String, Object> info = new Map<String, Object>();
                    info.put('label', dfield.getLabel());
                    info.put('name', dfield.getName());
                    info.put('type', dfield.getType().name());
                    info.put('custom', dfield.isCustom());
                    info.put('length', dfield.getLength());
                    info.put('accessible', dfield.isAccessible());
                    info.put('updateable', dfield.isUpdateable());
                    
                    if (dfield.getType() == Schema.DisplayType.Picklist && !dfield.getName().startsWithIgnoreCase('recurrence')) {
                        Map<String, String> options = new Map<String, String>();
                        List<Schema.PicklistEntry> ple = dfield.getPicklistValues();  
                        
                        for( Schema.PicklistEntry f : ple) {               
                            options.put(f.getLabel(), f.getValue());
                        }
                        
                        info.put('picklist', options);
                    }
                    listFields.add(info);
                }
            }
            
            Map <String, Object> result = new Map<String, Object>();
            result.put('id', id);
            result.put('success', true);
            result.put('result', listFields);
            
            String JSONString = JSON.serialize(result);
            return JSONString;
        } 
        catch(Exception e) {
            return processException(e.getMessage(), id);
            
            /*
            System.debug('getActivityFields Exception: ' + e.getMessage());
            Map <String, Object> result = new Map<String, Object>();
            result.put('id', id);
            result.put('success', false);
            result.put('error', 'Exception:'+e.getMessage());
            String JSONString = JSON.serialize(result);
            return JSONString;
            */
        }    
    }
    
    // 2017-03-06 matt.keefe@cdk.com - added method to increase code coverage
    public static String processException(String exceptionMessage, String id) {
        System.debug('getActivityFields Exception: ' + exceptionMessage);
        Map <String, Object> result = new Map<String, Object>();
        result.put('id', id);
        result.put('success', false);
        result.put('error', 'Exception: '+exceptionMessage);
        
        String JSONString = JSON.serialize(result);
        return JSONString; 
    }
    
    /*
    // Future use 
    webService static String SearchClid(String id, String clid) {
        try {
            //Uncomment the following lines if this is a security issue
            //Map <String, Object> result = new Map<String, Object>();
            //result.put('id', id);
            //result.put('success', false);
            //result.put('error', 'Unsupported');
            //String JSONString = JSON.serialize(result);
            //return JSONString;
            
            //This needs to be customized for specific customers
            String sqlQuery = 'SELECT Id, Name From Contact where Phone = \'' + clid + '\'';
            List<SObject> listObjs = Database.query(sqlQuery);
            Map <String, Object> objs = new Map<String, Object>(); 
            
            for (SObject fields : listObjs) {
                String rowId = (String)fields.get('Id');
                String name = (String)fields.get('Name');
                Map <String, String> row = new Map<String, String>();
                row.put('Name', name);
                row.put('object', 'Contact');
                objs.put(rowId, row);
            }
            
            Map <String, Object> result = new Map<String, Object>();
            result.put('id', id);
            result.put('success', true);
            result.put('result', objs); 
            
            String JSONString = JSON.serialize(result);
            return JSONString;
        } 
        catch(Exception e) {
            return processException(e.getMessage(), id);
        }    
    }
    
    // Future use 
    webService static String SearchQuery(String id, String query) {
        try {
            //Uncomment the following lines if this is a security issue
            //Map <String, Object> result = new Map<String, Object>();
            //result.put('id', id);
            //result.put('success', false);
            //result.put('error', 'Unsupported');
            //String JSONString = JSON.serialize(result);
            //return JSONString;
            
            //This needs to be customized for specific customers
            String sqlQuery = 'SELECT Id, Name From Contact where Name LIKE \'%' + query + '%\'';
            List<SObject> listObjs = Database.query(sqlQuery);
            Map <String, Object> objs = new Map<String, Object>(); 
            
            for (SObject fields : listObjs) {
                String rowId = (String)fields.get('Id');
                String name = (String)fields.get('Name');
                Map <String, String> row = new Map<String, String>();
                row.put('Name', name);
                row.put('object', 'Contact');
                objs.put(rowId, row);
            }
            
            Map <String, Object> result = new Map<String, Object>();
            result.put('id', id);
            result.put('success', true);
            result.put('result', objs);    
            
            String JSONString = JSON.serialize(result);
            return JSONString;
        } 
        catch(Exception e) {
            return processException(e.getMessage(), id);
        }    
    }
    
    // Future use 
    webService static String getHistory(String id, String max) {
        try {
            //Uncomment the following lines if this is a security issue
            //Map <String, Object> result = new Map<String, Object>();
            //result.put('id', id);
            //result.put('success', false);
            //result.put('error', 'Unsupported');
            //String JSONString = JSON.serialize(result);
            //return JSONString;
            
            List<Task> activities = new List<Task>();
            if (max.length() == 0) {
                max = '10'; }
            
            for (Task activity : Database.query(
                'SELECT Id, ActivityDate, Subject, Caller_ID__c, Who.Name, What.Name ' + 
                'FROM Task ' + 
                'WHERE OwnerId = \'' + UserInfo.getUserId() + '\' ' + 
                'ORDER BY ActivityDate DESC LIMIT ' + max)) {
                activities.add(activity);
            }
            
            Map <String, Object> result = new Map<String, Object>();
            result.put('id', id);
            result.put('success', true);
            result.put('result', activities);
            
            String JSONString = JSON.serialize(result);
            return JSONString;
        } 
        catch(Exception e) {
            return processException(e.getMessage(), id);
        }    
    }
    
    // Future use 
    webService static String getPicklistValues(String id, String object_name, String field_name) {
        try {
            //Uncomment the following lines if this is a security issue
            //Map <String, Object> result = new Map<String, Object>();
            //result.put('id', id);
            //result.put('success', false);
            //result.put('error', 'Unsupported');
            //String JSONString = JSON.serialize(result);
            //return JSONString;
            
            Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(object_name).getDescribe().fields.getMap();    
            List<Schema.PicklistEntry> ple = fieldMap.get(field_name).getDescribe().getPickListValues();
            
            Map<String, String> options = new Map<String, String>();
            for( Schema.PicklistEntry f : ple) {               
                options.put(f.getLabel(), f.getValue());
            }
            
            Map <String, Object> result = new Map<String, Object>();
            result.put('id', id);
            result.put('success', true);
            result.put('result', options);
            String JSONString = JSON.serialize(result);
            return JSONString;
        } 
        catch(Exception e) {
            return processException(e.getMessage(), id);
        }    
    }
    
    // Future use 
    webService static String getObjectFields(String id, String object_name) {
        try {
            //Uncomment the following lines if this is a security issue
            //Map <String, Object> result = new Map<String, Object>();
            //result.put('id', id);
            //result.put('success', false);
            //result.put('error', 'Unsupported');
            //String JSONString = JSON.serialize(result);
            //return JSONString;
            
            Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(object_name).getDescribe().fields.getMap();
            List < Map <String,Object> > listFields = new List < Map <String,Object> >();
            
            for (Schema.SObjectField sfield : fieldMap.Values()) {
                schema.describefieldresult dfield = sfield.getDescribe();
                Map<String, Object> info =new Map<String, Object>();
                info.put('label', dfield.getLabel());
                info.put('name', dfield.getName());
                info.put('type', dfield.getType().name());
                info.put('length', dfield.getLength());
                info.put('custom', dfield.isCustom());
                info.put('accessible', dfield.isAccessible());
                info.put('updateable', dfield.isUpdateable());
                listFields.add(info);
            }
            
            Map <String, Object> result = new Map<String, Object>();
            result.put('id', id);
            result.put('success', true);
            result.put('result', listFields);
            
            String JSONString = JSON.serialize(result);
            return JSONString;
        } 
        catch(Exception e) {
            return processException(e.getMessage(), id);
        }    
    }
    
    // Future use 
    webService static String getQuery(String id, String query) {
        try {
            //Uncomment the following lines if this is a security issue
            //Map <String, Object> result = new Map<String, Object>();
            //result.put('id', id);
            //result.put('success', false);
            //result.put('error', 'Unsupported');
            //String JSONString = JSON.serialize(result);
            //return JSONString;
            
            List<SObject> objs = Database.query(query);
            Map <String, Object> result = new Map<String, Object>();
            result.put('id', id);
            result.put('success', true);
            result.put('result', objs);    
            String JSONString = JSON.serialize(result);
            return JSONString;
        } 
        catch(Exception e) {
            return processException(e.getMessage(), id);
        }    
    }
    */
    
}