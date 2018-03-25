//6/7/2016 - created - siva.pragada@cdk.com
//10/4/2017 - added beforeInsert and beforeUpdate method - vishal.bandari@cdk.com - RQ-09018
public class CB_LMARFP_Handler
{
    Static map<integer, string> monthMap = new map<integer, string>{
                1 => 'Jan__c', 2 => 'Feb__c', 3 => 'Mar__c', 4 => 'Apr__c', 5 => 'May__c', 6 => 'Jun__c', 
                    7 => 'Jul__c', 8 => 'Aug__c', 9 => 'Sep__c', 10 => 'Oct__c', 11 => 'Nov__c', 12 => 'Dec__c'
            };
                
    public static void beforeInsert(List<LMA_RFP__c> newList,Map<Id,LMA_RFP__c> oldMap)
    {
        main(newList,oldMap);
    }
    public static void beforeUpdate(List<LMA_RFP__c> newList,Map<Id,LMA_RFP__c> oldMap)
    {
        main(newList,oldMap);
    }
    public static void afterInsert(List<LMA_RFP__c> newList,Map<Id,LMA_RFP__c> oldMap)
    {
        if(ALL_CheckRecursive.runCodeBlockOnce('runOnce_1@LMA_RFP__c'))
        {
            CB_LMARFP_Handler.assignBudgetValuesForMonthsOnPipeline(newList);
        }
    }
    public static void afterUpdate(List<LMA_RFP__c> newList,Map<Id,LMA_RFP__c> oldMap)
    {
        if(ALL_CheckRecursive.runCodeBlockOnce('runOnce_2@LMA_RFP__c'))
        {
            CB_LMARFP_Handler.assignBudgetValuesForMonthsOnPipeline(newList);
        }
    }
    private static void main(List<LMA_RFP__c> newList,Map<Id,LMA_RFP__c> oldMap)
    {
        oldMap = oldMap == null ? new Map<Id,LMA_RFP__c>() : oldMap;
        //2016-05-20 lalitha.adduru@cdk.com - RQ-06982
        //2016-06-09 lalitha.adduru@cdk.com - edited to use the modified method (added another argument)
        Map<String, String> contactToCRMap = new Map<String, String> ();
        contactToCRMap.put('LMA_Contact__c', 'LMA_Contact_Relationship__c');
        ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.New, oldMap, 'LMA__c', null, contactToCRMap);
        
        if(ALL_CheckRecursive.runCodeBlockOnce('runOnce_3@LMA_RFP__c'))
        {
            //6/8/2016 - siva.pragada@cdk.com - added below method
            CB_LMARFP_Handler.assignBudgetValuesForMonths(oldMap, newList);
            CB_LMARFP_Handler.lmaPresidentUpdates(oldMap, newList);
        }
    }
    
    private static void assignBudgetValuesForMonthsOnPipeline(list<LMA_RFP__c> newList)
    {
        list<ID> lmaPipelineIDset  = new List<ID>();
        map<ID, LMA_Pipeline__c> lmaPipelinesMap;
        List<LMA_Pipeline__c> lmaPipelineUpdateList = new List<LMA_Pipeline__c>();
        
        for(LMA_RFP__c lmarfp: newList)
        {
            if(lmarfp.LMA_Pipeline__c != null)
            {
                lmaPipelineIDset.add(lmarfp.LMA_Pipeline__c);
            }
        }
        
        if(!lmaPipelineIDset.isEmpty())
        {
            lmaPipelinesMap = new map<ID, LMA_Pipeline__c>([
                Select ID, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c 
                From LMA_Pipeline__c 
                Where ID IN :lmaPipelineIDset
            ]);
        }
        
        for(LMA_RFP__c currentRecord: newList)
        {
            LMA_Pipeline__c currentPipeLine = (lmaPipelinesMap != null && !lmaPipelinesMap.isEmpty() && 
                                               currentRecord.LMA_Pipeline__c != null) ? lmaPipelinesMap.get(currentRecord.LMA_Pipeline__c) : null;
            Integer i = 1;
             
            if(currentPipeLine != null)
            {
                While(i<13 && i>0)
                {
                    currentPipeLine.put(monthMap.get(i), currentRecord.get(monthMap.get(i)));
                    i++;
                }
                
                lmaPipelineUpdateList.add(currentPipeLine);
            }
        }
        
        if(!lmaPipelineUpdateList.isEmpty())
        {
            Database.SaveResult [] results  = Database.Update (lmaPipelineUpdateList, false);
            
            ALL_UtilitiesMiscellaneous.logDmlFailedRecords(results);
            
            for(Database.SaveResult sr: results)
            {
                if(!sr.isSuccess())
                {
                    for(Database.Error dr: sr.getErrors())
                    {
                        newList[0].addError(dr.getMessage());
                    }
                }
            }
        }
        
    }
    
   /* private static void assignBudgetValuesForMonths(map<ID, LMA_RFP__c> oldMap, list<LMA_RFP__c> newList)
    {
        try
        {   
            //pipeline
            map<ID, LMA_Pipeline__c> lmaPipelinesMap;
                        
            list<LMA_Pipeline__c> pipelinesList = new list<LMA_Pipeline__c>();
            
            Iterator<LMA_RFP__c> itr = newList.iterator();
            set<ID> pipelineIDset = new set<ID>();
            list<LMA_RFP__c> lmaRfpList = new list<LMA_RFP__c>();
            
            map<ID, LMA_RFP__c> LMARFPmap;
            
            if(Trigger.isUpdate)
            {
                LMARFPmap = new map<ID, LMA_RFP__c>([
                    Select ID, Name, (Select ID, ParentID, oldValue, newValue, Field From Histories Where Field = 'Budget__c') 
                    From LMA_RFP__c
                    Where ID IN :Trigger.new
                ]);
            }
            
            while(itr.hasNext())
            {
                LMA_RFP__c currentRecord = itr.next();
                boolean currentBudgetEnddatesNotNull = (currentRecord.Budget__c !=null && currentRecord.IO_End_Date__c != null);
                LMA_RFP__c oldRecord = oldMap.get(currentRecord.ID);
                
                boolean allFieldsNullCheck = (currentRecord.Budget__c != null && currentRecord.IO_End_Date__c != null &&
                                              currentRecord.IO_Start_Date__c != null && currentRecord.LMA_Pipeline__c != null);
                
                
                boolean budgetOrDateOrPipeChanged = 
                    (
                        oldRecord != null && allFieldsNullCheck &&
                        (oldRecord.Budget__c != currentRecord.Budget__c ||                         
                         oldRecord.IO_Start_Date__c != currentRecord.IO_Start_Date__c ||
                         oldRecord.LMA_Pipeline__c != currentRecord.LMA_Pipeline__c ||
                         oldRecord.IO_End_Date__c != currentRecord.IO_End_Date__c)
                    );
                
                //system.debug(budgetOrDateOrPipeChanged);
                
                if(
                    (oldRecord == null && currentBudgetEnddatesNotNull) ||
                    (oldRecord != null && budgetOrDateOrPipeChanged)
                )
                {
                    pipelineIDset.add(currentRecord.LMA_Pipeline__c);
                    lmaRfpList.add(currentRecord);
                }
            }
            
            if(!pipelineIDset.isEmpty())
            {
                lmaPipelinesMap = new map<ID, LMA_Pipeline__c>([
                    Select ID, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c 
                    From LMA_Pipeline__c 
                    Where ID IN :pipelineIDset
                ]);
            }
        
            //system.debug(lmaPipelinesMap);
        
            if(!lmaRfpList.isEmpty() && lmaPipelinesMap != null && !lmaPipelinesMap.isEmpty())
            {
                Iterator<LMA_RFP__c> iterator2 = lmaRfpList.iterator();
                
                while(iterator2.hasNext())
                {
                    LMA_RFP__c currentRecord = iterator2.next();
                    
                    currentRecord.Status__c = 'Confidence Level';
                    
                    
                    date startDate = currentRecord.IO_Start_Date__c;
                    date endDate = currentRecord.IO_End_Date__c;
                    integer startMonth = startDate != null ? startDate.month() : null;
                    integer endMonth = endDate != null ? endDate.month() : null;
                    integer monthsBetween = (endMonth != null && startMonth != null) ? Math.abs(endMonth - startMonth) + 1 : null;
                    decimal currentBudget = (currentRecord.Budget__c != null && monthsBetween != null) ? (currentRecord.Budget__c)/monthsBetween : null;
                    LMA_Pipeline__c currentPipeLine = lmaPipelinesMap.get(currentRecord.LMA_Pipeline__c);
                    
                    integer i = 1;
                    boolean startGreaterThanEndDate = startMonth > endMonth;
                                     
                    //system.debug(startMonth);
                    //system.debug(endMonth);
                    //system.debug(monthsBetween);
                    //system.debug(currentBudget);
                    //system.debug(startMonth);
                    //system.debug(endMonth);
                    //system.debug(currentBudget);
                    
                    if(currentPipeLine != null)
                    {
                        While(i<13 && i>0)
                        {
                            if(!startGreaterThanEndDate)
                            {
                                if(i>=startMonth && i<endMonth+1)
                                {
                                    currentPipeLine.put(monthMap.get(i), currentBudget); 
                                }
                                else
                                {
                                    currentPipeLine.put(monthMap.get(i), 0); 
                                }
                            }
                            else
                            {
                                if(i>=startMonth || i<endMonth+1)
                                {
                                    currentPipeLine.put(monthMap.get(i), currentBudget); 
                                }
                                else
                                {
                                    currentPipeLine.put(monthMap.get(i), 0); 
                                }
                            }
                            
                            i++;
                        }
                        pipelinesList.add(currentPipeLine);
                    }
                }
            }
            //system.debug(pipelinesList);
            if(!pipelinesList.isEmpty())
            {
                Database.SaveResult [] results  = Database.Update (pipelinesList, false);
                
                ALL_UtilitiesMiscellaneous.logDmlFailedRecords(results);
                
                for(Database.SaveResult sr: results)
                {
                    if(!sr.isSuccess())
                    {
                        for(Database.Error dr: sr.getErrors())
                        {
                            newList[0].addError(dr.getMessage());
                        }
                    }
                }
            }
        }
        catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
            newList[0].addError(exp.getStackTraceString());
        }
    }*/
    
    private static void assignBudgetValuesForMonths(map<ID, LMA_RFP__c> oldMap, list<LMA_RFP__c> newList)
    {
        try
        {   
            //pipeline
            map<ID, LMA_Pipeline__c> lmaPipelinesMap;
            
            list<LMA_Pipeline__c> pipelinesList = new list<LMA_Pipeline__c>();
            
            Iterator<LMA_RFP__c> itr = newList.iterator();
            set<ID> pipelineIDset = new set<ID>();
            list<LMA_RFP__c> lmaRfpList = new list<LMA_RFP__c>();
            
            map<ID, LMA_RFP__c> LMARFPmap;
            
            if(Trigger.isUpdate)
            {
                LMARFPmap = new map<ID, LMA_RFP__c>([
                    Select ID, Name, (Select ID, ParentID, oldValue, newValue, Field From Histories Where Field = 'Budget__c') 
                    From LMA_RFP__c
                    Where ID IN :Trigger.new
                ]);
            }
            
            while(itr.hasNext())
            {
                LMA_RFP__c currentRecord = itr.next();
                boolean currentBudgetEnddatesNotNull = (currentRecord.Budget__c !=null && currentRecord.IO_End_Date__c != null);
                LMA_RFP__c oldRecord = oldMap.get(currentRecord.ID);
                
                boolean allFieldsNullCheck = (currentRecord.Budget__c != null && currentRecord.IO_End_Date__c != null &&
                                              currentRecord.IO_Start_Date__c != null);// && currentRecord.LMA_Pipeline__c != null);
                
                boolean budgetValueChangedFirstTime = false; 
                
                if(oldRecord != null)
                {
                    set<Decimal> BudgetValueSet = new set<Decimal>();
                    list<LMA_RFP__History> LMARFPHistories = LMARFPmap.get(currentRecord.ID).Histories;
                    
                    if(!LMARFPHistories.isEmpty())
                    {
                        for(LMA_RFP__History his: LMARFPHistories)
                        {
                            BudgetValueSet.add((Decimal)his.newValue);
                            BudgetValueSet.add((Decimal)his.oldValue); 
                        }
                        BudgetValueSet.remove(null);
                        if(BudgetValueSet.isEmpty()){ budgetValueChangedFirstTime = true; }
                    }
                }
                
                boolean anyMonthlyBudgetsChanged = (oldRecord != null &&  
                                                    (oldRecord.Jan__c != currentRecord.Jan__c || oldRecord.Feb__c != currentRecord.Feb__c 
                                                     || oldRecord.Mar__c != currentRecord.Mar__c || oldRecord.Apr__c != currentRecord.Apr__c
                                                     || oldRecord.May__c != currentRecord.May__c || oldRecord.Jul__c != currentRecord.Jul__c
                                                     || oldRecord.Jun__c != currentRecord.Jun__c || oldRecord.Aug__c != currentRecord.Aug__c
                                                     || oldRecord.Sep__c != currentRecord.Sep__c || oldRecord.Oct__c != currentRecord.Oct__c
                                                     || oldRecord.Nov__c != currentRecord.Nov__c || oldRecord.Dec__c != currentRecord.Dec__c));
                
                
                boolean budgetOrDateOrPipeChanged = 
                    (
                        oldRecord != null && allFieldsNullCheck &&
                        (oldRecord.Budget__c != currentRecord.Budget__c || 
                         oldRecord.IO_End_Date__c != currentRecord.IO_End_Date__c ||
                         oldRecord.IO_Start_Date__c != currentRecord.IO_Start_Date__c ||
                         oldRecord.LMA_Pipeline__c != currentRecord.LMA_Pipeline__c)
                    );
                
                if(
                    (oldRecord == null && currentBudgetEnddatesNotNull) ||
                    (oldRecord != null && (budgetOrDateOrPipeChanged /* || anyMonthlyBudgetsChanged*/) && budgetValueChangedFirstTime)
                )
                {                   
                    lmaRfpList.add(currentRecord);
                }
                
                if(currentRecord.LMA_Pipeline__c != null)
                {
                    pipelineIDset.add(currentRecord.LMA_Pipeline__c);
                }
            }                       
            
            if(!lmaRfpList.isEmpty())
            {
                Iterator<LMA_RFP__c> iterator2 = lmaRfpList.iterator();
                
                while(iterator2.hasNext())
                {
                    LMA_RFP__c currentRecord = iterator2.next();
                    
                    currentRecord.Status__c = 'Confidence Level';
                    
                    
                    date startDate = currentRecord.IO_Start_Date__c;
                    date endDate = currentRecord.IO_End_Date__c;
                    
                    integer startMonth = startDate != null ? startDate.month() : null;
                    integer endMonth = endDate != null ? endDate.month() : null;
                    
                    integer monthsBetween = (endMonth != null && startMonth != null) ? (endMonth > startMonth ? endMonth - startMonth : startMonth - endMonth) + 1 : null;
                    decimal currentBudget = (currentRecord.Budget__c != null && monthsBetween != null) ? (currentRecord.Budget__c)/monthsBetween : null;
                    
                    integer i = 1;
                    
                    boolean startGreaterThanEndDate = startMonth > endMonth;
                    
                    While(i<13 && i>0)
                    {
                        if(!startGreaterThanEndDate)
                        {
                            if(i>=startMonth && i<endMonth+1)
                            {
                                currentRecord.put(monthMap.get(i), currentBudget);
                            }
                            else
                            {
                                currentRecord.put(monthMap.get(i), 0);
                            }
                        }
                        else
                        {
                            if(i>=startMonth || i<endMonth+1)
                            {
                                currentRecord.put(monthMap.get(i), currentBudget);
                            }
                            else
                            {
                                currentRecord.put(monthMap.get(i), 0);
                            }
                        }
                        i++;
                    }                
                }
            }
            
        }
        catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
            newList[0].addError(exp.getMessage());
        }
    }
    
   /* private static void assignBudgetValuesForMonths2(map<ID, LMA_RFP__c> oldMap, list<LMA_RFP__c> newList)
    {
        try
        {   
            //pipeline
            map<ID, LMA_Pipeline__c> lmaPipelinesMap;
            map<integer, string> monthMap = new map<integer, string>{
                1 => 'Jan__c', 2 => 'Feb__c', 3 => 'Mar__c', 4 => 'Apr__c', 5 => 'May__c', 6 => 'Jun__c', 
                    7 => 'Jul__c', 8 => 'Aug__c', 9 => 'Sep__c', 10 => 'Oct__c', 11 => 'Nov__c', 12 => 'Dec__c'
                    };
                        
            list<LMA_Pipeline__c> pipelinesList = new list<LMA_Pipeline__c>();
            
            Iterator<LMA_RFP__c> itr = newList.iterator();
            set<ID> pipelineIDset = new set<ID>();
            list<LMA_RFP__c> lmaRfpList = new list<LMA_RFP__c>();
            
            while(itr.hasNext())
            {
                LMA_RFP__c currentRecord = itr.next();
                boolean currentBudgetEnddatesNotNull = (currentRecord.Budget__c !=null && currentRecord.IO_End_Date__c != null);
                LMA_RFP__c oldRecord = oldMap.get(currentRecord.ID);
                
                boolean allFieldsNullCheck = (currentRecord.Budget__c != null && currentRecord.IO_End_Date__c != null &&
                                              currentRecord.IO_Start_Date__c != null && currentRecord.LMA_Pipeline__c != null);
                
                
                boolean budgetOrDateOrPipeChanged = 
                    (
                        oldRecord != null && allFieldsNullCheck &&
                        (oldRecord.Budget__c != currentRecord.Budget__c || 
                         oldRecord.IO_End_Date__c != currentRecord.IO_End_Date__c ||
                         oldRecord.IO_Start_Date__c != currentRecord.IO_Start_Date__c ||
                         oldRecord.LMA_Pipeline__c != currentRecord.LMA_Pipeline__c)
                    );
                
                //system.debug(budgetOrDateOrPipeChanged);
                
                if(
                    (oldRecord == null && currentBudgetEnddatesNotNull) ||
                    (oldRecord != null && budgetOrDateOrPipeChanged)
                )
                {
                    pipelineIDset.add(currentRecord.LMA_Pipeline__c);
                    lmaRfpList.add(currentRecord);
                }
            }
            
            if(!pipelineIDset.isEmpty())
            {
                lmaPipelinesMap = new map<ID, LMA_Pipeline__c>([
                    Select ID, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c 
                    From LMA_Pipeline__c 
                    Where ID IN :pipelineIDset
                ]);
            }
            
            //system.debug(lmaPipelinesMap);
            
            if(!lmaRfpList.isEmpty())
            {
                Iterator<LMA_RFP__c> iterator2 = lmaRfpList.iterator();
                
                while(iterator2.hasNext())
                {
                    LMA_RFP__c currentRecord = iterator2.next();
                    
                    currentRecord.Status__c = 'Confidence Level';
                    
                    
                    date startDate = currentRecord.IO_Start_Date__c;
                    date endDate = currentRecord.IO_End_Date__c;
                    integer startMonth = startDate != null ? startDate.month() : null;
                    integer endMonth = endDate != null ? endDate.month() : null;
                    integer monthsBetween = (endMonth != null && startMonth != null) ? (endMonth - startMonth) + 1 : null;
                    decimal currentBudget = (currentRecord.Budget__c != null && monthsBetween != null) ? (currentRecord.Budget__c)/monthsBetween : null;
                    LMA_Pipeline__c currentPipeLine = (lmaPipelinesMap != null && !lmaPipelinesMap.isEmpty() && 
                                                      currentRecord.LMA_Pipeline__c != null) ? lmaPipelinesMap.get(currentRecord.LMA_Pipeline__c) : null;
                    
                    integer i = 1;
                    //system.debug(startMonth);
                    //system.debug(endMonth);
                    //system.debug(monthsBetween);
                    //system.debug(currentBudget);
                   // system.debug(startMonth);
                    //system.debug(endMonth);
                    //system.debug(currentBudget);
                    
                    While(i<13 && i>0)
                    {
                        if(i>=startMonth && i<endMonth+1)
                        {
                            if(currentPipeLine != null){ currentPipeLine.put(monthMap.get(i), currentBudget); pipelinesList.add(currentPipeLine); }
                            currentRecord.put(monthMap.get(i), currentBudget);
                        }
                        else
                        {
                            if(currentPipeLine != null) { currentPipeLine.put(monthMap.get(i), 0); pipelinesList.add(currentPipeLine); }
                            currentRecord.put(monthMap.get(i), currentBudget);
                        }
                        i++;
                    }                
                }
            }
            //system.debug(pipelinesList);
            if(!pipelinesList.isEmpty())
            {
                Database.SaveResult [] results  = Database.Update (pipelinesList, false);
                
                ALL_UtilitiesMiscellaneous.logDmlFailedRecords(results);
                
                for(Database.SaveResult sr: results)
                {
                    if(!sr.isSuccess())
                    {
                        for(Database.Error dr: sr.getErrors())
                        {
                            newList[0].addError(dr.getMessage());
                        }
                    }
                }
            }
        }
        catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
            newList[0].addError(exp.getMessage());
        }
    }*/
    
    
    private static void lmaPresidentUpdates(map<ID, LMA_RFP__c> oldMap, list<LMA_RFP__c> newList)
    {
        try
        {
            set<ID> lmaAccountAndContactIDSet = new set<ID>();
            map<ID, Contact> contactMap;
            list<Contact_Relationship__c> contactRelations = new list<Contact_Relationship__c>();
            
            for(LMA_RFP__c lmaRfp: newList)
            {
                if(lmaRfp.LMA__c != null)
                {
                    lmaAccountAndContactIDSet.add(lmaRfp.LMA__c);
                }
                if(lmaRfp.LMA_President__c != null)
                {
                    lmaAccountAndContactIDSet.add(lmaRfp.LMA_President__c);
                }
            }
            
            if(!lmaAccountAndContactIDSet.isEmpty() && !oldMap.isEmpty())
            {
                contactMap = new map<ID, contact>([
                    Select Id, FirstName, LastName, Name, Email, Role__c, AccountId 
                    From Contact               
                    Where (AccountId IN :lmaAccountAndContactIDSet 
                           OR Id IN :lmaAccountAndContactIDSet)
                    AND Status__c = 'Active'
                ]);
            }
            
            if(!lmaAccountAndContactIDSet.isEmpty() && oldMap.isEmpty())
            {
                contactRelations = [
                    Select Id, Name, Account__c, Contact__c, Contact__r.Name, Contact__r.Email
                    From Contact_Relationship__c
                    Where Account__c IN :lmaAccountAndContactIDSet 
                    AND Role__c = 'LMA President'
                ];
            }
            
            if(oldMap.isEmpty())
            {
                CB_LMARFP_Handler.lmaRfpInsert(newList, contactRelations);
            }
            else
            {
                CB_LMARFP_Handler.lmaRfpUpdate(oldMap, newList, contactMap);
            }
        }
        catch(Exception exp)
        {
            All_UtilitiesMiscellaneous.logException(exp);
            newList[0].addError(exp.getStackTraceString());
        }
    }
    
    private static void lmaRfpInsert(list<LMA_RFP__c> newList, list<contact_Relationship__c> contactRelations)
    { 
        if(contactRelations != null)
        {
            for(LMA_RFP__c lmaRfp: newList)
            {
                for(contact_Relationship__c con: contactRelations)
                {
                    if(lmaRfp.LMA__c == con.Account__c)
                    {
                        lmaRfp.LMA_President__c = con.contact__c;
                        lmaRfp.LMA_President_Email__c = con.Contact__r.Email;
                    }
                }
            }
        }
    }
    
    private static void lmaRfpUpdate(map<ID, LMA_RFP__c> oldMap, list<LMA_RFP__c> newList, map<ID, contact> contactMap)
    {
        try
        {
            map<ID, Contact> contactsToUpdate = new map<ID, Contact>();
            
            for(LMA_RFP__c lmaRfp: newList)
            {
                LMA_RFP__c oldLmaRfp = oldMap.get(lmaRfp.ID);
                
                boolean lmaPresidentChanged = 
                    (oldLmaRfp != null && (oldLmaRfp.LMA_President__c == null || lmaRfp.LMA_President__c != oldLmaRfp.LMA_President__c));
                
                boolean lmaPresidentEmailChanged = (lmaRfp.LMA_President_Email__c != oldLmaRfp.LMA_President_Email__c);
                
                contact contactToUpdate = contactMap.get(lmaRfp.LMA_President__c);
               
                if(lmaPresidentChanged == true && (lmaPresidentEmailChanged == false || oldLmaRfp.LMA_President_Email__c == null) && contactToUpdate != null)
                {
                    lmaRfp.LMA_President_Email__c = contactToUpdate.Email;
                }
                
                if(lmaPresidentChanged == true && lmaPresidentEmailChanged == true && contactToUpdate != null)
                {
                    contactToUpdate.Email = lmaRfp.LMA_President_Email__c;
                    contactsToUpdate.put(contactToUpdate.ID, contactToUpdate);
                }
                
                if(lmaPresidentChanged == false && lmaPresidentEmailChanged == true && contactToUpdate != null)
                {
                    contactToUpdate.Email = lmaRfp.LMA_President_Email__c;
                    contactsToUpdate.put(contactToUpdate.ID, contactToUpdate);
                }
                
                if(!contactsToUpdate.isEmpty())
                {
                    update contactsToUpdate.values();
                }
            }
        }
        catch(Exception exp)
        {
            All_UtilitiesMiscellaneous.logException(exp);
            newList[0].addError(exp.getStackTraceString());
        }
    }
}