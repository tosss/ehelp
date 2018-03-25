public class DynamicSOQL_Helper implements DynamicSOQL_Interface
{    
    public class QueryConstructorCondition
    {
        public decimal order {get;set;} 
        public string key {get;set;} 
        public string operator {get;set;}
        public string value {get;set;}
        public string className {get;set;} 
        public string methodName {get;set;}        
    }
    
    public class QueryConditionsPacketClass
    {
        public List<QueryConstructorCondition> ConditionsList {get;set;}
        public string QueryConditionExpression {get;set;}
        
        public QueryConditionsPacketClass() 
        {
            ConditionsList = new List<QueryConstructorCondition>();
        }
    }
    
    public static string QueryConstructor(QueryConditionsPacketClass QueryConditionsPacket)
    {        
        string queryConditions = ''; 
        
        map<integer, string> OrderToStringMap = new map<integer, string>();       
        
        for(QueryConstructorCondition cdqc: QueryConditionsPacket.ConditionsList)
        {            
            if(cdqc.value == 'Dynamic') 
            {             
                cdqc.value = '\'' + (string) DynamicSOQL_Helper.QueryValueMethod(cdqc.classname, cdqc.methodname) + '\''; 
            }
            else
            {
                cdqc.value = '\'' + cdqc.value + '\'';
            }
            
            OrderToStringMap.put(integer.valueOf(cdqc.Order), cdqc.key + ' ' + cdqc.operator + ' ' +cdqc.value + ' ');
            
        }
        
        system.debug(OrderToStringMap);     
        
        if(QueryConditionsPacket.QueryConditionExpression != null)
        {
            for(string s: QueryConditionsPacket.QueryConditionExpression.split(' '))
            {
                if(s.isNumeric()) 
                {
                    queryConditions += ' ' + OrderToStringMap.get(integer.valueOf(s));
                }
                else
                {
                    queryConditions += ' ' + s;
                }
            }
        }
        
        system.debug(queryConditions);
        
        return queryConditions;
    }
    
    public ID CurrentUserId() { return userInfo.getUserId(); }
    
    /*
    public string CurrentUserName() { return userInfo.getName(); }
    public string CurrentLoginUserName() { return userInfo.getUserName(); }
    public string CurrentUserFirstName() { return userInfo.getFirstName(); }
    public string CurrentUserLastName() { return userInfo.getLastName(); }
    */

    
    public static object QueryValueMethod(string ClassName, string MethodName)
    {
        object RequestedValue;
        
        Type t = Type.forName(ClassName);
        
        DynamicSOQL_Interface InterfaceInstance = (DynamicSOQL_Interface) t.newInstance();
        
        // could not access this method dynamically, had to check with condition
        if(MethodName == 'CurrentUserId()'){ RequestedValue = InterfaceInstance.CurrentUserId(); }
        
        return RequestedValue;
    }
    
    public static ID getRecordTypeID(string sObjectName, string recordTypeName)
    {
        ID recordTypeID = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject(sObjectName, recordTypeName);
        return recordTypeID;
    }
    
    public static object routeToSpecificMethod(ALL_Query_Conditions__c currentQueryCondition, ALL_Field_Value_Assignment_Settings__c fva)
    {
        object RequestedValue;
        string ClassName = currentQueryCondition.Class_Name__c;
        string MethodName = currentQueryCondition.Method_Name__c;
        string sObjectName = fva.Receiving_sObject__c;
        string recordTypeName = currentQueryCondition.value__c;
        Type t = Type.forName(ClassName);
        
        DynamicSOQL_Interface InterfaceInstance = (DynamicSOQL_Interface) t.newInstance();        
       
        if(MethodName == 'getRecordTypeId()'){ RequestedValue = InterfaceInstance.getRecordTypeId(sObjectName, recordTypeName); }
        if(MethodName == 'getAdminUser()'){ RequestedValue = InterfaceInstance.getAdminUser(); }
      
        return RequestedValue;
    }
    
    public static string getAdminUser()
    {
        GlobalSettings__c gs = GlobalSettings__c.getOrgDefaults();
        string userName = gs.Admin_Integration_Username__c;
        
        return userName;
    }

}