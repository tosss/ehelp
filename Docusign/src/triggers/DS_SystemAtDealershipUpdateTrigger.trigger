trigger DS_SystemAtDealershipUpdateTrigger on System_at_Dealership__c (before update) 
{   
	/* 
    if (Trigger.isBefore)
    {
        String strDMS = '';
        String strVendor = '';
        String strIdate = '';
        
        List <System_at_Dealership__c> updateSys = new List<System_at_Dealership__c>();
        
        for(integer i=0; i<trigger.new.size();i++)
        {
            if (trigger.new[i].System_Type__c == trigger.old[i].System_Type__c || 
                trigger.new[i].System_Type__c == 'Previous ' + trigger.old[i].System_Type__c || 
                trigger.old[i].System_Type__c == 'Previous ' + trigger.new[i].System_Type__c) 
            {
                // Do Nothing here
            }
            else
            {
                //cancel update
                Trigger.new[i].addError('The System Type can not be changed. Please enter a new record for the new System Type.');                          
            }
            
            system.debug('Trigger old value ' + trigger.old[i].System_Type__c);
            system.debug('Trigger new value ' + trigger.new[i].System_Type__c);
            
            if(trigger.old[i].System_Type__c == 'Previous ' + trigger.new[i].System_Type__c)
            {
                Trigger.new[i].addError('The System Type can not be changed from Previous to Current.'
                                        + ' Please add a new record with the desired Current System Type.');  
            }
            
            
            if (trigger.new[i].System_Type__c == trigger.old[i].System_Type__c || 
                trigger.new[i].System_Type__c == 'Previous ' + trigger.old[i].System_Type__c || 
                trigger.old[i].System_Type__c == 'Previous ' + trigger.new[i].System_Type__c) 
            {
                //should not allow changing type except to/from(?) previous                   
                if (trigger.new[i].Vendor__c != trigger.old[i].Vendor__c || 
                    trigger.new[i].System_Type__c != trigger.old[i].System_Type__c || 
                    trigger.new[i].Install_Date__c != trigger.old[i].Install_Date__c) 
                {
                    Systems__c[] curSys1 = [
                        select s.Id, s.SLXSystem_ID__c, s.SLXVendor_ID__c, s.Type__c 
                        from Systems__c s 
                        where s.Id = :trigger.new[i].Vendor__c];
                    
                    if(curSys1[0].SLXSystem_ID__c == '' || curSys1[0].SLXSystem_ID__c == null)
                    {
                        strDMS = '            ';
                    } 
                    else 
                    {
                        strDMS = curSys1[0].SLXSystem_ID__c;
                    }
                    
                    if(trigger.new[i].Install_Date__c == null)
                    {
                        strIdate = '        ';  
                    }
                    else 
                    {
                        if(trigger.new[i].Install_Date__c.Month() < 10)
                        {
                            strIdate = trigger.new[i].Install_Date__c.Year() + '' + '0' + trigger.new[i].Install_Date__c.Month() + '';     
                        } 
                        else 
                        {
                            strIdate = trigger.new[i].Install_Date__c.Year() + '' + trigger.new[i].Install_Date__c.Month() + '';                                               
                        }     
                        if(trigger.new[i].Install_Date__c.Day() < 10)
                        {
                            strIdate = strIdate + '' +  '0' + ''  + trigger.new[i].Install_Date__c.Day() + '';            
                        } 
                        else 
                        {
                            strIdate = strIdate + '' + trigger.new[i].Install_Date__c.Day() + '';                                                
                        }
                    }
                    
                    if (trigger.new[i].CompositeExtID__c == null || 
                        trigger.new[i].CompositeExtID__c != trigger.new[i].Account__c + '' 
                        + strIdate +  curSys1[0].SLXVendor_ID__c + '' + strDMS + '' + trigger.new[i].System_Type__c) 
                    {
                        trigger.new[i].CompositeExtID__c = trigger.new[i].Account__c + '' + 
                            strIdate +  curSys1[0].SLXVendor_ID__c + '' + strDMS + '' + trigger.new[i].System_Type__c;
                    }
                    
                    if (trigger.new[i].SLX_Vendor_ID__c == null || 
                        trigger.new[i].SLX_Vendor_ID__c != curSys1[0].SLXVendor_ID__c) 
                    {
                        trigger.new[i].SLX_Vendor_ID__c = curSys1[0].SLXVendor_ID__c;
                    }
                    
                    if (trigger.new[i].SLX_Sys_ID__c == null || trigger.new[i].SLX_Sys_ID__c != strDMS) 
                    {
                        trigger.new[i].SLX_Sys_ID__c = strDMS;
                    }
                }
            }
        }  
 
    }
    */
}