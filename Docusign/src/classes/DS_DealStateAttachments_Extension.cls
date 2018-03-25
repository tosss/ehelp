public class DS_DealStateAttachments_Extension {
    
    //Instance variables
    public Id opportunityId {get; set;} 
    public final Opportunity opportunity=null;
    public List<Deal_State__c> dealStateList = new List<Deal_State__c>();
    public Integer numberOfPageBlocks{get;set;}
    public boolean hasNoError{get;set;}
    public boolean enableButtons{get;set;}
    public String attachmentId{get;set;}
    public List<String> mapReOrderValues = new List<String>();
    public set<String> createdDateSet = new Set<string>();
    public String dealChangeId{get;set;}
    
    //Setter and Getter
    public void setMapReOrderValues(List<String> mapReOrderValues)
    {
        this.mapReOrderValues = mapReOrderValues;
    }
    public List<String> getMapReOrderValues()
    {
        return this.mapReOrderValues;
    }
    
    //Wrapper class for datatable
    public class AttachmentWrapper
    {
        public List<Attachment> attachmentList {get; set;}
        public List<Deal_Change__c> dealChanges{get;set;}
        public String sectionTitle{get; set;}
    }
    
    //Constructor
    public DS_DealStateAttachments_Extension(ApexPages.StandardController OpportunityController)
    { 
        try
        {
            hasNoError=true;  
            this.opportunity = (Opportunity)OpportunityController.getRecord();
            if(this.opportunity!=null)
            {
                opportunityId = opportunity.Id;
                if(opportunityId!=null)
                {
                    getAttachmentMap();
                    dealStateList = [SELECT Id,Name,(select id,createdDate from Deal_Change__r order by createdDate desc) FROM Deal_State__c WHERE Opportunity__c=:opportunityId order by createdDate desc];
                    if(dealStateList.size()!=0)
                    {
                        List<Deal_Change__c> dcList;
                        for(Deal_State__c dealStateObj : dealStateList)
                        {
                            dcList =  dealStateObj.Deal_Change__r;
                        }
                        if(createdDateSet==null||createdDateSet.isEmpty()||createdDateSet.size()==0)
                        {
                            if(dcList==null||dcList.size()==0||dcList.isEmpty())
                            {
                                hasNoError = false;
                                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'No Attachment or no Deal Change found for this opportunity'));  
                            }
                        }
                    }
                    else
                    {
                        if((createdDateSet==null||createdDateSet.isEmpty()) || dealStateList==null )
                        {
                            hasNoError = false;
                            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'No Attachments or no Deal State found for this opportunity'));  
                        }
                    }
                }
                else
                {
                    dealStateList = null;
                    hasNoError=false;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Opportunity ID not found in the url'));
                }
            }
        }
        catch(Exception e)
        {
            hasNoError=false;
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Opportunity ID not found in the url'));
        }
    }
    
    
    //Create Deal Change map
    public Map<String,List<Deal_Change__c>> getDCMap()
    {
        if(dealStateList!=null)
        {
            List<Deal_Change__c> dcList = [select id,Requested_Changes__c,Hole_in_Firewall_No_Charge__c,Hole_in_Firewall_use_Cat_34122_98__c	,
                                           ASP_Buy_Out_Cat_34174_36__c,ASP_Buy_Out_Price__c, ASP_Buy_Out_Quote__c,
                                           No_Quotes_Required__c,Network_Quotes_Attached__c,createdDate from Deal_Change__c 
                                           where Deal_State__c in :dealStateList order by createdDate desc];
            
            
            Map<String,List<Deal_Change__c>> dcMap = new Map<String,List<Deal_Change__c>>();
            
            if(dcList!=null)
            {
                for(Deal_Change__c dcObj : dcList) 
                {
                    String mapId = String.valueOf(resetSeconds(dcObj.createdDate));
                    dcObj = createDcNotesBody(dcObj);
                    List<Deal_Change__c> dealChangeList ;
                    if(dcMap.containsKey(mapId))
                    {
                        dealChangeList = dcMap.get(mapId);
                        dealChangeList.add(dcObj);
                        dcMap.put(mapId, dealChangeList);
                    }
                    else
                    {
                        dealChangeList = new List<Deal_Change__c>();
                        dealChangeList.add(dcObj);
                        dcMap.put(mapId,dealChangeList);
                    }
                }
                return dcMap;
            }
            else
            {
                return null;
            }
        }
        else
        {
            return null;
        }
    }
    
    
    
    //Creates notes body depending on the fields of DC object
    public Deal_Change__c createDcNotesBody(Deal_Change__c dcObj)
    {
        String buildString  = '';
        if(dcObj.No_Quotes_Required__c==true)
        {
            buildString = buildString + 'No Quotes Required. ';
        }
        
        if(dcObj.Hole_in_Firewall_use_Cat_34122_98__c==true)
        {
            buildString = buildString + 'Hole in Firewall use Cat # 34122-98. ';
        }
        
        if(dcObj.Hole_in_Firewall_No_Charge__c==true)
        {
            buildString = buildString + 'Hole in Firewall No Charge. ';
        }
        
        if(dcObj.ASP_Buy_Out_Cat_34174_36__c==true)
        {
            buildString = buildString+ 'ASP Buy-Out Cat # 34174-36. ';
            Decimal aspBuyOutQuote = 0;
            String aspBuyOutPrice = '';
            if(dcObj.ASP_Buy_Out_Quote__c!=null)
            {
                aspBuyOutQuote = dcObj.ASP_Buy_Out_Quote__c;
                buildString = buildString+'ASP Buy-Out Quote #: '+aspBuyOutQuote+'. ';
            }
            if(dcObj.ASP_Buy_Out_Price__c!=null)
            {
                aspBuyOutPrice =  dcObj.ASP_Buy_Out_Price__c;
                buildString = buildString+'ASP Buy-Out Price: '+aspBuyOutPrice+'. ';
            }
            
        }
        
        Deal_Change__c dealChangeObj = dcObj;
        if( dealChangeObj.Requested_Changes__c==null)
        {
            dealChangeObj.Requested_Changes__c = '';
        }
        dealChangeObj.Requested_Changes__c = (buildString==''?((dealChangeObj.Requested_Changes__c).endsWith('.')?
                                              dealChangeObj.Requested_Changes__c:
                                             (dealChangeObj.Requested_Changes__c==''?
                                              dealChangeObj.Requested_Changes__c:dealChangeObj.Requested_Changes__c+'.')
                                              ):
                                              (dealChangeObj.Requested_Changes__c==''?buildString:
                                              (dealChangeObj.Requested_Changes__c).endsWith('.')?
                                              dealChangeObj.Requested_Changes__c+' '+
                                              buildString:dealChangeObj.Requested_Changes__c+'. '+buildString)
                                             );
        return dealChangeObj;
    }
    
    //Create attachment map from Attachment sObject
    public Map<String,List<Attachment>> getAttachmentMap()
    {
        List<Attachment> attachmentList = [select id,parentId,Description,Name,createdDate from Attachment 
                                           where parentId=:opportunityId order by createdDate desc];
        Map<String,List<Attachment>> attachmentMap = new Map<String,List<Attachment>>();
        
        if(attachmentList!=null || attachmentList.size()!=0)
        {
            for(Attachment attachmentObj:attachmentList)
            {
                createdDateSet.add(String.valueOf(resetSeconds(attachmentObj.createdDate)));
                //attachment parent id is opportunity id
                String mapId = attachmentObj.parentId+':'+String.valueOf(resetSeconds(attachmentObj.createdDate));
                List<attachment> attachList;
                if(attachmentMap.containsKey(mapId))
                {
                    attachList = attachmentMap.get(mapId);
                    attachList.add(attachmentObj);
                    attachmentMap.put(mapId, attachList);
                }
                else
                {
                    attachList = new List<Attachment>();
                    attachList.add(attachmentObj);
                    attachmentMap.put(mapId, attachList);
                }
            }
            return attachmentMap;
        }
        else{
            hasNoError=false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'No Attachments found for this opportunity'));
            return null;
        }
    }
    
    //Create wrapper object list of all attachments and notes
    public  Map<String,List<AttachmentWrapper>> getAttachments()
    {   
        try
        {
            renderEditDeleteBtns();
            mapReOrderValues.clear();
            Map<String,List<AttachmentWrapper>> attachmentWrapperMap;
            List<AttachmentWrapper> attachmentWrapperList;
            Map<String,List<Attachment>>  attachmentMap = getAttachmentMap();
            AttachmentWrapper attachmentWrapper;
            Map<String,List<Deal_Change__c>> dcMap =  getdcMap();
            Note noteObj;
            
            if(dealStateList!=null)
            {
                for(Deal_State__c dealStateObj : dealStateList)
                {
                    List<Deal_Change__c> dcList = dealStateObj.Deal_Change__r;
                    
                    attachmentWrapperMap = new Map<String,List<AttachmentWrapper>>();
                    for(String dcCreatedDate : dcMap.keySet())
                    {
                        attachmentWrapperList = new  List<AttachmentWrapper>();
                        attachmentWrapper = new AttachmentWrapper();
                        String mapId = opportunityId+':'+ dcCreatedDate;
                        
                        if(attachmentMap.get(mapId)!=null)
                        {
                            attachmentWrapper.attachmentList = attachmentMap.get(mapId);
                            createdDateSet.remove(dcCreatedDate);
                        }
                        if(dcMap.get(dcCreatedDate)!=null)
                        {
                            attachmentWrapper.dealChanges =  dcMap.get(dcCreatedDate);
                        }
                        String cDate = String.valueOf(dcCreatedDate).substring(0, 10);
                        attachmentWrapper.sectionTitle = cDate;
                        attachmentWrapperList.add(attachmentWrapper);
                        attachmentWrapperMap.put(cDate,attachmentWrapperList);
                    }
                }
                //If attachments are added directly without DS and DC
                if(!createdDateSet.isEmpty())
                {
                    attachmentWrapperMap  = createWrapperbyDate(attachmentWrapperMap, attachmentMap);
                }                
            }
            
            //To arrange the map in decreasing order of created date
            List<String> tempList = new List<String>();            
            if(attachmentWrapperMap!=null)
            {
                for(String temp : attachmentWrapperMap.keySet())
                {
                    tempList.add(temp);
                }                
                tempList.sort();                
                
                for(Integer i = tempList.size()-1; i>=0; i--)
                {
                    mapReOrderValues.add(tempList.get(i));
                }                
                numberOfPageBlocks = mapReOrderValues.size();
                return attachmentWrapperMap;
            }
            else
            {
                if(createdDateSet!=null||!createdDateSet.isEmpty())
                {
                    attachmentWrapperMap  = createWrapperbyDate(attachmentWrapperMap, attachmentMap);
                    return attachmentWrapperMap; 
                }
                else
                {
                    hasNoError = false;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'No Attachment found for this opportunity'));  
                    return null;
                }
            }
        }
        catch(Exception e)
        {
            hasNoError = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Opportunity ID not found in the url'+e.getMessage()+ ' '+e.getLineNumber()));  
            return null;
        }
    }
    
    //Attachments inserted without DS and DC. Creating Wrapper
    public Map<String,List<AttachmentWrapper>> createWrapperbyDate(Map<String,List<AttachmentWrapper>> attachmentWrapperMap,  Map<String,List<Attachment>>  attachmentMap)
    {
        if(attachmentWrapperMap==null){
            attachmentWrapperMap = new Map<String,List<AttachmentWrapper>>();
        }
        for(String createdDate : createdDateSet)
        {
            AttachmentWrapper attchWrapperObj = new AttachmentWrapper();
            attchWrapperObj.attachmentList = attachmentMap.get(opportunityId+':'+createdDate);
            attchWrapperObj.sectionTitle = createdDate.substring(0, 10);
            List<AttachmentWrapper> tempAttachWrapperList = new List<AttachmentWrapper>();
            tempAttachWrapperList.add(attchWrapperObj);
            attachmentWrapperMap.put(createdDate.substring(0, 10), tempAttachWrapperList);
        }
        return attachmentWrapperMap;
    }
    
    //View and hide edit and delete buttons based on profile
    public void renderEditDeleteBtns()
    {
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name; 
        List<DS_Network_Quote_Attachment_Permissions__c> validProfileList = [select Profile_Name__c from DS_Network_Quote_Attachment_Permissions__c];
        
        if(validProfileList!=null||!validProfileList.isEmpty())
        {
            for(DS_Network_Quote_Attachment_Permissions__c quoteObj : validProfileList)
            {
                String validProfileName = quoteObj.Profile_Name__c;
                if(validProfileName.equalsIgnoreCase(profileName))
                {
                    enableButtons = true;
                    break;
                }
                else
                {
                    enableButtons=false;
                }
            }
        }
    }
    
    //Delete attachment
    public PageReference deleteAttachment()
    {
        if(attachmentId!=null)
        {
            List<Attachment> attachmentList = [select id from attachment where id=:attachmentId];
            delete attachmentList;
        }
        return  new PageReference('/apex/DS_DealStateAttachmentsView?id='+opportunityId);
    }
    
    //Delete Deal Change Notes
    public PageReference deleteDealChange()
    {
        if(dealChangeId!=null)
        {
            List<Deal_Change__c> dealChangeList = [select id from Deal_Change__c where id=:dealChangeId];
            delete dealChangeList;
        }
        return  new PageReference('/apex/DS_DealStateAttachmentsView?id='+opportunityId);
    }
    
    //Reset seconds and milliseconds from datetime
    public datetime resetSeconds(datetime createdDate)
    {
        Integer day =createdDate.day();
        Integer month =createdDate.month();
        Integer year =createdDate.year();
        Integer hour =0;
        Integer minute =0;
        integer second =0;
        DateTime newCreatedDate = datetime.newInstance(year, month, day, hour, minute, second);
        return newCreatedDate;
    }
}