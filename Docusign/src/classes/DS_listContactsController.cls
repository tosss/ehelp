public class DS_listContactsController 
{
      public Contact contact = new Contact();
      public Account account;
      public Campaign_Account_Members__c Cam;
      public Id user;
      public String countries;
      public String countries2;
      public String[] countries1 = new String[]{};
      public List<SelectOption> options1 = new List<SelectOption>();
      public List<SelectOption> options = new List<SelectOption>(); 
      
      public String accountId = System.currentPageReference().getParameters().get('accountId');
      public String contactId = System.currentPageReference().getParameters().get('conId');
      public String campaignId = System.currentPageReference().getParameters().get('campaignId');
      public Campaign_Account_Members__c campAcctMem;
      public Campaign_Account_Members__c campAcctMeml;
      public Id usrId = UserInfo.getUserId();
      public String profileName = [select Profile.Name from User where Id=:usrId].Profile.Name;
      public String error='';
      public String lastName=null;

      public String getLastName(){
            return lastName;
      }
      public void setLastName(String lName){
            lastName=lName;
      }
      
      public String getError(){
            return error;
      }
      public Boolean getPageView(){
            List<Campaign_Mgmt_VF_Page_Assign__c> assignment = [Select Campaign_VF_Layout__c From Campaign_Mgmt_VF_Page_Assign__c where Profile_Name__c=:profileName];
            if(assignment.size()==0){
                  return true;
            }
            if(assignment.size()>0){
                  if(assignment[0].Campaign_VF_Layout__c.toLowerCase()=='inside sales'){
                        return false;
                  }     
            }
            return true;
      }
      
      public Id getUser(){
            System.debug('User ID: '+UserInfo.getUserId());
            return UserInfo.getUserId();  
      }
      public String getAccountId(){
            return accountId;
      }
      public String getCampaignId(){
            return campaignId;      
      }
      public List<SelectOption>getItems(){ 
            options=new List<SelectOption>(); 
            Campaign_Member_Status__c[] listOfOptions = [select Name, Default_Status__c from Campaign_Member_Status__c where Campaign__c=:campaignId];
            options.add(new SelectOption('','--None--'));
            Integer sz = listOfOptions.size()-1;
            
            for(Integer i=sz; i>=0; i--){
                  options.add(new SelectOption(listOfOptions[i].Name,listOfOptions[i].Name)); 
            }
            return options; 
      } 
      
      public List<SelectOption> getItems1() {
            List<SelectOption> options1 = new List<SelectOption>();

            options1.add(new SelectOption('', '--None--'));
            options1.add(new SelectOption('Inbound Email', 'Inbound Email'));
            options1.add(new SelectOption('Inbound Phone Call', 'Inbound Phone Call'));
            options1.add(new SelectOption('Marketing Website', 'Marketing Website'));
            options1.add(new SelectOption('Rep Initiated', 'Rep Initiated'));
            
            return options1;              
      } 
      
      public String[] getCountries1(){
            return countries1;      
      }
      
      public void setCountries1(String[] countries1){
            this.countries1 = countries1; 
      }
      
      
      public String getCountries(){
            campAcctMem = [select Id, Campaign_Member_Status__c, Leadsource__c from Campaign_Account_Members__c where Account__c=:accountId and Campaign__c=:campaignId limit 1];
            countries=campAcctMem.Campaign_Member_Status__c;
            return countries; 
      } 
      public void setCountries(String countries){ 
            this.countries=countries; 
            campAcctMem.Campaign_Member_Status__c=countries;
      } 
      
      public String getCountries2(){
            campAcctMeml = [select Id, Leadsource__c from Campaign_Account_Members__c where Account__c=:accountId and Campaign__c=:campaignId limit 1];
            countries2=campAcctMeml.Leadsource__c;
            return countries2; 
      }
      
       
      public void setCountries2(String countries2){ 
            this.countries2=countries2; 
            campAcctMeml.Leadsource__c=countries2;
      } 
      

      public List<Contact> getContacts()
      {
            List <Contact> contacts = new List<Contact>();
            for (Contact con : [SELECT AccountId, Role__c, Title__c, Department__c, Name, FirstName, LastName, Phone, Email FROM Contact where AccountID =: accountId])
            {
                  String conId = con.Id;
                  con.Small_ID__c = conId.substring(0, 15);
                  contacts.add(con);
            }
            return contacts;
      }

      public Contact getNewContact()
      {
            contact = new Contact();
            //contact.clear();
            return contact;
      }
      
      public void setNewCam(){
            Cam = [SELECT Id, Leadsource__c FROM Campaign_Account_Members__c where Account__c=:accountId and Campaign__c=:campaignId limit 1];       
      }
      
      public Campaign_Account_Members__c getNewCam(){
            Cam = [SELECT Id, Leadsource__c FROM Campaign_Account_Members__c where Account__c=:accountId and Campaign__c=:campaignId limit 1];
            return Cam; 
      }
      
      
      public void setNewAccount()
      {
            account = [SELECT Id, Name, BillingCity, BillingState, Phone FROM Account where ID =: accountId limit 1];
      }
      
      public Account getNewAccount()
      {
            account = [SELECT Id, Name, BillingCity, BillingState, Phone FROM Account where ID =: accountId limit 1];
            return account;
      }
      
      //public void setNewContact()
      //{
      //    contact = new Contact();
      //}
      public PageReference save()
      {
            //if(lastName==null || lastName==''){
            //    error='Last name is required.';           
            //    return null;
            //}
            try{
                  contact.accountid = accountId;
                  //contact.LastName=lastName;
                  insert contact;
                  contact=new Contact();
            }catch(Exception e){
                  ApexPages.addMessages(e);
                  return null;
            }
            PageReference currentPage = new PageReference('/apex/listContacts?accountId=' + accountId + '&campaignId=' + campaignId);
            currentPage.setRedirect(true);
            return currentPage;
      }
      public Campaign_Account_Members__c getCampAcctMem(){
            return campAcctMem;     
      }
      
      public Campaign_Account_Members__c getCampAcctMeml(){
            return campAcctMeml;    
      }
      public PageReference addToCampaign()
      {
            CampaignMember cm = new CampaignMember(
                  CampaignId = campaignId, 
                  ContactId =  contactId,
                  Status = 'Responded');
            
            insert cm;
      
            PageReference currentPage = new PageReference('/apex/listContacts?accountId=' + contact.accountid + '&campaignId=' + campaignId);
            currentPage.setRedirect(true);
            return currentPage;
      }
      public PageReference saveCampAcctMem(){
            upsert campAcctMem;
            saveCampAcctMeml();
            //PageReference currentPage = new PageReference('/apex/CampaignMemberStatus?accountId=' + accountId + '&campaignId=' + campaignId);
            //currentPage.setRedirect(true);
            return null;
      }
      
      public PageReference saveCampAcctMeml(){
            upsert campAcctMeml;
            return null;            
      }

      public String getOpportunityURL(){

            RecordType[] opptId;
            String url = '/006/e';

//            Commented out 2/23 Ron Davis            
//            Default_Opportunity_Type__c[] def = [select Default_Opportunity_Record_Type__c from Default_Opportunity_Type__c where Profile_Name__c=:profileName];
//            if(def!=null && def.size()!=0){
//                  String recName = def[0].Default_Opportunity_Record_Type__c;
//                  opptId = [select Id from RecordType where Name=:recName];         
//            }
//            if(opptId!=null && opptId.size()>0){
//                  url+='?RecordType='+opptId[0].Id;
//            }
            
            String nm = [select Name from Campaign where Id=:campaignId].Name;
            String nm2 = [select Name from Account where Id=:accountId].Name;
            if(url=='/006/e'){
                  url+='?opp4='+nm2+'&opp17='+nm+'&opp3='+nm;     
            }
            else{
                  url+='&opp4='+nm2+'&opp17='+nm+'&opp3='+nm;     
            }
            
            return url;
      }
}