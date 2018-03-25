global class getFieldObject 
{
    @RemoteAction 
    global static String getSobjectField(String sobjectName)
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
}