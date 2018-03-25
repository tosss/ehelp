public with sharing class EMP_FormsPolicy_Controller 
{
    public list<ContentVersion> lstContent {get;set;} 
    public list<ContentVersion> lstContentmp {get;set;} 
    public Map<String,Map<String, List<ContentVersion>>> mapAllValue {get;set;}
    public set<String> setPolicyGeo {get;set;}
    public Boolean showHeader {get;set;}
    public Boolean showtabs {get;set;}
    public String TempstrType; 
    public ContentWorkspaceDoc objContentVersions {get;set;}
    public List<ContentVersion> listcontentVersions {get;set;} 
    
    public EMP_FormsPolicy_Controller(){
      
        String strType = apexpages.currentpage().getparameters().get('type');
        String strpage = apexpages.currentpage().getparameters().get('page');
        
        showtabs= true;
        if(TempstrType == 'Report' || TempstrType == 'Immigration'){
            showtabs = false;
        }
        
        if(strType == null){      
            TempstrType = '%' + strpage + '%';
        }
        else{
            TempstrType = '%' + strType + '%';
        }
        
        setPolicyGeo  = new set<String>(); 
        
        ContentWorkspaceDoc objContentVersion = null;
        list<ContentWorkspaceDoc> objContentVersions = [
            SELECT ContentDocument.Id,
            ContentDocument.CreatedDate,
            ContentDocument.LastModifiedDate,
            ContentDocument.IsDeleted,
            ContentDocument.SystemModstamp,
            ContentDocument.Title,
            ContentWorkspace.Name 
            FROM ContentWorkspaceDoc 
            where  ContentWorkspace.Name Like : TempstrType
            ORDER BY contentdocument.CreatedDate DESC NULLS FIRST limit 1 
        ];
        
        if(objContentVersions != null && !objContentVersions.isEmpty()) { objContentVersion = objContentVersions.get(0); }
        else { return; }
        
        listContentVersions =[
            Select  ContentDocumentId, 
            Title, 
            Publish_Date__c,
            Geographic_Applicability__c,
            Category__c, 
            TagCsv,
            Document_Type__c, 
            Video_File_Location__c,
            Content_Type__c,
            Policy_Geographic_Applicability__c,
            isLatest
            From ContentVersion 
            // where Geographic_Applicability__c != null AND ContentDocumentId =: objContentVersion.ContentDocument.Id];
            where Geographic_Applicability__c != null AND Recordtype.name =: objContentVersion.ContentWorkspace.Name AND isLatest = true 
        ];
        
        for(ContentVersion objCV : listContentVersions){
            system.debug('**************** loop   :' +objCV.title);
            String strGeoVal = objCV.Geographic_Applicability__c;
            for(String strU : strGeoVal.split(',')){
                setPolicyGeo.add(strU);
            }
        }
        
        //Getting the map of values for each and every Geographic region
        mapAllValue=new Map<String,Map<String, List<ContentVersion>>>();
        for(String strGeoApp : setPolicyGeo){
            Map<String, List<ContentVersion>> ContentVersionMap = new Map<String, List<ContentVersion>>();
            ContentVersionMap = pullDescrpt(strType,strGeoApp);
            mapAllValue.put(strGeoApp, ContentVersionMap);
        }
    }
    
    public Map<String, List<ContentVersion>> pullDescrpt(String strLib, String strGeo)
    {
        Map<String, List<ContentVersion>> ContentVersionMap = new Map<String, List<ContentVersion>>();
        String strGeoTemp='';
        
        for(ContentVersion objCop : ListContentVersions)
        {
            strGeoTemp=objCop.Geographic_Applicability__c;
            if(!strGeoTemp.contains(strGeo)) {
                continue;
            }
            
            if(ContentVersionMap.containsKey(objCop.Category__c)) {
                List<ContentVersion> lstCH = ContentVersionMap.get(objCop.Category__c);
                //check for duplicates
                Boolean isDuplicate=false;
                for(ContentVersion objCont : lstCH){
                    if(objCont.Title==objCop.Title){
                        isDuplicate=true;
                        break;
                    }
                }
                if(isDuplicate==false) lstCH.add(objCop);
                ContentVersionMap.put(objCop.Category__c, lstCH);
            } 
            else {
                ContentVersionMap.put(objCop.Category__c, new List<ContentVersion> {objCop});
            }
        }
        
        return ContentVersionMap;
    }
}