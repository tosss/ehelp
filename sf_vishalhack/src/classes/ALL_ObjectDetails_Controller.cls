//2016-08-29- anirudh.singh@cdk.com- Created this class for ALL_ObjectDetails Visualforce Component.
//2016-12-22- anirudh.singh@cdk.com- Changed the field reference from Building_Name_Identifier__c to Site_Building_Name__c.
public class ALL_ObjectDetails_Controller
{
    private Boolean initialized=false;
    public Id oppLocationSiteIdForRecs{get; set;}
    public ALL_SObject__mdt sObjectMetadataRecord{get; set;}
    public String objDetailsScenario{get; set;}
    
    public ObjectDetailsWrapper wrapperRecordToDisplay
    {
        get
        {
            if(!initialized && oppLocationSiteIdForRecs!=Null && sObjectMetadataRecord!=Null)
            {
                wrapperRecordToDisplay=fetchObjectDetailsWrapper(oppLocationSiteIdForRecs, sObjectMetadataRecord, 
                                                                 objDetailsScenario);
                initialized=true;
            }
            return wrapperRecordToDisplay;
        }
        set;
    }
    
    private static ObjectDetailsWrapper fetchObjectDetailsWrapper(Id oppLocationSiteIdForRecs, ALL_SObject__mdt sObjectMetadataRecord, 
                                                                  String objDetailsScenario)
    {
        ObjectDetailsWrapper wrapperRecord;
        Opportunity_Location__c siteRecord=(objDetailsScenario!='pdf') ? fetchSiteRecord(oppLocationSiteIdForRecs, sObjectMetadataRecord.SObject_Name__c) : Null;
        
        if(sObjectMetadataRecord.Building_Dependent__c)
        {
            Map<Id, BuildingNameIdentifierWrapper> buildingIdNameIdentifierMap=fetchBuildingIdNameIdentifierMap(oppLocationSiteIdForRecs);
            wrapperRecord=fetchSobjectList(new List<Id>(buildingIdNameIdentifierMap.keySet()), sObjectMetadataRecord, 
                                           Null, objDetailsScenario);
            
            wrapperRecord.buildingWrapperList=(objDetailsScenario!='pdf') ? buildingIdNameIdentifierMap.values() : Null;
        }
        else
        {
            wrapperRecord=fetchSobjectList(new List<Id>{oppLocationSiteIdForRecs}, sObjectMetadataRecord, 
                                           siteRecord, objDetailsScenario);
            
            wrapperRecord.holidayScheduleForSite=(objDetailsScenario!='pdf' 
                                                  && siteRecord.Holiday_Schedule__c!=Null 
                                                  && sObjectMetadataRecord.SObject_Name__c=='Hours_Of_Operation__c') ? siteRecord.Holiday_Schedule__c.replace(';', ', ') : Null;
        }
        
        wrapperRecord.reportNameLinkMap=(objDetailsScenario!='pdf') ? fetchReportNameLinkMap(siteRecord, sObjectMetadataRecord) : Null;
        
        return wrapperRecord;
    }
    
    private static Opportunity_Location__c fetchSiteRecord(Id oppLocationSiteIdForRecs, String sObjectAPIName)
    {
        String queryString='SELECT Id, Name, Holiday_Schedule__c';
        List<ALL_ObjectFieldIds__c> objFieldsList=ALL_ObjectFieldIds__c.getAll().values();
        
        if(objFieldsList!=Null && objFieldsList.size()>0)
        {
            for(ALL_ObjectFieldIds__c rec: objFieldsList)
            {
                if(rec.Object_API_Name__c==sObjectAPIName && rec.Equivalent_OppSite_Field_API_Name__c!=Null 
                   && queryString.indexOf(rec.Equivalent_OppSite_Field_API_Name__c)==-1)
                {
                    queryString+=', '+rec.Equivalent_OppSite_Field_API_Name__c;
                }
            }
        }
        
        queryString+=' FROM Opportunity_Location__c WHERE Id=\''+oppLocationSiteIdForRecs+'\'';
        
        Opportunity_Location__c siteRecord=database.query(queryString);
        return siteRecord;
    }
    
    private static Map<Id, BuildingNameIdentifierWrapper> fetchBuildingIdNameIdentifierMap(Id oppLocationSiteIdForRecs)
    {
        Map<Id, BuildingNameIdentifierWrapper> buildingIdNameIdentifierMap=new Map<Id, BuildingNameIdentifierWrapper>();
        
        for(Opportunity_Location__c rec: new List<Opportunity_Location__c>([
            SELECT Id, Name, Building_Site__c, Site_Building_Name__c 
            FROM Opportunity_Location__c 
            WHERE Building_Site__c=:oppLocationSiteIdForRecs
        ]))
        {
            BuildingNameIdentifierWrapper wrapperRecord=new BuildingNameIdentifierWrapper();
            wrapperRecord.name=rec.Name;
            wrapperRecord.identifier=rec.Site_Building_Name__c;
            
            buildingIdNameIdentifierMap.put(rec.Id, wrapperRecord);
        }
        
        return buildingIdNameIdentifierMap;
    }
    
    private static ObjectDetailsWrapper fetchSobjectList(List<Id> locationRecordIds, ALL_SObject__mdt sObjectMetadataRecord, 
                                                         Opportunity_Location__c siteRecord, String objDetailsScenario)
    {
        List<sObject> sObjectList=new List<sObject>();
        List<String> columnNamesList=new List<String>();
        List<String> columnAPINamesList=new List<String>();
        ObjectDetailsWrapper wrapperRecord=new ObjectDetailsWrapper();
        
        Schema.DescribeSobjectResult objResult=Schema.getGlobalDescribe().get(sObjectMetadataRecord.SObject_Name__c).getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap=objResult.fieldSets.getMap();
        
        if(locationRecordIds!=Null && locationRecordIds.size()>0)
        {
            String queryString='SELECT ';
            queryString+=processFieldSets(fieldSetMap.get(sObjectMetadataRecord.Field_Set_API_Name__c).getFields(), 
                                          columnNamesList, columnAPINamesList, sObjectMetadataRecord);
            queryString+='WHERE '+sObjectMetadataRecord.Where_Clause_Field_API_Name__c+' IN :locationRecordIds';
            
            try
            {
                sObjectList=Database.query(queryString);
            }
            catch(Exception ex)
            {
                system.debug('ex---->'+ex.getMessage());
            }
            
            if(sObjectList.size()>0 || objDetailsScenario=='pdf')
            {
                wrapperRecord.columnNamesList=columnNamesList;
                wrapperRecord.columnAPINamesList=columnAPINamesList;
                wrapperRecord.sObjectList=sObjectList;
            }
        }
        
        if(objDetailsScenario!='pdf')
        {
            wrapperRecord.createNewHrefLink=fetchCreateNewHrefLink(objResult, sObjectMetadataRecord, siteRecord);
            wrapperRecord.sObjectLabel=objResult.getLabel();
        }
        else
        {
            wrapperRecord.noOfRowsToDisplay=10;
        }
        
        return wrapperRecord;
    }
    
    private static String processFieldSets(List<Schema.FieldSetMember> fieldSetMembersList, List<String> columnNamesList, 
                                           List<String> columnAPINamesList, ALL_SObject__mdt sObjectMetadataRecord)
    {
        String queryString='';
        for(Schema.FieldSetMember field: fieldSetMembersList)
        {
            queryString+=field.getFieldPath()+', ';
            columnNamesList.add(field.getLabel());
            columnAPINamesList.add(field.getFieldPath());
        }
        
        if(sObjectMetadataRecord.SObject_Record_Type__c!=Null && sObjectMetadataRecord.SObject_Record_Type__c!='' && queryString.indexOf('RecordTypeId')==-1)
        {
            queryString+='RecordTypeId, ';
        }
        queryString+='Id FROM '+sObjectMetadataRecord.SObject_Name__c+' ';
        return queryString;
    }
    
    private static String fetchCreateNewHrefLink(Schema.DescribeSobjectResult objResult, ALL_SObject__mdt sObjectMetadataRecord, 
                                                 Opportunity_Location__c siteRecord)
    {
        String hrefLink='';
        Map<String, Schema.SObjectField> fieldMap=objResult.fields.getMap();
        
        String keyPrefix=objResult.getKeyPrefix();
        Id sObjectId;
        String fieldIdParameter='';
        
        for(ALL_ObjectFieldIds__c rec: ALL_ObjectFieldIds__c.getAll().values())
        {
            if(rec.Object_API_Name__c==sObjectMetadataRecord.SObject_Name__c 
               && rec.Record_Type_Name__c==sObjectMetadataRecord.SObject_Record_Type__c)
            {
                if(rec.Field_API_Name__c!=Null && rec.Field_API_Name__c!='')
                {
                    String tempFieldIdParameter='';
                    
                    if(rec.Equivalent_OppSite_Field_API_Name__c!=Null && rec.Equivalent_OppSite_Field_API_Name__c.indexOf('__r')>-1)
                    {
                        Integer indexOfDot=rec.Equivalent_OppSite_Field_API_Name__c.indexOf('.')+1;
                        Integer lengthOfFieldAPIName=rec.Equivalent_OppSite_Field_API_Name__c.length();
                        String referencedSObjectFieldName=rec.Equivalent_OppSite_Field_API_Name__c.substring(indexOfDot, lengthOfFieldAPIName);
                        
                        String parentRelationshipName=rec.Equivalent_OppSite_Field_API_Name__c.substring(0, indexOfDot-1);
                        SObject referencedSObject=siteRecord.getSObject(parentRelationshipName);
                        
                        tempFieldIdParameter=rec.Object_Or_Field_Id__c+'=';
                        if(!sObjectMetadataRecord.Building_Dependent__c)
                        {
                            tempFieldIdParameter+=EncodingUtil.urlEncode((String)referencedSObject.get(referencedSObjectFieldName), 'UTF-8')
                                +'&'+rec.Object_Or_Field_Id__c+'_lkid='+(String)referencedSObject.get('Id');
                        }
                        fieldIdParameter+=(fieldIdParameter.length()==0) ? tempFieldIdParameter : ('&'+tempFieldIdParameter);
                    }
                    else
                    {
                        tempFieldIdParameter=rec.Object_Or_Field_Id__c+'=';
                        if(!sObjectMetadataRecord.Building_Dependent__c)
                        {
                            tempFieldIdParameter+=EncodingUtil.urlEncode((String)siteRecord.get(rec.Equivalent_OppSite_Field_API_Name__c), 'UTF-8')
                                +'&'+rec.Object_Or_Field_Id__c+'_lkid='+(String)siteRecord.get('Id');
                        }
                        fieldIdParameter+=(fieldIdParameter.length()==0) ? tempFieldIdParameter : ('&'+tempFieldIdParameter);
                    }
                }
                else
                {
                    sObjectId=rec.Object_Or_Field_Id__c;
                }
            }
        }
        
        if(sObjectMetadataRecord.SObject_Record_Type__c!=Null && sObjectMetadataRecord.SObject_Record_Type__c!='')
        {
            String recordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject(sObjectMetadataRecord.SObject_Name__c, sObjectMetadataRecord.SObject_Record_Type__c);
            hrefLink='/'+keyPrefix+'/e?RecordType='+recordTypeId+'&';
        }
        else
        {
            if(checkIfRecordTypesPresent(sObjectMetadataRecord.SObject_Name__c))
            {
                hrefLink='/setup/ui/recordtypeselect.jsp?ent='+sObjectId
                    +'&retURL=/apex/ALL_CloseSelfDonotReload'
                    +'&save_new_url=/'+keyPrefix+'/e?';
            }
            else
            {
                hrefLink='/'+keyPrefix+'/e?';
            }
        }
        
        hrefLink+='retURL=/apex/ALL_CloseSelfDonotReload&saveURL=/apex/ALL_CloseSelf';
        hrefLink+='&'+fieldIdParameter;
        
        return hrefLink;
    }
    
    private static Boolean checkIfRecordTypesPresent(String sObjectAPIName)
    {
        Boolean recordTypesPresent=false;
        
        List<RecordType> recordTypesList=new List<RecordType>([
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType=:sObjectAPIName
        ]);
        
        if(recordTypesList.size()>0)
        {
            recordTypesPresent=true;
        }
        return recordTypesPresent;
    }
    
    private static Map<String, String> fetchReportNameLinkMap(Opportunity_Location__c siteRecord, ALL_SObject__mdt sObjectMetadataRecord)
    {
        Map<String, String> reportNameLinkMap=new Map<String, String>();
        Map<Id, String> reportIdParamMap=new Map<Id, String>();
        List<ALL_ObjectReportIds__c> reportIdsList=ALL_ObjectReportIds__c.getAll().values();
        
        if(reportIdsList!=Null && reportIdsList.size()>0)
        {
            for(ALL_ObjectReportIds__c ref: reportIdsList)
            {
                if(ref.Object_API_Name__c==sObjectMetadataRecord.SObject_Name__c && ref.Record_Type_Name__c==sObjectMetadataRecord.SObject_Record_Type__c)
                {
                    reportIdParamMap.put(ref.Report_Id__c, ref.Parameter_Number__c);
                }
            }
            
            if(reportIdParamMap.size()>0)
            {
                List<Report> reportsList=[SELECT Id, Name FROM Report WHERE Id IN :reportIdParamMap.keySet()];
                for(Integer i=0; i<reportsList.size(); i++)
                {
                    String reportLink='/'+reportsList[i].Id+'?'+reportIdParamMap.get(reportsList[i].Id)+'='+siteRecord.Name;
                    reportNameLinkMap.put(reportsList[i].Name, reportLink);
                }
            }
        }
        
        return reportNameLinkMap;
    }
    
    @RemoteAction
    public static String deleteObjectRecord(Id objectIdToBeDeletedId, String objectAPIName)
    {
        String errorMessage='';
        String queryString='SELECT Id FROM '+objectAPIName+' WHERE Id=\''+objectIdToBeDeletedId+'\'';
        
        try
        {
            sObject recordToDelete=database.query(queryString);
            delete recordToDelete;
        }
        catch(Exception ex)
        {
            errorMessage=ex.getMessage();
        }
        return errorMessage;
    }
    
    public class ObjectDetailsWrapper
    {
        public List<String> columnNamesList{get; set;}
        public List<String> columnAPINamesList{get; set;}
        public List<sObject> sObjectList{get; set;}
        public String holidayScheduleForSite{get; set;}
        public String createNewHrefLink{get; set;}
        public String sObjectLabel{get; set;}
        public List<BuildingNameIdentifierWrapper> buildingWrapperList{get; set;}
        public Map<String, String> reportNameLinkMap;
        public Integer noOfRowsToDisplay{get; set;}
        
        public Map<String, String> getReportNameLinkMap()
        {
            if(reportNameLinkMap.size()==0)
            {
                return Null;
            }
            else
            {
                return reportNameLinkMap;
            }
        }
    }
    
    public class BuildingNameIdentifierWrapper
    {
        public String name{get; set;}
        public String identifier{get; set;}
    }
}