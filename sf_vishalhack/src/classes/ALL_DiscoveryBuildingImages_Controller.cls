/*--------------------------------------------------------------------
* 2016-08-31 -venkata.shrivol@cdk.com	-Created in SLSLong
* Description - Controller for ALL_DiscoveryBuildingImagesComponent
* ------------------HISTORY----------------------------------------
* 
----------------------------------------------------------------------*/
//2016-12-22- anirudh.singh@cdk.com- Changed the field reference from Building_Name_Identifier__c to Site_Building_Name__c.
public class ALL_DiscoveryBuildingImages_Controller
{
    private Boolean initialized=false;
    private String previousCommentsValue{get; set;}
    
    public Id oppLocationSiteIdForRecs{get; set;}
    public Opportunity_Location__c oppLocRecord
    {
        get
        {
            if(!initialized && oppLocationSiteIdForRecs!=Null)
            {
                oppLocRecord=fetchOppLocationRecord(oppLocationSiteIdForRecs);
                previousCommentsValue=oppLocRecord.Comments_on_Building_Images__c;
                initialized=true;
            }
            return oppLocRecord;
        }
        set;
    }
    
    public BuildingImgWrapper buildingImgWrapperRec
    {
        get
        {
            if(!initialized && oppLocationSiteIdForRecs!=Null)
            {
                buildingImgWrapperRec=fetchBuildingRecords(oppLocationSiteIdForRecs);
                initialized=true;
            }
            return buildingImgWrapperRec;
        }
        set;
    }
    
    private static Opportunity_Location__c fetchOppLocationRecord(Id oppLocationSiteIdForRecs)
    {
        List<Opportunity_Location__c> oppocList=[
            SELECT Id, Site__r.Name, Site__r.BillingStreet, Site__r.BillingCity, Site__r.BillingPostalCode, 
            Comments_on_Building_Images__c
            FROM Opportunity_Location__c 
            WHERE Id=:oppLocationSiteIdForRecs
        ];
        
        Opportunity_Location__c oppLocRecord=oppocList.size()>0 ? oppocList[0] : new Opportunity_Location__c();
        
        return oppLocRecord;
    }
    
    private BuildingImgWrapper fetchBuildingRecords(Id oppLocationSiteIdForRecs)
    {
        BuildingImgWrapper bIWrapperRec=new BuildingImgWrapper();
        
        for(Opportunity_Location__c oppLoc: [
            SELECT Id, Name, Site_Building_Name__c, 
            (
                SELECT Id, Description 
                FROM Attachments 
                WHERE ContentType LIKE 'image%'
            )
            FROM Opportunity_Location__c 
            WHERE Building_Site__c=:oppLocationSiteIdForRecs
        ])
        {
            BuildingAttchsWrapper baWrapper=new BuildingAttchsWrapper();
            baWrapper.buildingAutoNumber=oppLoc.Name;
            baWrapper.buildingName=oppLoc.Site_Building_Name__c;
            baWrapper.buildingId=oppLoc.Id;
            
            if(oppLoc.Attachments!=Null && !oppLoc.Attachments.isEmpty())
            {
                List<Attachment> attachmentRecs=new List<Attachment>();
                for(Attachment att: oppLoc.Attachments)
                {
                    attachmentRecs.add(att);
                }
                baWrapper.buildingAttachments=attachmentRecs;
                
                bIWrapperRec.isAttachment=true;
            }
            bIWrapperRec.buildingWrapperList.add(baWrapper);
        }
        
        return bIWrapperRec;
    }
    
    public void saveAndRefresh()
    {
        if(previousCommentsValue!=oppLocRecord.Comments_on_Building_Images__c)
        {
            update oppLocRecord;
        }
    }
    
    @RemoteAction
    public static String saveMap(String oppLocationId, String mapChangesObject)
    {
        List<Opportunity_Location__c> oppLocRecords=new List<Opportunity_Location__c>([SELECT Id, Map_Annotations__c FROM Opportunity_Location__c WHERE Id=:oppLocationId]);
        String errMessage='';
        
        if(!oppLocRecords.isEmpty() && oppLocRecords[0].Map_Annotations__c!=mapChangesObject)
        {
            oppLocRecords[0].Map_Annotations__c=mapChangesObject;
            DataBase.SaveResult updateResult=Database.Update(oppLocRecords[0], false);
            
            if(updateResult!=Null && !updateResult.isSuccess())
            {
                for(Database.Error err: updateResult.getErrors())
                {
                    String currentErrMsg=err.getMessage();
                    
                    if(errMessage=='')
                    {
                        errMessage=currentErrMsg;
                    }
                    else if(errMessage!='' && !errMessage.contains(currentErrMsg))
                    {
                        errMessage+=', '+currentErrMsg;
                    }
                }
            }
        }
        else
        {
            errMessage='Save not valid. No changes found.';
        }
        
        return errMessage;
    }
    
    @RemoteAction
    public static String fetchMap(String oppLocationId)
    {
        Opportunity_Location__c oppLoc=[SELECT Id, Map_Annotations__c FROM Opportunity_Location__c WHERE Id=:oppLocationId];
        
        return oppLoc.Map_Annotations__c;
    }
    
    @RemoteAction
    public static String saveImgChanges(String deviceImgId, String deviceImgDesc, String oppBuildingObj)
    {
        BuildingIdRotatnsWrapper oppBuildingObjWrapper=(BuildingIdRotatnsWrapper)JSON.deserialize(oppBuildingObj, BuildingIdRotatnsWrapper.class);
        system.debug('oppBuildingObjWrapper---->'+oppBuildingObjWrapper);
        
        try
        {
            Opportunity_Location__c oppBuilding=new Opportunity_Location__c();
            oppBuilding.Id=oppBuildingObjWrapper.oppBuildingId;
            oppBuilding.Device_Image_Rotations__c=oppBuildingObjWrapper.imgRotations;
            update oppBuilding;
            
            Attachment modifiedAttch=new Attachment();
            modifiedAttch.Id=deviceImgId;
            modifiedAttch.Description=deviceImgDesc;
            update modifiedAttch;
        }
        catch(Exception ex)
        {
            return ex.getMessage();
        }
        
        return 'Success';
    }
    
    @RemoteAction
    public static List<BuildingIdRotatnsWrapper> fetchImgRotations(String oppLocationId)
    {
        List<BuildingIdRotatnsWrapper> buildingImgRotatnsList=new List<BuildingIdRotatnsWrapper>();
        for(Opportunity_Location__c oppBuilding: new List<Opportunity_Location__c>([
            SELECT Id, Name, Device_Image_Rotations__c 
            FROM Opportunity_Location__c 
            WHERE Building_Site__c=:oppLocationId
        ]))
        {
            BuildingIdRotatnsWrapper ref=new BuildingIdRotatnsWrapper();
            ref.oppBuildingId=oppBuilding.Id;
            ref.oppBuildingName=oppBuilding.Name;
            ref.imgRotations=oppBuilding.Device_Image_Rotations__c;
            buildingImgRotatnsList.add(ref);
        }
        system.debug('buildingImgRotatnsList---->'+buildingImgRotatnsList);
        if(buildingImgRotatnsList.size()>0)
        {
            return buildingImgRotatnsList;
        }
        return Null;
    }
    
    public class BuildingImgWrapper
    {
        public Boolean isAttachment{get; set;}
        public List<BuildingAttchsWrapper> buildingWrapperList{get; set;}
        
        public BuildingImgWrapper()
        {
            isAttachment=false;
            buildingWrapperList=new List<BuildingAttchsWrapper>();
        }
    }
    
    public class BuildingAttchsWrapper
    {
        public String buildingAutoNumber{get; set;}
        public List<Attachment> buildingAttachments{get; set;}
        public String buildingName{get; set;}
        public String buildingId{get; set;}
    }
    
    public class BuildingIdRotatnsWrapper
    {
        public Id oppBuildingId{get; set;}
        public String oppBuildingName{get; set;}
        public String imgRotations{get; set;}
    }
}