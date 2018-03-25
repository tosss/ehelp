//2017-05-02	lalitha.adduru@cdk.com	added frenchDocusignNeeded - RQ-08667
public class TRV_RenderB4BCoachingAsPDF_Controller {
    
    public Traver_Coaching__c objB4B {get;set;}
    public String DateOfVisit {get;set;}
    Public String NumberOfDays {get;set;}
    Public string deliveryLocation {get;set;}
    Public String processCoachVisitId;
    Public String pscVisitTypeId;
    public Boolean isDeliveryLocation{get;set;}
    public String linkToB4B {get;set;}
    public boolean frenchDocusignNeeded {get;set;} //added by lalitha RQ-08667
   
    public TRV_RenderB4BCoachingAsPDF_Controller(ApexPages.StandardController controller) {
        
         deliveryLocation= '';
                    
         for(RecordType objRecordType : [
                                            SELECT Id, DeveloperName, SobjectType 
                                            FROM RecordType 
                                            WHERE SobjectType = 'Traver_Coaching__c'
                                        ]) {
            
            if(objRecordType.DeveloperName == 'Process_Coach_Visit') {
                
                processCoachVisitId = objRecordType.Id;
            }
            
           
            if(objRecordType.DeveloperName == 'PSC_Visit') {
                
                pscVisitTypeId = objRecordType.Id;
            }
        }
		
        // lalitha included French_DocuSign_Needed__c in the query
        objB4B = [SELECT Id,Delivery_Location__c,RecordTypeId,Delivery_Location__r.BillingStreet,Delivery_Location__r.BillingCity,
                  Delivery_Location__r.BillingPostalCode,Delivery_Location__r.BillingState,
                  Traver_Project__r.Account__r.BillingAddress,Traver_Project__r.French_DocuSign_Needed__c,Traver_Project__c,TRV_Completed_By__c,
                  TRV_FRM_Resource_Name_onResource__c,TRV_Resource_Email__c,Visit_Start_Date__c,Number_of_Days_PSG__c,
                  Number_of_Days_Traver__c
                    FROM Traver_Coaching__c WHERE id=: controller.getRecord().Id];
        
        //lalitha - RQ-08667
        frenchDocusignNeeded = objB4B.Traver_Project__r.French_DocuSign_Needed__c == false ? false : true;
        
        DateOfVisit = String.ValueOf(Date.ValueOf(objB4B.Visit_Start_Date__c));
        if(objB4B.RecordTypeId == pscVisitTypeId)
            NumberOfDays = String.ValueOf(Integer.ValueOf(objB4B.Number_of_Days_PSG__c));
        else if(objB4B.RecordTypeId == processCoachVisitId) 
            NumberOfDays = String.ValueOf(Integer.ValueOf(objB4B.Number_of_Days_Traver__c));
         linkToB4B = System.URL.getSalesforceBaseURL().toExternalForm()+'/'+ objB4B.Id;   
          
       if(objB4B.Delivery_Location__c!= NULL) {
            isDeliveryLocation =true;
         
            if(!String.ISBLANK(objB4B.Delivery_Location__r.BillingStreet))
               deliveryLocation = objB4B.Delivery_Location__r.BillingStreet+', ';
            if(!String.ISBLANK(objB4B.Delivery_Location__r.BillingCity))
               deliveryLocation += objB4B.Delivery_Location__r.BillingCity+', ';
            if(!String.ISBLANK(objB4B.Delivery_Location__r.BillingState))
               deliveryLocation += objB4B.Delivery_Location__r.BillingState+' ';
            if(!String.ISBLANK(objB4B.Delivery_Location__r.BillingPostalCode))
               deliveryLocation += objB4B.Delivery_Location__r.BillingPostalCode;
        
       }
       else 
            isDeliveryLocation = false;
         //  deliveryLocation =  String.ValueOf(objB4B.Traver_Project__r.Account__r.BillingAddress);
          System.debug('--deliveryLocation--'+deliveryLocation);
    }


}