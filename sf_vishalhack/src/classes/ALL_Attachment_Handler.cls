//2017-05-05 - siva.pragad@cdk.com - edited and added attachmentPreventDelete
public class ALL_Attachment_Handler 
{
    public static void HandleNew(List<Attachment> TriggerList, Map<Id, Attachment> TriggerMap)
    {
        List<Id> attachmentIds = new List<Id>();
        attachmentIds.addAll(TriggerMap.keySet());
        
        // Filter the attachments to only select those that are for Service Connect Cases that were 
        // not already created from Vision and replicated into Salesforce
        
        List<Attachment> attachments = [
            select Id, Name, Parent.RecordType.Name, CreatedBy.Name 
            from Attachment 
            where Id in :attachmentIds  
            AND (Parent.RecordType.Name = 'Service Connect')
            AND (CreatedBy.Name != 'Service Connect Integration User')
        ];
        
        List<ALL_PendingOutboundMessage__c> pendingMessageList = new List<ALL_PendingOutboundMessage__c>();
        ALL_PendingOutboundMessage__c newPendingMessage;
        
        for(Attachment a : attachments)
        {          
            //System.debug('a.Parent.RecordType.Name = ' + a.Parent.RecordType.Name + ' and a.CreatedBy.Name = ' + a.CreatedBy.Name);
            
            newPendingMessage = new ALL_PendingOutboundMessage__c(ObjectName__c='Attachment',Record_ID__c=a.Id);
            pendingMessageList.add(newPendingMessage);
            
        }
        
        Database.insert(pendingMessageList);
    }
    
    public static void AttachmentPreventDelete(List<Attachment> oldList)
    {
        GlobalSettings__c gs = GlobalSettings__c.getInstance();
    
        if(gs.Email_2_Case_Prevent_Delete__c)
        {
            Map<Id,Profile> profiles = new Map<Id,Profile>([Select Id, Name From Profile]);
            
            for(Attachment a : oldList)
            {
                Profile p = profiles.get(UserInfo.getProfileId());
                String pName = p.Name.toLowerCase();
                
                if(gs.Email_2_Case_Email_Attachment_Profiles__c == null) { 
                    gs.Email_2_Case_Email_Attachment_Profiles__c = ''; }
                
                String parent = String.valueOf(a.ParentId);
                
                if(!gs.Email_2_Case_Email_Attachment_Profiles__c.toLowerCase().contains(pName)
                   && parent.startsWith('02s')) // if the parent is an Email object (Email object Ids begin with 02s)
                {
                    a.addError('Your Profile does not have permission to delete Email Attachments.');
                }
            }
        }
    }
}