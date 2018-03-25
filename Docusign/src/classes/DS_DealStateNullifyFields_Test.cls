@IsTest
public class DS_DealStateNullifyFields_Test 
{
    public static testmethod void validateHandler()
    {
        try  
        { 
            Opportunity oppObj = DS_TestObjects.NewOpportunity_Inserted();
            
            Deal_State__c dsObj = new Deal_State__c();
            dsObj.Quantity_of_Sites__c = 2;
            dsObj.Opportunity__c = oppObj.Id;
            dsObj.Client_1_Sign_In_Person__c = true;
            dsObj.CA_Approver__c = 'Samp';
            dsObj.Client_1_Delivered_Date__c = DateTime.now();
            insert dsObj; 
            
            DS_DealStateNullifyFields_Handler.fieldsMap = new Map<String,DealStateFieldsToNull__c>();
            
            DealStateFieldsToNull__c dsfv = new DealStateFieldsToNull__c(Name='CA Approver',Field_Type__c='Text',Field_API_Name__c='CA_Approver__c');
            insert dsfv;
            DS_DealStateNullifyFields_Handler.fieldsMap.put(dsfv.Name,dsfv); 
            
            dsfv = new DealStateFieldsToNull__c(Name='Client 1 Delivered Date',Field_Type__c='Date/Time',Field_API_Name__c='Client_1_Delivered_Date__c');
            insert dsfv;
            DS_DealStateNullifyFields_Handler.fieldsMap.put(dsfv.Name,dsfv); 
            
            dsfv = new DealStateFieldsToNull__c(Name='Client 1 Sign In Person',Field_Type__c='Checkbox',Field_API_Name__c='Client_1_Sign_In_Person__c');
            insert dsfv;
            DS_DealStateNullifyFields_Handler.fieldsMap.put(dsfv.Name,dsfv); 
             
            dsObj.Docusign_Envelope_Status__c = 'Voided';
            update dsObj;
            
            dsObj = [
                SELECT Id, Client_1_Delivered_Date__c, Client_1_Sign_In_Person__c, CA_Approver__c , Deal_Status__c
                FROM Deal_State__c 
                WHERE Id=:dsObj.id
            ];
            
            
            System.assertEquals(null, dsObj.CA_Approver__c, 'Text Field type is not updated');
            System.assertEquals( null, dsObj.Client_1_Delivered_Date__c,'Date/Time Field type is not updated');
            System.assertEquals( false, dsObj.Client_1_Sign_In_Person__c,'Checkbox Field type is not updated');
            System.assertEquals('Envelope Voided', dsObj.Deal_Status__c, 'Deal State Status is not updated');
            
            DS_DealStateNullifyFields_Handler.nullifyFields(null,null);
        }
        catch(Exception e) 
        {
            system.debug('Exception :' + e.getMessage()+' at '+e.getLineNumber()); 
        }
    }
}