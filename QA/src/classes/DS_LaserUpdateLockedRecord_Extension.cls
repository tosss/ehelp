public class DS_LaserUpdateLockedRecord_Extension 
{
    public ID LaoId;
    public Laser_Artwork_Order__c LaoRecord {get;set;}
    public list<Laser_Ordered_Forms__c> ChildRecords {get;set;}
    public boolean createLaserOrderedForms {get;set;}
    public Laser_Ordered_Forms__c newLofRecord {get;set;}
    
    public DS_LaserUpdateLockedRecord_Extension(ApexPages.StandardController LaoController)
    { 
        createLaserOrderedForms = false;
        this.LaoRecord = (Laser_Artwork_Order__c)Laocontroller.getRecord();
        this.LaoId = LaoRecord.Id; 
        
        String QueryString = getLaserArtworkOrderQueryString();        
        
        QueryString += 'Where ID = \'' + LaoId + '\' LIMIT 1';
        
        LaoRecord = Database.query(QueryString);
        if(LaoRecord != null)
        {
            ChildRecords = LaoRecord.getsObjects('Forms__r');
        }
    }
    
    private string getLaserArtworkOrderQueryString()
    {         
        String query = 'SELECT ';
        
        for(Schema.FieldSetMember f : this.getFOfields()) 
        {
            query += f.getFieldPath() + ', ';
        }
        
        query += 'Id, Name, (Select Id, Name, Catalog_Number__c, Laser_Artwork_Order__c, Quantity__c, Unit_Price_Override__c, Unit_Price__c  From Forms__r) '
            + 'FROM laser_Artwork_Order__c ';
        
        return query;        
    }
    
    public List<Schema.FieldSetMember> getFOfields() 
    {
        return SObjectType.laser_Artwork_Order__c.FieldSets.Unlock_And_Update.getFields();
    }
    
    public List<Schema.FieldSetMember> getLofFields() 
    {
        return SObjectType.laser_Ordered_Forms__c.FieldSets.Unlock_And_Update.getFields();
    }
    
    public PageReference UpdateAndSave()
    {
        Update LaoRecord;
        
        PageReference LaoPage = new ApexPages.StandardController(LaoRecord).view();        
        LaoPage.setRedirect(true);
        
        return LaoPage;
    }
    
    public PageReference createNewLaserOrderedForms()
    {       
        newLofRecord = new Laser_Ordered_Forms__c();
        createLaserOrderedForms = true; 
        return null;
    }
    
    public void saveLaserOrderForm()
    {
        try
        {
            newLofRecord.Laser_Artwork_Order__c = LaoId;
            insert newLofRecord;
        }
        catch(DMLexception ex)
        {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        }
       
        ChildRecords = [
            Select Id, Name, Catalog_Number__c, Laser_Artwork_Order__c, Quantity__c, Unit_Price_Override__c, Unit_Price__c  
            From Laser_Ordered_Forms__c
            Where Laser_Artwork_Order__c = :LaoId
        ];
        
        createLaserOrderedForms = false;
        
    }
}