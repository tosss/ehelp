//2015-12-07- anirudh.singh@cdk.com- Modified the API Version from 22.0 to 34.0.
trigger DS_LSR_LAO_Owner_Change on Laser_Artwork_Order__c (before insert, before update)
{
    if(Trigger.isUpdate)
    {
        List<Laser_Artwork_Order__c> updatedLAO = new list<Laser_Artwork_Order__c>();
        set<string> changedOwners = new set<string>();
        
        for(integer i = 0; i<trigger.new.size(); i++)
        {
            if(trigger.new[i].OwnerId <> trigger.old[i].OwnerId)
            {
                changedOwners.add(trigger.new[i].ownerid);
                updatedLAO.add(trigger.new[i]);
            }   
        }
        
        if(changedOwners.size()>0)
        {
            Map<ID, User> userMap = new Map<ID, User>([Select Id, Email From User where IsActive = true and id in : changedowners]);
            
            for (Laser_Artwork_Order__c lao : updatedLAO)
            {
                if(userMap.containsKey(lao.OwnerId))
                {
                    lao.Owner_Email__c = userMap.get(lao.OwnerId).Email;    
                }
                else
                {
                    lao.Owner_Email__c = null;
                }
            }           
        }
    }
    
    if(Trigger.isInsert)
    {
        List<Laser_Artwork_Order__c> updatedLAO = new list<Laser_Artwork_Order__c>();
        set<string> changedOwners = new set<string>();
        
        for(integer i = 0; i<trigger.new.size(); i++)
        {
            changedOwners.add(trigger.new[i].ownerid);
            updatedLAO.add(trigger.new[i]); 
        }
        
        if(changedOwners.size()>0)
        {
            Map<ID,User> userMap = new Map<ID,User>([Select Id, Email From User where IsActive = true and id in : changedowners]);
            
            for (Laser_Artwork_Order__c lao : updatedLAO)
            {
                if(userMap.containsKey(lao.OwnerId))
                {
                    lao.Owner_Email__c = userMap.get(lao.OwnerId).Email;    
                }
                else
                {
                    lao.Owner_Email__c = null;
                }
            }   
        }
    }
}