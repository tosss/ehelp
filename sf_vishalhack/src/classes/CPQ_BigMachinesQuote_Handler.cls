//2016-08-08 - vishal.bandari@cdk.com - created and added before Delete Code to delete record with particular status - RQ-07540.
//2016-10-18 - ragashalini.koka@cdk.com - added methods updateSitesOnOpportunity and groupRecords for RQ-08013
//2016-11-03 - ragashalini.koka@cdk.com - modified the method updateSitesOnOpportunity for RQ-08134
//2016-11-10 - ragashalini.koka@cdk.com - Added the method updateNSAInfo for RQ-08164
//2016-11-21 - vishal.bandari@cdk.com - added code to Parse Pending Approval String - RQ-08211
//2016-02-02 - vishal.bandari@cdk.com - added code to Clear Parsed value for NA - RQ-08585
//2017-04-14 ragashalini.koka@cdk.com - Added a method updateQuoteCreationOnOpportunity for RQ-09040
public class CPQ_BigMachinesQuote_Handler 
{
    public static void beforeDelete(List<BigMachines__Quote__c> oldList)
    {
        for(BigMachines__Quote__c quoteObj : oldList)
        {
            if(!(quoteObj.BigMachines__Status__c == 'Quote Initiated' || quoteObj.BigMachines__Status__c == 'Draft' || quoteObj.BigMachines__Status__c == 'Rejected'))
            {
                quoteObj.addError('Only quotes in "Quote Initiated", "Draft", or "Rejected" status can be deleted!');
            }
        }
    }
    
    //2016-11-21 - vishal.bandari@cdk.com - added code to Parse Pending Approval String - RQ-08211
    public static void beforeInsert(List<BigMachines__Quote__c> newList)
    {
        parsePendingApprovalFields(newList,null,true);
    }
    
    //2016-11-21 - vishal.bandari@cdk.com - added code to Parse Pending Approval String - RQ-08211
    public static void beforeUpdate(List<BigMachines__Quote__c> newList,Map<Id,BigMachines__Quote__c> oldMap)
    {
        parsePendingApprovalFields(newList,oldMap,false);
    }
    
    //2016-10-18 - ragashalini.koka@cdk.com - updates the sites related to the opportunities for the RQ-08013
    //2016-11-03 - ragashalini.koka@cdk.com - modified the method updateSitesOnOpportunity for the RQ-08134
    public static void updateSitesOnOpportunity(List<BigMachines__Quote__c> oldList, List<BigMachines__Quote__c> newList, Boolean isInsert)
    {
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> quoteIdSet = new Set<Id>();
        for(Integer i = 0;i < newList.size();i++)
        {
            
            if(newList[i].BigMachines__Is_Primary__c && newList[i].BigMachines__Status__c == 'Order Submitted' && 
               (isInsert || newList[i].MSA_ARNA__c != oldList[i].MSA_ARNA__c || newList[i].MSA_Digital__c != oldList[i].MSA_Digital__c 
                || newList[i].MSA_IPNS__c != oldList[i].MSA_IPNS__c )) 
            {
                if(newList[i].BigMachines__Opportunity__c != null)
                {
                    oppIdSet.add(newList[i].BigMachines__Opportunity__c);
                    quoteIdSet.add(newList[i].Id);
                }
            }
        }
        
        List<Opportunity_Location__c> oppLocationList = [SELECT Site__c, Opportunity__c FROM Opportunity_Location__c WHERE Opportunity__c IN :oppIdSet AND RecordType.Name='Site'];
        Map<Object,Set<Object>> keyToValueMap = groupRecords(oppLocationList, 'Opportunity__c', 'Site__c');
        Map<Id,Account> accountsMap = new Map<Id,Account>();
        System.debug('keyToValueMap : ' + keyToValueMap);
        for(BigMachines__Quote__c quote : newList) 
        {
            if(keyToValueMap != null && quoteIdSet.contains(quote.Id) && keyToValueMap.get(quote.BigMachines__Opportunity__c)!= null)
            {
                for(Object obj : keyToValueMap.get(quote.BigMachines__Opportunity__c)) 
                { 
                    Account acc = new Account();
                    acc.Id = String.valueOf(obj);
                    
                    if(quote.MSA_ARNA__c) {
                        acc.DS_SLS_MSA__c = true;
                        acc.DS_SLS_MSA_Signed_Date__c = System.today();
                    }
                    else {
                        acc.DS_SLS_MSA__c = false;
                    }
                    
                    if(quote.MSA_Digital__c) {
                        acc.CB_SLS_MSA_Digital__c = true;
                        acc.MDA_NEW__c = System.today();
                    }
                    else {
                        acc.CB_SLS_MSA_Digital__c = false;
                    }
                    
                    if(quote.MSA_IPNS__c) {
                        acc.DS_SLS_IPNS_MSA__c = true;
                        acc.DS_SLS_IPNS_MSA_Signed_Date__c = System.today();
                    }
                    else {
                        acc.DS_SLS_IPNS_MSA__c = false;
                    }
                    
                    acc.SLS_Combined_MSA__c = quote.MSA_ARNA__c && quote.MSA_Digital__c;
                    
                    
                    accountsMap.put(acc.Id, acc);
                }
                
            }
            System.debug(quote.Pending_Approvals_From_Users_Parsed__c);
        }
        
        System.debug('accountsMap values' + accountsMap.values());
        update accountsMap.values();
        
    }
    
    //returns a map by grouping the records based on the key
    public static Map<Object,Set<Object>> groupRecords(List<SObject> recordsList, String keyAPI, String valueAPI)
    {
        Map<Object,Set<Object>> keyToValueMap = new Map<Object,Set<Object>>();
        for(SObject record : recordsList) 
        {
            Object keyValue = record.get(keyAPI);
            if(!keyToValueMap.containsKey(keyValue)) 
            {
                keyToValueMap.put(keyValue, new Set<Object>());
            }
            Set<Object> valueSet = keyToValueMap.get(keyValue);
            valueSet.add(record.get(valueAPI)); 
            
        }
        return keyToValueMap;
    }
    //sets the NSA information on the Oracle Quotes for RQ-08164
    public static void updateNSAInfo(List<BigMachines__Quote__c> quotesList) 
    {
        Set<Id> opportunityIdSet = new Set<Id>();
        
        for(BigMachines__Quote__c quote : quotesList)
        {
            opportunityIdSet.add(quote.BigMachines__Opportunity__c);
        }
        //removes any null value if present from the set
        opportunityIdSet.remove(null);
        
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>([
            SELECT AccountId, Account.NSA__c, Account.Price_Protection_NSA__c
            FROM Opportunity 
            WHERE Id IN :opportunityIdSet
        ]);
        
        for(BigMachines__Quote__c quote : quotesList)
        {
            Opportunity oppRecord = opportunityMap.get(quote.BigMachines__Opportunity__c);
            if(oppRecord != null)
            {
                quote.NSA__c = oppRecord.Account.NSA__c;
                quote.Price_Protection_NSA__c = oppRecord.Account.Price_Protection_NSA__c;
            }
        }
    }
    
    //2016-11-21 - vishal.bandari@cdk.com - added code to Parse Pending Approval String - RQ-08211
    public static void parsePendingApprovalFields(List<BigMachines__Quote__c> newList, Map<Id,BigMachines__Quote__c> oldMap, Boolean isInsert)
    {
        Set<String> bigMachinesloginNames = new Set<String>();
        for(BigMachines__Quote__c quoteObj : newList)
        {
            BigMachines__Quote__c oldQuoteObj = isInsert ? null : oldMap.get(quoteObj.Id);
            if( (quoteObj.Pending_Approvals_From_Users_String__c != null && 
                 quoteObj.Pending_Approvals_From_Users_String__c != '\"\"' &&
                 quoteObj.Pending_Approvals_From_Users_String__c != '') &&
               (isInsert || oldQuoteObj.Pending_Approvals_From_Users_String__c !=  quoteObj.Pending_Approvals_From_Users_String__c))
            {
                //2016-02-02 - vishal.bandari@cdk.com - added code to Clear Parsed value for NA - RQ-08585
                if(quoteObj.Pending_Approvals_From_Users_String__c == 'NA')
                {
                    quoteObj.Pending_Approvals_From_Users_Parsed__c = '';
                }
                else
                {
                    String actualString = quoteObj.Pending_Approvals_From_Users_String__c;   
                    List<String> allStrings = actualString.split('\\$,\\$');
                    if(allStrings != null && !allStrings.isEmpty())
                    {
                        for(String singleString : allStrings)
                        {
                            List<String> fieldValues = singleString.split(',');
                            bigMachinesloginNames.add(fieldValues[0]);
                        }   
                    }
                }
            }
        }
        
        if(bigMachinesloginNames != null && bigMachinesloginNames.size() > 0)
        {
            Map<String,String> bigMachinesLoginNamesToNames = convertBigMachineLoginToUserName(bigMachinesloginNames);
            for(BigMachines__Quote__c quoteObj : newList)
            {
                BigMachines__Quote__c oldQuoteObj = isInsert ? null : oldMap.get(quoteObj.Id);
                if( (quoteObj.Pending_Approvals_From_Users_String__c != null && 
                     quoteObj.Pending_Approvals_From_Users_String__c != '\"\"' &&
                     quoteObj.Pending_Approvals_From_Users_String__c != '' &&
                     quoteObj.Pending_Approvals_From_Users_String__c != 'NA') && 
                   (isInsert ||  oldQuoteObj.Pending_Approvals_From_Users_String__c !=  quoteObj.Pending_Approvals_From_Users_String__c))
                {
                    String actualString = quoteObj.Pending_Approvals_From_Users_String__c;   
                    List<String> allStrings = actualString.split('\\$,\\$');
                    String resultingString = '';
                    if(allStrings != null && !allStrings.isEmpty())
                    {
                        for(String singleString : allStrings)
                        {
                            List<String> fieldValues = singleString.split(',');
                            resultingString = resultingString+bigMachinesLoginNamesToNames.get(fieldValues[0])+' - '+fieldValues[2]+';';                        
                        }   
                        if(resultingString != '' && resultingString != null)
                        {
                            quoteObj.Pending_Approvals_From_Users_Parsed__c = resultingString.removeEnd(';');
                        }
                    }
                }
            }
        }
    }
    
    //2016-11-21 - vishal.bandari@cdk.com - added code to Parse Pending Approval String - RQ-08211
    public static Map<String,String> convertBigMachineLoginToUserName(Set<String> bigMachinesUserNames)
    {
        List<User> userList = [SELECT Name,BigMachines__Login__c FROM USER WHERE IsActive = true AND BigMachines__Login__c IN: bigMachinesUserNames];
        Map<String,String> bigMachineLoginNameToNameMap = new Map<String,String>();
        for(User userObj :userList)
        {
            bigMachineLoginNameToNameMap.put(userObj.BigMachines__Login__c,userObj.Name);
        }
        return bigMachineLoginNameToNameMap;
    }
    
    //2017-04-14 ragashalini.koka@cdk.com - updates a flag on Opportunity based on the Quote status for RQ-09040
    public static void updateQuoteCreationOnOpportunity(List<BigMachines__Quote__c> oldList, List<BigMachines__Quote__c> newList)
    {
        Set<Id> opportunityIdSetToPreventQuote = new Set<Id>();
        Set<Id> orderSubmittedOpportunityIdSet = new Set<Id>();
        Set<Id> opportunityIdSetToAllowQuote = new Set<Id>();
       
       	for(Integer i = 0;i < newList.size();i++) 
        {
            String status = newList[i].BigMachines__Status__c;
                if(status == 'Customer Review' || status == 'Finalized' || status == 'Order Submitted')
                {
                    opportunityIdSetToPreventQuote.add(newList[i].BigMachines__Opportunity__c);
                    if(status == 'Order Submitted')
                    {
                        orderSubmittedOpportunityIdSet.add(newList[i].BigMachines__Opportunity__c);
                    }
                }
                else
                {
                    opportunityIdSetToAllowQuote.add(newList[i].BigMachines__Opportunity__c);
                }
            
        }
     
        List<Opportunity> oppList = [
            SELECT Id, StageName, Prevent_Quote_Creation__c 
            FROM Opportunity 
            WHERE Id IN : opportunityIdSetToPreventQuote AND (Prevent_Quote_Creation__c  = false OR StageName != 'Closed - Won')
        ];
       // System.debug('oppList : ' + oppList);
        for(Opportunity opp : oppList)
        {
            if(!opp.Prevent_Quote_Creation__c)
            {
                opp.Prevent_Quote_Creation__c = true;
            }
            if(orderSubmittedOpportunityIdSet.contains(opp.Id))
            {
                opp.StageName = 'Closed - Won';
            }
            
        }
        opportunityIdSetToAllowQuote.removeAll(opportunityIdSetToPreventQuote);
        List<AggregateResult> allowQuoteOpportunityAggregateList = [SELECT count(Id),BigMachines__Opportunity__c
                                                           FROM BigMachines__Quote__c 
                                                           WHERE BigMachines__Opportunity__c IN :opportunityIdSetToAllowQuote 
                                                           AND (BigMachines__Status__c='Customer Review' 
                                                                OR  BigMachines__Status__c='Finalized'
                                                                OR  BigMachines__Status__c='Order Submitted')
                                                           GROUP BY BigMachines__Opportunity__c];
        Set<Id> oppIdToPreventSet = new Set<Id>();
        for(AggregateResult quoteAggRes : allowQuoteOpportunityAggregateList)
        {
            oppIdToPreventSet.add(String.valueOf(quoteAggRes.get('BigMachines__Opportunity__c')));
        }
        
        for(Id oppId : opportunityIdSetToAllowQuote)
        {
            if(!oppIdToPreventSet.contains(oppId))
            {
                Opportunity opp = new Opportunity();
                opp.Id = oppId;
                opp.Prevent_Quote_Creation__c = false;
                oppList.add(opp);
            }
        }
        
        update oppList;
    }
}