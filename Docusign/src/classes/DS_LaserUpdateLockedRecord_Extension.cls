public class DS_LaserUpdateLockedRecord_Extension 
{
    public ID LaoId;
    public Laser_Artwork_Order__c LaoRecord {get;set;}    
    
    public DS_LaserUpdateLockedRecord_Extension(ApexPages.StandardController LaoController)
    {
        this.LaoRecord = (Laser_Artwork_Order__c)Laocontroller.getRecord();
        this.LaoId = LaoRecord.Id; 
        
        String QueryString = getLaserArtworkOrderQueryString();        
        
        QueryString += 'Where ID = \'' + LaoId + '\' LIMIT 1';
        
        LaoRecord = Database.query(QueryString);            
    }
    
    private string getLaserArtworkOrderQueryString()
    {         
        String query = 'SELECT ';
        
        for(Schema.FieldSetMember f : this.getFields()) 
        {
            query += f.getFieldPath() + ', ';
        }
        
        query += 'Id, Name FROM laser_Artwork_Order__c ';
        
        return query;        
    }
    
    public List<Schema.FieldSetMember> getFields() 
    {
        return SObjectType.laser_Artwork_Order__c.FieldSets.Unlock_And_Update.getFields();
    }
    
    public PageReference UpdateAndSave()
    {
        Update LaoRecord;
        
        PageReference LaoPage = new ApexPages.StandardController(LaoRecord).view();        
        LaoPage.setRedirect(true);
        
        return LaoPage;
    }
}