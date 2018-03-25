//2017-03-31 - created - siva.pragada@cdk.com
//Special Project Support
//Service Connect
//Service Connect Escalation
//Inquiry - AA/GAM/CAM
//Tier 2 - CVS Integration
public class CB_AllCaseRecordTypes_Handler 
{
    public static void updateCasePhone(List<Case> newCases, Map<ID, Case> oldMap)
    {
        Set<ID> contactRelIds = new Set<ID>();
        
        for(Case newCase: newCases)
        {
            boolean phoneChanged = (
                oldMap != null ? 
                (oldMap.get(newCase.ID) != null ? oldMap.get(newCase.ID).Contact_Name_Relationship__c != newCase.Contact_Name_Relationship__c : false) : 
                True
            );
            
            if(phoneChanged)
            {
                contactRelIds.add(newCase.Contact_Name_Relationship__c);
            }
        }
        
        if(!contactRelIds.isEmpty())
        {
            Map<ID, Contact_Relationship__c> contactRelationMap = new Map<ID, Contact_Relationship__c>([
                Select ID, Phone__c From Contact_Relationship__c
                Where ID IN :contactRelIds
            ]);
            
            if(!contactRelationMap.isEmpty())
            {
                for(Case newCase: newCases)
                {
                    Contact_Relationship__c crs = newCase.Contact_Name_Relationship__c != null ? contactRelationMap.get(newCase.Contact_Name_Relationship__c) : null;
                    
                    if(crs != null)
                    {
                        newCase.Contact_Relationship_Phone__c = crs.Phone__c;
                    }
                }
            }
        }
    }
}