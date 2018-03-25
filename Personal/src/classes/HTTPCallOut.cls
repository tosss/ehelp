public class HTTPCallOut {
    @RemoteAction
   public static string basicAuthCallout(String endurl)
   {
       HttpRequest req = new HttpRequest();
       req.setEndpoint(endurl);
       req.setMethod('GET');
       req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
       req.setHeader('Content-Type', 'text/xml');
       Http http = new Http();
       HTTPResponse res = http.send(req);
       return res.getBody();
   }
}