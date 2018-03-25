public class Databackup 
{
    public transient String sobjectType{get;set;}
    public transient String feildNames{get;set;}
    public transient List<String> feildNamesList{get;set;}
    public transient List<sobject> records{get;set;}
    public transient List<String> recordDetail{get;set;}
    public transient integer totalfields{get;set;}
    public Databackup()
    {
        //sobjectType = ApexPages.currentPage().getParameters().get('object');
        sobjectType = 'Account';
        feildNamesList = fetchFieldNames(sobjectType);
        String fields = '';
        feildNames = '';
        for(String f: feildNamesList)
        {
            fields+=f+',';
            feildNames += '"'+f+'",';
        }
        fields = fields.removeEnd(','); 
        feildNames = feildNames.removeEnd(',');
        feildNames += '\n';
        totalfields = feildNamesList.size();
        records = Database.query('select '+fields+' from '+sobjectType+' limit 1000');
        recordDetail = new List<String>();
        for(Sobject s:records)
        {
            String v = '';
            for(String f:feildNamesList)
            {
                v += String.valueof(s.get(f))+',';
            }
            v=v.removeEnd(',');
            v=v.replaceAll('\n', '');
            v += '\n';
            recordDetail.add(v);
        }
    }
    
    public List<string> fetchFieldNames(String sobjectType)
    {
        Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sobjectType).getDescribe().fields.getMap();
        List<String> fields = new List<String>();
        for(string s:fieldMap.keySet())
        {
            if(String.valueof(fieldMap.get(s).getDescribe().getType())!='Address')
            fields.add(s);
        }
        return fields;
    }
}