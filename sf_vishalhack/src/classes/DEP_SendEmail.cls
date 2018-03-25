public class DEP_SendEmail 
{
    public static void sendEmailWithAttachment(String toAddress,String ccAddress, Change_Set_Component__c component) {
        
        set<string> setEmailAddresses = new set<string>();
        string subject = 'Salesforce Changeset '+component.Change_Set__r.Name+' - Backup of '+component.Component_Name__c;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(true);
        setEmailAddresses.clear();
        if(setEmailAddresses.size() > 0){
            mail.setToAddresses(new List<String>{'bandari.vishal@gmail.com'});
        }
        //Set CC Addresses
        setEmailAddresses.clear();
        if(ccAddress != null && ccAddress != ''){
            setEmailAddresses.addAll(ccAddress.split('[,;]'));
        }
        if(setEmailAddresses.size() > 0){
            mail.setCcAddresses(convertToList(setEmailAddresses));
        }
        
        mail.setSubject(subject);
        mail.setHtmlBody('Hello <br/> Attached are backup files of '+component.Component_Name__c+' component deleted in ChangeSet - '+component.Change_Set__r.Name+'. <br/><br/>Thanks');
        Messaging.EmailFileAttachment [] efaList = new List<Messaging.EmailFileAttachment> () ;
        for (Attachment attach1 : [select Name, Body, ContentType from Attachment where ParentId = :component.Id]) {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(attach1.Name);
            efa.setBody(attach1.Body);
            efa.setContentType('text/plain');
            efaList.add(efa) ;
        }
        if(efaList != null) {
            mail.setFileAttachments(efaList) ;
        }
        mail.setCharset('UTF-8'); //Use Signatue
        mail.setUseSignature(true);
        // Send the email
        System.debug(mail);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        return;
    }
    
    public static list<string> convertToList(set<string> setToConvert) {
        list<string> lstString = new list<string>();
        lstString.addAll(setToConvert);
        return lstString;
    }
}