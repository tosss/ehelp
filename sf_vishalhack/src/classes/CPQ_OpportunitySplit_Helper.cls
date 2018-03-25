//2016-09-30 - vishal.bandari@cdk.com - RQ-07843:created the class
public class CPQ_OpportunitySplit_Helper 
{
    public static void preventInsertAndUpdate(List<Opportunity_Split__c> newList,Boolean isInsert)
    {
        Map<String,Decimal> oppToSplitPercentMap = new Map<String,Decimal>();
        Set<Id> opportunityIds = new Set<Id>();
        for(Opportunity_Split__c splitObj : newList)
        {
            opportunityIds.add(splitObj.Opportunity__c);
            
            if(!oppToSplitPercentMap.containsKey(splitObj.Opportunity__c + ' '+splitObj.Site__c+' '+ splitObj.Channel__c))
            {
                oppToSplitPercentMap.put(splitObj.Opportunity__c + ' '+splitObj.Site__c+' '+ splitObj.Channel__c, 0);
            }
           
            Decimal channelToPercent = oppToSplitPercentMap.get(splitObj.Opportunity__c + ' '+splitObj.Site__c+' '+ splitObj.Channel__c);
            Decimal updatedPercent = channelToPercent + splitObj.NewQ__c;
            oppToSplitPercentMap.put(splitObj.Opportunity__c + ' '+splitObj.Site__c+' '+ splitObj.Channel__c,updatedPercent);
        }
        List<Opportunity_Split__c> splitList;
        if(isInsert)
        {
            splitList= [
                SELECT Id,Channel__c,NewQ__c,Opportunity__c, Site__c 
                FROM Opportunity_Split__c 
                WHERE Opportunity__c IN: opportunityIds
            ];
        }
        else
        {
            splitList= [
                SELECT Id,Channel__c,NewQ__c,Opportunity__c, Site__c 
                FROM Opportunity_Split__c 
                WHERE Opportunity__c IN: opportunityIds
                AND ID NOT IN: newList
            ];
        }
        
        System.debug('starting loop1 ---- ');
        if(splitList != null && splitList.size() > 0)
        {
            for(Opportunity_Split__c splitObj : splitList)
            {
                if(!oppToSplitPercentMap.containsKey(splitObj.Opportunity__c + ' '+splitObj.Site__c+' '+ splitObj.Channel__c))
                {
                    oppToSplitPercentMap.put(splitObj.Opportunity__c + ' '+splitObj.Site__c+' '+ splitObj.Channel__c, 0);
                }
                Decimal channelToPercent = oppToSplitPercentMap.get(splitObj.Opportunity__c + ' '+splitObj.Site__c+' '+ splitObj.Channel__c);
               //  System.debug('value ---' + splitObj.Opportunity__c + ' '+splitObj.Site__c+' '+ splitObj.Channel__c + '---' + 'channelToPercent :'  + channelToPercent + '---' + ' NewQ__c : ' + splitObj.NewQ__c );
                Decimal updatedPercent = channelToPercent + splitObj.NewQ__c;
                oppToSplitPercentMap.put(splitObj.Opportunity__c + ' '+splitObj.Site__c+' '+ splitObj.Channel__c,updatedPercent);
            }
        } 
          System.debug('ending loop1 ---- ');
        System.debug('starting loop2 ---- ');
        Set<Id> userIdSet = new Set<Id>();
        for(Opportunity_Split__c splitObj : newList)
        {
            String value = splitObj.Opportunity__c + ' '+splitObj.Site__c+' '+ splitObj.Channel__c;
            //System.debug('split percent : ' + value + '---' + oppToSplitPercentMap.get(value) );
            userIdSet.add(splitObj.Sales_Rep__c);
            if(oppToSplitPercentMap.get(splitObj.Opportunity__c + ' '+splitObj.Site__c+' '+ splitObj.Channel__c) > 100)
            {
               
                splitObj.addError('NewQ Percent for Opportunity and Site is exceeding 100% for the '+splitObj.Channel__c+' channel !!!');
            }
        }
          System.debug('ending loop2 ---- ');
       
    }
    
    public static void preventDelete(Map<Id,Opportunity_Split__c> oldMap)
    {
        List<Id> siteLocationIds = new List<Id>();
        for(Opportunity_Split__c opportunitySplitObject : oldMap.values())
        {
            siteLocationIds.add(opportunitySplitObject.Opportunity_Location__c);
        }
        
        for(Opportunity_Location__c opportunityLocation : 
            [Select Id, 
             (
                 SELECT id FROM Opportunity_Splits__r
             ) 
             From Opportunity_Location__c 
             WHere Id IN:siteLocationIds 
            ])
        {
            
            if(opportunityLocation.Opportunity_Splits__r.size() == 1)
            {
                Opportunity_Split__c recordToBePrevented = oldMap.get(opportunityLocation.Opportunity_Splits__r[0].Id);
                recordToBePrevented.addError('Cannot delete the record as it is the only Opportunity Split record under Opportunity Location');
            }
        }
    }
    
    public static String setChannel(User SalesRep, Account siteObj)
    {
        if(SalesRep != null && siteObj != null)
        {
            if(SalesRep.Forecasting_Channel__c != null && 
               (new Set<String>{ 'Inside Sales','Digital Solutions','Inventory Sales','National','Enterprise - Carson','Enterprise - Seeman'}).contains(SalesRep.Forecasting_Channel__c))
            {
                return SalesRep.Forecasting_Channel__c;
            }
            else if(SalesRep.Id == siteObj.Key_Rep__c) 
            {
                return 'Baseline';
            }
            else if(SalesRep.Id == siteObj.Designated_DSM__c)
            {
                return 'Digital Solutions';
            }
            else if(SalesRep.Forecasting_Channel__c != null)
            {            
                return 'Baseline';
            } 
            else if(SalesRep.Profile.Name.startswith('Cobalt'))
            {
                return 'Digital Solutions';
            }
        }
        return 'Baseline';
    }
    
    public static List<Opportunity_Location__c> getOpportunityLocationList(List<Opportunity_Location__c> oppLocList)
    {
        return [
            SELECT Id, Site__r.Dealer_Group_Name2__c,Opportunity__r.Account.Dealer_Group_Name2__c,Site__r.ParentId,RecordType.Name,
            Opportunity__r.Account.ParentId,Opportunity__r.ADP_Opportunity_Owner__c,Opportunity__r.Account.Designated_DSM__c,
            Site__r.Key_Rep__r.Id, Site__r.Key_Rep__r.Forecasting_Channel__c, Site__r.Key_Rep__r.Profile.Name,
            Site__r.Designated_DSM__r.Id,Site__r.Designated_DSM__r.Forecasting_Channel__c,Site__r.Designated_DSM__r.Profile.Name,
            Opportunity__r.Account.Digital_Advertising_Specialist__c,Site__r.Digital_Advertising_Specialist__c,
            Site__r.Digital_Advertising_Specialist__r.Id,Site__r.Digital_Advertising_Specialist__r.Forecasting_Channel__c,
            Site__r.Digital_Advertising_Specialist__r.Profile.Name,Opportunity__r.Account.Name,
            Opportunity__r.ADP_Opportunity_Owner__r.Profile.Name,Site__r.Name,
            Opportunity__r.ADP_Opportunity_Owner__r.Forecasting_Channel__c,Opportunity__r.AccountId,
            Opportunity__r.ADP_Opportunity_Owner__r.Title,Opportunity__r.Account.Key_Rep__r.Id, 
            Opportunity__r.Account.Key_Rep__r.Forecasting_Channel__c, Opportunity__r.Account.Key_Rep__r.Profile.Name,
            Site__r.Id,Site__c,Site__r.Key_rep__c,Site__r.Designated_DSM__c,
            Opportunity__r.Account.Key_rep__c, Opportunity__c
            FROM Opportunity_Location__c
            WHERE Id IN: oppLocList
            AND RecordType.Name = 'Site'
        ];
    }
    
    public static Boolean needPercentageSplit(Opportunity_Location__c oppLoc)
    {
        return (oppLoc.Site__c != oppLoc.Opportunity__r.AccountId && ((oppLoc.Site__r.ParentId == NULL && oppLoc.Opportunity__r.Account.ParentId == NULL) 
                            || (oppLoc.Site__r.ParentId == NULL && oppLoc.Opportunity__r.Account.ParentId != NULL && oppLoc.Site__r.Name != oppLoc.Opportunity__r.Account.Dealer_Group_Name2__c)
                            ||(oppLoc.Site__r.ParentId != NULL && oppLoc.Opportunity__r.Account.ParentId == NULL && oppLoc.Site__r.Dealer_Group_Name2__c != oppLoc.Opportunity__r.Account.Name)
                            ||(oppLoc.Site__r.Dealer_Group_Name2__c != oppLoc.Opportunity__r.Account.Dealer_Group_Name2__c) 
                               && (oppLoc.Site__r.ParentId != NULL && oppLoc.Opportunity__r.Account.ParentId != NULL)));
    }
    
    public static Opportunity_Split_Defaults_Settings__c getOpportunitySplitCustomSettings()
    {
        Opportunity_Split_Defaults_Settings__c oppLocCustomSettings = Opportunity_Split_Defaults_Settings__c.getOrgDefaults();
        if((oppLocCustomSettings == null || (oppLocCustomSettings == new Opportunity_Split_Defaults_Settings__c()) )&& Test.IsRunningTest())
        {
            Opportunity_Split_Defaults_Settings__c orgDefaults = new Opportunity_Split_Defaults_Settings__c();
            orgDefaults.AutoKeyRepAdds__c = 'ARM, ERM, NRM';
            orgDefaults.Name = 'Sample';
            orgDefaults.KeyRepChannels__c = 'Baseline, National, Enterprise - Seeman, Enterprise - Carson';
            orgDefaults.InsideInventoryChannels__c = 'Inside Sales, Inventory Sales';
            insert orgDefaults;
            oppLocCustomSettings = Opportunity_Split_Defaults_Settings__c.getOrgDefaults();
        }
        return oppLocCustomSettings;
    }
    
    public static Map<String,User> getAccountTeamMembersMap(List<Id> accountIds,List<String> roles)
    {
        Map<String,User> accountTeamMap = new  Map<String,User>();
        
        List<Account_Team__c> accountTeamMembers = [
            SELECT Id, Team_Member__r.Forecasting_Channel__c, Account__c,Team_member__r.Title,Team_member__r.Profile.Name
            FROM Account_Team__c 
            WHERE Team_Member__r.Title  IN: roles 
            AND Account__c IN: accountIds
        ];
        
        for(Account_Team__c accTeamObj : accountTeamMembers)
        {
            accountTeamMap.put(accTeamObj.Account__c +accTeamObj.Team_member__r.Title, accTeamObj.Team_Member__r);
        }
        
        return accountTeamMap;
    }
    
    public static User opportunitySplitRep(Opportunity_Location__c oppLoc,Map<String,User> accountTeamMap,Opportunity_Split_Defaults_Settings__c oppLocCustomSettings)
    {
        User oppSplitRep = null;
        
        if(oppLoc.Opportunity__r.ADP_Opportunity_Owner__c == oppLoc.Opportunity__r.Account.Key_Rep__c )
        {
            oppSplitRep = opploc.Site__r.Key_Rep__r;
        }
        else if(oppLoc.Opportunity__r.ADP_Opportunity_Owner__c == oppLoc.Opportunity__r.Account.Designated_DSM__c)
        {
            if(oppLoc.Site__r.Designated_DSM__c != NULL)
            {
                oppSplitRep = oppLoc.Site__r.Designated_DSM__r;
            }
        }
        else if(oppLoc.Opportunity__r.ADP_Opportunity_Owner__c == oppLoc.Opportunity__r.Account.Digital_Advertising_Specialist__c)
        {
            if(oppLoc.Site__r.Digital_Advertising_Specialist__c != NULL)
            {
                oppSplitRep = oppLoc.Site__r.Digital_Advertising_Specialist__r;
            }
        }
        else if((new Set<String>(oppLocCustomSettings.InsideInventoryChannels__c.split(','))).contains(oppLoc.Opportunity__r.ADP_Opportunity_Owner__r.Forecasting_Channel__c))
        { 
            oppSplitRep = accountTeamMap.get(oppLoc.Site__c+oppLoc.Opportunity__r.ADP_Opportunity_Owner__r.Title);
        }
        
        return oppSplitRep;
    }
    
    public static void newSplitInsert(List<Opportunity_Location__c> oppLocList)
    {
        List<Opportunity_Location__c> detialedOppLocList = getOpportunityLocationList(oppLocList);
        
        List<Id> accountIds = new List<Id>();
        List<String> roles = new List<String>();
        
        for(Opportunity_Location__c oppLoc : detialedOppLocList)
        {
            accountIds.add(oppLoc.Site__c);
            roles.add(oppLoc.Opportunity__r.ADP_Opportunity_Owner__r.Title);
        }
        
        Map<String,User> accountTeamMap = getAccountTeamMembersMap(accountIds,roles);
        
        Opportunity_Split_Defaults_Settings__c oppLocCustomSettings = getOpportunitySplitCustomSettings();
        
        Set<Opportunity_Split__c> splitSet = new Set<Opportunity_Split__c>();
        
        for(Opportunity_Location__c oppLoc : detialedOppLocList)
        {
            Boolean split = needPercentageSplit(oppLoc);
            
            User oppSplitRep = opportunitySplitRep(oppLoc,accountTeamMap,oppLocCustomSettings);
            
            if(oppSplitRep == null)
            {
                split = false;
            }
            // system.debug('split  -- >'+split);
            
            if(oppSplitRep != null)
            {
                splitSet.add(new Opportunity_Split__c
                              (Sales_Rep__c = oppSplitRep.Id, 
                               Channel__c= setChannel(oppSplitRep, opploc.Site__r), 
                               Site__c = oppLoc.Site__c,
                               Opportunity__c = oppLoc.Opportunity__c,
                               NewQ__c = (split && oppSplitRep.Id != oppLoc.Opportunity__r.ADP_Opportunity_Owner__c) ? 50 : 100));
            }
            
            if(oppLoc.Opportunity__r.ADP_Opportunity_Owner__r.Forecasting_Channel__c != null
              && (oppSplitRep == null 
              || (split && oppSplitRep.Id != oppLoc.Opportunity__r.ADP_Opportunity_Owner__c)))
            {
                system.debug('ADDING OPP OWNER -- >'+oppLoc.Opportunity__r.ADP_Opportunity_Owner__c);
 
                splitSet.add(new Opportunity_Split__c
                              (Sales_Rep__c = oppLoc.Opportunity__r.ADP_Opportunity_Owner__c, 
                               Channel__c= setChannel(oppLoc.Opportunity__r.ADP_Opportunity_Owner__r, opploc.Opportunity__r.Account), 
                               Site__c = oppLoc.Site__c,
                               Opportunity__c = oppLoc.Opportunity__c,
                               NewQ__c = (split && oppSplitRep != null) ? 50 : 100));
            }
            
            if((new Set<String>(oppLocCustomSettings.AutoKeyRepAdds__c.split(','))).contains(oppLoc.Opportunity__r.ADP_Opportunity_Owner__r.Title)
               || (new Set<String>(oppLocCustomSettings.InsideInventoryChannels__c.split(','))).contains(oppLoc.Opportunity__r.ADP_Opportunity_Owner__r.Forecasting_Channel__c))
                {
                    splitSet.add(new Opportunity_Split__c
                              (Sales_Rep__c = oppLoc.Site__r.Key_Rep__c, 
                               Channel__c= setChannel(opploc.Site__r.Key_Rep__r, opploc.Site__r), 
                               Site__c = oppLoc.Site__c,
                               Opportunity__c = oppLoc.Opportunity__c,
                               NewQ__c = split ? 50 : 100));
                               
                    if(split && oppLoc.Site__r.Key_Rep__c != oppLoc.Opportunity__r.Account.Key_Rep__c)
                        {
                            splitSet.add(new Opportunity_Split__c
                                  (Sales_Rep__c = oppLoc.Opportunity__r.Account.Key_Rep__c, 
                                   Channel__c= setChannel(oppLoc.Opportunity__r.Account.Key_Rep__r, opploc.Opportunity__r.Account), 
                                   Site__c = oppLoc.Site__c,
                                   Opportunity__c = oppLoc.Opportunity__c,
                                   NewQ__c = split ? 50 : 100));
                        }

                }
        }
        // insert new List<Opportunity_Split__c>(splitList);
        List<Opportunity_Split__c> splitList = new List<Opportunity_Split__c>(splitSet);
        validateSplitErrors(new List<Opportunity_Split__c>(splitSet), Database.insert(splitList, false), oppLocList);
        
    }
        
    public static void setOpportunityLocation(List<Opportunity_Split__c> newList,Map<Id,Opportunity_Split__c> oldMap,Boolean isUpdate)
    {
        List<Id> opporutunityIds = new List<Id>();
        List<Id> accountIds = new List<Id>();
        Set<Id> opportunityLocationIds = new Set<Id>();
        Map<String,Id> accoutToOppCombination = new Map<String,Id>();
        for(Opportunity_Split__c oppSplitObj : newList)
        {
            opporutunityIds.add(oppSplitObj.Opportunity__c);
            accountIds.add(oppSplitObj.Site__c);
            if(oppSplitObj.Opportunity_Location__c != null)
            {
                opportunityLocationIds.add(oppSplitObj.Opportunity_Location__c);
            }
        }
        Map<Id, Opportunity_Location__c> oppLocMap = new Map<Id, Opportunity_Location__c>([
            SELECT Id , RecordType.Name,Site__c, Opportunity__c
            FROM Opportunity_Location__c 
            WHERE ID IN:opportunityLocationIds
            OR ( Site__c IN: accountIds 
            AND Opportunity__c IN: opporutunityIds )
        ]);
        for(Opportunity_Location__c oppLocObj : oppLocMap.values())
        {
            if(oppLocObj.RecordType.Name == 'Site')
            {
                accoutToOppCombination.put(oppLocObj.Site__c +' '+ oppLocObj.Opportunity__c,oppLocObj.Id);
            }
        }
        for(Opportunity_Split__c oppSplitObj : newList)
        {
            Id opportunityLocationId = accoutToOppCombination.get(oppSplitObj.Site__c +' '+ oppSplitObj.Opportunity__c);
            Boolean error = false;
            if(oppSplitObj.Opportunity_Location__c == null || (isUpdate && oldMap.get(oppSplitObj.Id).Opportunity_Location__c != opportunityLocationId))
            {
                if(opportunityLocationId != null)
                {
                    oppSplitObj.Opportunity_Location__c = opportunityLocationId;
                }
                else
                {
                    System.debug('in add error forecasting channel');
                    oppSplitObj.addError('You cannot create an Opportunity Split record if there does not exist an Opportunity Location (Site) record for that Site.');
                    error = true;
                }
            }
            
            if(!error && opportunityLocationId == null && oppLocMap != null && oppLocMap.get(oppSplitObj.Opportunity_Location__c).RecordType.Name != 'Site')
            {
                oppSplitObj.addError('Opportunity Location of Site Type doesnot exist with that combination');
            }
        }
    }
    //2017-03-03  ragashalini.koka@cdk.com - Added this method to add errors on the corresponding Opportunity Locations
    private static void validateSplitErrors(List<Opportunity_Split__c> splitList, List<Database.SaveResult> srList, List<Opportunity_Location__c> oppLocList) 
    {
        Map<String,Opportunity_Location__c> oppLocMap = new Map<String,Opportunity_Location__c>();
        for(Opportunity_Location__c oppLoc : oppLocList) 
        {
            oppLocMap.put(oppLoc.Opportunity__c + '' + oppLoc.Site__c, oppLoc);
        }
        
        for(Integer i = 0;i < srList.size();i++) {
            Database.SaveResult sr = srList[i];
            System.debug('sr result : ' + sr.isSuccess());
            if(!sr.isSuccess())
            {
                 String errorMsg = '';
                for(Database.Error err : sr.getErrors()) 
                {
                    errorMsg += err.getMessage() + '\n';
                }
                oppLocMap.get(splitList[i].Opportunity__c + '' + splitList[i].Site__c).addError(errorMsg);
            }
        }
    }
}