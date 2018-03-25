/**
* @author Original: Srinivas Sattoor @ CloudSherpas, Last Modified: Karl Simon @ CloudSherpas
* @date Original: 2014-06-23, Last Modified: 2014-09-05
* @description Class is used as helper class in the VF Components for the spin portal page. This will return
* content document Ids from DS Spinoff Portal Content library and the latestversion of the Ids.
* Modified on 2014-09-05 to eliminate the hard-coded Content Workspace name when querying the ContentDocument object
* The helper class will now accept a String parameter defining the workspace to be used in the query filter.
*/

public class EMP_ContentDocumentHelper 
{
    public set<Id> contentDocumentIds {get; private set;}
    public set<Id> latestVersionIds {get; private set;}
    
    public EMP_ContentDocumentHelper (String workspace)
    {
        contentDocumentIds = new set<Id>();
        latestVersionIds = new set<Id>();
        
        list<ContentDocument> ContentDocuments = [
            SELECT Title,  PublishStatus,  ParentId, OwnerId,  Id, LatestPublishedVersionId
            FROM ContentDocument
            WHERE ParentId IN: [
                SELECT Id 
                FROM ContentWorkspace 
                WHERE Name = :workspace
            ] 
        ];
        
        if(ContentDocuments != null && !ContentDocuments.isEmpty())
        {
            for(ContentDocument objContentDocument : ContentDocuments)
            {
                contentDocumentIds.add(objContentDocument.Id);
                latestVersionIds.add(objContentDocument.LatestPublishedVersionId);
            }
        }
    } // end of ContentDocumentHelper
}