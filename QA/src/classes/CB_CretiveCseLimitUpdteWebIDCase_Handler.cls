//NOTE : This method is updating both the cases and webId list in single update

public with sharing class CB_CretiveCseLimitUpdteWebIDCase_Handler {
    
    public static void creativeCaseLimitUpdate(map<Id,decimal> ccLimitMap){
        system.debug('-----------ccLimitMap--------'+ccLimitMap);
        try
        {
                list<sObject> webIdCasesLst = new list<sObject>();
                for(WebID__c webId : [select Id, Creative_Case_Limit__c from WebID__c where Id IN: ccLimitMap.KeySet()])
                {
                    if(ccLimitMap.containsKey(webId.Id)){
                        webId.Creative_Case_Limit__c = ccLimitMap.get(webId.Id);
                        webIdCasesLst.add(webId);       
                        //system.debug('Creative case limit----------'+webId.Creative_Case_Limit__c );
                    }
                }
                for(Case cs:[Select Id, Creative_Case_Limit__c, RecordType.Name, WebId__c, Status from Case where WebID__c IN:ccLimitMap.KeySet()
                             and RecordType.Name='Inquiry - Creative' and (NOT Status like '%Closed%') limit 50000])
                {
                    if(ccLimitMap.containsKey(cs.WebId__c))
                    {
                        cs.Creative_Case_Limit__c = ccLimitMap.get(cs.WebID__c);
                        webIdCasesLst.add(cs);
                    }
                }
                update webIdCasesLst;
                //database.update(webIdCasesLst);
        }
        catch(Exception ex)
        {
            system.debug('--------Exception-----'+ex);
        }
        
    }
    
    /* If the cases and WebId's needs to be updated in separate list
     * update webIdList;
    
    for(Case cs: [select Id, Creative_Case_Limit__c, RecordType.Name, WebId__c, Status from Case where WebId__c IN: ccLimitMap.KeySet()])
    {
    if(cs.Status!= 'Closed' && cs.RecordType.Name=='Inquiry - Creative'  && ccLimitMap.containsKey(cs.WebId__c))
    {
    cs.Creative_Case_Limit__c = ccLimitMap.get(cs.WebID__c);
    webIdCasesLst.add(cs);
    }
    system.debug('Creative case limit on case-------'+cs.Creative_Case_Limit__c);  
    }
    //update caseList;    
    */

}