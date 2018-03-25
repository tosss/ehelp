trigger DishSelectionEmailing on Potluck_Dish_Selection__c (before insert,after insert, after update, before delete, after delete) 
{
    try
    {
        if(Trigger.IsBefore && !Trigger.isDelete)
        {
            Id currentId = (Trigger.IsInsert || Trigger.IsUpdate ? Trigger.New[0].Potluck_Attendee__c : Trigger.old[0].Potluck_Attendee__c);
            List<Id> dishIds = (Trigger.IsInsert ? new List<Id>{Trigger.New[0].Potluck_Dish__c} : Trigger.IsUpdate ? new List<Id>{Trigger.New[0].Potluck_Dish__c, Trigger.Old[0].Potluck_Dish__c} :  new List<Id>{ Trigger.Old[0].Potluck_Dish__c});
            List<Potluck_Dish_Selection__c> selectedDishes = [Select id,Potluck_Dish__r.Dish_Name__c, Potluck_Dish__r.Name,Potluck_Attendee__r.Name__r.Email,Potluck_Attendee__r.Name__r.Name, Quantity__c, Brought_By__c from Potluck_Dish_Selection__c WHERE Potluck_Attendee__c = :currentId];
            List<Potluck_Dish__c> selected = [select id, Remaining_Quantity__c, Quantity__c,(select Quantity__c from Potluck_Dish_Selections__r) from Potluck_Dish__c where Id IN: dishIds];
            Decimal ReminingQuantity = selected[0].Remaining_Quantity__c;
            if(Trigger.IsInsert)
            {
                ReminingQuantity = selected[0].Remaining_Quantity__c - Trigger.New[0].Quantity__c;
            }
            else if(Trigger.IsUpdate)
            {
                ReminingQuantity = selected[0].Remaining_Quantity__c - (Trigger.New[0].Quantity__c - Trigger.Old[0].Quantity__c); 
            }
            if(ReminingQuantity < 0)
            {
                Trigger.New[0].addError('You are choosing more than required Quantity');
            }
        }
        else if(!(Trigger.IsDelete && Trigger.IsAfter))
        {
            Id currentId = (Trigger.IsInsert || Trigger.IsUpdate ? Trigger.New[0].Potluck_Attendee__c : Trigger.old[0].Potluck_Attendee__c);
            List<Id> dishIds = (Trigger.IsInsert ? new List<Id>{Trigger.New[0].Potluck_Dish__c} : Trigger.IsUpdate ? new List<Id>{Trigger.New[0].Potluck_Dish__c, Trigger.Old[0].Potluck_Dish__c} :  new List<Id>{ Trigger.Old[0].Potluck_Dish__c});
            List<Potluck_Dish_Selection__c> selectedDishes = [Select id,Potluck_Dish__r.Dish_Name__c,Dish_Detailed_Name__c, Potluck_Dish__r.Name,Potluck_Attendee__r.Name__r.Email,Potluck_Attendee__r.Name__r.Name, Quantity__c, Brought_By__c from Potluck_Dish_Selection__c WHERE Potluck_Attendee__c = :currentId];
            List<Potluck_Dish__c> selected = [select id, Remaining_Quantity__c, Quantity__c,(select Quantity__c from Potluck_Dish_Selections__r) from Potluck_Dish__c where Id IN: dishIds];
            List<Messaging.SingleEmailMessage> AllMails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            mail.setToAddresses(new List<String>{selectedDishes[0].Potluck_Attendee__r.Name__r.Email});
            mail.setBccAddresses(new List<String>{'vishal.bandari@cdk.com'});
            String EmailBody = 'Hello '+selectedDishes[0].Potluck_Attendee__r.Name__r.Name+',<br/><br/>';
            if(selectedDishes != null || selectedDishes.size() == 0)
            {                
                if(!(selectedDishes.size() == 1 && Trigger.IsDelete))
                {
                    EmailBody += 'You have selected below dishes to serve for our Potluck:<br/><br/><br/><table><tr><th width="300px">Dish</th><th width="300px">Description</th><th width="300px">Quantity</th><th width="300px">Brought By</th></tr>';
                    for(Potluck_Dish_Selection__c pdsc : selectedDishes)
                    {
                        EmailBody += '<tr><td width="100px" align="center">'+pdsc.Potluck_Dish__r.Dish_Name__c+'</td><td width="100px" align="center">'+(pdsc.Dish_Detailed_Name__c!=null?pdsc.Dish_Detailed_Name__c:'')+'</td><td width="100px" align="center">'+pdsc.Quantity__c+'</td><td width="100px" align="center">'+pdsc.Brought_By__c+'</td></tr>';
                    }
                    EmailBody += '</table><br/><br/>';
                }
                else
                {
                    Emailbody += '<br/><b>You haven\'t selected any dish yet, please select a dish to get.</b><br/><br/>Please select your dish at our <a href="https://adpdealerservices--sfprimes.lightning.force.com/c/PotLuck.app" style="text-decoration:none;">Potluck Portal</a><br/>';
                }
            }
            else
            {
                Emailbody += '<br/><b>You haven\'t selected any dish yet, please select a dish to get.</b><br/><br/>Please select your dish at our <a href="https://adpdealerservices--sfprimes.lightning.force.com/c/PotLuck.app" style="text-decoration:none;">Potluck Portal</a><br/>';
            }
            Emailbody += '<br/>Thank You<br/><br/><b>Potluck Team</b>';
            mail.setSubject('The Big Potluck!!!!');
            mail.setHTMLBody(Emailbody);
            if(!Trigger.IsDelete)
            {
                AllMails.add(mail);
                List<Messaging.SendEmailResult> mailResult =  Messaging.sendEmail(AllMails);
                for(Potluck_Dish__c pd : selected)
                {
                    List<Potluck_Dish_Selection__c> pds = pd.Potluck_Dish_Selections__r;
                    if(pds != null && pds.size() >0)
                    {
                        Decimal Remaining = 0;
                        for(Potluck_Dish_Selection__c pdObj : pds)
                        {
                            Remaining += pdObj.Quantity__c;
                        }
                        pd.Remaining_Quantity__c = pd.Quantity__c - Remaining;
                    }
                }
                update selected;
            }
        }
        else
        {
            Id currentId = Trigger.old[0].Potluck_Attendee__c;
            List<Id> dishIds = new List<Id>{ Trigger.Old[0].Potluck_Dish__c};
                List<Potluck_Dish_Selection__c> selectedDishes = [
                    Select id,Potluck_Dish__r.Dish_Name__c, Potluck_Dish__r.Name,
                    Potluck_Attendee__r.Name__r.Email,Potluck_Attendee__r.Name__r.Name, Quantity__c, Brought_By__c 
                    from Potluck_Dish_Selection__c 
                    WHERE Potluck_Attendee__c = :currentId
                ];
            List<Potluck_Dish__c> selected = [
                select id, Remaining_Quantity__c, Quantity__c,
                (
                    select Quantity__c 
                    from 
                    Potluck_Dish_Selections__r
                ) 
                from Potluck_Dish__c where Id IN: dishIds
            ];
            List<Messaging.SingleEmailMessage> AllMails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            String EmailBody;
            if(selectedDishes != null && selectedDishes.size() != 0)
            {
                mail.setToAddresses(new List<String>{selectedDishes[0].Potluck_Attendee__r.Name__r.Email});
                mail.setBccAddresses(new List<String>{'vishal.bandari@cdk.com'});
                EmailBody = 'Hello '+selectedDishes[0].Potluck_Attendee__r.Name__r.Name+',<br/><br/>';
                EmailBody += 'You have selected below dishes to serve for our Potluck:<br/><br/><br/><table><tr><th width="300px">Dish</th><th width="300px">Quantity</th><th width="300px">Brought By</th></tr>';
                for(Potluck_Dish_Selection__c pdsc : selectedDishes)
                {
                    EmailBody += '<tr><td width="100px" align="center">'+pdsc.Potluck_Dish__r.Dish_Name__c+'</td><td width="100px" align="center">'+pdsc.Quantity__c+'</td><td width="100px" align="center">'+pdsc.Brought_By__c+'</td></tr>';
                }
                EmailBody += '</table><br/><br/>';
            }
            else
            {
                currentId = [Select Name__c from PotLuck_Attendee__c where Id=: currentId].Name__c;
                User u = [select Name, email from User where Id =: currentId];
                mail.setToAddresses(new List<String>{u.Email});
                mail.setBccAddresses(new List<String>{'vishal.bandari@cdk.com'});
                EmailBody = 'Hello '+u.Name+',<br/><br/>';
                Emailbody += '<br/><b>You haven\'t selected any dish yet, please select a dish to get.</b><br/><br/>Please select your dish at our <a href="https://adpdealerservices--sfprimes.lightning.force.com/c/PotLuck.app" style="text-decoration:none;">Potluck Portal</a><br/>';
            }
            Emailbody += '<br/>Thank You<br/><br/><b>Potluck Team</b>';
            mail.setSubject('The Big Potluck!!!!');
            mail.setHTMLBody(Emailbody);
            AllMails.add(mail);
            List<Messaging.SendEmailResult> mailResult =  Messaging.sendEmail(AllMails);
            for(Potluck_Dish__c pd : selected)
            {
                List<Potluck_Dish_Selection__c> pds = pd.Potluck_Dish_Selections__r;
                if(pds != null && pds.size() >0)
                {
                    Decimal Remaining = 0;
                    for(Potluck_Dish_Selection__c pdObj : pds)
                    {
                        Remaining += pdObj.Quantity__c;
                    }
                    pd.Remaining_Quantity__c = pd.Quantity__c - Remaining;
                }
            }
            update selected;
        }
        
    }
    catch(Exception e)
    {
        System.debug('DishSelectionEmailing Trigger Exception: '+e.getMessage()+' at '+e.getLineNumber());
    }
    
}