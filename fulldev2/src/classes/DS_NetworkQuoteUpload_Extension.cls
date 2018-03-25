public class DS_NetworkQuoteUpload_Extension 
{
    public Id sobjId {get; set;} 
    public final Opportunity Opp;
    public static final Integer NoOfMoreAttachments = 1;
    public String OverAllNotes {get; set;}
    public boolean isIE{get;set;}
    public boolean noQuotesRequired {get;set;}
    public boolean holeInFirewallUseCat {get;set;}
    public boolean holeInFirewallNoCharge{get;set;}
    public boolean aspBuyOutCat{get;set;}
    public String aspBuyOutPrice{get;set;}
    
    public class PageVariablePack
    {
        public integer FileNumber {get; set;}
        public attachment Attach {get; set;}
        public PageVariablePack(integer i, Attachment at)
        {
            FileNumber = i;
            Attach = at;
        }
    }
    
    public List<PageVariablePack> FileUploadVariableList {get; set;}
    public List<PageVariablePack> FileUploadVariableList2 {get; set;}
    
    //Constructor    
    public DS_NetworkQuoteUpload_Extension(ApexPages.StandardController OpportunityController)
    {
        FileUploadVariableList = new List<PageVariablePack>();
        FileUploadVariableList2 = new List<PageVariablePack>();
        
        try
        {
            this.Opp = (Opportunity)OpportunityController.getRecord();
            sobjId = Opp.Id;
            //To check browser for multi upload
            String browserInfo = ApexPages.currentPage().getHeaders().get('USER-AGENT');
            
            if(browserInfo.contains('MSIE')) { this.isIE = true; }
            else { this.isIE = false; }
            
            for(integer i=0; i<5; i++)
            {           
                FileUploadVariableList.add(new PageVariablePack(i+1, new attachment()));
            }
            
            for (Integer i=1; i<11; i++)
            {
                FileUploadVariableList2.add(
                    new PageVariablePack(
                        (FileUploadVariableList[FileUploadVariableList.size()-1].FileNumber+i), 
                        new Attachment()
                    )
                );
            } 
        }
        catch(Exception e)
        {
            System.debug(' Exception is '+ e.getMessage());
        }     
    }    
    
    //For Multiupload
    @RemoteAction
    public static String doUploadAttachment(
        String sobjId, String attachmentBody, String attachmentName,
        String attachmentId,String fileDescription,Integer counter, 
        Integer fileCount,String OverAllNotes,Boolean noQuotesRequired, 
        Boolean holeInFirewallUseCat, Boolean holeInFirewallNoCharge,
        Boolean aspBuyOutCat,String aspBuyOutPrice)
    {
        if(sobjId != null)
        {
            if(attachmentBody!=null&&
               attachmentName!=null&&
               fileDescription!=null&&
               counter!=null&&
               fileCount!=null)
            {
                Opportunity opp = getOpportunity(sobjId);
                
                if(opp != null) 
                {
                    if(attachmentBody != null) 
                    {
                        Attachment att = getAttachment(attachmentId);
                        String newBody = '';
                        
                        if(att.Body != null) 
                        {
                            newBody = EncodingUtil.base64Encode(att.Body);
                        }
                        
                        newBody += attachmentBody;
                        att.Body = EncodingUtil.base64Decode(newBody);
                        
                        if(attachmentId == null) 
                        {
                            att.Name = attachmentName;
                            att.parentId = opp.Id;
                            att.Description = fileDescription;
                        }
                        upsert att;
                        Datetime createdDate = System.now();
                        if(counter==fileCount-1)
                        {
                            createDealChange(
                                fileCount,
                                OverAllNotes,
                                sobjId,
                                noQuotesRequired, 
                                holeInFirewallUseCat, 
                                holeInFirewallNoCharge,
                                aspBuyOutCat,
                                aspBuyOutPrice
                            );
                        }
                        return att.Id;
                    } 
                    else
                    {
                        return 'Attachment Body was null';
                    }
                }
                else
                {
                    return 'Opportunity could not be found';
                }
            }
            else
            {
                if(overallNotes!=null)
                {
                    createDealChange(0,OverAllNotes,sobjId,
                                     noQuotesRequired, holeInFirewallUseCat,holeInFirewallNoCharge,
                                     aspBuyOutCat,aspBuyOutPrice);
                    return 'Notes inserted successfully';
                }
                return 'Notes not found';
            }
        }
        else
        {
            return 'Opportunity Id was null';
        }
    }
    
    //Method to get opportunity
    private static Opportunity getOpportunity(String sobjId) 
    {
        list<Opportunity> opportunities = [
            SELECT Id, Name
            FROM Opportunity
            WHERE Id =: sobjId
        ];
        
        if(opportunities.isEmpty()) 
        {
            return null;
        } 
        else 
        {
            return opportunities[0];
        }
    }
    
    //Insert Deal Change
    public static void createDealChange(
        Integer fileCount, String OverAllNotes, Id sobjId,
        Boolean noQuotesRequired, Boolean holeInFirewallUseCat,
        Boolean holeInFirewallNoCharge, Boolean aspBuyOutCat, 
        String aspBuyOutPrice)
    {
        try
        {
            Deal_State__c Ds = null;
            List<Deal_State__c> DsList = [
                Select Id, Name,
                First_NW_Quote_Uploaded_Date_Time__c,
                PSE_Status__c,
                Network_Needed__c,
                Last_Updated_By__c,
                Last_Updated_Date_Time__c 
                From Deal_State__c 
                Where Opportunity__c = :sobjId
            ];
            
            if(DsList != null && !DsList.isEmpty())
            { 
                Ds = DsList.get(0); 
            }
            
            //Create a deal change and insert it
            Deal_Change__c Dc = new Deal_Change__c();
            
            if (Ds == null)
            {
                RecordType DealStateRecordType = null;
                list<RecordType> DealStateRecordTypes = [select id from RecordType where name='Contract Sigining'];
                if (DealStateRecordTypes != null) { DealStateRecordType = DealStateRecordTypes.get(0); }
                
                Ds = new Deal_State__c();
                if (DealStateRecordType != null) { Ds.RecordTypeId = DealStateRecordType.Id; }
                Ds.Deal_Status__c = 'Networking Quote Uploaded';
                Ds.Created_By_Chatter_Action__c = true;
                Ds.Opportunity__c = sobjId;
                insert Ds;
            }
            if(Ds.First_NW_Quote_Uploaded_Date_Time__c==null)
            {
                Attachment attachObj = checkAttachments(sobjId,false);
                if(attachObj!=null)
                {
                    Ds.First_NW_Quote_Uploaded_Date_Time__c =  attachObj.CreatedDate;
                }
            }
            Attachment attachObj = checkAttachments(sobjId,true);
            if(attachObj!=null)
            {
               User userObj = [select id,firstName,LastName from User where id=:attachObj.CreatedById];
               Ds.Last_Updated_By__c =  userObj.FirstName+' '+userObj.lastName;
               Ds.Last_Updated_Date_Time__c = attachObj.CreatedDate;
            }
            if(Ds.PSE_Status__c.equalsIgnoreCase('Open') || Ds.PSE_Status__c.equalsIgnoreCase('Network Changes Requested'))
            {
                Ds.PSE_Status__c = 'Completed'; //Closed status not present
            }
            if(Ds.Network_Needed__c=='Yes' && Ds.PSE_Status__c.equalsIgnoreCase('Completed'))
            {
                Ds.PSE_Status__c='Network Changes Requested';
            }
            String plural = fileCount <= 1 ? '' : 's';
            String NumberOfFilesAttached;
            
            if(fileCount==0)
            {
                NumberOfFilesAttached = 'No files added';
            }
            else
            {
                NumberOfFilesAttached = fileCount + ' new file' + plural + ' added';
            }
            
            Dc.Type_of_Change__c = 'Network Quote Uploaded';
            Dc.Deal_State__c = Ds.Id;
            Dc.No_Quotes_Required__c = noQuotesRequired;
            Dc.Hole_in_Firewall_use_Cat_34122_98__c = holeInFirewallUseCat;
            Dc.Hole_in_Firewall_No_Charge__c = holeInFirewallNoCharge;
            Dc.ASP_Buy_Out_Cat_34174_36__c = aspBuyOutCat;
            //Dc.Change_Completed__c = true; // SCS’s, it doesn’t appear that the Deal Change for Network Quote Uploaded should 
            //automatically close when PSE uploads the quotes _Asked by David Lopez.
            //changed by SivaP 02/26/2015
            
            Dc.Network_Quotes_Attached__c = NumberOfFilesAttached;
            
            if(aspBuyOutPrice!=''||aspBuyOutPrice!=null )
            {
                Dc.ASP_Buy_Out_Price__c = aspBuyOutPrice;
            }
            
            Dc.Requested_Changes__c = (OverAllNotes != null ? OverAllNotes : '');
            
            insert dc;
            upsert ds;
        }
        catch(DMLexception e)
        {
            system.debug(e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error occured while uploading file.'));
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
        }
    }
    
    //Method to get attachments
    private static Attachment getAttachment(String attId) 
    {
        list<Attachment> attachments = [
            SELECT Id, Body,Description
            FROM Attachment 
            WHERE Id =: attId
        ];
        
        if(attachments.isEmpty()) 
        {
            Attachment a = new Attachment();
            return a;
        }
        else 
        {
            return attachments[0];
        }
    }
    
    //Method to get attachments
    private static Attachment checkAttachments(String opportunityID,boolean isDescending) 
    {
        String descOrAsc = isDescending==true?'desc':'asc';
        String query = 'SELECT Id, Body,Description,'
            +'createdDate,createdById'
            +' FROM Attachment'
            +' WHERE parentId = \''+opportunityID+'\''
            +' Order by createdDate '+descOrAsc
            +' LIMIT 1';
        /* Attachment attach = [
            SELECT Id, Body,Description,createdDate
            FROM Attachment 
            WHERE parentId=: opportunityID
            order by createdDate asc limit 1
        ];*/
        Attachment attach = Database.query(query);
        
        if(attach==null) 
        {
            return null;
        }
        else
        {
            return attach;
        }
    }
    
    //Method used for IE browsers
    public PageReference UploadAndSave()
    {        
        List<Attachment> FilesToAttach = new List<Attachment>();
        
        if(FileUploadVariableList!=null)
        {
            for (integer i=0; i<FileUploadVariableList.size(); i++)
            {
                if (FileUploadVariableList[i].Attach.Body != null)
                {
                    FileUploadVariableList[i].Attach.parentId = sobjId;
                    FilesToAttach.add(FileUploadVariableList[i].Attach);
                }
            }
        }
        
        if(FileUploadVariableList2!=null)
        {
            for (integer i=0; i<FileUploadVariableList2.size(); i++)
            {
                if (FileUploadVariableList2[i].Attach.Body != null)
                {
                    FileUploadVariableList2[i].Attach.parentId = sobjId;
                    FilesToAttach.add(FileUploadVariableList2[i].Attach);
                }
            }
        }
        
        if(FilesToAttach.size() == 0)
        {
            createDealChange(
                0,
                OverAllNotes,
                sobjId, 
                noQuotesRequired, 
                holeInFirewallUseCat, 
                holeInFirewallNoCharge,
                aspBuyOutCat,
                aspBuyOutPrice
            );
        }
        else
        {
            createDealChange(
                FilesToAttach.size(),
                OverAllNotes,
                sobjId, 
                noQuotesRequired, 
                holeInFirewallUseCat, 
                holeInFirewallNoCharge,
                aspBuyOutCat,
                aspBuyOutPrice
            );
        }
        
        try
        {
            insert FilesToAttach; 
        } 
        catch(DMLexception e)
        { 
            system.debug(e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error occured while uploading file.'));
            return null;
        }
        finally
        {
            FilesToAttach.clear();
            if(FileUploadVariableList != null) { FileUploadVariableList.clear(); }
            if(FileUploadVariableList2 != null) { FileUploadVariableList2.clear(); }
            FileUploadVariableList.add(new PageVariablePack(1, new attachment()));            
        }
        
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'The files are uploaded successfully'));
        pageReference newPgRef = new PageReference('/' + sobjId);
        newPgRef.getParameters().put('message', 'The files are uploaded successfully');
        newPgRef.setRedirect(true);
        return newPgRef;
    } 
    
    //Cancel button
    public PageReference Cancel()
    {        
        return new PageReference('/' + sobjId);
    }  
}