//2017-03-13 - ragashalini.koka@cdk.com - commented the Technology_Solutions_Manager references for RQ-08732
//2017-04-05 - ragashalini.koka@cdk.com - Modified the StageName from Inactive/Cancelled to Closed for RQ-08944
public class DS_DealState_Handler
{
    public static void CreateDealStateSecured(map<Id, Deal_State__c> DealStateNewMap)
    {
        list<Deal_State_Secured__c> DealStateSecuredDocsToInsert = new list<Deal_State_Secured__c>();
        
        list<Deal_State_Secured__c> DealStateSecuredDocs = [
            Select Id, Name, Deal_State__c
            From Deal_State_Secured__c
            Where Deal_State__c IN : DealStateNewMap.keySet()
        ];
        
        set<Id> DealStateIdsWithSecured = new set<Id>();
        for(Deal_State_Secured__c dss : DealStateSecuredDocs) { DealStateIdsWithSecured.add(dss.Deal_State__c); }
        
        for(Deal_State__c CurrentDealState : DealStateNewMap.values())
        {
            if(!DealStateIdsWithSecured.contains(CurrentDealState.Id))
            {
                // Create Deal State - Secured record if one does not exist for Deal State
                // Set lookup to Deal State (based on Deal State that points to this Deal State - Secured record)
                Deal_State_Secured__c NewDealStateSecuredDoc = new Deal_State_Secured__c();
                NewDealStateSecuredDoc.Deal_State__c = CurrentDealState.Id;
                DealStateSecuredDocsToInsert.add(NewDealStateSecuredDoc);
            }
        }
        
        insert DealStateSecuredDocsToInsert;
    }
    
    public static void UpdateOpportunityDealStateID(list<Deal_State__c> TriggerNew)
    {
        map<ID, Opportunity> OpportunitiesToUpdate = new map<ID, Opportunity>();
        
        for(Deal_State__c ds : TriggerNew)
        {
            if(ds.Opportunity__c != null)
            {
                string DealStateId = String.valueOf(ds.Id); DealStateId = DealStateId.substring(0, 15);
                Opportunity DealStateOpportunity = new Opportunity(Id=ds.Opportunity__c, Deal_State_ID__c = DealStateId);
                OpportunitiesToUpdate.put(DealStateOpportunity.Id, DealStateOpportunity);
            }
        }
        //DS_UpdateSObjectList_Batch instance = new DS_UpdateSObjectList_Batch(OpportunitiesToUpdate.values(), 'Opportunity');
        Database.Update (OpportunitiesToUpdate.values(), False);
    }
    
    public static void UpdateDealState(List<Opportunity> newOpportunityList)
    {
        try
        {
            Set<Id> dealStateId = new Set<Id>();
            
            for(Opportunity opportunityObj: newOpportunityList)
            {
                //2017-04-05 - ragashalini.koka@cdk.com - Modified StageName from Inactive/Cancelled to Closed for RQ-08944
                if(opportunityObj.StageName == 'Closed')
                {
                    dealStateId.add(opportunityObj.Deal_State_ID__c);
                }   
            }
            
            List<Deal_State__c> requiredDealState = [
                SELECT ID, Deal_Status__c 
                FROM Deal_State__c 
                WHERE Id IN :dealStateId 
                AND Deal_Status__c!='Cancelled'
            ];
            
            for(Deal_State__C dealState : requiredDealState)
            {
                dealState.Deal_Status__c = 'Cancelled';
            }
            
            if(requiredDealState.size()>0)
            {
                update requiredDealState;
            }
        }
        catch(exception e)
        {
            System.debug('Exception: '+e.getMessage()+' At '+e.getLineNumber());
        }
    }
    
    // this method is called from ALL_Opportunity trigger on Opportunity, used for update of email address when a field on Opportunity is changed
    // look for details in the code
    public static void DealStateEmailUpdateFromOpportunity(map<ID, Opportunity> oppNewMap, map<ID, Opportunity> oppOldMap)
    {
        Set<ID> QueryOppIDset = new Set<ID>();
        for(Opportunity opp: oppNewMap.values())
        {
            Opportunity OldOpportunity = oppOldMap.get(opp.Id);
            if((opp.ADP_Opportunity_Owner__c != OldOpportunity.ADP_Opportunity_Owner__c)||
              (opp.Client_Signer_1__c != OldOpportunity.Client_Signer_1__c)||
              (opp.Client_Signer_2__c != OldOpportunity.Client_Signer_2__c))
            {
                QueryOppIDset.add(opp.ID);
            }
        }
        
        map<ID, Opportunity> QueriedOppMap;
        
        if(QueryOppIDset != null && !QueryOppIDset.isEmpty())
        {
            QueriedOppMap = new map<ID, Opportunity>([
                Select Id, Name, ADP_Opportunity_Owner__r.Email, Client_Signer_1__r.Name, Client_Signer_2__r.Name, 
                (Select Id, Name, CDK_Opportunity_Owner_Email__c, Client_Signer_1__c, Client_Signer_2__c 
                 From Deal_State__r)
                From Opportunity
                Where Id IN : QueryOppIDset 
            ]);
        }
        
        List<Deal_State__c> DealStatesToUpdate = new list<Deal_State__c>();     
        
        if(QueriedOppMap != null && !QueriedOppMap.isEmpty())
        {
            for(Opportunity opp: QueriedOppMap.values())
            {
                list<Deal_State__c> DsList = opp.Deal_State__r;
                
                if(DsList != null && !DsList.isEmpty())
                {
                    for(Deal_State__c ds: DsList)
                    {
                        ds.CDK_Opportunity_Owner_Email__c = opp.ADP_Opportunity_Owner__r.Email;
                        ds.Client_Signer_1__c = opp.Client_Signer_1__r.Name;
                        ds.Client_Signer_2__c = opp.Client_Signer_2__r.Name;
                        DealStatesToUpdate.add(ds);
                    }
                }
            }
        }
        
        if(DealStatesToUpdate != null && !DealStatesToUpdate.isEmpty())
        {
            DataBase.SaveResult[] Results = Database.Update(DealStatesToUpdate, false);
            
            if(Results != null && !Results.isEmpty())
            {
                for(DataBase.SaveResult sr: Results)
                {
                    if(sr.isSuccess())
                    {
                        system.debug(sr.getId() + ' Is Successfully Updated');
                    }
                    else
                    {
                        for(DataBase.Error de: sr.getErrors())
                        {
                            if(de.getMessage() != null)
                            {
                                if(oppNewMap.values().size() == 1) {
                                    oppNewMap.values()[0].addError(de.getMessage()); }
                                else {
                                    system.debug(de.getMessage()); }
                            }
                        }
                    }
                } // end database.saveresult
            }
        }
    }
    
    // this method is called from ALL_Account trigger On Account, used for update of email addresses if the users on Account record are changed
    public static void DealStateEmailUpdateFromAccount(map<ID, Account> accNewMap, map<ID, Account> accOldMap)
    {
        Set<ID> QueryAccIDset = new Set<ID>();
        for(Account acc: accNewMap.values())
        {
            Account OldAccount = accOldMap.get(acc.Id);
            
            boolean FieldChanged = (acc.Key_Rep__c != OldAccount.Key_Rep__c || 
                                    acc.Key_DOS__c != OldAccount.Key_DOS__c /*|| 
                                    acc.Technology_Solutions_Manager__c != OldAccount.Technology_Solutions_Manager__c*/);
            
            system.debug(FieldChanged); 
            
            if(FieldChanged)
            {
                QueryAccIDset.add(acc.ID); system.debug(QueryAccIDset);
            }            
        }
        
        map<ID, Account> QueriedAccMap;
        
        if(QueryAccIDset != null && !QueryAccIDset.isEmpty())
        {
            QueriedAccMap = new map<ID, Account>([
                Select Id, Name, Key_Rep__r.Email, Key_DOS__r.Email, /*Technology_Solutions_Manager__r.Email,*/ Key_DOS__r.Manager.Email, 
                (Select Id, Name From Opportunities)
                From Account
                Where Id IN : QueryAccIDset
            ]);
        }
        
        system.debug(QueriedAccMap);
        
        Set<ID> OppIDset = new Set<ID>();
        
        if(QueriedAccMap != null && !QueriedAccMap.isEmpty())
        {            
            for(Account acc: QueriedAccMap.values())
            {
                list<Opportunity> OppsList = acc.Opportunities;
                
                if(OppsList != null && !OppsList.isEmpty())
                {
                    for(Opportunity opp: OppsList)
                    {
                        OppIDset.add(opp.Id);
                    }
                }
            }
        }
        
        system.debug(OppIDset);
        
        map<ID, Opportunity> QueriedOppMap;
        //2017-03-21 ragashalini.koka@cdk.com - Commented the TSM_Email__c in the query for RQ-08732
        if(OppIDset != null && !OppIDset.isEmpty())
        {           
            QueriedOppMap = new map<ID, Opportunity>([
                Select Id, Name, AccountId, Account.Key_Rep__r.Email, Account.Key_DOS__r.Email, /*Account.Technology_Solutions_Manager__r.Email,*/
                Account.Key_DOS__r.Manager.Email, ADP_Opportunity_Owner__r.Email,
                (Select Id, Name, Account_Key_Rep_Email__c,  Key_DOS_Email__c, /* TSM_Email__c,*/ VP_Email__c From Deal_State__r)
                From Opportunity
                Where Id IN :OppIdSet
            ]);        
        }
        
        system.debug(QueriedOppMap);
        
        List<Deal_State__c> DealStatesToUpdate = new list<Deal_State__c>();
        
        if(QueriedOppMap != null && !QueriedOppMap.isEmpty())
        {
            for(Opportunity opp: QueriedOppMap.values())
            {
                Account CurrentAccount = QueriedAccMap.get(opp.AccountId);
                list<Deal_State__c> DsList = opp.Deal_State__r;
                
                if(DsList != null && !DsList.isEmpty())
                {
                    for(Deal_State__c ds: DsList)
                    {   
                        if(CurrentAccount != null)
                        {
                            ds.Account_Key_Rep_Email__c = CurrentAccount.Key_Rep__r.Email;
                            ds.Key_DOS_Email__c = CurrentAccount.Key_DOS__r.Email;
                           // ds.TSM_Email__c = CurrentAccount.Technology_Solutions_Manager__r.Email;
                            ds.VP_Email__c = CurrentAccount.Key_DOS__r.Manager.Email;
                            
                            DealStatesToUpdate.add(ds);
                        }
                    }
                }                
            }
        }
        
        system.debug(DealStatesToUpdate);
        
        if(DealStatesToUpdate != null && !DealStatesToUpdate.isEmpty())
        {           
            Database.SaveResult[] Results = DataBase.Update(DealStatesToUpdate, false);
            
            if(Results != null && !Results.isEmpty())
            {
                for(DataBase.SaveResult sr: Results)
                {
                    if(sr.isSuccess())
                    {
                        System.debug(sr.getId() + ' Is successfully updated');
                    }
                    else
                    {                        
                        for(DataBase.Error de: sr.getErrors())
                        {
                            if(de.getMessage() != null)
                            {
                                if(accNewMap.values().size() == 1)
                                {
                                    accNewMap.values()[0].addError(de.getMessage());
                                }
                                else
                                {
                                    system.debug(de.getMessage());
                                }                                
                            }
                        }
                    }
                }                
            }
        }
    }
    
    // this method id called from DS_DealState trigger on Deal State, used for update/insert of email addresses
    public static void DealStateEmailInserts(list<Deal_State__c> dsList)
    {  
        Set<ID> OppIdSet = new Set<ID>();      
        
        for(Deal_State__c ds: dsList)
        {
            OppIdSet.add(ds.Opportunity__c);           
        }
        
        map<ID, Opportunity> OpportunityMap;
        
        if(OppIdSet != null && !OppIdSet.isEmpty())
        {
            OpportunityMap = new map<ID, Opportunity>([
                Select Id, Name, AccountId, Account.Key_Rep__r.Email, Account.Key_DOS__r.Email, 
               /* Account.Technology_Solutions_Manager__r.Email,*/ Account.Key_DOS__r.Manager.Email, ADP_Opportunity_Owner__r.Email,
                Account.Site_Type__r.Name, 
                Account.Parent.Site_Type__r.Name, 
                Account.Parent.Parent.Site_Type__r.Name,
                Account.Parent.Parent.Parent.Site_Type__r.Name, 
                Account.Name, 
                Account.Parent.Name, 
                Account.Parent.Parent.Name, 
                Account.Parent.Parent.Parent.Name,                
                Account.Group__c,
                //Account.District__c,
                Account.Corporation__c,
                Account.Corporation__r.Name,
                Account.Group__r.Name,
               // Account.District__r.Name,
                Account.Corporation__r.Site_Type__r.Name,
                Account.Group__r.Site_Type__r.Name,
               // Account.District__r.Site_Type__r.Name,
                Account.Region__c
                From Opportunity
                Where Id IN :OppIdSet
            ]);
        }
        
        set<string> DsAccountRegions = new Set<string>();
        
        if(OpportunityMap != null && !OpportunityMap.isEmpty())
        {
            for(opportunity opp: OpportunityMap.values())
            {
                DsAccountRegions.add(opp.Account.Region__c);
            }
        }
        
        List<AVP_RGM_Link__c> avpRGMList = [                                                   
            SELECT Id, Region__c, Controller__c, Controller__r.Name, Controller__r.Email 
            FROM AVP_RGM_Link__c Where Region__c IN :DsAccountRegions
        ];
        
        map<string, string> RegionToControllerEmail = new map<string, string>();
        
        if(avpRGMList != null && !avpRGMList.isEmpty())
        { 
            for(AVP_RGM_Link__c avp: avpRGMList)
            {
                if(avp.Controller__c != null && avp.Controller__r.Email != null)
                {
                    RegionToControllerEmail.put(avp.Region__c, avp.Controller__r.Email);
                }
            }            
        }
        
        for(Deal_State__c ds: dsList)
        {
            Opportunity CurrentOpportunity = OpportunityMap.get(ds.Opportunity__c);        
            
            if(CurrentOpportunity != null)
            {
                string CDKOpportunityOwnerEmail = CurrentOpportunity.ADP_Opportunity_Owner__r.Email;
                string AccountKeyDOS = CurrentOpportunity.Account.Key_Rep__r.Email;
                string KeyDOSEmail = CurrentOpportunity.Account.Key_DOS__r.Email;
                //string TSMEmail = CurrentOpportunity.Account.Technology_Solutions_Manager__r.Email;
                string VPEmail = CurrentOpportunity.Account.Key_DOS__r.Manager.Email;
                string Region = CurrentOpportunity.Account.Region__c;
                
                String DealerGroup;
                
                if(CurrentOpportunity.AccountId != null){ 
                    DealerGroup = CurrentOpportunity.Account.Name 
                        + ' (' + (CurrentOpportunity.Account.Site_Type__r.Name != null 
                                  ? CurrentOpportunity.Account.Site_Type__r.Name : 'No Site Type Found') + ')';}
                //2017-03-14  ragashalini.koka@cdk.com - commented the code for RQ-08732
                /*if(CurrentOpportunity.Account.District__c != null){ 
                    DealerGroup = CurrentOpportunity.Account.District__r.Name 
                        + ' (' + (CurrentOpportunity.Account.District__r.Site_Type__r.Name != null 
                                  ? CurrentOpportunity.Account.District__r.Site_Type__r.Name : 'No Site Type Found') + ')';}*/
                
                if(CurrentOpportunity.Account.Group__c != null){ 
                    DealerGroup = CurrentOpportunity.Account.Group__r.Name + ' (' 
                        + (CurrentOpportunity.Account.Group__r.Site_Type__r.Name != null 
                           ? CurrentOpportunity.Account.Group__r.Site_Type__r.Name : 'No Site Type Found') + ')';}
                
                if(CurrentOpportunity.Account.Corporation__c != null){ 
                    DealerGroup = CurrentOpportunity.Account.Corporation__r.Name + ' (' 
                        + (CurrentOpportunity.Account.Corporation__r.Site_Type__r.Name != null 
                           ? CurrentOpportunity.Account.Corporation__r.Site_Type__r.Name : 'No Site Type Found') + ')';}
                
                
                ds.Dealer_Group__c = DealerGroup;
                
                
                if(!String.isEmpty(CDKOpportunityOwnerEmail))
                {
                    ds.CDK_Opportunity_Owner_Email__c = CDKOpportunityOwnerEmail;
                }
                
                if(!String.isEmpty(AccountKeyDOS))
                {
                    ds.Account_Key_Rep_Email__c = AccountKeyDOS;
                }
                
                if(!string.isEmpty(KeyDOSEmail))
                {
                    ds.Key_DOS_Email__c = KeyDOSEmail;
                }
                
            /*    if(!string.isEmpty(TSMEmail))
                {
                    ds.TSM_Email__c = TSMEmail;
                }*/
                
                if(!string.isEmpty(VPEmail))
                {
                    ds.VP_Email__c = VPEmail;
                }
                
                if(RegionToControllerEmail != null && !RegionToControllerEmail.isEmpty())
                {
                    if(ds.Dash_Only__c)
                    {
                        ds.Controller_Email__c = RegionToControllerEmail.get('DASH');
                    }
                    else
                    {
                        ds.Controller_Email__c = RegionToControllerEmail.get(Region);
                    }
                }               
            }
        } // end for deal state
    }
    
    public static void updateSQTNSA(List<Deal_State__c> newList, Map<id, Deal_State__c> oldMap)
    {
        try
        {
            List<SQT_NSA__c> sqtNSAList = [
                SELECT ID , Deal_State__c
                FROM SQT_NSA__c 
                WHERE Deal_State__c IN: oldMap.keySet()];
            
            Map<id,Integer> sqtNSACountMap = new Map<id,Integer>();
            
            for(SQT_NSA__c sqtObj : sqtNSAList)
            {
                if(!sqtNSACountMap.keySet().contains(sqtObj.Deal_State__c))
                {
                    sqtNSACountMap.put(sqtObj.Deal_State__c,1);
                }
                else
                {
                    Integer count  = sqtNSACountMap.get(sqtObj.Deal_State__c)+1;
                    sqtNSACountMap.put(sqtObj.Deal_State__c,count);
                }
            }
            
            
           /* for(Deal_State__c ds : newList)
            {
                if(sqtNSACountMap.keyset().contains(ds.id))
                {
                    ds.Count_of_SQT_NSA__c = sqtNSACountMap.get(ds.id);
                }
                else
                {
                    ds.Count_of_SQT_NSA__c = 0;
                }
            }*/  
        }
        catch(exception e)
        {
            System.debug('Exception :'+e.getMessage()+' at '+e.getCause());
        }
    }
}