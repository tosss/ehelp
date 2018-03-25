public class DS_OpportunityQuotes_Handler
{
    public static void UpdateDealState(List<Opportunity_Quotes__c> OpportunityQuotesToProcess)
    {
        // get docusign custom settings
        List<Docusign_Deal_State_Fields__c> DocusignCSList = Docusign_Deal_State_Fields__c.getAll().Values();
        
        // describe the Deal State metadata
        Schema.DescribeSObjectResult DescribeDealState = Schema.getGlobalDescribe().get('Deal_State__c').getDescribe();
        
        List<Deal_State__c> DealStatesToUpdate = new List<Deal_State__c>();
        
        Map<Id, Deal_State__c> OppIdToDSRecordMap = new Map<Id, Deal_State__c>();
        Set<Id> DSIdSet = new Set<Id>();
        
        Set<Id> OpportunityQuoteIds = new Set<Id>();
        for(Opportunity_Quotes__c oq: OpportunityQuotesToProcess) { OpportunityQuoteIds.add(oq.Opportunity__c); }
        
        List<Deal_State__c> DSList = [
            Select Id, Opportunity__c, SQT_Deal_ID__c, Client_Data_Exchange_Products__c, Finalized_Deal__c 
            From Deal_State__c 
            Where Opportunity__c IN :OpportunityQuoteIds
        ];
        
        for(Deal_State__c ds: DSList)
        { 
            OppIdToDSRecordMap.put(ds.Opportunity__c, ds);
            DSIdSet.add(ds.Id);
        }
        
        //List<dsfs__DocuSign_Status__c> DocusignStatusList = new List<dsfs__DocuSign_Status__c>();
        //Map<Id, dsfs__DocuSign_Status__c> DSIdToDocusignRecMap = new Map<Id, dsfs__DocuSign_Status__c>();
        
        //DocusignStatusList = [
        //    Select Id, dsfs__Envelope_Status__c, Deal_State__c 
        //    From dsfs__DocuSign_Status__c 
        //    Where Deal_State__c IN :DSIdSet
        //];
        
        //for(dsfs__DocuSign_Status__c DocStat: DocusignStatusList){
        //    DSIdToDocusignRecMap.put(DocStat.Deal_State__c, DocStat);
        //}
        
        for(Opportunity_Quotes__c oq: OpportunityQuotesToProcess)
        {
            Deal_State__c CurrentDealState = OppIdToDSRecordMap.get(oq.Opportunity__c);
            
            //dsfs__DocuSign_Status__c CurrentDocusignStatus = new dsfs__DocuSign_Status__c();
            //if(!DSIdToDocusignRecMap.isEmpty()){ CurrentDocusignStatus = DSIdToDocusignRecMap.get(CurrentDealState.Id); }
            
            if(CurrentDealState != null) // && CurrentDocusignStatus != null
            {
                if (CurrentDealstate.Finalized_Deal__c == null && 
                    //CurrentDocusignStatus.dsfs__Envelope_Status__c != 'Sent' && 
                    //CurrentDocusignStatus.dsfs__Envelope_Status__c != 'Completed' && 
                    //CurrentDocusignStatus.dsfs__Envelope_Status__c != 'Delivered' &&
                    CurrentDealState.SQT_Deal_ID__c == oq.Deal_ID__c)
                {
                    system.debug('Finalized_Deal__c is not null');
                    
                    for(Docusign_Deal_State_Fields__c DocuSignField : DocusignCSList)
                    {
                        system.debug(DocuSignField);
                        
                        object OpportunityQuoteValue = oq.get(DocuSignField.Opportunity_Quote_Field__c);
                        system.debug(OpportunityQuoteValue);
                        
                        if(OpportunityQuoteValue != null || DocuSignField.Allow_Null__c)
                        {
                            Schema.DescribeFieldResult FieldDescription =
                                DescribeDealState.fields.getMap().get(DocuSignField.Deal_State_Field__c).getDescribe();
                            
                            // handle checkboxes separately because they cannot be set to null
                            if(FieldDescription.getType() == Schema.DisplayType.BOOLEAN && OpportunityQuoteValue == null) {
                                CurrentDealState.put(DocuSignField.Deal_State_Field__c, false); }
                            else {
                                CurrentDealState.put(DocuSignField.Deal_State_Field__c, OpportunityQuoteValue); }
                        }
                    }
                    
                    DealStatesToUpdate.add(CurrentDealState);
                }
            }
        }
        
        update DealStatesToUpdate;
    }

}