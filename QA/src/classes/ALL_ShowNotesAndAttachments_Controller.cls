public class ALL_ShowNotesAndAttachments_Controller {
    //properties
    public Id sObjectId{get;set;}
    public List<Note> notes{get;set;}
    public List<Attachment> attachments{get;set;}
    
    //Constructor
    public ALL_ShowNotesAndAttachments_Controller(ApexPages.StandardController controller){      
        sObjectId =  system.currentPageReference().getparameters().get('id');           
        displayNotesAndAttachments();
    }

    //Action Methods
    public void displayNotesAndAttachments()
    {
        notes = [
            select Id, CreatedByid,createdDate, title, Body 
            from Note 
            where parentid =: sObjectId
        ];
        attachments= [
            SELECT Id, Name, Body, ContentType,createdByid,createdDate
            FROM Attachment 
            WHERE Parentid =: sObjectId
        ];
    }

}