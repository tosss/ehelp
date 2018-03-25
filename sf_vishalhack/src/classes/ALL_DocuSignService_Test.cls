@isTest
public class ALL_DocuSignService_Test 
{
    static testMethod void signerOptionsTest()
    {
        Account NewAccount = DS_TestObjects.NewAccount_Inserted();
        
        NewAccount.Has_Corporate_Authorized_Signer__c = true;
        NewAccount.Signer_Required__c = true;
        Update NewAccount;
        
        ALL_DocuSign_Service.signerInputParameterPack newPack = new ALL_DocuSign_Service.signerInputParameterPack();
        newPack.accountId = string.valueOf(NewAccount.Id);
        newPack.groupType = 'Dealer';
        newPack.Deal_type = 'Add-on';
        newPack.Total_One_Times = '3000';
        newPack.Total_Monthlies = '200';
        newPack.DCS = 'False';
        newPack.x3PA = 'False';
        newPack.Network_Telephony = 'False';
        newPack.Client_Data_Exchange_Products = 'False';
        
        Id rt = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        
        // insert two new contacts for using as signers
        Contact Signer1 = DS_TestObjects.NewContact();
        Signer1.AccountId = NewAccount.Id;
        Signer1.RecordTypeId = rt;
        Signer1.Email = 'testsigner1@gmail.com';
        insert Signer1;
        
        Contact Signer2 =  new Contact();
        Signer2.lastName='TESTLastName1';
        Signer2.FirstName='TESTFirstName1';
        Signer2.Title__c='Manager1';
        Signer2.Department__c='Service1';
        Signer2.AccountId  = NewAccount.Id;
        Signer2.RecordTypeId = rt;
        Signer2.Email = 'testsigner2@gmail.com';
        insert Signer2;
        
         // insert contact relations along with contacts
        Contact_Relationship__c crs1 = new Contact_Relationship__c();
        crs1.First_Name_LGY__c = Signer1.FirstName;
        crs1.Last_Name_LGY__c = Signer1.LastName;
        crs1.Email_LGY__c = Signer1.Email;
        crs1.Account__c = NewAccount.Id;
        crs1.Role__c = 'Business Manager;Account Manager';
        crs1.Contact__c = Signer1.Id;
        crs1.Authorized_Contract_Signer__c = true;
        crs1.Additional_Client_Designated_Signer__c = true;
        
        Contact_Relationship__c crs2 = new Contact_Relationship__c();
        crs2.First_Name_LGY__c = Signer2.FirstName;
        crs2.Last_Name_LGY__c = Signer2.LastName;
        crs2.Email_LGY__c = Signer2.Email;
        crs2.Account__c = NewAccount.Id;
        crs2.Role__c = 'Business Office Director';
        crs2.Contact__c = Signer2.Id;
        
        insert new list<Contact_Relationship__c>{ crs1, crs2 };
        
        
        // insert custom settings for contact roles
        DocuSign_Contact_Roles__c DocusignRoles = new DocuSign_Contact_Roles__c();
        DocusignRoles.RoleSet1__c = True;
        DocusignRoles.RoleSet2__c = True;
        DocusignRoles.Name = 'Business Office Director';
        insert DocusignRoles; 
        
        DocuSign_Contact_Roles__c DocusignRoles2 = new DocuSign_Contact_Roles__c();
        DocusignRoles2.RoleSet1__c = True;
        DocusignRoles2.RoleSet2__c = True;
        DocusignRoles2.Name = 'Business Manager';
        insert DocusignRoles2;
        
        ALL_DocuSign_Service.getSignerOptions(newPack);
        
               
        newPack.groupType = 'Dealer';
        NewAccount.Signer_1_2_Signer__c = 'Client Authorized Signer';
        ALL_DocuSign_Service.getSignerOptions(newPack);
        
        //NewAccount.Signer_1_2_Signer__c = 'Client Authorized Signer';
        //NewAccount.Has_Corporate_Authorized_Signer__c = true;
        update NewAccount;
        ALL_DocuSign_Service.getSignerOptions(newPack);
        
        //NewAccount.Signer_Required__c = true;
        NewAccount.Signer_1_2_Signer__c = 'Client Authorized Signer';
        NewAccount.Signer_2_2_Signer__c = 'Contact Specific Signer';
        update NewAccount;
        
        ALL_DocuSign_Service.getSignerOptions(newPack);
        
        NewAccount.Signer_1_2_Signer__c = 'General Manager';
       
        update NewAccount;
        
        ALL_DocuSign_Service.getSignerOptions(newPack);
        
        Opportunity opp = DS_TestObjects.NewOpportunity();
        opp.AccountId = NewAccount.ID;
        Insert opp;
        
        newPack.opportunityId = opp.ID;
        
        ALL_DocuSign_Service.getSignerOptions(newPack);
    }
}