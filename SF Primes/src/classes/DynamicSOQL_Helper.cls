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
}