public class CB_Webservices_Handler 
{
    public static void beforeTimezoneWebserviceCall(list<Account> accountsList)
    {
        set<ID> accIDset = new set<ID>();
        
        for(Account acc: accountsList)
        {
            if(acc.Billinglatitude != null && acc.Billinglongitude != null && acc.Timezone__c == null)
            {
                accIDset.add(acc.ID);
            }
        }
        
        if(accIDset != null && !accIDset.isEmpty())
        {
            CB_Webservices_Handler.timeZoneWebserviceCall(accIDset); 
        }
    }
    
    @future(callout = true)
    public static void timeZoneWebserviceCall(set<ID> accountIDs)
    {
        list<Account> accountList = new list<Account>();
        list<Account> updateList = new list<Account>();
        if(accountIDs != null && !accountIDs.isEmpty())
        {
            accountList = [
                Select Id, Name, Billinglatitude, Billinglongitude, Timezone__c 
                From Account 
                Where ID 
                IN :accountIDs
            ];
        }
        if(accountList != null && !accountList.isEmpty())
        {
            for(Account acc: accountList)
            {
                if(acc.BillingLatitude != null && acc.BillingLongitude != null)
                {
                    double latitude = acc.BillingLatitude; 
                    double longitude = acc.BillingLongitude;
                    String[] Coordinates; 
                    
                    // http://www.geonames.org/login;  username:cdksalesforce; password:cdksalesforce
                    String url = 'http://api.geonames.org/timezoneJSON?lat=' + latitude + '&lng='+ longitude + '&username=cdksalesforce';
                    
                    
                    Http h = new Http(); 
                    HttpRequest req = new HttpRequest();
                    
                    req.setMethod('GET');
                    req.setEndpoint(url); 
                    
                    String responseBody;
                    
                    HttpResponse res = h.send(req); 
                    
                    responseBody = res.getBody();
                    system.debug(url);
                    system.debug(responseBody);
                    list<string> jsonStringList = responseBody.split(',');
                    for(string s: jsonStringList)
                    {
                        if(s.contains('timezoneId'))
                        {
                            list<string>strings = s.split(':');
                            acc.Timezone__c = strings[1].remove('"');
                            updateList.add(acc);                            
                        }
                    }
                }
            }
        }
        
        update updateList;
    }
    
}