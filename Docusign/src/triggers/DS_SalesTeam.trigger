trigger DS_SalesTeam on Sales_Team__c (before delete, after insert, after update, before insert, before update) 
{
    // 2015-06-29 matt.keefe@cdk.com - added condition for error handling
    boolean run = true; // default to on
    if(CustomSettings__c.getInstance() != null) { 
        run = CustomSettings__c.getInstance().DS_SalesTeamTrigger_On__c; 
    }
    
    if(run)
    {
        List<Sales_Team__c> salesTeam = Trigger.new;
        List<Sales_Team__c> oldSalesTeam = Trigger.old;
        
        // 6/26/09 - removed since not use forecast opportunities now
        //Utilities utils = new Utilities();
        
        DS_CreateSForceSalesTeam sForceSalesTeam = new DS_CreateSForceSalesTeam();
        
        List<OpportunityTeamMember> opportunityMembers;
        String errorMessage = 'A user can only appear once in the sales team for each opportunity.';
        
        if(Trigger.isBefore)
        {
            if(Trigger.isDelete)
            {
                //Delete the standard salesforce sales team
                sForceSalesTeam.deleteSForceSalesTeam(oldSalesTeam);
                
                // 6/26/09 - removed since not use forecast opportunities now
                //utils.deleteSalesTeam(oldSalesTeam);
            }
            
            //Insert the standard salesforce sales team
            if(Trigger.isInsert)
            {
                opportunityMembers=sForceSalesTeam.insertSForceSalesTeam(salesTeam);    
                
                Integer x=0;
                Map <ID,ID> existingStdSTMS = new Map <ID,ID>();
                
                for(x=0; x<salesTeam.size(); x++)
                {
                    if(opportunityMembers.size()>0 && opportunityMembers.get(x)!=null)
                    {
                        //cn commented 03 / 20
                        //salesTeam.get(x).SForce_Sales_Team_Id__c = opportunityMembers.get(x).Id;  
                        //x++;
                        
                        if(existingStdSTMS.get(opportunityMembers.get(x).Id)==null)
                        {
                            salesTeam.get(x).SForce_Sales_Team_Id__c = opportunityMembers.get(x).Id;
                            existingStdSTMS.put(opportunityMembers.get(x).Id, opportunityMembers.get(x).Id);
                        }
                        else
                        {
                            salesTeam.get(x).SForce_Sales_Team_Id__c = null;
                        }
                    }
                    else
                    {
                        salesTeam.get(x).addError('Error in Creating Sales Team - Check for active Opp Owner');
                    }
                }
            }
            
            //Update the standard salesforce sales team by deleting then inserting the records
            if(Trigger.isUpdate)
            {
                sForceSalesTeam.deleteSForceSalesTeam(salesTeam);
                opportunityMembers = sForceSalesTeam.insertSForceSalesTeam(salesTeam);    
                
                for(Integer x=0; x<salesTeam.size(); x++)
                {
                    salesTeam.get(x).SForce_Sales_Team_Id__c = opportunityMembers.get(x).Id;    
                }
            }
            
            if(Trigger.isInsert || Trigger.isUpdate)
            {
                Set<String> parentOpportunities = new Set<String>();
                
                for(Sales_Team__c sTeamMember:salesTeam)
                {
                    parentOpportunities.add(sTeamMember.Opportunity__c);
                }   
                
                Map<String, String> opportunityTeam = new Map<String, String>();
                List<Sales_Team__c> salesTeamAll = [
                    select User__c, Opportunity__c 
                    from Sales_Team__c 
                    where Opportunity__c in :parentOpportunities
                ];
                
                for(Sales_Team__c teamMember:salesTeamAll)
                {
                    String temp = opportunityTeam.get(teamMember.Opportunity__c);
                    
                    if(temp == null)
                    {
                        opportunityTeam.put(teamMember.Opportunity__c, teamMember.User__c);
                    }
                    else
                    {
                        opportunityTeam.remove(teamMember.Opportunity__c);
                        opportunityTeam.put(teamMember.Opportunity__c, temp + teamMember.User__c);
                    }
                }
                
                for(Integer x=0; x<salesTeam.size(); x++)
                {
                    String opptId = opportunityTeam.get(salesTeam[x].Opportunity__c);
                    
                    if(Trigger.isInsert)
                    {
                        if(opptId != null)
                        {   
                            if(salesTeam.get(x).SForce_Sales_Team_Id__c !=null)
                            {
                                if(opptId.indexOf(salesTeam[x].User__c)!=-1)
                                {
                                    salesTeam[x].User__c.addError(errorMessage);                    
                                }
                            }
                            else
                            {
                                salesTeam[x].User__c.addError(errorMessage);
                            }
                        }
                        else
                        {
                            if(salesTeam.get(x).SForce_Sales_Team_Id__c == null) 
                            {
                                salesTeam[x].User__c.addError(errorMessage);
                                system.debug('Adding error as the user exists');
                            }
                        }
                    }
                    if(Trigger.isUpdate)
                    {
                        if(opptId != null)
                        {   
                            if(opptId.indexOf(salesTeam[x].User__c) != -1 
                            && salesTeam[x].User__c != oldSalesTeam[x].User__c)
                            {
                                salesTeam[x].User__c.addError('A user can only appear once in the sales team for each opportunity.');                   
                            }
                        }
                    }
                }   
            }
        }
        
        // 6/26/09 - removed since not use forecast opportunities now
        //if(Trigger.isAfter){
        //    if(Trigger.isInsert){
        //        utils.insertSalesTeam(salesTeam);
        //    }
        //    if(Trigger.isUpdate){
        //        utils.updateSalesTeam(salesTeam);
        //    }
        //}
    }
}