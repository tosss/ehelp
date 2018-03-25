//2016-07-18 - vishal.bandari@cdk.com - RQ-07371:created the handler
//2016-08-10- anirudh.singh@cdk.com- Changed the API Name Opportunity_Site_Building__c to Opportunity_Location__c for RQ-07569.
public class CPQ_SOWQuestions_Handler 
{
    public static void beforeInsert(List<SOW_Question__c> sowQuestionsNewList)
    {
        List<String> oppSiteBuildingIds=new List<String>();
        List<String> oppToSiteMap=new List<String>();
        
        for(SOW_Question__c sowQuestionObject : sowQuestionsNewList)
        {
            if(sowQuestionObject.Opportunity_Site_Building_ID__c==null && (sowQuestionObject.Opportunity__c!=null && sowQuestionObject.Site__c!=null))
            {
                oppToSiteMap.add(sowQuestionObject.Opportunity__c+','+sowQuestionObject.Site__c);
            }
            else if(sowQuestionObject.Opportunity_Site_Building_ID__c!=null && (sowQuestionObject.Opportunity__c==null || sowQuestionObject.Site__c==null))
            {
                oppSiteBuildingIds.add(sowQuestionObject.Opportunity_Site_Building_Id__c);
            }
        }
        
        Map<Id,Opportunity_Location__c> oppSiteBuildingMap;
        if(oppSiteBuildingIds.size()>0)
        {
            oppSiteBuildingMap=CPQ_SOWQuestions_Helper.getOpporunityBuildingsDetailsByIds(oppSiteBuildingIds);
        }
        
        Map<String, String> oppToSiteToOppSiteId;
        if(oppToSiteMap.size() > 0)
        {
            oppToSiteToOppSiteId=CPQ_SOWQuestions_Helper.getOpporunityBuildingsDetailsBySite(new Set<String>(oppToSiteMap));
        }
        
        for(SOW_Question__c sowQuestionObject: sowQuestionsNewList)
        {
            if(oppSiteBuildingMap!=null && sowQuestionObject.Opportunity_Site_Building_Id__c!=null && oppSiteBuildingMap.containsKey(sowQuestionObject.Opportunity_Site_Building_Id__c))
            {
                Opportunity_Location__c oppSiteBuildingObj=oppSiteBuildingMap.get(sowQuestionObject.Opportunity_Site_Building_Id__c);
                sowQuestionObject.Opportunity__c=oppSiteBuildingObj.Opportunity__c;
                sowQuestionObject.Site__c=oppSiteBuildingObj.Site__c;
                sowQuestionObject.Solution_Design_Building_ID__c=oppSiteBuildingObj.Solution_Design_Building_ID__c;
                sowQuestionObject.Solution_Design_ID__c=oppSiteBuildingObj.Solution_Design_ID__c;
            }
            else if(oppToSiteToOppSiteId != null && oppToSiteToOppSiteId.containsKey(sowQuestionObject.Opportunity__c+','+sowQuestionObject.Site__c))
            {
                sowQuestionObject.Opportunity_Site_Building_Id__c=oppToSiteToOppSiteId.get(sowQuestionObject.Opportunity__c+','+sowQuestionObject.Site__c);
            }
        }
    }
    
    public static void beforeUpdate(List<SOW_Question__c> sowQuestionsNewList, Map<Id, SOW_Question__c> sowQuestionsOldMap)
    {
        List<String> oppSiteBuildingSetRecordIds=new List<String>();
        List<String> oppSiteBuildingIds=new List<String>();
        
        for(SOW_Question__c sowQuestionObject: sowQuestionsNewList)
        {
            if((sowQuestionObject.Opportunity_Site_Building_ID__c!=sowQuestionsOldMap.get(sowQuestionObject.Id).Opportunity_Site_Building_ID__c) 
               && sowQuestionObject.Opportunity_Site_Building_ID__c!=null)
            {
                oppSiteBuildingSetRecordIds.add(sowQuestionObject.Id);
                oppSiteBuildingIds.add(sowQuestionObject.Opportunity_Site_Building_Id__c);
            }
        }
        
        if(oppSiteBuildingSetRecordIds.size()>0)
        {
            Map<Id,Opportunity_Location__c> oppSiteBuildingMap=CPQ_SOWQuestions_Helper.getOpporunityBuildingsDetailsByIds(oppSiteBuildingIds);
            if(oppSiteBuildingMap!=null)
            {
                for(SOW_Question__c sowQuestionObject: sowQuestionsNewList)
                {
                    if(oppSiteBuildingMap.containsKey(sowQuestionObject.Opportunity_Site_Building_Id__c))
                    {
                        Opportunity_Location__c oppSiteBuildingObj=oppSiteBuildingMap.get(sowQuestionObject.Opportunity_Site_Building_Id__c);
                        sowQuestionObject.Opportunity__c=oppSiteBuildingObj.Opportunity__c;
                        sowQuestionObject.Site__c=oppSiteBuildingObj.Site__c;
                        sowQuestionObject.Solution_Design_Building_ID__c=oppSiteBuildingObj.Solution_Design_Building_ID__c;
                        sowQuestionObject.Solution_Design_ID__c=oppSiteBuildingObj.Solution_Design_ID__c;
                    }
                }
            }
        }
    }
}