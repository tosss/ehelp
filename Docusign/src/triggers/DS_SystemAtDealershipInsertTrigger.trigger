trigger DS_SystemAtDealershipInsertTrigger on System_at_Dealership__c (before insert) {
	/*
    // Code for setting the compositeid for newly inserted record only
    Systems__c sys = [Select s.Id, s.SLXSystem_ID__c, s.SLXVendor_ID__c, s.Type__c from Systems__c s where s.Id = :trigger.new[0].Vendor__c];
    String strIdate = '';
    for(integer i=0; i<trigger.new.size();i++){
        if (trigger.new[i].CompositeExtID__c == '' || trigger.new[i].CompositeExtID__c == null){
            if(trigger.new[i].Install_Date__c == null){
                strIdate =  '        ';
            } else {
                if(trigger.new[i].Install_Date__c.Month() < 10){
                    strIdate = trigger.new[i].Install_Date__c.Year() + '' + '0' + trigger.new[i].Install_Date__c.Month() + '';     
                } else {
                    strIdate = trigger.new[i].Install_Date__c.Year() + '' + trigger.new[i].Install_Date__c.Month() + '';                                               
                }     
                if(trigger.new[i].Install_Date__c.Day() < 10){
                    strIdate = strIdate + '' +  '0' + ''  + trigger.new[i].Install_Date__c.Day() + '';            
                } else {
                    strIdate = strIdate + '' + trigger.new[i].Install_Date__c.Day() + '';                                                
                }
            }
            if(sys.SLXSystem_ID__c == '' || sys.SLXSystem_ID__c == null){
                trigger.new[i].CompositeExtID__c = trigger.new[i].Account__c + '' + strIdate + sys.SLXVendor_ID__c + '' + '            ' + '' + trigger.new[i].System_Type__c;
                trigger.new[i].SLX_Vendor_ID__c = sys.SLXVendor_ID__c;
            }else{
                trigger.new[i].CompositeExtID__c = trigger.new[i].Account__c + '' + strIdate + sys.SLXVendor_ID__c + '' + sys.SLXSystem_ID__c + '' + trigger.new[i].System_Type__c;
                trigger.new[i].SLX_Vendor_ID__c = sys.SLXVendor_ID__c;
                trigger.new[i].SLX_Sys_ID__c = sys.SLXSystem_ID__c;
            }
        }

    }

    String strDMS = '';
    String strMonth = '';
    String strYear = '';
    String strDay = '';
    String strVendor = '';
    List <System_at_Dealership__c> updatedSys1 = new List<System_at_Dealership__c>(); 
    List <System_at_Dealership__c> deletedSys = new List<System_at_Dealership__c>();
    for(integer i=0; i<trigger.new.size();i++){
        if(trigger.new[i].System_Type__c != 'Previous DMS' && trigger.new[i].System_Type__c != 'Previous CRM' && trigger.new[i].System_Type__c != 'Previous Leasing' && trigger.new[i].System_Type__c != 'Previous Phone'){
            System_at_Dealership__c[] curSys = [select Id, Account__c, Install_Date__c, System_Type__c, Vendor__c, CompositeExtID__c from System_at_Dealership__c where Account__c = :trigger.new[i].Account__c and System_Type__c = :trigger.new[i].System_Type__c];
            if(curSys.size() > 0){
                System_at_Dealership__c[] allSys = [select Id, CompositeExtID__c from System_at_Dealership__c where Account__c = :trigger.new[i].Account__c];
                for(integer j=0; j<curSys.size();j++){
                    Systems__c[] upSys = [select Id, SLXSystem_ID__c, SLXVendor_ID__c, Type__c from Systems__c where Id = :curSys[j].Vendor__c];
                    if(upSys[0].SLXSystem_ID__c == '' || upSys[0].SLXSystem_ID__c == null){
                        strDMS = '            ';
                    } else {
                        strDMS = upSys[0].SLXSystem_ID__c;
                    }
                    strVendor = upSys[0].SLXVendor_ID__c;
                    if(curSys[j].Install_Date__c == null){
                        strIdate = '        ';  
                    } else {
                        if(curSys[j].Install_Date__c.Month() < 10){
                            strIdate = curSys[j].Install_Date__c.Year() + '' + '0' + curSys[j].Install_Date__c.Month() + '';   
                        } else {
                            strIdate = curSys[j].Install_Date__c.Year() + '' + curSys[j].Install_Date__c.Month() + '';                                             
                        }     
                        if(curSys[j].Install_Date__c.Day() < 10){
                            strIdate = strIdate + '' +  '0' + ''  + curSys[j].Install_Date__c.Day() + '';           
                        } else {
                            strIdate = strIdate + '' + curSys[j].Install_Date__c.Day() + '';                                               
                        }
                    }                        
                    if(curSys[j].System_Type__c == 'DMS'){
                        curSys[j].System_Type__c = 'Previous DMS';
                        curSys[j].CompositeExtID__c = curSys[j].Account__c + '' +  strIdate + strVendor + strDMS + 'Previous DMS';
                    } 
                    if(curSys[j].System_Type__c == 'CRM'){
                        curSys[j].System_Type__c = 'Previous CRM';      
                        curSys[j].CompositeExtID__c = curSys[j].Account__c + '' +  strIdate + strVendor + strDMS + 'Previous CRM';
                    }
                    if(curSys[j].System_Type__c == 'Leasing'){
                        curSys[j].System_Type__c = 'Previous Leasing';
                        curSys[j].CompositeExtID__c = curSys[j].Account__c + '' +  strIdate + strVendor + strDMS + 'Previous Leasing';
                    }                       
                    if(curSys[j].System_Type__c == 'Phone'){
                        curSys[j].System_Type__c = 'Previous Phone';
                        curSys[j].CompositeExtID__c = curSys[j].Account__c + '' +  strIdate + strVendor + strDMS + 'Previous Phone';
                    }     
                    for(integer k=0; k<allSys.size();k++){
                        if(allSys[k].CompositeExtID__c == curSys[j].CompositeExtID__c && allSys[k].id != curSys[j].id){
                            deletedSys.add(allSys[k]);    
                            //system.debug(deletedSys);                        
                        }                                         
                    }
                    updatedSys1.add(curSys[j]);
                }     
            }
        }
        if(deletedSys.size()>0){
            system.debug(deletedSys);
            delete deletedSys;
        }
            
            
        if(updatedSys1.size()>0)
            system.debug(updatedSys1);
            update updatedSys1; 
        }     
        */
}