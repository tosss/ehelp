/* Author: Josephine Del Mundo , Last Modified: Karl Simon @ CloudSherpas
*  Date Created: 2014-06-13
*  Date Updated: 2024-09-05  
*  Description: Serves as controller class for component(DS_SPIN_QuickLinks)
*  Modified on 2014-09-05 to pass a Content Workspace name to the EMP_ContentDocumentHelper class
*/

public class EMP_SPIN_QuickLinksComponentCC 
{
    //public list<ContentVersion> cLinks{get;set;}
    public id contentVersionId{get;set;}
    
    public Set<Id> setContentDocumentIds = new Set<Id>();//contains set of contentDocument Id's
    public list<ContentVersion> cLinks{get;set;}
    public list<ContentVersion> cVersion{get;set;}
    public Set<Id> cVersionID  = new Set<Id>();
    public list<Contentversion> fAQLinks{get;set;}
    public list<Contentversion> scriptLinks{get;set;}
    public list<Contentversion> videoLinks{get;set;}
    public list<Contentversion> miscLinks{get;set;}
    public Set<Id> latestVersion = new Set<Id>();
    public static final String workspace = System.Label.EMP_Library_Name;
    
    public EMP_SPIN_QuickLinksComponentCC ()
    {
        cVersion = new list<ContentVersion>();
        cLinks = new list<ContentVersion>();
        fAQLinks = new list<ContentVersion>();
        scriptLinks = new list<ContentVersion>();
        videoLinks = new list<ContentVersion>();
        miscLinks = new list<ContentVersion>();
        
        
        // helper class to get the contentdocumentids and latestversionIds
        // for the documents in 'DS Spinoff Portal Content' library
        EMP_ContentDocumentHelper cdhelper = new EMP_ContentDocumentHelper (workspace);
        
        setContentDocumentIds = cdHelper.ContentDocumentIds;
        latestVersion = cdHelper.LatestVersionIds;      
        
        // checks that links (content Document Ids) are not null
        if(!setContentDocumentIds.isEmpty() || setContentDocumentIds.size() > 0)
        {
            list<ContentVersion> ContentVersions = [
                SELECT Title, Document_Type__c, Update_Comment__c, Video_File_Location__c 
                FROM ContentVersion
                WHERE ContentDocumentId IN :setContentDocumentIds
                AND Id IN: latestVersion 
                AND Expiration_Date__c >: system.Today()
                AND Content_Start_Date__c <=: system.Today() 
                AND Quicklink__c = TRUE
                ORDER BY Publish_Date__c DESC
            ];
            
            if(ContentVersions != null && !ContentVersions.isEmpty())
            {
                //query all content version connected to links
                for (ContentVersion cv : ContentVersions)
                {
                    //check if the document type is FAQ and add to the list  
                    if(cv.Document_Type__c == 'FAQ') { fAQLinks.add(cv); }
                    if(cv.Document_Type__c == 'Letters') { cLinks.add(cv); }
                    if(cv.Document_Type__c == 'Script') { scriptLinks.add(cv); }
                    if(cv.Document_Type__c == 'Video') { videoLinks.add(cv); }
                    if(cv.Document_Type__c == 'Miscellaneous') { miscLinks.add(cv); }  
                } 
            }
        } //end of if condition 
    }
}