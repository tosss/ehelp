//2016-10-13  ragashalini.koka@cdk.com - Created this class for the RQ-07918
public without sharing class CPQ_BuySell_Extension {
    
    public Opportunity opportunityRecord{get;set;}
    public Boolean isView{get;set;}
    private String buyer;
  
    public CPQ_BuySell_Extension(ApexPages.StandardController controller) {
        opportunityRecord = [SELECT Id, SLS_Buyer_Account__c, AccountId FROM Opportunity WHERE Id = :controller.getId()];
        isView = true;
        buyer = opportunityRecord.SLS_Buyer_Account__c;
       
    }
    
    public PageReference edit() {
       isView = false; 
       return null;
    }
    
    public PageReference cancel() {
        opportunityRecord.SLS_Buyer_Account__c = buyer;
        clearMessages();
        isView = true;
        return null;
    }
    
    public PageReference save() {
        try {
            clearMessages();
            String buyerAccountId = opportunityRecord.SLS_Buyer_Account__c;
            isView = true;
            if(buyerAccountId != null) {
              
                update opportunityRecord;
                buyer = buyerAccountId;
                
                Account buyerAccount = [SELECT Id, Key_Rep__c FROM Account WHERE Id = :buyerAccountId ];
              
                List<Opportunity_Split__c> opportunitySplitList = [
                    SELECT Id, Channel__c 
                    FROM Opportunity_Split__c 
                    WHERE Sales_Rep__c = :buyerAccount.Key_Rep__c AND Opportunity__c = :opportunityRecord.Id AND Channel__c = 'Baseline'
                ];
                
                if(opportunitySplitList.size() > 0) {
                  
                    opportunitySplitList = updateNewQPercent(opportunitySplitList);
                    update opportunitySplitList;
                   
                }
                else {
                   verifyAndCreateOpportunityLocation(opportunityRecord, buyerAccount);
                }
            }
            else {
                update opportunityRecord;
                buyer = buyerAccountId;
            }
        }
        catch(Exception exp) {
            isView = false;
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, exp.getMessage()));
        }
        return null;
    }
    
    private static void clearMessages() {
        if(ApexPages.hasMessages()) {
            ApexPages.getMessages().clear();
        }
    }
    
    private static void verifyAndCreateOpportunityLocation(Opportunity opportunityRecord, Account buyerAccount) {
        //to ensure Record type Site comes first
        List<Opportunity_Location__c> opportunityLocationList = [
            SELECT Id 
            FROM Opportunity_Location__c 
            WHERE Opportunity__c = :opportunityRecord.Id AND Site__c = :opportunityRecord.AccountId
            ORDER BY RecordType.Name desc
        ];
        
        if(opportunityLocationList.size() > 0) {
            Opportunity_Split__c splitRecord = createOpportunitySplit(opportunityRecord, buyerAccount, opportunityLocationList[0]);
            insert splitRecord;
        }
        else {
            String siteRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity_Location__c', 'Site');
            Opportunity_Location__c opportunityLocationRecord = new Opportunity_Location__c();
            opportunityLocationRecord.RecordTypeId = siteRecordTypeId;
            opportunityLocationRecord.Site__c = opportunityRecord.AccountId;
            opportunityLocationRecord.Opportunity__c = opportunityRecord.Id;
            insert opportunityLocationRecord;
            System.debug('location test : ' + opportunityLocationRecord);
            //Opportunity Splits are auto created when Opportunity Location is created
            List<Opportunity_Split__c> opportunitySplitList = [
                SELECT Id, Channel__c, NewQ__c
                FROM Opportunity_Split__c 
                WHERE Sales_Rep__c = :buyerAccount.Key_Rep__c AND Opportunity__c = :opportunityRecord.Id 
                AND Channel__c = 'Baseline' AND Opportunity_Location__c = :opportunityLocationRecord.Id
            ];
            System.debug('splits test : ' + opportunitySplitList);
            
            if(opportunitySplitList.size() > 0) {
               opportunitySplitList = updateNewQPercent(opportunitySplitList);
            }
            else {
                Opportunity_Split__c oppSplitRecord = createOpportunitySplit(opportunityRecord, buyerAccount, opportunityLocationRecord);
            }
            update opportunitySplitList;
        }
    }
    
    private static Opportunity_Split__c createOpportunitySplit(Opportunity opp, Account acc, Opportunity_Location__c oppLocation) {
        Opportunity_Split__c splitRecord = new Opportunity_Split__c();
        splitRecord.Site__c = acc.Id;
        splitRecord.Opportunity__c = opp.Id;
        splitRecord.Sales_Rep__c = acc.Key_Rep__c;
        splitRecord.Channel__c = 'Baseline';
        splitRecord.Opportunity_Location__c = oppLocation.Id;
        splitRecord.NewQ__c = 50;
        return splitRecord;
        
    }
    
    private static List<Opportunity_Split__c> updateNewQPercent(List<Opportunity_Split__c> opportunitySplitList) {
        
        for(Opportunity_Split__c split : opportunitySplitList) {
            split.NewQ__c = 50;
        } 
        return opportunitySplitList;
        
    }
    
    
}