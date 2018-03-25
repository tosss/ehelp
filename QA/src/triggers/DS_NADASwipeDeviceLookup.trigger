//2015-12-03- anirudh.singh@cdk.com- Modified the API Version from 26.0 to 34.0. Corrected the indentation.
trigger DS_NADASwipeDeviceLookup on NADA_Swipe__c (before insert, before update)
{
    List<NADA_Swipe__c> SwipesToProcess = new List<NADA_Swipe__c>();
    List<String> ApparatusIds = new List<String>();
    
    List<NADA_Swipe__c> CurrentSwipes = new List<NADA_Swipe__c>();
    List<String> AllApparatusIds = new List<String>();
    List<String> SwipeCardNumbers = new List<String>();
    
    for(NADA_Swipe__c s : Trigger.New)
    {
        // format phone and fax
        // match from the beginning (a group of 3 digits) (a group of 3 digits) (a group of four digits) until the end
        // ^  beginning
        // $  end
        // () groups
        // \d decimals
        // {} repeat
        Pattern FormatPhoneFax = Pattern.compile('^(\\d{3})(\\d{3})(\\d{4})$');
        
        if(s.Phone__c != null)
        {
            Matcher pm = FormatPhoneFax.matcher(s.Phone__c);
            if(pm.matches())
            {
                s.Phone__c = '('+pm.group(1)+') '+pm.group(2) + '-' + pm.group(3);
            }
        }
        
        if(s.Fax__c != null)
        {
            Matcher fm = FormatPhoneFax.matcher(s.Fax__c);
            if(fm.matches())
            {
                s.Fax__c = '(' + fm.group(1)+') ' + fm.group(2) + '-' + fm.group(3);
            }
        }
        // finish formatting
        
        // if null, continue on to the next project in loop
        if(s.Apparatus_Id__c == null) 
        {
            s.NADA_Scan_Device__c = null; 
            continue; 
        }
        
        Object OldApparatusId = (Trigger.OldMap != null ? 
                                 (Trigger.OldMap.get(s.Id) != null ? Trigger.OldMap.get(s.Id).get('Apparatus_Id__c') : null) : 
                                 null
                                );
        
        if(s.Apparatus_Id__c != OldApparatusId)
        {
            SwipesToProcess.add(s);
            ApparatusIds.add(s.Apparatus_Id__c);
        }
        
        if(Trigger.isInsert)
        {
            CurrentSwipes.add(s);
            AllApparatusIds.add(s.Apparatus_Id__c);
            SwipeCardNumbers.add(s.Swiped_Card_Number__c);
        }
    }
    
    List<NADA_Device__c> Devices = [Select Id, Name From NADA_Device__c Where Name IN :ApparatusIds];
    Map<String, NADA_Device__c> DevicesByApparatusIds = new Map<String, NADA_Device__c>();
    
    if(!Devices.IsEmpty()) 
    {
        for(NADA_Device__c n : Devices)
        {
            DevicesByApparatusIds.put(n.Name, n);
        }
    }
    
    if(!SwipesToProcess.IsEmpty())
    {
        for(NADA_Swipe__c s : SwipesToProcess)
        {
            NADA_Device__c Device = DevicesByApparatusIds.get(s.Apparatus_Id__c);
            
            if(Device != null)
            {
                s.NADA_Scan_Device__c = Device.Id;
            }
            else
            {
                s.NADA_Scan_Device__c = null;
            }
        }
    }
    
    if(Trigger.isInsert)
    {
        List<NADA_Swipe__c> InsertedDuplicates = new List<NADA_Swipe__c>();
        
        List<NADA_Swipe__c> AllSwipes = [Select Id, Name, Apparatus_Id__c, Swiped_Card_Number__c, Swiped_Date_Time__c 
                                         From NADA_Swipe__c Where Apparatus_Id__c IN :AllApparatusIds And Swiped_Card_Number__c IN :SwipeCardNumbers];
        AllSwipes.addAll(Trigger.New);
        
        // loop through and log AllSwipes
        //for(NADA_Swipe__c ns : AllSwipes){system.debug(ns.Id + ' - ' + ns.Name + ' - ' + ns.Apparatus_Id__c + ' - ' + ns.Swiped_Card_Number__c);}
        
        for(Integer i = 0; i < AllSwipes.size(); i++) // current Swipe
        {
            NADA_Swipe__c Current = AllSwipes[i];
            AllSwipes.remove(i); i--; // remove (and decrement to keep place in the loop)
            
            Set<NADA_Swipe__c> Matches = new Set<NADA_Swipe__c>();
            
            for(Integer j = 0; j < AllSwipes.size(); j++) // all Swipes
            {
                //system.debug((AllSwipes[j].Swiped_Card_Number__c == Current.Swiped_Card_Number__c) + ': ' + AllSwipes[j].Swiped_Card_Number__c + ' == ' + Current.Swiped_Card_Number__c);
                if(AllSwipes[j].Swiped_Card_Number__c == Current.Swiped_Card_Number__c)
                {
                    //system.debug((AllSwipes[j].Apparatus_Id__c == Current.Apparatus_Id__c) + ': ' + AllSwipes[j].Apparatus_Id__c + ' == ' + Current.Apparatus_Id__c);
                    if(AllSwipes[j].Apparatus_Id__c == Current.Apparatus_Id__c)
                    {
                        if(AllSwipes[j].Swiped_Date_Time__c != null && Current.Swiped_Date_Time__c != null)
                        {
                            //system.debug((AllSwipes[j].Swiped_Date_Time__c >= Current.Swiped_Date_Time__c.addHours(-1) && AllSwipes[j].Swiped_Date_Time__c <= Current.Swiped_Date_Time__c.addHours(1)) + ': ' 
                            //	+ AllSwipes[j].Swiped_Date_Time__c + ' >= ' + Current.Swiped_Date_Time__c.addHours(-1) 
                            //	+ ' && ' + AllSwipes[j].Swiped_Date_Time__c + ' <= ' + Current.Swiped_Date_Time__c.addHours(1));
                            
                            // 6:30 AM >= 5:41 AM && 6:30 AM < 7:41 AM --- true
                            // 5:30 AM >= 5:41 AM && 5:30 AM < 7:41 AM --- false
                            if(AllSwipes[j].Swiped_Date_Time__c >= Current.Swiped_Date_Time__c.addHours(-1) 
                               && AllSwipes[j].Swiped_Date_Time__c <= Current.Swiped_Date_Time__c.addHours(1)) 
                            {
                                //system.debug('Match - Current:               ' + Current);
                                //system.debug('Match - All Swipes:            ' + AllSwipes[j]);
                                
                                NADA_Swipe__c Match = AllSwipes[j];
                                AllSwipes.remove(j); j--; // remove and decrement
                                
                                // if the matching record is an inserted record
                                //   add an error and mark it as a duplicate (preventing DML)
                                if(Match.Id == null) 
                                {
                                    //system.debug('Marking duplicate');
                                    
                                    Match.addError('This record matches a duplicate record '
                                                   + '(matching Swiped Card Number, Apparatus ID, and Swiped Date Time - within two hours) '
                                                   + 'in the data being inserted or already in Salesforce.');
                                }
                            }
                        }
                    }
                }
            } // end for all Swipes
        } // end for current
    }
}