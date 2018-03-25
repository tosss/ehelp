public class COM_Utility 
{
    @AuraEnabled
    public static String stockTickerServer()
    {        
        Http http = new Http();
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://finance.google.com/finance/info?client=ig&q=NASDAQ:CDK');
        req.setMethod('GET');
        
        // Send the request, and return a response
        HttpResponse res = http.send(req);
        System.debug(res.getStatusCode());
        if(res.getStatusCode() == 200)
        {
            return res.getBody().replaceAll('\n','').replaceAll('\\[','').replaceAll('\\]','').replace('\\/','');
        }
        return  null;
    }
}