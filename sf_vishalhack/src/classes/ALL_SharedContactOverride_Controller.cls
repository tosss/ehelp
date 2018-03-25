/*----------------------------------------------------------------------
 * RQ-06966
 * Sanjay.Ghanathey@cdk.com - created this class  
 * Description: Trigger on Launch Object
 * ---------------------------MODIFICATIONS-----------------------------
 * 2016-05-25 Vijay.manimaran@cdk.com  Updated logic to redirect on Edit.
 * 2016-05-25 Sanjay.Ghanathey@cdk.com Updated logic for View.
  ------------------------------------------------------------------------*/

public class ALL_SharedContactOverride_Controller {
    public ALL_SharedContactOverride_Controller(apexPages.StandardController controller)
    {}
    
    public PageReference RedirectPage()
    {                   
        PageReference pageReference;
        String ContactId;
        try{
        ContactId = apexpages.currentpage().getparameters().get('Id');
        }
        catch(Exception e){
            String tempURL =  String.ValueOf(ApexPages.currentPage().getUrl());
            List<String> ids = tempURL.split('/');
            system.debug('$$ exception in contactid ids'+ids);
        }
        system.debug('$$ exception in contactid ContactId'+ContactId);
        String retURL = apexpages.currentpage().getparameters().get('retURL');   
        String recordType = apexpages.currentpage().getparameters().get('RecordType');  
        if(ContactId == null){
        String tempURL =  String.ValueOf(ApexPages.currentPage().getUrl());
            List<String> ids = tempURL.split('/');
            system.debug('$$ ids'+ids);
        }
        if(ContactId != null){            
            Contact tempContact = [select Id,AccountId from Contact where Id=:ContactId];            
            String accountContactId = String.valueOf(tempContact.AccountId) + String.valueOf(tempContact.Id);             
            Contact_Relationship__c tempCR;
            try{
                tempCR = [select Id from Contact_Relationship__c where Account_Contact_Id__c=:accountContactId];                
                if(retURL!=null){
                    //Edit Page - isEdit Param is to skip duplicate check
                    pageReference = new PageReference('/apex/SharedContactsPage?CRId'+tempCR.Id+'&AccountId='+tempContact.AccountId+'&isEdit=true');  
                    pageReference.getParameters().put('isEdit','true');                       
                }
                else{
                    //View Page
                    pageReference = new PageReference('/apex/SharedContactsPage?CRId'+tempCR.Id+'&AccountId='+tempContact.AccountId+'&readMode=true');
                    pageReference.getParameters().put('readMode','true');                        
                }
                pageReference.getParameters().put('AccountId',tempContact.AccountId);
                pageReference.getParameters().put('CRId',tempCR.Id);  
                if(recordType!=null){
                    pageReference.getParameters().put('recordId',recordType);    
                }
                system.debug('$$ pageReference-'+pageReference);
            }
            catch(Exception e){
                //In this scenario contact exists without CR so just redirecting
                pageReference = new PageReference('/apex/SharedContactsPage');
                system.debug('$$ pageReference exception-'+pageReference);
            }                        
            pageReference.setRedirect(true);
            return pageReference;
        }
        else{
            pageReference = new PageReference('/apex/SharedContactsPage');
            pageReference.setRedirect(true);
            return pageReference;
        }                        
        
    }
}