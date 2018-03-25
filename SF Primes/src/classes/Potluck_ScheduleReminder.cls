global class Potluck_ScheduleReminder Implements Schedulable 
{
    global void execute(SchedulableContext sc)
    {
        List<Potluck_Attendee__C> pa = [Select id, Name__r.Email,Name__r.Name, (select id from potluck_dish_Selections__r) from Potluck_Attendee__C];
        List<Messaging.SingleEmailMessage> AllMails = new List<Messaging.SingleEmailMessage>();
        for(Potluck_Attendee__C paObj : pa)
        {
            List<potluck_dish_Selection__c> pds = paObj.potluck_dish_Selections__r;
            if(pds == null || pds.size() == 0) 
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                mail.setToAddresses(new List<String>{paObj.Name__r.Email});
                mail.setBccAddresses(new List<String>{'vishal.bandari@cdk.com'});
                String EmailBody = 'Hello '+paObj.Name__r.Name+',<br/><br/>';
                Emailbody += '<br/><b>You haven\'t selected any dish yet, please select a dish to get.</b><br/><br/>Please select your dish at our <a href="https://adpdealerservices--sfprimes.lightning.force.com/c/PotLuck.app" style="text-decoration:none;">Potluck Portal</a><br/>';
                Emailbody += '<br/>Thank You<br/><br/><b>Potluck Team</b>';
                mail.setSubject('The Big Potluck Gentle Reminder!!!!');
                mail.setHTMLBody(Emailbody);
                AllMails.add(mail);
            }
        }
        List<Messaging.SendEmailResult> mailResult =  Messaging.sendEmail(AllMails);
    }

}