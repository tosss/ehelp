/*
*
* 01/28/15 - Venkata Shrivol -  Added custom settings logic on Routing Order Comparisons. 
*
* 04/28/15 - Venkata Shrivol - Added oldMap values for not including other recipients which are already signed;
							    bcos dfs managed package of docusign is updating all the recipients of one
							    docusign status record for every recipient sent/delivery/signature update
* 2015-11-02 siva.pragada@cdk.com - added condition and assignment of value to field Shared_System_Signer2_Signed_Date__c
* 11/06/15 - Venkata Shrivol - Added Name Conditon in the CA Approver routing order check 							  
							  
*/

public class DS_DocusignRecipientStatus_Handler 
{
    public static List<id> FilterIdsToProcessAfterUpdate(list<dsfs__DocuSign_Recipient_Status__c> NewRecipientStatuses, map<Id, dsfs__DocuSign_Recipient_Status__c> OldRecipientStatusesMap)
    {
        system.debug('in FilterIdsToProcessAfterUpdate');
        list<Id> RecipientStatusIdsToProcess = new list<Id>();
        Datetime oldSentDate = null;
        Datetime oldDeliveredDate = null;
        Datetime oldSignedDate = null;
        
        for(dsfs__DocuSign_Recipient_Status__c RecipientStatus : NewRecipientStatuses)
        {
            Boolean SentDeliveredOrCompleted = 
                RecipientStatus.dsfs__Recipient_Status__c == 'Sent' || 
                RecipientStatus.dsfs__Recipient_Status__c == 'Delivered' ||
                RecipientStatus.dsfs__Recipient_Status__c == 'Completed';
                
            oldSentDate = OldRecipientStatusesMap.get(RecipientStatus.Id).dsfs__Date_Sent__c;
            oldDeliveredDate = OldRecipientStatusesMap.get(RecipientStatus.Id).dsfs__Date_Delivered__c;
            oldSignedDate = OldRecipientStatusesMap.get(RecipientStatus.Id).dsfs__Date_Signed__c;
            if (SentDeliveredOrCompleted && 
               ((RecipientStatus.dsfs__Date_Sent__c!=null && RecipientStatus.dsfs__Date_Sent__c!=oldSentDate) || 
                (RecipientStatus.dsfs__Date_Delivered__c!=null && RecipientStatus.dsfs__Date_Delivered__c!=oldDeliveredDate) || 
                (RecipientStatus.dsfs__Date_Signed__c!=null && RecipientStatus.dsfs__Date_Signed__c!=oldSignedDate))) // RecipientStatus.Recipient_Signed_on_Paper__c == 'yes' || // disabled for initial release
            {
                RecipientStatusIdsToProcess.add(RecipientStatus.Id);
            }
        }
        
        return RecipientStatusIdsToProcess;
    }
    
    public static List<id> FilterIdsToProcessAfterInsert(list<dsfs__DocuSign_Recipient_Status__c> NewRecipientStatuses)
    {
        system.debug('in FilterIdsToProcessAfterInsert');
        list<Id> RecipientStatusIdsToProcess = new list<Id>();
        
        for(dsfs__DocuSign_Recipient_Status__c RecipientStatus : NewRecipientStatuses)
        {
            Boolean SentDeliveredOrCompleted = 
                RecipientStatus.dsfs__Recipient_Status__c == 'Sent' || 
                RecipientStatus.dsfs__Recipient_Status__c == 'Delivered' ||
                RecipientStatus.dsfs__Recipient_Status__c == 'Completed';
            
            if (SentDeliveredOrCompleted) // RecipientStatus.Recipient_Signed_on_Paper__c == 'yes' || // disabled for initial release
            {
                RecipientStatusIdsToProcess.add(RecipientStatus.Id);
            }
        }
        
        return RecipientStatusIdsToProcess;
    }
    
    
    public static list<dsfs__DocuSign_Recipient_Status__c> QueryRecipientStatuses(list<Id> RecipientStatusIdsToProcess)
    {
        system.debug('in QueryRecipientStatuses');
        string RecipientStatusIds = ALL_UtilitiesString.ListToEnclosedCsv(RecipientStatusIdsToProcess, '\'');
        
        list<dsfs__DocuSign_Recipient_Status__c> QueriedRecipientStatuses 
            = new list<dsfs__DocuSign_Recipient_Status__c>();
        
        try
        {
            string q = 'Select Id, Name, dsfs__Recipient_Status__c, dsfs__DocuSign_Routing_Order__c, ' + 
                'dsfs__Date_Sent__c, dsfs__Date_Signed__c, dsfs__DocuSign_Recipient_Email__c,Recipient_Signed_On_Paper__c, ' + 
                'dsfs__Parent_Status_Record__c, dsfs__Parent_Status_Record__r.Deal_State__c,dsfs__Date_Delivered__c ' + 
                'From dsfs__DocuSign_Recipient_Status__c ' + 
                'Where Id IN (' + RecipientStatusIds + ') ';
            
            system.debug(q);
            QueriedRecipientStatuses = database.query(q);
        }
        catch(Exception e) { system.debug(e); }
        
        return QueriedRecipientStatuses;
    }
    
    public static void UpdateDealStates(list<dsfs__DocuSign_Recipient_Status__c> QueriedRecipientStatuses)
    {
        system.debug('In UpdateDealStates');
        // 2016-10-03 lalitha.adduru@cdk.com - modified the code to use Map as it was running into duplicated id error
        Map<id, Deal_State__c> DealStatesToUpdateMap = new Map<Id,Deal_State__c>();
        
        // Docusign Recipient Values from Custom Settings
        Map<String, Docusign_Recipient__c> docusignRecipientMap = Docusign_Recipient__c.getAll();
         
        
        map<Id, list<dsfs__DocuSign_Recipient_Status__c>> RecipientStatusesByDealState 
            = new map<id, list<dsfs__DocuSign_Recipient_Status__c>>();
        
        for(dsfs__DocuSign_Recipient_Status__c RecipientStatus : QueriedRecipientStatuses)
        {
            Id DealStateId = null;
            if (RecipientStatus.dsfs__Parent_Status_Record__c != null && 
                RecipientStatus.dsfs__Parent_Status_Record__r.Deal_State__c != null) 
            {
                DealStateId = RecipientStatus.dsfs__Parent_Status_Record__r.Deal_State__c;
            }
            
            list<dsfs__DocuSign_Recipient_Status__c> RecipientStatuses 
                = RecipientStatusesByDealState.get(DealStateId);
            
            if(RecipientStatuses == null || RecipientStatuses.isEmpty()) { 
                RecipientStatuses = new list<dsfs__DocuSign_Recipient_Status__c>(); }
            
            RecipientStatuses.add(RecipientStatus);
            RecipientStatusesByDealState.put(DealStateId, RecipientStatuses);
        }
        
        for(Id DealStateId : RecipientStatusesByDealState.keySet())
        {
            Deal_State__c DealState = new Deal_State__c(Id=DealStateId);
            
            if(DealStateId != null)
            {
                for(dsfs__DocuSign_Recipient_Status__c RecipientStatus : QueriedRecipientStatuses)
                {
                    Boolean IsSentOrCreated = RecipientStatus.dsfs__Recipient_Status__c == 'Sent' || 
                        RecipientStatus.dsfs__Recipient_Status__c == 'Created';
                    
                    Decimal RoutingOrder = null;
                    
                    if(RecipientStatus != null)
                    {
                        RoutingOrder = RecipientStatus.dsfs__DocuSign_Routing_Order__c;
                    }
                    
                    string email = null;
                    
                    if(RecipientStatus != null)
                    {
                        email = RecipientStatus.dsfs__DocuSign_Recipient_Email__c;
                    }
                                        
                    if(RecipientStatus.Recipient_Signed_On_Paper__c == 'yes')
                    {
                        if(RoutingOrder == 1) {
                            DealState.Signer1_Sign_on_Paper__c = true; }
                        
                        if(RoutingOrder == 2) {
                            DealState.Signer2_Sign_on_Paper__c = true; }
                    }
                    
                    
                    if(RoutingOrder == 1 && IsSentOrCreated) 
                    { 
                        DealState.Send_To_Client_Date__c = RecipientStatus.dsfs__Date_Sent__c; 
                    }
                    
                    
                    if((RoutingOrder == 1 || RoutingOrder == 2) && 
                       RecipientStatus.dsfs__Date_Signed__c != null) 
                    {
                        DealState.Client_Signed_Date__c = RecipientStatus.dsfs__Date_Signed__c;
                        
                    }
                    
                    //2016-03-10 lalitha.adduru@cdk.com - added null check
                    if( docusignRecipientMap.get('SCS') != null &&
                       (email == docusignRecipientMap.get('SCS').Email__c && 
                        (RoutingOrder == docusignRecipientMap.get('SCS').Alternate_Routing_Order__c || 
                         RoutingOrder == docusignRecipientMap.get('SCS').Routing_Order__c)) && 
                        RecipientStatus.dsfs__Date_Signed__c != null) 
                    {
                        DealState.SCS_Approved_Date__c = RecipientStatus.dsfs__Date_Signed__c;
                    }
                    
                    //2016-03-10 lalitha.adduru@cdk.com - added null check
                    if( docusignRecipientMap.get('CA') != null &&
                        (RoutingOrder ==  docusignRecipientMap.get('CA').Alternate_Routing_Order__c || 
                         RoutingOrder == docusignRecipientMap.get('CA').Routing_Order__c) && 
                         (RecipientStatus.Name == docusignRecipientMap.get('CA').First_Name__c +' '+ 
                         docusignRecipientMap.get('CA').Last_Name__c) &&
                        RecipientStatus.dsfs__Date_Signed__c != null) 
                    {
                        DealState.CA_Approved_Date__c = RecipientStatus.dsfs__Date_Signed__c;
                    }
                    
                    //2016-03-10 lalitha.adduru@cdk.com - added null check
                    if(docusignRecipientMap.get('Legal Counter Signer') != null &&
                        (email == docusignRecipientMap.get('Legal Counter Signer').Email__c && 
                        (RoutingOrder == docusignRecipientMap.get('Legal Counter Signer').Alternate_Routing_Order__c || 
                         RoutingOrder == docusignRecipientMap.get('Legal Counter Signer').Routing_Order__c)) &&
                        RecipientStatus.dsfs__Date_Signed__c != null) 
                    {
                        DealState.Legal_Counter_Signer_Date__c = RecipientStatus.dsfs__Date_Signed__c;
                    }
                    
                    //2016-03-10 lalitha.adduru@cdk.com - added null check
                    if( docusignRecipientMap.get('CRA Signer') != null && 
                        (email == docusignRecipientMap.get('CRA Signer').Email__c && 
                        (RoutingOrder ==  docusignRecipientMap.get('CRA Signer').Alternate_Routing_Order__c || 
                         RoutingOrder == docusignRecipientMap.get('CRA Signer').Routing_Order__c)) && 
                        RecipientStatus.dsfs__Date_Signed__c != null) 
                    {
                        DealState.CRA_Signed_Date__c = RecipientStatus.dsfs__Date_Signed__c;
                    }
                    
                    
                    if(RoutingOrder == 1 && RecipientStatus.dsfs__Date_Delivered__c!=null)
                    {
                        DealState.Client_1_Delivered_Date__c = RecipientStatus.dsfs__Date_Delivered__c;
                    }
                    
                    
                    if(RoutingOrder == 2)
                    {
                        if(RecipientStatus.dsfs__Date_Signed__c!=null)
                        {
                            DealState.Client_2_Signed_Date__c = RecipientStatus.dsfs__Date_Signed__c;
                        }
                        if(RecipientStatus.dsfs__Date_Delivered__c!=null)
                        {
                            DealState.Client_2_Delivered_Date__c = RecipientStatus.dsfs__Date_Delivered__c;
                        }
                    }
                    
                    if(RoutingOrder == 3)
                    {
                        if(RecipientStatus.dsfs__Date_Signed__c!=null)
                        {
                            DealState.Shared_System_Signer_Signed_Date__c = RecipientStatus.dsfs__Date_Signed__c;
                        }
                    }
                    
                    if(RoutingOrder == 4)
                    {
                        if(RecipientStatus.dsfs__Date_Signed__c!=null)
                        {
                            DealState.Shared_System_Signer2_Signed_Date__c = RecipientStatus.dsfs__Date_Signed__c;
                        }
                    }
                    
                    DealStatesToUpdateMap.put(DealState.id,DealState);                       
                }
            }
        }
        
        if(DealStatesToUpdateMap != null && !DealStatesToUpdateMap.isEmpty())
        {
            system.debug('DealStatesTpUpdate list -- > '+ DealStatesToUpdateMap.values());
            update DealStatesToUpdateMap.values();
        }
    }
    
}