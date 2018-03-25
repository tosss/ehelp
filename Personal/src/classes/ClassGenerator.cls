public class ClassGenerator {
    public static void generate()
    {
        StaticResource sr = [select id,body from StaticResource Where Name = 'ClassDynamic'];
String contents = sr.body.toString();
System.debug(contents);
        // Create the ApexClass via Tooling REST API
String sampleClass = 'ClassNew';
JSONGenerator body = JSON.createGenerator(false);
body.writeStartObject();
body.writeStringField('Name', sampleClass);
body.writeStringField('Body', contents);
body.writeEndObject();
HttpRequest createReq = new HttpRequest();
createReq.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v29.0/tooling/sobjects/ApexClass');
createReq.setBody( body.getAsString() );
createReq.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
createReq.setHeader('Content-Type', 'application/json');
createReq.setMethod('POST');
Http h = new Http();    
HttpResponse createRes = h.send(createReq);  

    }
}