/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Handler for DS_UpdateKeyRep, ALL_CMF_Info, ALL_LaserArtworkOrder Trigger used to update Key_Rep__c on Forms_Collection__c Object
Created on:    17 July 2015.
Test Class:    ALL_UpdateFormOrders_Test
Code Coverage: 100%
------------------------------------------------------------
History
17 July 2015    Vishal Bandari      RQ-04982: Added updateFormsOrderAccountChanged method
17 July 2015    Vishal Bandari      RQ-04982: Added futureUpdateFormOrders method
17 July 2015    Vishal Bandari      RQ-04982: Added updateFormsOrderChanged method
------------------------------------------------------------*/
public class ALL_UpdateFormOrders_Handler 
{
    
    //Invoked from DS_UpdateKeyRep Trigger
    public static void updateFormsOrderAccountChanged(Map<Id, Account> newMapParam, Map<Id, Account> oldMapParam)
    {
        boolean keyRepChanged = false;
        set<ID> AccountIDset = new set<ID>();
        
        if(newMapParam != null && !newMapParam.isEmpty())
        {
            for(Account acc: newMapParam.values())
            {
                if(oldMapParam != null && !oldMapParam.isEmpty())
                {
                    Account oldAccount = oldMapParam.get(acc.ID);
                    
                    if(oldAccount != null && oldAccount.Key_Rep__c != acc.Key_Rep__c)
                    {
                        AccountIDset.add(acc.ID);
                        keyRepChanged = true;
                    }
                }
            }
        }
        
        boolean notAsynchronousProcess = !system.isBatch() && !system.isFuture() && !system.isScheduled();
        
        if(keyRepChanged && AccountIDset != null && 
           !AccountIDset.isEmpty() && 
           notAsynchronousProcess) //only execute if key rep on Account is changed
        {
            ALL_UpdateFormOrders_Handler.futureUpdateFormOrders(AccountIDset);            
        }
    }
    
    @future
    public static void futureUpdateFormOrders(set<ID> AccountIDset)
    {
        Map<ID, Laser_Artwork_Order__c> laoMap = new Map<ID, Laser_Artwork_Order__c>([            
            Select Id, Ship_Cmf_Info__r.Account__c, Ship_Cmf_Info__r.Account__r.Key_Rep__c
            From Laser_Artwork_Order__c
            Where Ship_Cmf_Info__r.Account__c
            IN : AccountIDset
        ]);
        
        if(laoMap != null && !laoMap.isEmpty())
        {
            for(Laser_Artwork_Order__c laoObj: laoMap.values())
            {
                laoObj.Key_Rep__c = laoObj.Ship_Cmf_Info__r.Account__r.Key_Rep__c;
            }
            
            update laoMap.values();
        }
    }
    
    public static void updateFormsOrderChanged(List<Laser_Artwork_Order__c> formsOrderList)
    {
        try
        {
            List<Id> requiredCMFIds = new List<Id>();
            
            for(Laser_Artwork_Order__c laoObj : formsOrderList)
            {
                if(laoObj.Ship_CMF_Info__c != null)
                {
                    requiredCMFIds.add(laoObj.Ship_CMF_Info__c);
                }
            }
            
            Map<Id, CMF_Info__c> cmfMap =new Map<Id,CMF_Info__c>();
            
            if(requiredCMFIds != null && !requiredCMFIds.isEmpty())
            {
                cmfMap = new Map<Id,CMF_Info__c>([
                    SELECT Account__c, Account__r.Key_Rep__c
                    FROM CMF_Info__c
                    WHERE Id IN: requiredCMFIds
                    AND Account__c != Null
                ]);
            }
            for(Laser_Artwork_Order__c laoObj : formsOrderList)
            {
                if(laoObj.Ship_CMF_Info__c != null)
                {
                    CMF_Info__c cmfObj = cmfMap.get(laoObj.Ship_CMF_Info__c);
                    
                    if(cmfObj!=null)
                    {
                        laoObj.Key_Rep__c = cmfObj.Account__r.Key_Rep__c;
                    }  
                }
                else
                {
                    laoObj.Key_Rep__c = null;
                }
            }
        }
        catch(Exception e)
        {
            System.debug('Exception:'+e.getMessage()+' At '+e.getLineNumber());
        }
    } 
    
}