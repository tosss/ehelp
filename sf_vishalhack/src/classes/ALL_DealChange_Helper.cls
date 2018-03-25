public class ALL_DealChange_Helper {
    
    public static void updateDealState(List<Deal_Change__c> dcNewList)
    {
        final Id PSE_USER_PROFILE_ID;
        
        list<Profile> PSEProfiles = [
            select Id 
            from Profile 
            where Name = 'ADPDS - Sales Related - PSE User' LIMIT 1];
        
        if(PSEProfiles != null && !PSEProfiles.isEmpty()) { 
            PSE_USER_PROFILE_ID = PSEProfiles.get(0).Id; 
        }
        
        Map<Id,Deal_State__c> dsMap = new Map<Id,Deal_State__c>();
        List<Id> dsIds = new  List<Id>();
        List<Deal_State__c> dsToUpdate = new List<Deal_State__c>();        
        
        for(Deal_Change__c dc : dcNewList)
        {
            if(dc.Deal_State__c != null)
            {
                dsIds.add(dc.Deal_State__c);
            }
        }
        
        List<Deal_State__c> dsList =[
            select id,name,PSE_Revision__c,PSE_Status__c,
            Owner.ProfileId,Assigned_PSE_Engineer__c
            from Deal_State__c 
            where id IN :dsIds
        ];
        
        for(Deal_State__c dsObject : dsList)
        {
            dsMap.put(dsObject.Id, dsObject);
        }
        
        for(Deal_Change__c dc : dcNewList)
        {
            Deal_State__c dsObj = dsMap.get(dc.Deal_State__c);
            
            if(dsObj!=null)
            {
                if(dc.Type_of_Change__c.equalsIgnoreCase('Network Quote Uploaded')||
                   dc.Type_of_Change__c == 'Network Quote Uploaded')
                {
                    if(dsObj.PSE_Revision__c >= 1)
                    {
                        dsObj.PSE_Revision__c = dsObj.PSE_Revision__c + 1;
                    }
                    else
                    {
                        dsObj.PSE_Revision__c = 1;
                    }
                    
                    dsObj.PSE_Status__c = 'Completed';
                }
                //  else if(dc.Type_of_Change__c.equalsIgnoreCase('Network Needed')||
                //         dc.Type_of_Change__c == 'Network Needed')
                if(
                    dc.get('Network_Needed__c')!=null &&
                    (
                        (dc.get('Network_Needed__c')!=null && 
                         String.valueOf(dc.get('Network_Needed__c')).toLowerCase()=='yes') || 
                        dc.get('Network_Needed__c') == 'Yes'
                    ) && 
                    (dc.get('Network_Needed__c')!=null && dsObj.PSE_Status__c != null && dsObj.PSE_Status__c.equalsIgnoreCase('Completed'))
                )
                {
                    System.debug('$$ Changing the status');
                    //dsObj.PSE_Status__c = 'Open';
                    dsObj.PSE_Status__c = 'Network Changes Requested'; // RQ-05213 changed by Hemanth.kesapragada@cdk.com
                    
                }

            }
            
            //2015-08-11 Hemanth RQ-05129 Assigned PSE Engineer disappearing when PSE Network Quote is added (commented)
            if(dsObj.Owner != null && 
               dsObj.Owner.Id != null && 
               dsObj.Assigned_PSE_Engineer__c == null && // if the field is blank, we want to set it
               dsObj.Owner.ProfileId == PSE_USER_PROFILE_ID)
            {                
                dsObj.Assigned_PSE_Engineer__c = dsObj.Owner.Id; 
                
            }
			//else
            //{
            //    dsObj.Assigned_PSE_Engineer__c = null;
            //    dsToUpdate.add(dsObj);
            //}
            dsToUpdate.add(dsObj);
        }            
        
        if(dsToUpdate!=null && !dsToUpdate.isEmpty())
        {            
            upsert dsToUpdate;
        }
    }    
}