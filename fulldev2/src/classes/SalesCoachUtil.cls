//2015-11-13- anirudh.singh@cdk.com- To upgrade the API Version FROM 16.0 to 34.0.
//2015-11-13- anirudh.singh@cdk.com- This class consisted TestMethods. Now, a new class SalesCoachUtil_Test has been created for test coverage.
public with sharing class SalesCoachUtil
{
    private static Sales_Coach_Role__c salesCoachRole;
    
    //2015-11-13- anirudh.singh@cdk.com- Changed SelectOption[] to List<SelectOption>.
    //this gets the opurtunity stages from OppurtunityStage which is set by user   
    public static List<SelectOption> getOpptyStages()
    {
        //2015-11-13- anirudh.singh@cdk.com- Changed SelectOption[] to List<SelectOption>.
        List<SelectOption> options=new List<SelectOption>();
        options.add(new SelectOption('-- Select --', '-- Select --'));
        
        //2015-11-13- anirudh.singh@cdk.com- Changed String[] to List<String>.
        List<String> oList=new List<String>();
        List<OpportunityStage> OS=[
            SELECT MasterLabel 
            FROM OpportunityStage 
            WHERE IsActive=true 
            ORDER BY SortOrder
        ];
        
        for(OpportunityStage ml: OS)
        {
            oList.add(ml.MasterLabel);
        }
        
        for(String s: oList)
        {
            options.add(new SelectOption(s.trim(), s.trim()));
        }
        return options;
    }
}