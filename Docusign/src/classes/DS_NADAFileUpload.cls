public class DS_NADAFileUpload
{
    // page variables for uploading a new file
    public String FileName {get;set;}
    public Blob FileContents {get;set;}
    
    // global settings - used to get the NADA Folder Name
    public static GlobalSettings__c gs = GlobalSettings__c.getInstance();
    
    // constructor
    public DS_NADAFileUpload() {}
    
    // file upload action method
    public PageReference ReadFile()
    {
        String ErrorMessage = 'Invalid file type. Only Excel files ending in ".xls" can be uploaded.';
        
        if(!FileName.endsWith('.xls')) 
        {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ErrorMessage)); 
        	return ApexPages.currentPage(); 
        }
        
        Folder f = null;
        List<Folder> fs = [Select Id From Folder Where Name = :gs.NADA_Lead_Folder__c];
        if(fs != null) { if(!fs.IsEmpty()) { f = fs[0]; } }
        
        if(f == null) {
            ErrorMessage = 'The NADA file upload folder could not be found. Please contact an administrator.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ErrorMessage)); 
            return ApexPages.currentPage(); 
        }
        
        Document d = new Document();
        d.Body = FileContents;
        d.Name = FileName;
        d.IsInternalUseOnly = true;
        d.FolderId = f.Id;
        insert d;
        
        PageReference FolderPage = new PageReference('/'+f.Id);
        FolderPage.setRedirect(true);
        return FolderPage;
    }
}