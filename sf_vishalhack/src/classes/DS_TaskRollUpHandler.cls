//2017-04-05 ragashalini.koka@cdk.com - Commented the class as the field Track_Follow_up_c is no longer used for RQ-08811
public class DS_TaskRollUpHandler 
{
    public static void TaskRollUp(list<task> newTasklist)
    { 
       /* set<ID> LaoIDs = new set<ID>();        
        for(task t: newTasklist)
        {
            if(t.WhatId != null)
            {
                LaoIDs.add(t.WhatId);                
            }
        }
        
        //query related LAO's
        map<ID, Laser_Artwork_Order__c> UniqueLaosMap;        
        if(LaoIDs != null && !LaoIDs.isEmpty())
        {
            UniqueLaosMap = new map<ID, Laser_Artwork_Order__c>([
                Select Id, Name, Number_Follow_up_Calls__c, Order_Status__c
                From Laser_Artwork_Order__c
                Where ID IN :LaoIDs
            ]);                
        } 
        
        for(Task t: newTasklist)
        {
            for(Laser_Artwork_Order__c lao: UniqueLaosMap.values())
            {
                if(t.WhatId != null  && t.WhatId == lao.Id)
                {
                    //if(t.Track_Follow_up__c)
                    //{
                        Laser_Artwork_Order__c UniqueLAO = UniqueLaosMap.get(t.WhatId);
                        
                        if(UniqueLAO.Number_Follow_up_Calls__c == null)
                        {
                            UniqueLAO.Number_Follow_up_Calls__c = 0;
                            UniqueLAO.Number_Follow_up_Calls__c += 1;
                        }
                        else
                        {
                            UniqueLAO.Number_Follow_up_Calls__c += 1;
                        }
                        
                        lao.Last_Followup_Date__c = DateTime.now();
                   // }            
                    //t.Track_Follow_up__c = false; //set it back to false
                }
            }
        }
            
        if(UniqueLaosMap.values() != null && !UniqueLaosMap.values().isEmpty())    
        {  
            try
            {
                ALL_UtilitiesData.SerializesObjectList(UniqueLaosMap.values(), 'update');
                //Update UniqueLaosMap.values();
            }Catch(DmlException dx)
            {
                if(newTasklist != null && newTasklist.size() == 1)
                {
                    newTasklist[0].addError('On the Related LAO record ' + dx.getDmlMessage(0));
                }
            }
        }    */        
        
    }      
}