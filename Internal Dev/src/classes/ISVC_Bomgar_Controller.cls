public class ISVC_Bomgar_Controller {
    
    @AuraEnabled    
    public static String sendRequest(String caseId){
        BomgarInstance__c BI = BomgarInstance__c.getOrgDefaults();
        String BomgarUrl = 'https://'+BI.Bomgar_Host__c+'/api/command?username=api&password=bomgarapi&action=generate_session_key&type=support'+''+
            '&queue_id=rep_username:moolkys&session.custom.external_key=sf:'+caseId+':'+UserInfo.getSessionId()+':'+URL.getSalesforceBaseUrl().toExternalForm()+'&url_hostname='+BI.Bomgar_Portal__c;
        system.Debug('****BomgarUrl***'+BomgarUrl);
        HttpRequest hp = new HttpRequest();
        hp.setMethod('GET');
        hp.setEndPoint(BomgarUrl);
        hp.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        http http = new http();
        HttpResponse res = http.send(hp);
        system.debug('res body'+res.getbody());
        string responseXML = res.getbody();
        
        DOM.Document doc = new DOM.Document();
        String toParse = responseXML;
        doc.load(toParse);
        DOM.XMLNode root = doc.getRootElement();
        system.debug('*** root ***'+root);
        String nms = root.getNameSpace();
        System.Debug('namespace: ' +  root.getChildElement('queue',nms).getAttribute('available', null));
        string availablity =  root.getChildElement('queue',nms).getAttribute('available', null);
        if(availablity != '0'){
            DOM.XMLNode body = root.getChildElement('key_url', nms);
            System.Debug('body: ' + body.getText());
            string keyUrl = body.getText();
            return keyUrl;
        }else{
            return null;  
        }
    }
}