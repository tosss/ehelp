/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Controller for LAO_Datails_HomePage(Forms Order Section) on Home Page 
Test Class:    LAO_Details_HomePage_Test
Created on:    5 August 2015.
Code Coverage: 100%
------------------------------------------------------------
History
2015-08-05    vishal.bandari@cdk.com        RQ-05120: Created
2015-11-03    vishal.bandari@cdk.com		RQ-05661: Added code to filter LaserAtworkOrder records name >= 70000
2015-12-28    vishal.bandari@cdk.com        made changes to have vertical scroll bar for "My Items"
------------------------------------------------------------*/
public class LAO_Details_HomePage_Controller 
{
    public List<LAODetails> LAODetails_List{get;set;}
    
    public static Integer recordsPerPage;
    
    //Represent View Mode 'self' and 'all'
    public String self{get;set;}
    
    //Represent search criteria to search Form Order records by name
    public String searchText{get;set;}
    
    //to show table
    public Boolean showTableForProfile{get;set;}
    
    public Boolean showButtons{get;set;}
    
    //Represents current page number in view
    public Integer pageNumber{get;set;}
    
    //Represnts value if there is a need to navigate next
    public Integer extraRecords{get;set;}
    
    public Map<String,Boolean> profileFieldAssignment{get;set;}
    
    //Current user Profile Name
    private string profileName;
    
    //Fields needed for current profile based on FormsOrderFieldsToProfile__c Custom Setting
    private String fieldsRequired;
    
    //Date for the records after LAO-70000 or FO-70000
    private DateTime newRecordsDate;
    
    //Forms Order list in view
    private List<Laser_Artwork_Order__c> laoList;
    
    //Forms Order Id to SubProject_External_Reference__c Map
    private Map<Id, SubProject_External_Reference__c> LAO_To_SperMap;
    
    static
    {
        recordsPerPage = 5;
    }
    
    //Controller to Profile Name, Profile Assigment Map and other Default Values
    public LAO_Details_HomePage_Controller()
    {
        self = 'self';
        
        showTableForProfile=false;
        
        fieldsRequired ='';
        
        profileName = [
            SELECT Id, Name 
            FROM Profile 
            WHERE Id =: Userinfo.getProfileId()
        ].Name;
        
        newRecordsDate = null;
        
        extraRecords = 0;
        
        pageNumber = 1;
        
        searchText ='';
        
        List<FormsOrderFieldsToProfile__c> profileAssignmentList = FormsOrderFieldsToProfile__c.getALL().values();
        
        profileFieldAssignment = new Map<String,Boolean>();
        
        for(FormsOrderFieldsToProfile__c obj : profileAssignmentList)
        {
            //Constructing Profile To Field Column Assignment Map
            if(profileName == obj.Profile_Name__c || profileName == 'ADPDS - Admin - System Administrator' 
               && (profileFieldAssignment.get(obj.Field_API_Name__c.toLowerCase())==null || !profileFieldAssignment.get(obj.Field_API_Name__c.toLowerCase())))
            {
                profileFieldAssignment.put(obj.Field_API_Name__c.toLowerCase(),true);
                
                showTableForProfile = true;
                
                showButtons =true;
                
                if(obj.Field_API_Name__c != 'Subproject__c' )
                {
                    fieldsRequired += ','+obj.Field_API_Name__c;
                }
            }
            else if(profileFieldAssignment.get(obj.Field_API_Name__c.toLowerCase())==null)
            {
                profileFieldAssignment.put(obj.Field_API_Name__c.toLowerCase(),false);
            }
        }
    }
    
    //Method to Set the values of LAODetails Wrapper Class List
    public void getDetails()
    {   
        try
        {
            LAODetails_List = new List<LAODetails>();
            
            showButtons =true;
            
            //Set values of the Wrapper by Querying 
            setLAORecords();
            
            for(Laser_Artwork_Order__c laoObj : laoList)
            {
                LAODetails laoDetailObj = new LAODetails();
                laoDetailObj.LAO_Record = laoObj;
                laoDetailObj.sperObj = LAO_To_SperMap.get(laoObj.Id);
                LAODetails_List.add(laoDetailObj);
            }
            
            //Hides the Table and Navigation Buttons when List is Empty
            if(LAODetails_List.size() == 0)
            {
                LAODetails_List = null;
                showButtons=false;
            }
            
        }
        catch(Exception e)
        {
            System.debug('Exception:'+e.getMessage()+' at '+e.getLineNumber());
            LAODetails_List = null;
            showButtons=false;
            searchText = searchText.remove('%');
        }
    }
    
    public void setLAORecords()
    {
        Integer offset = (pageNumber-1)*recordsPerPage;
        
        recordsPerPage++;
        
        searchText = '%'+searchText+'%';
        
        laoList = new List<Laser_Artwork_Order__c>();
        
        //Querying Forms_Order Records related to Owner if self
        if(self == 'self')
        {
            Id userId = UserInfo.getUserId() ;
            
            // 2015-11-03 vishal.bandari@cdk.com     RQ-05661 added code to get createddate of last record in LAO-60000 or FO-60000 series
            // 2015-12-28 vishal.bandari@cdk.com     removed Limit condition to have vertical scroll bar for "My Items"
            laoList= Database.query('SELECT Id'
                                    +fieldsRequired
                                    +' FROM Laser_Artwork_Order__c '
                                    +' WHERE OwnerId =: userId '
                                    +' AND Name Like :searchText'
                                    +(profileName == 'CDK - Laser - FCC'?' AND Status__C != \'Sent to FB and/or Complete\'':' AND Order_Status__c != \'Installed\' ')
                                    +'  AND Order_Status__c != \'Cancelled\'  AND (Name >= \'LAO - 70000\' OR Name LIKE \'LAO - 1_____\' OR Name LIKE \'FO%\') '
                                    +' ORDER BY Name');
            extraRecords = 1;
            
        }
        else
        {
            // 2015-11-03 vishal.bandari@cdk.com RQ-05661 added code to get createddate of last record in LAO-60000 or FO-60000 series
            
            laoList= Database.query('SELECT Id '
                                    +fieldsRequired
                                    +' FROM Laser_Artwork_Order__c '
                                    +' WHERE Name Like :searchText'
                                    +' AND Order_Status__c != \'Cancelled\' '
                                    +(profileName == 'CDK - Laser - FCC'?' AND Status__C != \'Sent to FB and/or Complete\'':' AND Order_Status__c != \'Installed\' ')
                                    +'  AND Order_Status__c != \'Cancelled\'  AND (Name >= \'LAO - 70000\' OR Name LIKE \'LAO - 1_____\' OR Name LIKE \'FO%\') '
                                    +' ORDER BY Name'
                                    +' LIMIT :recordsPerPage '
                                    +' OFFSET :offset');
            
        }
        
        //Check if records are available for navigation for next set of records
        if(laoList.size()>0 && self != 'self')
        {
            extraRecords = recordsPerPage - laoList.size();
            
            if(extraRecords == 0)
            {
                laoList.remove(recordsPerPage-1);
            }
        }
        
        recordsPerPage--;
        
        List<Id> laoIds = new List<Id>();
        
        for(Laser_Artwork_Order__c laoObj : laoList)
        {
            laoIds.add(laoObj.Id);
        }
        
        //Set the values in map relating Forms_Order__c Id with SubProject_External_Reference__c
        if(profileFieldAssignment.get('subproject__c'))
        {
            LAO_To_SperMap = new Map<Id,SubProject_External_Reference__c>();
            
            List<SubProject_External_Reference__c> sperList = new List<SubProject_External_Reference__c>();
            
            sperList = [
                SELECT ID, LAO_Id__c, SubProject__r.Name, SubProject__c 
                FROM SubProject_External_Reference__c 
                WHERE LAO_ID__c IN: laoIds
            ];
            
            for(SubProject_External_Reference__c sperObj : sperList)
            {
                LAO_To_SperMap.put(sperObj.LAO_Id__c,sperObj);
            }
        }
        
        searchText = searchText.remove('%');
    }
    
    //Invoked when the self value is changed, or search text is changed
    public void viewChanged()
    {
        pageNumber = 1;
        getDetails();
    }
    
    //Invoked when previous button is clicked
    public void previous()
    {
        //Navigation not possible for pagenumber 0 or less
        if(pageNumber > 1)
        {
            pageNumber--;
            getDetails();
        }
        return;
    }
    
    //Invoked when next button is clicked
    public void next()
    {
        if(LAODetails_List.size() >= recordsPerPage)
        {
            pageNumber++;
            getDetails();
        }
        return;
    }
    
    //Wrapper that holds Forms_Order and its related SubProject_External_Reference__c
    public class LAODetails
    {
        public Laser_Artwork_Order__c LAO_Record{get;set;}
        
        public SubProject_External_Reference__c sperObj{get;set;}
    }
}