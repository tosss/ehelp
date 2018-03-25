public with sharing class AngularJSDemoController{ 
    
    public String AccountList { get; set; }
    
    //Subclass : Wrapper Class 
    public class Accountwrap {
        //Static Variables 
        public string id;
        public string name;
        public string Phone;
        
        //Wrapper Class Controller
        Accountwrap() {
            Phone = '';
        }
        
    }
       
    //Method to bring the list of Account and Serialize Wrapper Object as JSON
    public  static String getlstAccount() {
        List < Accountwrap > lstwrap = new List < Accountwrap > ();
        List < account > lstacc = [SELECT Name, Phone
                                   FROM Account limit 100
                                  ];
        for (Account a: lstacc) {
            Accountwrap awrap = new Accountwrap();
            awrap.name = a.name;
            if (a.Phone != null) {
                awrap.Phone = a.Phone;
            }
            lstwrap.add(awrap);
        }
        System.debug(JSON.serialize(lstacc));
        return JSON.serialize(lstacc);
     }
    @RemoteAction
    public static Set<String> getFieldNames(String sObjectName)
    {
         Map<String, Schema.SObjectField> M=Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        System.debug('M.values()---->'+M.keySet());
        return M.keySet();
    }
    public static String getSobjectField(String sobjectName)
    {
        Map<String,String> fieldTotypeMap = new Map<String,String>();
        Map<String, Schema.SObjectField> M=Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap();
        
        for(String key: M.KeySet())
        {
            fieldTotypeMap.put(key, String.ValueOf(M.get(key).getDescribe().getType()));
        }
        for(String key : fieldTotypeMap.KeySet())
        {
            if(fieldTotypeMap.get(key)=='reference')
            {
                List<Schema.Sobjecttype> objectName = M.get(key).getDescribe().getReferenceTo();
                for( Schema.Sobjecttype s : objectName)
                {
                    fieldTotypeMap.put(key,'reference@'+s.getDescribe().getName());
                }
            }
        }
        string ser = JSON.serialize(fieldTotypeMap);
        ser = ser.replaceAll('"',' ');
        return ser;
    }
    
    public static String getSobjectFieldList()
    {
        Map<String,String> fieldTotypeMap = new Map<String,String>();
        Map<String, Schema.SObjectField> M=Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        List<String> keyString = new List<String>(M.keyset());
        keyString.sort();
        return JSON.serialize(keyString);

    }
    public static String getSobjectRecordList()
    {
        Map<String, Schema.SObjectField> M=Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        List<String> keyString = new List<String>(M.keyset());
        keyString.sort();
        String fields = '';
        for(String s:keyString)
        {
            fields = fields + ','+s;
        }
        fields = fields.removeStart(',');
        String query = 'select '+fields+ ' from Account LIMIT 40000';
        List<sobject> recordsList  = Database.query(query);
        List<String> fieldsSpl = JSON.serialize(recordsList).split(',');
        String returnValue = '';
        for(String s:fieldsSpl)
        {
            if(s.contains(':'))
            {
                List<String>  pairs = s.split(':');
                pairs[0] = pairs[0].toUpperCase();
                s=pairs[0]+':'+pairs[1];
                if(Math.Mod(s.countmatches('"'),2)==1)
                {
                    s = s+'"';
                }
                returnValue += ','+s;
            }
        }
        returnValue = returnValue.removeStart(',');
        System.debug(returnValue);
        return returnValue;
    }
    public static String getSobjectChildRelationship()
    {
        Map<String,String> fieldTotypeMap = new Map<String,String>();
        Schema.DescribeSobjectResult M=Schema.getGlobalDescribe().get('Account').getDescribe();
        List<Schema.ChildRelationship> C = M.getChildRelationships();
        List<String> str = new List<String>();
        for(Schema.ChildRelationship cr: C)
        {
            str.add(cr.getRelationshipName());
        }
        str.sort();
        return JSON.serialize(str);
    }
    public static String getSobjectFieldLabelList()
    {
        Map<String,String> fieldTotypeMap = new Map<String,String>();
        Map<String, Schema.SObjectField> M=Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        Map<String,String> keyString = new Map<String,String>();
        for(String key: M.KeySet())
        {
            keyString.put(key,M.get(key).getDescribe().getLabel());
        }
        return JSON.serialize(keyString);
    }
}